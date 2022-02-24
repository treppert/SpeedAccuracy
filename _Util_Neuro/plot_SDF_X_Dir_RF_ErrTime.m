function [  ] = plot_SDF_X_Dir_RF_ErrTime( behavData , unitData , spikesSAT )
%plot_SDF_X_Dir_RF_ErrTime() Summary of this function goes here
%   Detailed explanation goes here

MIN_TRIAL_COUNT = 3;
PRINTDIR = 'C:\Users\Thomas Reppert\Documents\Figs - SAT\';

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'E'});
idxFunction = (unitData.Grade_Rew == 1);
idxKeep = (idxArea & idxMonkey & idxFunction);

NUM_UNITS = sum(idxKeep);
unitData = unitData(idxKeep,:);
spikesSAT = spikesSAT(idxKeep);

tPlot = 3500 + (-300 : 600); %plot time vector
NUM_SAMP = length(tPlot);

RT_MAX = 900; %hard ceiling on primary RT

NUM_DIR = 9; %binning by saccade direction for heatmap
BIN_DIR = linspace(-pi, pi, NUM_DIR);

for uu = 2:NUM_UNITS
  fprintf('%s \n', unitData.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  
  RTP_kk = double(behavData.Sacc_RT{kk}); %RT of primary saccade
  RTP_kk(RTP_kk > RT_MAX) = NaN; %hard limit on primary RT
  
  tRew_kk = RTP_kk + double(behavData.Task_TimeReward{kk});
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by screen clear on Fast trials
  idxClear = logical(behavData.Task_ClearDisplayFast{kk});
  %index by condition
  idxFast = (behavData.Task_SATCondition{kk} == 3 & ~idxIso & ~idxClear);
  idxAcc = (behavData.Task_SATCondition{kk} == 1 & ~idxIso);
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  idxErr = (behavData.Task_ErrTime{kk} & ~behavData.Task_ErrChoice{kk}); %timing error
  
  %compute spike density function and align on primary response
  sdfA_kk = compute_spike_density_fxn(spikesSAT{uu});  %sdf from Array
  sdfP_kk = align_signal_on_response(sdfA_kk, RTP_kk); %sdf from Primary
  sdfR_kk = align_signal_on_response(sdfA_kk, round(tRew_kk)); %sdf from Reward
  
  %% Compute mean SDF for response into RF
  meanSDF_Fast_Corr = NaN(NUM_SAMP,3); %sdf re. array | sdf re. primary | sdf re. reward
  meanSDF_Fast_Err = NaN(NUM_SAMP,3); %sdf re. array | sdf re. primary | sdf re. reward
  meanSDF_Acc_Corr = NaN(NUM_SAMP,3);
  meanSDF_Acc_Err = NaN(NUM_SAMP,3);
  tSigR_Acc = struct('p10',NaN, 'p05',NaN, 'p01',NaN);
  tSigR_Fast = tSigR_Acc;
  
  Octant_Sacc1 = behavData.Sacc_Octant{kk}; %index by saccade octant re. response field (RF)
  RF = unitData.RF{uu};
  
  if ( isempty(RF) || (ismember(9,RF)) ) %average over all possible directions
    idxRF = true(behavData.Task_NumTrials(kk),1);
  else %average only trials with saccade into RF
    idxRF = ismember(Octant_Sacc1, RF);
  end
  
  meanSDF_Fast_Corr(:,1) = nanmean(sdfA_kk(idxFast & idxCorr & idxRF, tPlot)); %re. array
  meanSDF_Fast_Corr(:,2) = nanmean(sdfP_kk(idxFast & idxCorr & idxRF, tPlot)); %re. primary
  meanSDF_Fast_Corr(:,3) = nanmean(sdfR_kk(idxFast & idxCorr & idxRF, tPlot)); %re. reward
  if (sum(idxFast & idxErr & idxRF) > MIN_TRIAL_COUNT)
    meanSDF_Fast_Err(:,1) = nanmean(sdfA_kk(idxFast & idxErr & idxRF, tPlot)); %re. array
    meanSDF_Fast_Err(:,2) = nanmean(sdfP_kk(idxFast & idxErr & idxRF, tPlot)); %re. primary
    meanSDF_Fast_Err(:,3) = nanmean(sdfR_kk(idxFast & idxErr & idxRF, tPlot)); %re. reward
    tSigR_Fast = calc_tSignal_ChoiceErr(sdfR_kk(idxFast & idxCorr & idxRF, tPlot), sdfR_kk(idxFast & idxErr & idxRF, tPlot));
  end
  meanSDF_Acc_Corr(:,1) = nanmean(sdfA_kk(idxAcc & idxCorr & idxRF, tPlot)); %re. array
  meanSDF_Acc_Corr(:,2) = nanmean(sdfP_kk(idxAcc & idxCorr & idxRF, tPlot)); %re. primary
  meanSDF_Acc_Corr(:,3) = nanmean(sdfR_kk(idxAcc & idxCorr & idxRF, tPlot)); %re. reward
  if (sum(idxAcc & idxErr & idxRF) > MIN_TRIAL_COUNT)
    meanSDF_Acc_Err(:,1) = nanmean(sdfA_kk(idxAcc & idxErr & idxRF, tPlot)); %re. array
    meanSDF_Acc_Err(:,2) = nanmean(sdfP_kk(idxAcc & idxErr & idxRF, tPlot)); %re. primary
    meanSDF_Acc_Err(:,3) = nanmean(sdfR_kk(idxAcc & idxErr & idxRF, tPlot)); %re. reward
    tSigR_Acc = calc_tSignal_ChoiceErr(sdfR_kk(idxAcc & idxCorr & idxRF, tPlot), sdfR_kk(idxAcc & idxErr & idxRF, tPlot));
  end
  
  figure('visible','on')
  yTickLabel = num2cell(rad2deg(BIN_DIR));
  yTickLabel(2:2:end) = {''};
  
  %% Plot: Mean SDF for response into RF
  OFFSET_PRE = 300;
  sdfAll = [meanSDF_Fast_Corr meanSDF_Fast_Err meanSDF_Acc_Corr meanSDF_Acc_Err];
  maxFR = max(sdfAll,[],'all');
  yLim = [0, maxFR];

  subplot(2,3,1); hold on %Fast re. array
  plot(tPlot-3500, meanSDF_Fast_Corr(:,1), 'Color',[0 .7 0])
  plot(tPlot-3500, meanSDF_Fast_Err(:,1), ':', 'Color',[0 .7 0])
  plot([0 0], yLim, 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500)

  subplot(2,3,2); hold on %Fast re. primary
  title(['RF = ', num2str(rad2deg(convert_tgt_octant_to_angle(RF)))], 'FontSize',9)
  plot(tPlot-3500, meanSDF_Fast_Corr(:,2), 'Color',[0 .7 0])
  plot(tPlot-3500, meanSDF_Fast_Err(:,2), ':', 'Color',[0 .7 0])
  plot([0 0], yLim, 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500)
  set(gca, 'YColor','none')

  subplot(2,3,3); hold on %Fast re. reward
  plot(tPlot-3500, meanSDF_Fast_Corr(:,3), 'Color',[0 .7 0])
  plot(tPlot-3500, meanSDF_Fast_Err(:,3), ':', 'Color',[0 .7 0])
  plot([0 0], yLim, 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500)
  set(gca, 'YColor','none')
  scatter(tSigR_Fast.p05-OFFSET_PRE, 3, 20, [.4 .6 1], 'filled')
  scatter(tSigR_Fast.p01-OFFSET_PRE, 3, 20, [.1 .2 1], 'filled')

  subplot(2,3,4); hold on %Accurate re. array
  plot(tPlot-3500, meanSDF_Acc_Corr(:,1), 'r')
  plot(tPlot-3500, meanSDF_Acc_Err(:,1), 'r:')
  plot([0 0], yLim, 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500)
  xlabel('Time from array (ms)')
  ylabel('Activity (sp/sec)')

  subplot(2,3,5); hold on %Accurate re. primary
  plot(tPlot-3500, meanSDF_Acc_Corr(:,2), 'r')
  plot(tPlot-3500, meanSDF_Acc_Err(:,2), 'r:')
  plot([0 0], yLim, 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500)
  set(gca, 'YColor','none')
  xlabel('Time from primary saccade (ms)')

  subplot(2,3,6); hold on %Accurate re. reward
  plot(tPlot-3500, meanSDF_Acc_Corr(:,3), 'r')
  plot(tPlot-3500, meanSDF_Acc_Err(:,3), 'r:')
  plot([0 0], yLim, 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500)
  set(gca, 'YColor','none')
  xlabel('Time from reward (ms)')
  scatter(tSigR_Acc.p05-OFFSET_PRE, 3, 20, [.4 .6 1], 'filled')
  scatter(tSigR_Acc.p01-OFFSET_PRE, 3, 20, [.1 .2 1], 'filled')

  ppretty([10,4])
  
%   pause(0.1); print([PRINTDIR,unitData.Properties.RowNames{uu},'-',unitData.aArea{uu},'.tif'], '-dtiff')
%   pause(0.1); close(); pause(0.1)
  
end%for:cells(cc)

end%fxn:plot_SDF_X_Dir_RF_ErrTime()
