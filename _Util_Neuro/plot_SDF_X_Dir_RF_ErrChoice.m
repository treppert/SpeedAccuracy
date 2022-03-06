% function [  ] = plot_SDF_X_Dir_RF_ErrChoice( behavData , unitData , spikesSAT )
%plot_SDF_X_Dir_RF_ErrChoice() Summary of this function goes here
%   Detailed explanation goes here

MIN_TRIAL_COUNT = 3;
RT_MAX = 900; %hard ceiling on primary RT
PRINTDIR = 'C:\Users\Tom\Documents\Figs - SAT\';

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'E'});
idxFunction = (unitData.Grade_Err == 1);
idxKeep = (idxArea & idxMonkey & idxFunction);

NUM_UNIT = sum(idxKeep);
unitTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

tPlot = 3500 + (-350 : 500); %plot time vector
OFFSET_PRE = 350;
NUM_SAMP = length(tPlot);

for uu = 3:3%1:NUM_UNIT
  fprintf('%s \n', unitTest.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitTest.Task_Session(uu));
  
  RTP_kk = behavData.Sacc_RT{kk}; %Primary saccade RT
  RTP_kk(RTP_kk > RT_MAX) = NaN; %hard limit on primary RT
  RTS_kk = behavData.Sacc2_RT{kk}; %Second saccade RT
  RTS_kk(RTS_kk == 0) = NaN; %trials with no second saccade
  ISI_kk = RTS_kk - RTP_kk;
  
  %compute spike density function and align on primary response
  sdfA_kk = compute_spike_density_fxn(spikesTest{uu});  %sdf from Array
  sdfP_kk = align_signal_on_response(sdfA_kk, RTP_kk); %sdf from Primary
  sdfS_kk = align_signal_on_response(sdfA_kk, RTS_kk); %sdf from Second
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitTest.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
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
  tSigP_Acc = struct('p10',NaN, 'p05',NaN, 'p01',NaN);
  tSigP_Fast = tSigP_Acc;
  
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
  
  meanSDF_Fast_Corr(:,1) = nanmean(sdfA_kk(idxFast & idxCorr & idxRF1, tPlot)); %re. array
  meanSDF_Fast_Corr(:,2) = nanmean(sdfP_kk(idxFast & idxCorr & idxRF1, tPlot)); %re. primary
  if (sum(idxFast & idxErr & idxRF1) > MIN_TRIAL_COUNT)
    meanSDF_Fast_Err(:,1) = nanmean(sdfA_kk(idxFast & idxErr & idxRF1, tPlot)); %re. array
    meanSDF_Fast_Err(:,2) = nanmean(sdfP_kk(idxFast & idxErr & idxRF1, tPlot)); %re. primary
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
    tSigP_Acc = calc_tSignal_ChoiceErr(sdfP_kk(idxAcc & idxCorr & idxRF1, tPlot), sdfP_kk(idxAcc & idxErr & idxRF1, tPlot));
  end
  if (sum(idxAcc & idxErr & idxRF2) > MIN_TRIAL_COUNT)
    meanSDF_Acc_Err(:,3) = nanmean(sdfS_kk(idxAcc & idxErr & idxRF2, tPlot)); %re. second
  end
  
  %compute signal magnitude as the integrated difference between Err and Corr SDFs
  Sig_Time = unitTest.ErrorSignal_Time(uu,:);
  Sig_Idx = Sig_Time + OFFSET_PRE;
  if ~isnan(Sig_Time(1)) %if error signal was observed for Fast condition
    A_Err_Fast = mean(meanSDF_Fast_Err(Sig_Idx(1):Sig_Idx(2),2) - meanSDF_Fast_Corr(Sig_Idx(1):Sig_Idx(2),2)) * diff(Sig_Time(1:2))/1000;
  else
    A_Err_Fast = NaN;
  end
  if ~isnan(Sig_Time(3)) %if error signal was observed for Accurate condition
    A_Err_Acc = mean(meanSDF_Acc_Err(Sig_Idx(3):Sig_Idx(4),2) - meanSDF_Acc_Corr(Sig_Idx(3):Sig_Idx(4),2)) * diff(Sig_Time(3:4))/1000;
  else
    A_Err_Acc = NaN;
  end
  
  %% Plot: Mean SDF for response into RF
  hFig = figure('visible','on');
  
  sdfAll = [meanSDF_Fast_Corr meanSDF_Fast_Err meanSDF_Acc_Corr meanSDF_Acc_Err];
  maxFR = max(sdfAll,[],'all');
  yLim = [0, maxFR];

  subplot(2,3,1); hold on %Fast re. array
  title([unitTest.Properties.RowNames{uu}, '-', unitTest.aArea{uu}, '  ', ...
    'RF = ', num2str(rad2deg(convert_tgt_octant_to_angle(RF)))], 'FontSize',9)
  plot(tPlot-3500, meanSDF_Fast_Corr(:,1), 'Color',[0 .7 0])
  plot(tPlot-3500, meanSDF_Fast_Err(:,1), ':', 'Color',[0 .7 0])
  plot([0 0], yLim, 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500)

  subplot(2,3,2); hold on %Fast re. primary
  title(['Signal = ', num2str(A_Err_Fast)], 'FontSize',9)
  plot(tPlot-3500, meanSDF_Fast_Corr(:,2), 'Color',[0 .7 0])
  plot(tPlot-3500, meanSDF_Fast_Err(:,2), ':', 'Color',[0 .7 0])
  plot([0 0], yLim, 'k:', 'LineWidth',1.5)
  plot(Sig_Time(1)*ones(1,2), yLim, 'k:', 'LineWidth',.75)
  plot(Sig_Time(2)*ones(1,2), yLim, 'k:', 'LineWidth',.75)
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

  subplot(2,3,5); hold on %Accurate re. primary
  title(['Signal = ', num2str(A_Err_Acc)], 'FontSize',9)
  plot(tPlot-3500, meanSDF_Acc_Corr(:,2), 'r')
  plot(tPlot-3500, meanSDF_Acc_Err(:,2), 'r:')
  plot([0 0], yLim, 'k:', 'LineWidth',1.5)
  plot(Sig_Time(3)*ones(1,2), yLim, 'k:', 'LineWidth',.75)
  plot(Sig_Time(4)*ones(1,2), yLim, 'k:', 'LineWidth',.75)
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
  
end % for : unit(uu)

clearvars -except behavData unitData spikesSAT
% end%fxn:plot_SDF_X_Dir_RF_ErrChoice()
