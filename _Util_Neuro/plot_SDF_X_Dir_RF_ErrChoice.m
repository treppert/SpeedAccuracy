function [  ] = plot_SDF_X_Dir_RF_ErrChoice( behavData , unitData , spikesSAT )
%plot_SDF_X_Dir_RF_ErrChoice() Summary of this function goes here
%   Detailed explanation goes here

MIN_TRIAL_COUNT = 3;
PRINTDIR = 'C:\Users\Tom\Documents\Figs - SAT\';

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'E'});
idxFunction = (unitData.Grade_Err == -1);
idxKeep = (idxArea & idxMonkey & idxFunction);

NUM_UNITS = sum(idxKeep);
unitData = unitData(idxKeep,:);
spikesSAT = spikesSAT(idxKeep);

tPlot = 3500 + (-300 : 400); %plot time vector
NUM_SAMP = length(tPlot);

RT_MAX = 900; %hard ceiling on primary RT

NUM_DIR = 9; %binning by saccade direction for heatmap
BIN_DIR = linspace(-pi, pi, NUM_DIR);

for uu = 2:NUM_UNITS
  fprintf('%s \n', unitData.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  
  RTP_kk = double(behavData.Sacc_RT{kk}); %Primary saccade RT
  RTP_kk(RTP_kk > RT_MAX) = NaN; %hard limit on primary RT
  RTS_kk = double(behavData.Sacc2_RT{kk}); %Second saccade RT
  RTS_kk(RTS_kk == 0) = NaN; %trials with no second saccade
  ISI_kk = RTS_kk - RTP_kk;
  
  %compute spike density function and align on primary response
  sdfA_kk = compute_spike_density_fxn(spikesSAT{uu});  %sdf from Array
  sdfP_kk = align_signal_on_response(sdfA_kk, RTP_kk); %sdf from Primary
  sdfS_kk = align_signal_on_response(sdfA_kk, RTS_kk); %sdf from Second
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by condition
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  %index by inter-saccade interval (ISI) length
  idxShort = (ISI_kk < 320);
  idxLong = (ISI_kk > 280);
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  idxErr = (behavData.Task_ErrChoice{kk} & ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
%   idxErr = (idxErr & idxShort);
  
  %% Compute mean SDF for response into RF
  meanSDF_Fast_Corr = NaN(NUM_SAMP,2); %sdf re. array | sdf re. primary
  meanSDF_Fast_Err = NaN(NUM_SAMP,3); %sdf re. array | sdf re. primary | sdf re. second
  meanSDF_Acc_Corr = NaN(NUM_SAMP,2);
  meanSDF_Acc_Err = NaN(NUM_SAMP,3);
  tSigA_Acc = struct('p10',NaN, 'p05',NaN, 'p01',NaN);  tSigP_Acc = tSigA_Acc;
  tSigA_Fast = tSigA_Acc;  tSigP_Fast = tSigA_Acc;
  
  Octant_Sacc1 = behavData.Sacc_Octant{kk}; %index by saccade octant re. response field (RF)
  Octant_Sacc2 = behavData.Sacc2_Octant{kk};
  RF = unitData.RF{uu};
  
  if ( isempty(RF) || (ismember(9,RF)) ) %average over all possible directions
    idxRF1 = true(behavData.Task_NumTrials(kk),1);
    idxRF2 = idxRF1;
  else %average only trials with saccade into RF
    idxRF1 = ismember(Octant_Sacc1, RF);
    idxRF2 = ismember(Octant_Sacc2, RF);
  end
  
  meanSDF_Fast_Corr(:,1) = nanmean(sdfA_kk(idxFast & idxCorr & idxRF1, tPlot)); %re. array
  meanSDF_Fast_Corr(:,2) = nanmean(sdfP_kk(idxFast & idxCorr & idxRF1, tPlot)); %re. primary
  if (sum(idxFast & idxErr & idxRF1) > MIN_TRIAL_COUNT)
    meanSDF_Fast_Err(:,1) = nanmean(sdfA_kk(idxFast & idxErr & idxRF1, tPlot)); %re. array
    meanSDF_Fast_Err(:,2) = nanmean(sdfP_kk(idxFast & idxErr & idxRF1, tPlot)); %re. primary
    tSigA_Fast = calc_tSignal_ChoiceErr(sdfA_kk(idxFast & idxCorr & idxRF1, tPlot), sdfA_kk(idxFast & idxErr & idxRF1, tPlot));
    tSigP_Fast = calc_tSignal_ChoiceErr(sdfP_kk(idxFast & idxCorr & idxRF1, tPlot), sdfP_kk(idxFast & idxErr & idxRF1, tPlot));
  end
  if (sum(idxFast & idxErr & idxRF2) > MIN_TRIAL_COUNT)
    meanSDF_Fast_Err(:,3) = nanmean(sdfS_kk(idxFast & idxErr & idxRF2, tPlot)); %re. second
  end
  meanSDF_Acc_Corr(:,1) = nanmean(sdfA_kk(idxAcc & idxCorr & idxRF1, tPlot)); %re. array
  meanSDF_Acc_Corr(:,2) = nanmean(sdfP_kk(idxAcc & idxCorr & idxRF1, tPlot)); %re. primary
  if (sum(idxAcc & idxErr & idxRF1) > MIN_TRIAL_COUNT)
    meanSDF_Acc_Err(:,1) = nanmean(sdfA_kk(idxAcc & idxErr & idxRF1, tPlot)); %re. array
    meanSDF_Acc_Err(:,2) = nanmean(sdfP_kk(idxAcc & idxErr & idxRF1, tPlot)); %re. primary
    tSigA_Acc = calc_tSignal_ChoiceErr(sdfA_kk(idxAcc & idxCorr & idxRF1, tPlot), sdfA_kk(idxAcc & idxErr & idxRF1, tPlot));
    tSigP_Acc = calc_tSignal_ChoiceErr(sdfP_kk(idxAcc & idxCorr & idxRF1, tPlot), sdfP_kk(idxAcc & idxErr & idxRF1, tPlot));
  end
  if (sum(idxAcc & idxErr & idxRF2) > MIN_TRIAL_COUNT)
    meanSDF_Acc_Err(:,3) = nanmean(sdfS_kk(idxAcc & idxErr & idxRF2, tPlot)); %re. second
  end
  
  hFig = figure('visible','on');
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
  scatter(tSigA_Fast.p05-OFFSET_PRE, 3, 20, [.4 .6 1], 'filled')
  scatter(tSigA_Fast.p01-OFFSET_PRE, 3, 20, [.1 .2 1], 'filled')

  subplot(2,3,2); hold on %Fast re. primary
  title(['RF = ', num2str(rad2deg(convert_tgt_octant_to_angle(RF)))], 'FontSize',9)
  plot(tPlot-3500, meanSDF_Fast_Corr(:,2), 'Color',[0 .7 0])
  plot(tPlot-3500, meanSDF_Fast_Err(:,2), ':', 'Color',[0 .7 0])
  plot([0 0], yLim, 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500)
  set(gca, 'YColor','none')
  scatter(tSigP_Fast.p05-OFFSET_PRE, 3, 20, [.4 .6 1], 'filled')
  scatter(tSigP_Fast.p01-OFFSET_PRE, 3, 20, [.1 .2 1], 'filled')

  subplot(2,3,3); hold on %Fast re. second
  plot(tPlot-3500, meanSDF_Fast_Err(:,3), ':', 'Color',[0 .7 0])
  plot([0 0], yLim, 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500)
  set(gca, 'YColor','none')

  subplot(2,3,4); hold on %Accurate re. array
  plot(tPlot-3500, meanSDF_Acc_Corr(:,1), 'r')
  plot(tPlot-3500, meanSDF_Acc_Err(:,1), 'r:')
  plot([0 0], yLim, 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500)
  xlabel('Time from array (ms)')
  ylabel('Activity (sp/sec)')
  scatter(tSigA_Acc.p05-OFFSET_PRE, 3, 20, [.4 .6 1], 'filled')
  scatter(tSigA_Acc.p01-OFFSET_PRE, 3, 20, [.1 .2 1], 'filled')

  subplot(2,3,5); hold on %Accurate re. primary
  plot(tPlot-3500, meanSDF_Acc_Corr(:,2), 'r')
  plot(tPlot-3500, meanSDF_Acc_Err(:,2), 'r:')
  plot([0 0], yLim, 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500)
  set(gca, 'YColor','none')
  xlabel('Time from primary saccade (ms)')
  scatter(tSigP_Acc.p05-OFFSET_PRE, 3, 20, [.4 .6 1], 'filled')
  scatter(tSigP_Acc.p01-OFFSET_PRE, 3, 20, [.1 .2 1], 'filled')

  subplot(2,3,6); hold on %Accurate re. second
  plot(tPlot-3500, meanSDF_Acc_Err(:,3), 'r:')
  plot([0 0], yLim, 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500)
  set(gca, 'YColor','none')
  xlabel('Time from second saccade (ms)')

  ppretty([10,4])
  
%   pause(0.1); print([PRINTDIR,unitData.Properties.RowNames{uu},'-',unitData.aArea{uu},'.tif'], '-dtiff')
%   pause(0.1); close(hFig); pause(0.1)
  
end%for:cells(uu)

end%fxn:plot_SDF_X_Dir_RF_ErrChoice()