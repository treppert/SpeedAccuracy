% function [  ] = plot_SDF_X_Dir_RF_ErrChoice( behavData , unitData , spikesSAT )
%plot_SDF_X_Dir_RF_ErrChoice() Summary of this function goes here
%   Detailed explanation goes here

COMPUTE_SIGNIFICANCE = false; %add marker for significant difference
FIG_VISIBILITY = 'off';
MIN_TRIAL_COUNT = 3;
RT_MAX = 900; %hard ceiling on primary RT
PRINTDIR = 'C:\Users\Thomas Reppert\Documents\Figs - SAT\';

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});
idxFunction = (unitData.Grade_Err == -1);
idxKeep = (idxArea & idxMonkey & idxFunction);

NUM_UNIT = sum(idxKeep);
unitTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

tPlot = 3500 + (-350 : 500); %plot time vector
OFFSET_PRE = 350;
NUM_SAMP = length(tPlot);

for uu = 1:NUM_UNIT
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
  meanSDF_IN_Fast_Corr = NaN(NUM_SAMP,2); %sdf re. array | sdf re. primary
  meanSDF_IN_Fast_Err = NaN(NUM_SAMP,3); %sdf re. array | sdf re. primary | sdf re. second
  meanSDF_IN_Acc_Corr = meanSDF_IN_Fast_Corr;
  meanSDF_IN_Acc_Err = meanSDF_IN_Fast_Err;
  meanSDF_OUT_Fast_Corr = meanSDF_IN_Fast_Corr;   meanSDF_OUT_Acc_Corr = meanSDF_IN_Fast_Corr; %not into RF
  meanSDF_OUT_Fast_Err =  meanSDF_IN_Fast_Err;    meanSDF_OUT_Acc_Err =  meanSDF_IN_Fast_Err;
  
  if (COMPUTE_SIGNIFICANCE)
    tSigP_Acc = struct('p10',NaN, 'p05',NaN, 'p01',NaN);
    tSigP_Fast = tSigP_Acc;
  end
  
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
  
  %Fast condition
  meanSDF_IN_Fast_Corr(:,1) = nanmean(sdfA_kk(idxFast & idxCorr & idxRF1, tPlot)); %re. array
  meanSDF_IN_Fast_Corr(:,2) = nanmean(sdfP_kk(idxFast & idxCorr & idxRF1, tPlot)); %re. primary
  meanSDF_OUT_Fast_Corr(:,1) = nanmean(sdfA_kk(idxFast & idxCorr & ~idxRF1, tPlot));
  meanSDF_OUT_Fast_Corr(:,2) = nanmean(sdfP_kk(idxFast & idxCorr & ~idxRF1, tPlot));
  if (sum(idxFast & idxErr & idxRF1) > MIN_TRIAL_COUNT)
    meanSDF_IN_Fast_Err(:,1) = nanmean(sdfA_kk(idxFast & idxErr & idxRF1, tPlot)); %re. array
    meanSDF_IN_Fast_Err(:,2) = nanmean(sdfP_kk(idxFast & idxErr & idxRF1, tPlot)); %re. primary
    if (COMPUTE_SIGNIFICANCE)
      tSigP_Fast = calc_tSignal_ChoiceErr(sdfP_kk(idxFast & idxCorr & idxRF1, tPlot), sdfP_kk(idxFast & idxErr & idxRF1, tPlot));
    end
  end
  if (sum(idxFast & idxErr & ~idxRF1) > MIN_TRIAL_COUNT)
    meanSDF_OUT_Fast_Err(:,1) = nanmean(sdfA_kk(idxFast & idxErr & ~idxRF1, tPlot));
    meanSDF_OUT_Fast_Err(:,2) = nanmean(sdfP_kk(idxFast & idxErr & ~idxRF1, tPlot));
  end
  
  if (sum(idxFast & idxErr & idxRF2) > MIN_TRIAL_COUNT) %second saccade
    meanSDF_IN_Fast_Err(:,3) = nanmean(sdfS_kk(idxFast & idxErr & idxRF2, tPlot)); %re. second
  end
  if (sum(idxFast & idxErr & ~idxRF2) > MIN_TRIAL_COUNT)
    meanSDF_OUT_Fast_Err(:,3) = nanmean(sdfS_kk(idxFast & idxErr & ~idxRF2, tPlot));
  end
  
  %Accurate condition
  meanSDF_IN_Acc_Corr(:,1) = nanmean(sdfA_kk(idxAcc & idxCorr & idxRF1, tPlot)); %re. array
  meanSDF_IN_Acc_Corr(:,2) = nanmean(sdfP_kk(idxAcc & idxCorr & idxRF1, tPlot)); %re. primary
  meanSDF_OUT_Acc_Corr(:,1) = nanmean(sdfA_kk(idxAcc & idxCorr & ~idxRF1, tPlot));
  meanSDF_OUT_Acc_Corr(:,2) = nanmean(sdfP_kk(idxAcc & idxCorr & ~idxRF1, tPlot));
  if (sum(idxAcc & idxErr & idxRF1) > MIN_TRIAL_COUNT)
    meanSDF_IN_Acc_Err(:,1) = nanmean(sdfA_kk(idxAcc & idxErr & idxRF1, tPlot)); %re. array
    meanSDF_IN_Acc_Err(:,2) = nanmean(sdfP_kk(idxAcc & idxErr & idxRF1, tPlot)); %re. primary
    if (COMPUTE_SIGNIFICANCE)
      tSigP_Acc = calc_tSignal_ChoiceErr(sdfP_kk(idxAcc & idxCorr & idxRF1, tPlot), sdfP_kk(idxAcc & idxErr & idxRF1, tPlot));
    end
  end
  if (sum(idxAcc & idxErr & ~idxRF1) > MIN_TRIAL_COUNT)
    meanSDF_OUT_Acc_Err(:,1) = nanmean(sdfA_kk(idxAcc & idxErr & ~idxRF1, tPlot));
    meanSDF_OUT_Acc_Err(:,2) = nanmean(sdfP_kk(idxAcc & idxErr & ~idxRF1, tPlot));
  end
  
  if (sum(idxAcc & idxErr & idxRF2) > MIN_TRIAL_COUNT) %second saccade
    meanSDF_IN_Acc_Err(:,3) = nanmean(sdfS_kk(idxAcc & idxErr & idxRF2, tPlot)); %re. second
  end
  if (sum(idxAcc & idxErr & ~idxRF2) > MIN_TRIAL_COUNT)
    meanSDF_OUT_Acc_Err(:,3) = nanmean(sdfS_kk(idxAcc & idxErr & ~idxRF2, tPlot));
  end
  
  %compute signal magnitude as the integrated difference between Err and
  %Corr SDFs (IN RF)
  Sig_Time = unitTest.ErrorSignal_Time(uu,:);
  Sig_Idx = Sig_Time + OFFSET_PRE;
  if ~isnan(Sig_Time(1)) %if error signal was observed for Fast condition
    A_Err_Fast = mean(meanSDF_IN_Fast_Err(Sig_Idx(1):Sig_Idx(2),2) - meanSDF_IN_Fast_Corr(Sig_Idx(1):Sig_Idx(2),2)) * diff(Sig_Time(1:2))/1000;
  else
    A_Err_Fast = NaN;
  end
  if ~isnan(Sig_Time(3)) %if error signal was observed for Accurate condition
    A_Err_Acc = mean(meanSDF_IN_Acc_Err(Sig_Idx(3):Sig_Idx(4),2) - meanSDF_IN_Acc_Corr(Sig_Idx(3):Sig_Idx(4),2)) * diff(Sig_Time(3:4))/1000;
  else
    A_Err_Acc = NaN;
  end
  
  %% Plot: Mean SDF for response into RF
  SIGDOT_SIZE = 5; %size of significant difference marker
  hFig = figure('visible',FIG_VISIBILITY);
  
  sdfAll = [meanSDF_IN_Fast_Corr meanSDF_IN_Fast_Err meanSDF_IN_Acc_Corr meanSDF_IN_Acc_Err];
  maxFR = max(sdfAll,[],'all');
  yLim = [0, maxFR];

  subplot(2,3,1); hold on %Fast re. array
  title([unitTest.Properties.RowNames{uu}, '-', unitTest.aArea{uu}, '  ', ...
    'RF = ', num2str(rad2deg(convert_tgt_octant_to_angle(RF)))], 'FontSize',9)
  plot(tPlot-3500, meanSDF_IN_Fast_Corr(:,1), 'Color',[0 .7 0], 'LineWidth',1.25)
  plot(tPlot-3500, meanSDF_IN_Fast_Err(:,1), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
  plot(tPlot-3500, meanSDF_OUT_Fast_Corr(:,1), 'k', 'LineWidth',.75)
  plot(tPlot-3500, meanSDF_OUT_Fast_Err(:,1), 'k:', 'LineWidth',.75)
  plot([0 0], yLim, 'k:', 'LineWidth',1.25)
  xlim(tPlot([1,NUM_SAMP])-3500)
  legend({'Correct IN','Error IN','Correct OUT','Error OUT',''}, 'location','northwest')

  subplot(2,3,2); hold on %Fast re. primary
  title(['Signal = ', num2str(A_Err_Fast)], 'FontSize',9)
  plot(tPlot-3500, meanSDF_IN_Fast_Corr(:,2), 'Color',[0 .7 0], 'LineWidth',1.25)
  plot(tPlot-3500, meanSDF_IN_Fast_Err(:,2), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
  plot(tPlot-3500, meanSDF_OUT_Fast_Corr(:,2), 'k', 'LineWidth',.75)
  plot(tPlot-3500, meanSDF_OUT_Fast_Err(:,2), 'k:', 'LineWidth',.75)
  plot([0 0], yLim, 'k:', 'LineWidth',1.25)
  plot(Sig_Time(1)*ones(1,2), yLim, 'k:', 'LineWidth',.75)
  plot(Sig_Time(2)*ones(1,2), yLim, 'k:', 'LineWidth',.75)
  xlim(tPlot([1,NUM_SAMP])-3500)
  set(gca, 'YColor','none')
  if (COMPUTE_SIGNIFICANCE)
    scatter(tSigP_Fast.p05-OFFSET_PRE, 3, SIGDOT_SIZE, [.4 .6 1], 'filled')
    scatter(tSigP_Fast.p01-OFFSET_PRE, 3, SIGDOT_SIZE, [.1 .2 1], 'filled')
  end
  subPrimaryFast = subplot(2,3,2);

  subplot(2,3,3); hold on %Fast re. second
  plot(tPlot-3500, meanSDF_IN_Fast_Err(:,3), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
  plot(tPlot-3500, meanSDF_OUT_Fast_Err(:,3), 'k:', 'LineWidth',.75)
  plot([0 0], yLim, 'k:', 'LineWidth',1.25)
  xlim(tPlot([1,NUM_SAMP])-3500)
  set(gca, 'YColor','none')

  subplot(2,3,4); hold on %Accurate re. array
  plot(tPlot-3500, meanSDF_IN_Acc_Corr(:,1), 'r', 'LineWidth',1.25)
  plot(tPlot-3500, meanSDF_IN_Acc_Err(:,1), 'r:', 'LineWidth',1.25)
  plot(tPlot-3500, meanSDF_OUT_Acc_Corr(:,1), 'k', 'LineWidth',.75)
  plot(tPlot-3500, meanSDF_OUT_Acc_Err(:,1), 'k:', 'LineWidth',.75)
  plot([0 0], yLim, 'k:', 'LineWidth',1.25)
  xlim(tPlot([1,NUM_SAMP])-3500)
  xlabel('Time from array (ms)')
  ylabel('Activity (sp/sec)')
  legend({'Correct IN','Error IN','Correct OUT','Error OUT',''}, 'location','northwest')

  subplot(2,3,5); hold on %Accurate re. primary
  title(['Signal = ', num2str(A_Err_Acc)], 'FontSize',9)
  plot(tPlot-3500, meanSDF_IN_Acc_Corr(:,2), 'r', 'LineWidth',1.25)
  plot(tPlot-3500, meanSDF_IN_Acc_Err(:,2), 'r:', 'LineWidth',1.25)
  plot(tPlot-3500, meanSDF_OUT_Acc_Corr(:,2), 'k', 'LineWidth',.75)
  plot(tPlot-3500, meanSDF_OUT_Acc_Err(:,2), 'k:', 'LineWidth',.75)
  plot([0 0], yLim, 'k:', 'LineWidth',1.25)
  plot(Sig_Time(3)*ones(1,2), yLim, 'k:', 'LineWidth',.75)
  plot(Sig_Time(4)*ones(1,2), yLim, 'k:', 'LineWidth',.75)
  xlim(tPlot([1,NUM_SAMP])-3500)
  set(gca, 'YColor','none')
  xlabel('Time from primary saccade (ms)')
  if (COMPUTE_SIGNIFICANCE)
    scatter(tSigP_Acc.p05-OFFSET_PRE, 3, SIGDOT_SIZE, [.4 .6 1], 'filled')
    scatter(tSigP_Acc.p01-OFFSET_PRE, 3, SIGDOT_SIZE, [.1 .2 1], 'filled')
  end
  subPrimaryAcc = subplot(2,3,5);
  
  subplot(2,3,6); hold on %Accurate re. second
  plot(tPlot-3500, meanSDF_IN_Acc_Err(:,3), 'r:', 'LineWidth',1.25)
  plot(tPlot-3500, meanSDF_OUT_Acc_Err(:,3), 'k:', 'LineWidth',.75)
  plot([0 0], yLim, 'k:', 'LineWidth',1.25)
  xlim(tPlot([1,NUM_SAMP])-3500)
  set(gca, 'YColor','none')
  xlabel('Time from second saccade (ms)')

  ppretty([10,4])
  
%   %print zoomed view of activity re. primary saccade
%   hFigZoom = figure('visible','off');
%   copyobj(allchild(subPrimaryFast), subplot(2,1,1)); box on; grid on
%   set(gca, 'XMinorTick','on')
%   copyobj(allchild(subPrimaryAcc), subplot(2,1,2)); box on; grid on
%   set(gca, 'XMinorTick','on')
  
%   pause(0.1); print(hFigZoom, [PRINTDIR,'Zoom-',unitTest.Properties.RowNames{uu},'-',unitTest.aArea{uu},'.tif'], '-dtiff')
%   pause(0.1); close(hFigZoom); pause(0.1)
  pause(0.1); print(hFig, [PRINTDIR,unitTest.Properties.RowNames{uu},'-',unitTest.aArea{uu},'.tif'], '-dtiff')
  pause(0.1); close(hFig); pause(0.1)
  
end % for : unit(uu)

clearvars -except behavData unitData spikesSAT
% end % fxn : plot_SDF_X_Dir_RF_ErrChoice()
