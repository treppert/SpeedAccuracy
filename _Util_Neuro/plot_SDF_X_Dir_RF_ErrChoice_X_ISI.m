% function [  ] = plot_SDF_X_Dir_RF_ErrChoice_X_ISI( behavData , unitData , spikesSAT )
%plot_SDF_X_Dir_RF_ErrChoice() Summary of this function goes here
%   Detailed explanation goes here

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
  ISI_kk = RTS_kk - RTP_kk; %Inter-saccade interval
  
  %compute spike density function and align on primary response
  sdfA_kk = compute_spike_density_fxn(spikesTest{uu});  %sdf from Array
  sdfP_kk = align_signal_on_response(sdfA_kk, RTP_kk); %sdf from Primary
  sdfS_kk = align_signal_on_response(sdfA_kk, RTS_kk); %sdf from Second
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitTest.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by condition
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  idxErr = (behavData.Task_ErrChoice{kk} & ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  %split Fast error trials by median time of second saccade
  medISI_FastErr = nanmean(ISI_kk(idxFast & idxErr));
  medISI_AccErr  = nanmean(ISI_kk(idxAcc & idxErr));
  idxFastShort = (ISI_kk <= medISI_FastErr);
  idxFastLong  = (ISI_kk > medISI_FastErr);
  idxAccShort  = (ISI_kk <= medISI_AccErr);
  idxAccLong   = (ISI_kk > medISI_AccErr);
  
  %% Compute mean SDF for response into RF
  SDF_Fast_Corr = NaN(NUM_SAMP,2); %sdf re. array | sdf re. primary
  SDF_Fast_Err_Short = NaN(NUM_SAMP,3); %sdf re. array | sdf re. primary | sdf re. second
  SDF_Fast_Err_Long = SDF_Fast_Err_Short;
  SDF_Acc_Corr = SDF_Fast_Corr;
  SDF_Acc_Err_Short = SDF_Fast_Err_Short;
  SDF_Acc_Err_Long  = SDF_Fast_Err_Short;
  
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
  SDF_Fast_Corr(:,1) = nanmean(sdfA_kk(idxFast & idxCorr & idxRF1, tPlot)); %re. array
  SDF_Fast_Corr(:,2) = nanmean(sdfP_kk(idxFast & idxCorr & idxRF1, tPlot)); %re. primary
  SDF_Acc_Corr(:,1)  = nanmean(sdfA_kk(idxAcc  & idxCorr & idxRF1, tPlot));
  SDF_Acc_Corr(:,2)  = nanmean(sdfP_kk(idxAcc  & idxCorr & idxRF1, tPlot));
  
  %Choice error trials: Fast - Short ISI
  if (sum(idxFast & idxErr  & idxRF1 & idxFastShort) > MIN_TRIAL_COUNT)
    SDF_Fast_Err_Short(:,1) = nanmean(sdfA_kk(idxFast & idxErr  & idxRF1 & idxFastShort, tPlot)); %re. array
    SDF_Fast_Err_Short(:,2) = nanmean(sdfP_kk(idxFast & idxErr  & idxRF1 & idxFastShort, tPlot)); %re. primary
  end
  if (sum(idxFast & idxErr & idxRF2 & idxFastShort) > MIN_TRIAL_COUNT) %second saccade
    SDF_Fast_Err_Short(:,3) = nanmean(sdfS_kk(idxFast & idxErr & idxRF2 & idxFastShort, tPlot)); %re. second
  end
  
  %Choice error trials: Fast - Long ISI
  if (sum(idxFast & idxErr  & idxRF1 & idxFastLong) > MIN_TRIAL_COUNT)
    SDF_Fast_Err_Long(:,1) = nanmean(sdfA_kk(idxFast & idxErr  & idxRF1 & idxFastLong, tPlot)); %re. array
    SDF_Fast_Err_Long(:,2) = nanmean(sdfP_kk(idxFast & idxErr  & idxRF1 & idxFastLong, tPlot)); %re. primary
  end
  if (sum(idxFast & idxErr & idxRF2 & idxFastLong) > MIN_TRIAL_COUNT) %second saccade
    SDF_Fast_Err_Long(:,3) = nanmean(sdfS_kk(idxFast & idxErr & idxRF2 & idxFastLong, tPlot)); %re. second
  end
  
  %Choice error trials: Accurate - Short ISI
  if (sum(idxAcc & idxErr  & idxRF1 & idxAccShort) > MIN_TRIAL_COUNT)
    SDF_Acc_Err_Short(:,1) = nanmean(sdfA_kk(idxAcc & idxErr & idxRF1 & idxAccShort, tPlot)); %re. array
    SDF_Acc_Err_Short(:,2) = nanmean(sdfP_kk(idxAcc & idxErr & idxRF1 & idxAccShort, tPlot)); %re. primary
  end
  if (sum(idxAcc & idxErr & idxRF2 & idxAccShort) > MIN_TRIAL_COUNT) %second saccade
    SDF_Acc_Err_Short(:,3) = nanmean(sdfS_kk(idxAcc & idxErr & idxRF2 & idxAccShort, tPlot)); %re. second
  end
  
  %Choice error trials: Accurate - Long ISI
  if (sum(idxAcc & idxErr  & idxRF1 & idxAccLong) > MIN_TRIAL_COUNT)
    SDF_Acc_Err_Long(:,1) = nanmean(sdfA_kk(idxAcc & idxErr & idxRF1 & idxAccLong, tPlot)); %re. array
    SDF_Acc_Err_Long(:,2) = nanmean(sdfP_kk(idxAcc & idxErr & idxRF1 & idxAccLong, tPlot)); %re. primary
  end
  if (sum(idxAcc & idxErr & idxRF2 & idxAccLong) > MIN_TRIAL_COUNT) %second saccade
    SDF_Acc_Err_Long(:,3) = nanmean(sdfS_kk(idxAcc & idxErr & idxRF2 & idxAccLong, tPlot)); %re. second
  end
  
  %% Plot: Mean SDF for response into RF
  SIGDOT_SIZE = 5; %size of significant difference marker
  hFig = figure('visible',FIG_VISIBILITY);
  
  sdfAll = [SDF_Fast_Corr SDF_Fast_Err_Short SDF_Fast_Err_Long SDF_Acc_Corr SDF_Acc_Err_Short SDF_Acc_Err_Long];
  maxFR = max(sdfAll,[],'all');
  yLim = [0, maxFR];

  subplot(2,3,1); hold on %Fast re. array
  title([unitTest.Properties.RowNames{uu}, '-', unitTest.aArea{uu}, '  ', ...
    'RF = ', num2str(rad2deg(convert_tgt_octant_to_angle(RF)))], 'FontSize',9)
  plot(tPlot-3500, SDF_Fast_Corr(:,1), 'Color',[0 .7 0], 'LineWidth',1.25)
  plot(tPlot-3500, SDF_Fast_Err_Short(:,1), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
  plot(tPlot-3500, SDF_Fast_Err_Long(:,1), 'k:', 'LineWidth',0.75)
  plot([0 0], yLim, 'k:', 'LineWidth',0.75)
  xlim(tPlot([1,NUM_SAMP])-3500)

  subplot(2,3,2); hold on %Fast re. primary
  plot(tPlot-3500, SDF_Fast_Corr(:,2), 'Color',[0 .7 0], 'LineWidth',1.25)
  plot(tPlot-3500, SDF_Fast_Err_Short(:,2), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
  plot(tPlot-3500, SDF_Fast_Err_Long(:,2), 'k:', 'LineWidth',0.75)
  plot([0 0], yLim, 'k:', 'LineWidth',0.75)
  plot(medISI_FastErr*ones(1,2), yLim, 'b-', 'LineWidth',1.25)
  xlim(tPlot([1,NUM_SAMP])-3500)
  set(gca, 'YColor','none')
  subPrimaryFast = subplot(2,3,2);

  subplot(2,3,3); hold on %Fast re. second
  plot(tPlot-3500, SDF_Fast_Err_Short(:,3), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
  plot(tPlot-3500, SDF_Fast_Err_Long(:,3), 'k:', 'LineWidth',0.75)
  plot([0 0], yLim, 'k:', 'LineWidth',0.75)
  xlim(tPlot([1,NUM_SAMP])-3500)
  set(gca, 'YColor','none')

  subplot(2,3,4); hold on %Accurate re. array
  plot(tPlot-3500, SDF_Acc_Corr(:,1), 'r', 'LineWidth',1.25)
  plot(tPlot-3500, SDF_Acc_Err_Short(:,1), 'r:', 'LineWidth',1.25)
  plot(tPlot-3500, SDF_Acc_Err_Long(:,1), 'k:', 'LineWidth',0.75)
  plot([0 0], yLim, 'k:', 'LineWidth',0.75)
  xlim(tPlot([1,NUM_SAMP])-3500)
  xlabel('Time from array (ms)')
  ylabel('Activity (sp/sec)')

  subplot(2,3,5); hold on %Accurate re. primary
  plot(tPlot-3500, SDF_Acc_Corr(:,2), 'r', 'LineWidth',1.25)
  plot(tPlot-3500, SDF_Acc_Err_Short(:,2), 'r:', 'LineWidth',1.25)
  plot(tPlot-3500, SDF_Acc_Err_Long(:,2), 'k:', 'LineWidth',0.75)
  plot([0 0], yLim, 'k:', 'LineWidth',0.75)
  plot(medISI_AccErr*ones(1,2), yLim, 'b-', 'LineWidth',1.25)
  xlim(tPlot([1,NUM_SAMP])-3500)
  set(gca, 'YColor','none')
  xlabel('Time from primary saccade (ms)')
  subPrimaryAcc = subplot(2,3,5);
  
  subplot(2,3,6); hold on %Accurate re. second
  plot(tPlot-3500, SDF_Acc_Err_Short(:,3), 'r:', 'LineWidth',1.25)
  plot(tPlot-3500, SDF_Acc_Err_Long(:,3), 'k:', 'LineWidth',0.75)
  plot([0 0], yLim, 'k:', 'LineWidth',0.75)
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
% end % fxn : plot_SDF_X_Dir_RF_ErrChoice_X_ISI()
