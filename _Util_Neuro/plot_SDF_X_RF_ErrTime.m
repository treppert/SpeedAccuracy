% function [ varargout ] = plot_SDF_X_Dir_RF_ErrTime( behavData , unitData , spikesSAT )
%plot_SDF_X_Dir_RF_ErrTime() Summary of this function goes here
%   Detailed explanation goes here

PLOT = true;
FIG_VISIBLE = 'off';
PRINTDIR = 'C:\Users\Tom\Documents\Figs - SAT\';

PVAL_MW = .05;
TAIL_MW = 'left';

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});
idxFunction = (unitData.Grade_Rew == 2);
idxKeep = (idxArea & idxMonkey & idxFunction);

NUM_UNIT = sum(idxKeep);
unitTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

OFFSET_PRE = 400;
tPlot = 3500 + (-OFFSET_PRE : 800); %plot time vector
NUM_SAMP = length(tPlot);

RT_MAX = 900; %hard ceiling on primary RT

%prepare to bin trials by timing error magnitude
TERR_LIM = linspace(0, 1, 4); %quantile limits for binning
NUM_BIN = length(TERR_LIM) - 1;

for uu = 1:NUM_UNIT
  fprintf('%s \n', unitTest.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitTest.Task_Session(uu));
  
  RFuu = unitTest.RF{uu}; %response field
  if (length(RFuu) == 8) %if RF is the entire visual field
    switch unitTest.Monkey{uu}
      case 'D' %set to contralateral hemifield
        RFuu = [4 5 6];
      case 'E'
        RFuu = [8 1 2];
    end
  end
  
  RT_P = behavData.Sacc_RT{kk}; %RT of primary saccade
  RT_P(RT_P > RT_MAX) = NaN; %hard limit on primary RT
  tRew = round(nanmedian(RT_P + behavData.Task_TimeReward{kk})); %time of reward - fixed
  
  %compute spike density function and align appropriately
  sdfA = compute_spike_density_fxn(spikesTest{uu});  %sdf from Array
  sdfP = align_signal_on_response(sdfA, RT_P); %sdf from Primary
  sdfR = align_signal_on_response(sdfA, tRew); %sdf from Reward
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitTest.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by screen clear on Fast trials
  idxClear = logical(behavData.Task_ClearDisplayFast{kk});
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  idxErr = (behavData.Task_ErrTime{kk} & ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  %index by saccade octant re. response field (RF)
  Octant_Sacc1 = behavData.Sacc_Octant{kk};
  idxRF  = ismember(Octant_Sacc1, RFuu);
  idxRFn = (~idxRF & (Octant_Sacc1 ~= 0));
    
  %combine indexing
  idxAC = (idxAcc & idxCorr);    idxAE = (idxAcc & idxErr);
  idxFC = (idxFast & idxCorr);   idxFE = (idxFast & idxErr);
    
  %get task deadline
  dlineAcc =  median(behavData.Task_Deadline{kk}(idxAcc));
  %compute error in RT
  errRT = NaN(behavData.Task_NumTrials(kk),1);
  errRT(idxAcc) = RT_P(idxAcc) - dlineAcc;
  
  
  %% Compute mean SDF for response into RF
  sdfErr_A = NaN(NUM_SAMP,NUM_BIN); %sdf re. array
  sdfErr_P = sdfErr_A; %sdf re. primary saccade
  sdfErr_R = sdfErr_A; %sdf re. reward
  
  idxAC = (idxAcc  & idxCorr & idxRF); %Accurate correct
  sdfCorr_A = nanmean(sdfA(idxAC, tPlot));
  sdfCorr_P = nanmean(sdfP(idxAC, tPlot));
  sdfCorr_R = nanmean(sdfR(idxAC, tPlot));
  
  qtl_errRT = quantile(errRT(idxAcc & idxErr & idxRF), TERR_LIM);
  
  for bb = 1:NUM_BIN %loop over RT error bins
    idx_bb = (errRT > qtl_errRT(bb)) & (errRT <= qtl_errRT(bb+1));
    idxAE = (idxAcc  & idxErr & idxRF & idx_bb);  %Accurate timing error

    sdfErr_A(:,bb) = nanmean(sdfA(idxAE, tPlot));
    sdfErr_P(:,bb) = nanmean(sdfP(idxAE, tPlot));
    sdfErr_R(:,bb) = nanmean(sdfR(idxAE, tPlot));
%     [tSig, vecSig] = calc_tErrorSignal_SAT(sdfR_kk(idxAC, tPlot), sdfR_kk(idxAE, tPlot), ...
%       'pvalMW',PVAL_MW, 'tailMW',TAIL_MW);
  end %for: RT error bin (ii)
  
  if (PLOT)
    figure('visible', FIG_VISIBLE)
    Sig_Time = unitTest.RewardSignal_Time(uu,:);
    y_Lim = [0, max([sdfCorr_A' sdfErr_A sdfCorr_P' sdfErr_P sdfCorr_R' sdfErr_R],[],'all')];
    colorPlot = linspace(0.0, 0.8, NUM_BIN);

    subplot(1,3,1); hold on %Accurate re. array
    plot(tPlot-3500, sdfCorr_A, 'r')
    for bb = 1:NUM_BIN
      plot(tPlot-3500, sdfErr_A(:,bb), ':', 'Color',[colorPlot(bb) 0 0], 'LineWidth',1.25)
    end
    xlim(tPlot([1,NUM_SAMP])-3500)
%     legend({'Correct', num2cell(-qtl_errRT)})
    xlabel('Time from array (ms)')
    ylabel('Activity (sp/sec)')

    subplot(1,3,2); hold on %Accurate re. primary
    title([unitTest.Properties.RowNames{uu}, '-', unitTest.aArea{uu}, '   ', ...
      'RF = ', num2str(rad2deg(convert_tgt_octant_to_angle(RF)))], 'FontSize',9)
    plot(tPlot-3500, sdfCorr_P, 'r')
    for bb = 1:NUM_BIN
      plot(tPlot-3500, sdfErr_P(:,bb), ':', 'Color',[colorPlot(bb) 0 0], 'LineWidth',1.25)
    end
    xlim(tPlot([1,NUM_SAMP])-3500)
    set(gca, 'YColor','none')
    xlabel('Time from primary saccade (ms)')

    subplot(1,3,3); hold on %Accurate re. reward
    plot(tPlot-3500, sdfCorr_R, 'r')
    for bb = 1:NUM_BIN
      plot(tPlot-3500, sdfErr_R(:,bb), ':', 'Color',[colorPlot(bb) 0 0], 'LineWidth',1.25)
    end
    plot(Sig_Time(3)*ones(1,2), y_Lim, 'k:', 'LineWidth',1.25)
    plot(Sig_Time(4)*ones(1,2), y_Lim, 'k:', 'LineWidth',1.25)
%     plot((tSig-OFFSET_PRE)*ones(1,2), y_Lim, 'b:', 'LineWidth',1.25)
%     scatter(vecSig-OFFSET_PRE, 3, 20, [.1 .2 1], 'filled')
    xlim(tPlot([1,NUM_SAMP])-3500)
    set(gca, 'YColor','none')
    xlabel('Time from reward (ms)')

    ppretty([10,1.8])

    pause(0.1); print([PRINTDIR,unitTest.Properties.RowNames{uu},'-',unitTest.aArea{uu},'.tif'], '-dtiff')
    pause(0.1); close(); pause(0.1)
  end % if (PLOT)
  
end% for : unit (uu)

clearvars -except behavData unitData spikesSAT
% end%fxn:plot_SDF_X_Dir_RF_ErrTime()


function [ diff_FR ] = compute_FR_X_TErrMag( sdf_ErrSml , sdf_ErrLrg , sdf_Corr )

%compute firing rate for SDF re. reward
FR_ErrSml = mean(sdf_ErrSml(:,3),1);
FR_ErrLrg = mean(sdf_ErrLrg(:,3),1);
FR_Corr = mean(sdf_Corr(:,3),1);

diff_FR = [FR_ErrSml , FR_ErrLrg] - FR_Corr;

%normalize by the max FR on correct trials (across all epochs)
diff_FR = diff_FR / max(FR_Corr,[],'all');

end % fxn : compute_FR_X_TErrMag()



