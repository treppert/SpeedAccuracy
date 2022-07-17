function [ ] = plot_SDF_X_RF_ErrTime( behavData , unitData , varargin )
%plot_SDF_X_Dir_RF_ErrTime() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'unitID=',[]}});

if ~isempty(args.unitID) %if single neuron specified
  UNIT_PLOT = args.unitID;
else %consider all neurons
  UNIT_PLOT = (1 : size(unitData,1))';
end

PLOT = true;
FIG_VISIBLE = 'on';

PVAL_MW = .05;
TAIL_MW = 'left';

idxArea = ismember(unitData.Area, {'SEF'});
idxMonkey = ismember(unitData.Monkey, {'D','E'});
idxFunction = (abs(unitData.Grade_TErr) == 1);
idxKeep = (idxArea & idxMonkey & idxFunction);

NUM_UNIT = sum(idxKeep);
unitTest = unitData(idxKeep,:);

OFFSET_PRE = 400;
tPlot = 3500 + (-OFFSET_PRE : 800); %plot time vector
NUM_SAMP = length(tPlot);

%prepare to bin trials by timing error magnitude
TERR_LIM = linspace(0, 1, 2); %quantile limits for binning
NUM_BIN = length(TERR_LIM) - 1;

for uu = 1:NUM_UNIT
  if ~ismember(unitTest.Index(uu), UNIT_PLOT); continue; end
  fprintf('%s \n', unitTest.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitTest.Session(uu));
  
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
  tRew = RT_P + behavData.Task_TimeReward(kk); %time of reward - fixed re. saccade
  
  %compute spike density function and align appropriately
  spikes_uu = load_spikes_SAT(unitTest.Index(uu), 'user','thoma');
  sdfA = compute_spike_density_fxn(spikes_uu);  %sdf from Array
  sdfP = align_signal_on_response(sdfA, RT_P); %sdf from Primary
  sdfR = align_signal_on_response(sdfA, tRew); %sdf from Reward
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitTest.TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  idxErr = (behavData.Task_ErrTime{kk} & ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  %index by saccade octant re. response field (RF)
  Octant_Sacc1 = behavData.Sacc_Octant{kk};
  idxRF  = ismember(Octant_Sacc1, RFuu);
  
  %combine indexing
  idxAC = (idxAcc & idxCorr & idxRF);    idxAE = (idxAcc & idxErr & idxRF);
    
  %get task deadline
  dlineAcc =  median(behavData.Task_Deadline{kk}(idxAcc));
  %compute error in RT
  errRT = NaN(behavData.Task_NumTrials(kk),1);
  errRT(idxAcc) = RT_P(idxAcc) - dlineAcc;
  
  
  %% Compute mean SDF for response into RF
  sdfErr_A = NaN(NUM_SAMP,NUM_BIN); %sdf re. array
  sdfErr_P = sdfErr_A; %sdf re. primary saccade
  sdfErr_R = sdfErr_A; %sdf re. reward
  
  %Accurate correct
  sdfCorr_A = nanmean(sdfA(idxAC, tPlot));
  sdfCorr_P = nanmean(sdfP(idxAC, tPlot));
  sdfCorr_R = nanmean(sdfR(idxAC, tPlot));
  
  qtl_errRT = quantile(errRT(idxAcc & idxErr & idxRF), TERR_LIM);
  
  for bb = 1:NUM_BIN %loop over RT error bins
    idx_bb = (errRT > qtl_errRT(bb)) & (errRT <= qtl_errRT(bb+1));
    %Accurate timing error
    sdfErr_A(:,bb) = nanmean(sdfA(idxAE & idx_bb, tPlot));
    sdfErr_P(:,bb) = nanmean(sdfP(idxAE & idx_bb, tPlot));
    sdfErr_R(:,bb) = nanmean(sdfR(idxAE & idx_bb, tPlot));
  end %for: RT error bin (ii)

  if (NUM_BIN == 1)
    [~, vecSig] = calc_tErrorSignal_SAT(sdfR(idxAC,tPlot), sdfR(idxAE,tPlot), ...
      'pvalMW',PVAL_MW, 'tailMW',TAIL_MW);
  else
    vecSig = 0;
  end
  
  if (PLOT)
    figure('visible', FIG_VISIBLE)
    yLim = [0, max([sdfErr_A sdfErr_P sdfErr_R],[],'all')];
    colorPlot = linspace(0.0, 0.8, NUM_BIN);

    subplot(1,3,1); hold on %Accurate re. primary
    title([unitTest.Properties.RowNames{uu}, '-', unitTest.Area{uu}, '   ', ...
      'RF = ', num2str(rad2deg(convert_tgt_octant_to_angle(RFuu)))], 'FontSize',9)
    plot(tPlot-3500, sdfCorr_P, 'r')
    for bb = 1:NUM_BIN
      plot(tPlot-3500, sdfErr_P(:,bb), ':', 'Color',[colorPlot(bb) 0 0], 'LineWidth',1.25)
    end
    xlabel('Time from primary saccade (ms)'); xlim(tPlot([1,NUM_SAMP])-3500)
    ylabel('Activity (sp/sec)'); ylim(yLim)

    subplot(1,3,[2 3]); hold on %Accurate re. reward
    plot(tPlot-3500, sdfCorr_R, 'r')
    for bb = 1:NUM_BIN
      plot(tPlot-3500, sdfErr_R(:,bb), ':', 'Color',[colorPlot(bb) 0 0], 'LineWidth',1.25)
    end
    scatter(vecSig-OFFSET_PRE, 3, 20, [.1 .2 1], 'filled')
    set(gca, 'YColor','none'); ylim(yLim)
    xlabel('Time from reward (ms)'); xlim(tPlot([1,NUM_SAMP])-3500)

    ppretty([10,1.4])
    drawnow

  end % if (PLOT)
  
end% for : unit (uu)

end % fxn : plot_SDF_X_RF_ErrTime()
