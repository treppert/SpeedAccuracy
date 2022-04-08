% function [  ] = plot_SDF_X_Dir_RF_ErrChoice_X_ISI( behavData , unitData , spikesSAT )
%plot_SDF_X_Dir_RF_ErrChoice() Summary of this function goes here
%   Detailed explanation goes here

FIG_VISIBILITY = 'off';
MIN_TRIAL_COUNT = 5;
RT_MAX = 900; %hard ceiling on primary RT
PRINTDIR = 'C:\Users\Thomas Reppert\Documents\Figs - SAT\';

PVAL_MW = .05; %parameters for Mann-Whitney U-test of difference
TAIL_MW = 'left';

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});
idxFunction = ismember(unitData.Grade_Err, [1,9]);
idxKeep = (idxArea & idxMonkey & idxFunction);

NUM_UNIT = sum(idxKeep);
unitTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

OFFSET_PRE = 700;
OFFSET_POST = 700;
tPlot = 3500 + (-OFFSET_PRE : OFFSET_POST); %plot time vector
NUM_SAMP = length(tPlot);

tSig_FS = NaN(NUM_UNIT,1); %Fast - Short ISI
tSig_FL = tSig_FS; %Fast - Long ISI
tSig_AS = tSig_FS; %Accurate - Short ISI
tSig_AL = tSig_FS; %Accurate - Long ISI

for uu = 1:NUM_UNIT
  fprintf('%s \n', unitTest.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitTest.Task_Session(uu));
  
  RTP_kk = behavData.Sacc_RT{kk}; %Primary saccade RT
  RTP_kk(RTP_kk > RT_MAX) = NaN; %hard limit on primary RT
  RTS_kk = behavData.Sacc2_RT{kk}; %Second saccade RT
  RTS_kk(RTS_kk == 0) = NaN;
  ISI_kk = RTS_kk - RTP_kk; %Inter-saccade interval
  
  %compute spike density functions and align appropriately
  sdfA_kk = compute_spike_density_fxn(spikesTest{uu});  %sdf from Array
  sdfP_kk = align_signal_on_response(sdfA_kk, RTP_kk); %sdf from Primary
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitTest.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by condition
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  idxErr = (behavData.Task_ErrChoice{kk} & ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  %split Fast error trials by median time of second saccade
  medISI_Fast = nanmedian(ISI_kk(idxFast & idxErr));
  medISI_Acc  = nanmedian(ISI_kk(idxAcc & idxErr));
  idxShortISI_Fast = (ISI_kk <= medISI_Fast);
  idxLongISI_Fast  = (ISI_kk > medISI_Fast);
  idxShortISI_Acc  = (ISI_kk <= medISI_Acc);
  idxLongISI_Acc   = (ISI_kk > medISI_Acc);
  
  %set "RT2" of correct trials as the median RT2 on error trials
  RTS_kk(idxFast & idxCorr) = RTP_kk(idxFast & idxCorr) + round(medISI_Fast);
  RTS_kk(idxAcc  & idxCorr) = RTP_kk(idxAcc & idxCorr)  + round(medISI_Acc);
  sdfS_kk = align_signal_on_response(sdfA_kk, RTS_kk); %sdf from Second
  
  %% Compute mean SDF for response into RF
  sdfFast_Corr = NaN(NUM_SAMP,3); %sdf re. array | sdf re. primary | sdf re. second
  sdfFast_ErrShort = sdfFast_Corr;
  sdfFast_ErrLong  = sdfFast_Corr;
  sdfAcc_Corr = sdfFast_Corr;
  sdfAcc_ErrShort = sdfFast_Corr;
  sdfAcc_ErrLong  = sdfFast_Corr;
  
  %index by saccade octant re. response field (RF)
  Octant_Sacc1 = behavData.Sacc_Octant{kk};
  Octant_Sacc2 = behavData.Sacc2_Octant{kk};
  RF = unitTest.RF{uu};
  
  if ( isempty(RF) || (ismember(9,RF)) ) %average over all possible directions
    idxRF1 = true(behavData.Task_NumTrials(kk),1);
    idxRF2 = idxRF1;
  else %average only trials with saccade into RF
    idxRF1 = ismember(Octant_Sacc1, RF);
    idxRF2 = ismember(Octant_Sacc2, RF);
  end
  
  %Correct trials
  sdfFast_Corr(:,1) = nanmean(sdfA_kk(idxFast & idxCorr & idxRF1, tPlot)); %re. array
  sdfFast_Corr(:,2) = nanmean(sdfP_kk(idxFast & idxCorr & idxRF1, tPlot)); %re. primary
  sdfFast_Corr(:,3) = nanmean(sdfS_kk(idxFast & idxCorr & idxRF2, tPlot)); %re. second
  sdfAcc_Corr(:,1)  = nanmean(sdfA_kk(idxAcc  & idxCorr & idxRF1, tPlot));
  sdfAcc_Corr(:,2)  = nanmean(sdfP_kk(idxAcc  & idxCorr & idxRF1, tPlot));
  sdfAcc_Corr(:,3)  = nanmean(sdfS_kk(idxAcc  & idxCorr & idxRF2, tPlot));
  
  %Error trials: Fast - Short ISI
  idx_Primary = (idxFast & idxErr  & idxRF1 & idxShortISI_Fast);
  idx_Second  = (idxFast & idxErr  & idxRF2 & idxShortISI_Fast);
  if (sum(idx_Primary) >= MIN_TRIAL_COUNT)
    sdfFast_ErrShort(:,1) = nanmean(sdfA_kk(idx_Primary, tPlot)); %re. array
    sdfFast_ErrShort(:,2) = nanmean(sdfP_kk(idx_Primary, tPlot)); %re. primary
    [tSig_FS(uu),vecSig_FS] = calc_tSignal_ChoiceErr(sdfP_kk(idxFast & idxCorr & idxRF1, tPlot), ...
      sdfP_kk(idx_Primary, tPlot), 'pvalMW',PVAL_MW, 'tailMW',TAIL_MW);
  end
  if (sum(idx_Second) >= MIN_TRIAL_COUNT) %second saccade
    sdfFast_ErrShort(:,3) = nanmean(sdfS_kk(idx_Second, tPlot)); %re. second
  end
  
  %Error trials: Fast - Long ISI
  idx_Primary = (idxFast & idxErr  & idxRF1 & idxLongISI_Fast);
  idx_Second  = (idxFast & idxErr  & idxRF2 & idxLongISI_Fast);
  if (sum(idx_Primary) >= MIN_TRIAL_COUNT)
    sdfFast_ErrLong(:,1) = nanmean(sdfA_kk(idx_Primary, tPlot)); %re. array
    sdfFast_ErrLong(:,2) = nanmean(sdfP_kk(idx_Primary, tPlot)); %re. primary
    [tSig_FL(uu),vecSig_FL] = calc_tSignal_ChoiceErr(sdfP_kk(idxFast & idxCorr & idxRF1, tPlot), ...
      sdfP_kk(idx_Primary, tPlot), 'pvalMW',PVAL_MW, 'tailMW',TAIL_MW);
  end
  if (sum(idx_Second) >= MIN_TRIAL_COUNT) %second saccade
    sdfFast_ErrLong(:,3) = nanmean(sdfS_kk(idx_Second, tPlot)); %re. second
  end
  
  %Error trials: Accurate - Short ISI
  idx_Primary = (idxAcc & idxErr  & idxRF1 & idxShortISI_Acc);
  idx_Second  = (idxAcc & idxErr  & idxRF2 & idxShortISI_Acc);
  if (sum(idx_Primary) >= MIN_TRIAL_COUNT)
    sdfAcc_ErrShort(:,1) = nanmean(sdfA_kk(idx_Primary, tPlot)); %re. array
    sdfAcc_ErrShort(:,2) = nanmean(sdfP_kk(idx_Primary, tPlot)); %re. primary
    [tSig_AS(uu),vecSig_AS] = calc_tSignal_ChoiceErr(sdfP_kk(idxAcc & idxCorr & idxRF1, tPlot), ...
      sdfP_kk(idx_Primary, tPlot), 'pvalMW',PVAL_MW, 'tailMW',TAIL_MW);
  end
  if (sum(idx_Second) >= MIN_TRIAL_COUNT) %second saccade
    sdfAcc_ErrShort(:,3) = nanmean(sdfS_kk(idx_Second, tPlot)); %re. second
  end
  
  %Error trials: Accurate - Long ISI
  idx_Primary = (idxAcc & idxErr  & idxRF1 & idxLongISI_Acc);
  idx_Second  = (idxAcc & idxErr  & idxRF2 & idxLongISI_Acc);
  if (sum(idx_Primary) >= MIN_TRIAL_COUNT)
    sdfAcc_ErrLong(:,1) = nanmean(sdfA_kk(idx_Primary, tPlot)); %re. array
    sdfAcc_ErrLong(:,2) = nanmean(sdfP_kk(idx_Primary, tPlot)); %re. primary
    [tSig_AL(uu),vecSig_AL] = calc_tSignal_ChoiceErr(sdfP_kk(idxAcc & idxCorr & idxRF1, tPlot), ...
      sdfP_kk(idx_Primary, tPlot), 'pvalMW',PVAL_MW, 'tailMW',TAIL_MW);
  end
  if (sum(idx_Second) >= MIN_TRIAL_COUNT) %second saccade
    sdfAcc_ErrLong(:,3) = nanmean(sdfS_kk(idx_Second, tPlot)); %re. second
  end
  
  %% Plot: Mean SDF for response into RF
  SIGDOT_SIZE = 5; %size of significant difference marker
  hFig = figure('visible',FIG_VISIBILITY);
  yLim = [0, max([sdfFast_Corr sdfFast_ErrShort sdfFast_ErrLong sdfAcc_Corr sdfAcc_ErrShort sdfAcc_ErrLong],[],'all')];

  subplot(2,3,1); hold on %Fast re. array
  title([unitTest.Properties.RowNames{uu}, '-', unitTest.aArea{uu}, '  ', ...
    'RF = ', num2str(rad2deg(convert_tgt_octant_to_angle(RF)))], 'FontSize',9)
  plot(tPlot-3500, sdfFast_Corr(:,1), 'Color',[0 .7 0], 'LineWidth',1.25)
  plot(tPlot-3500, sdfFast_ErrShort(:,1), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
  plot(tPlot-3500, sdfFast_ErrLong(:,1), 'k:', 'LineWidth',0.75)
  xlim(tPlot([1,NUM_SAMP])-3500); ylim(yLim)

  subplot(2,3,2); hold on %Fast re. primary
  plot(tPlot-3500, sdfFast_Corr(:,2), 'Color',[0 .7 0], 'LineWidth',1.25)
  plot(tPlot-3500, sdfFast_ErrShort(:,2), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
  plot(tPlot-3500, sdfFast_ErrLong(:,2), 'k:', 'LineWidth',0.75)
  plot((tSig_FS(uu)-OFFSET_PRE)*ones(1,2), yLim, 'b:')
  plot((tSig_FL(uu)-OFFSET_PRE)*ones(1,2), yLim, 'b:')
  plot(medISI_Fast*ones(1,2), yLim, 'b-', 'LineWidth',1.25)
  xlim(tPlot([1,NUM_SAMP])-3500); ylim(yLim)
  set(gca, 'YColor','none')

  subplot(2,3,3); hold on %Fast re. second
  plot(tPlot-3500, sdfFast_Corr(:,3), 'Color',[0 .7 0], 'LineWidth',1.25)
  plot(tPlot-3500, sdfFast_ErrShort(:,3), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
  plot(tPlot-3500, sdfFast_ErrLong(:,3), 'k:', 'LineWidth',0.75)
  xlim(tPlot([1,NUM_SAMP])-3500); ylim(yLim)
  set(gca, 'YColor','none')

  subplot(2,3,4); hold on %Accurate re. array
  plot(tPlot-3500, sdfAcc_Corr(:,1), 'r', 'LineWidth',1.25)
  plot(tPlot-3500, sdfAcc_ErrShort(:,1), 'r:', 'LineWidth',1.25)
  plot(tPlot-3500, sdfAcc_ErrLong(:,1), 'k:', 'LineWidth',0.75)
  xlim(tPlot([1,NUM_SAMP])-3500); ylim(yLim)
  xlabel('Time from array (ms)')
  ylabel('Activity (sp/sec)')

  subplot(2,3,5); hold on %Accurate re. primary
  plot(tPlot-3500, sdfAcc_Corr(:,2), 'r', 'LineWidth',1.25)
  plot(tPlot-3500, sdfAcc_ErrShort(:,2), 'r:', 'LineWidth',1.25)
  plot(tPlot-3500, sdfAcc_ErrLong(:,2), 'k:', 'LineWidth',0.75)
  plot((tSig_AS(uu)-OFFSET_PRE)*ones(1,2), yLim, 'b:')
  plot((tSig_AL(uu)-OFFSET_PRE)*ones(1,2), yLim, 'b:')
  plot(medISI_Acc*ones(1,2), yLim, 'b-', 'LineWidth',1.25)
  xlim(tPlot([1,NUM_SAMP])-3500); ylim(yLim)
  set(gca, 'YColor','none')
  xlabel('Time from primary saccade (ms)')
  
  subplot(2,3,6); hold on %Accurate re. second
  plot(tPlot-3500, sdfAcc_Corr(:,3), 'r', 'LineWidth',1.25)
  plot(tPlot-3500, sdfAcc_ErrShort(:,3), 'r:', 'LineWidth',1.25)
  plot(tPlot-3500, sdfAcc_ErrLong(:,3), 'k:', 'LineWidth',0.75)
  xlim(tPlot([1,NUM_SAMP])-3500); ylim(yLim)
  set(gca, 'YColor','none')
  xlabel('Time from second saccade (ms)')

  ppretty([10,4])
  
  pause(0.1); print(hFig, [PRINTDIR,unitTest.Properties.RowNames{uu},'-',unitTest.aArea{uu},'.tif'], '-dtiff')
  pause(0.1); close(hFig); pause(0.1)
  
end % for : unit(uu)

clearvars -except behavData unitData spikesSAT
% end % fxn : plot_SDF_X_Dir_RF_ErrChoice_X_ISI()
