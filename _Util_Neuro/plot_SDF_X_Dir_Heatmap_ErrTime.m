function [  ] = plot_SDF_X_Dir_Heatmap_ErrTime( behavData , unitData , spikesSAT )
%plot_SDF_X_Dir_Heatmap_ErrTime() Summary of this function goes here
%   Detailed explanation goes here

MIN_TRIAL_COUNT = 3;
PLOT_TYPE = 'heatmap'; %{'SDF_RF','heatmap'}
PRINTDIR = 'C:\Users\Thomas Reppert\Documents\Figs - SAT\';

idxArea = ismember(unitData.aArea, {'FEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});
idxKeep = (idxArea & idxMonkey);

NUM_UNITS = sum(idxKeep);
unitData = unitData(idxKeep,:);
spikesSAT = spikesSAT(idxKeep);

tPlot = 3500 + (-300 : 400); %plot time vector
NUM_SAMP = length(tPlot);

RT_MAX = 900; %hard ceiling on primary RT

NUM_DIR = 9; %binning by saccade direction for heatmap
BIN_DIR = linspace(-pi, pi, NUM_DIR);
H_DIFF_DIR = diff(BIN_DIR([1,2]))/2;

for uu = 1:NUM_UNITS
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
  
  %% Compute SDF heatmaps across all 8 directions
  sdf_Fast_Corr = NaN(3*NUM_DIR, NUM_SAMP); %sdf re. array | sdf re. primary | sdf re. reward
  sdf_Acc_Corr = sdf_Fast_Corr;
  sdf_Fast_Err = sdf_Fast_Corr;
  sdf_Acc_Err = sdf_Fast_Corr;
  
  Dir_Sacc1 = behavData.Sacc_Direction{kk};
  
  for dd = 1:NUM_DIR
    %index by direction
    if ((dd == 1) || (dd == NUM_DIR))
      binLimDD = [(BIN_DIR(1)+H_DIFF_DIR) , (BIN_DIR(end)-H_DIFF_DIR) ];
      idxDD = transpose((Dir_Sacc1 < binLimDD(1) | Dir_Sacc1 > binLimDD(2)));
    else
      binLimDD = [(BIN_DIR(dd)-H_DIFF_DIR) , (BIN_DIR(dd)+H_DIFF_DIR) ];
      idxDD = transpose((Dir_Sacc1 > binLimDD(1) & Dir_Sacc1 < binLimDD(2)));
    end
    
    %compute SDFs - Correct trial outcome
    sdf_Fast_Corr(dd,:) = nanmean(sdfA_kk(idxFast & idxCorr & idxDD, tPlot)); %re. array
    sdf_Fast_Corr(dd+NUM_DIR,:) = nanmean(sdfP_kk(idxFast & idxCorr & idxDD, tPlot)); %re. primary
    sdf_Fast_Corr(dd+2*NUM_DIR,:) = nanmean(sdfR_kk(idxFast & idxCorr & idxDD, tPlot)); %re. reward
    sdf_Acc_Corr(dd,:) = nanmean(sdfA_kk(idxAcc & idxCorr & idxDD, tPlot)); %re. array
    sdf_Acc_Corr(dd+NUM_DIR,:) = nanmean(sdfP_kk(idxAcc & idxCorr & idxDD, tPlot)); %re. primary
    sdf_Acc_Corr(dd+2*NUM_DIR,:) = nanmean(sdfR_kk(idxAcc & idxCorr & idxDD, tPlot)); %re. reward
    
    %compute SDFs - Error trial outcome
    if (sum(idxFast & idxErr & idxDD) >= MIN_TRIAL_COUNT)
      sdf_Fast_Err(dd,:) = nanmean(sdfA_kk(idxFast & idxErr & idxDD, tPlot)); %re. array
      sdf_Fast_Err(dd+NUM_DIR,:) = nanmean(sdfP_kk(idxFast & idxErr & idxDD, tPlot)); %re. primary
      sdf_Fast_Err(dd+2*NUM_DIR,:) = nanmean(sdfR_kk(idxFast & idxErr & idxDD, tPlot)); %re. second
    end
    if (sum(idxAcc & idxErr & idxDD) >= MIN_TRIAL_COUNT)
      sdf_Acc_Err(dd,:) = nanmean(sdfA_kk(idxAcc & idxErr & idxDD, tPlot)); %re. array
      sdf_Acc_Err(dd+NUM_DIR,:) = nanmean(sdfP_kk(idxAcc & idxErr & idxDD, tPlot)); %re. primary
      sdf_Acc_Err(dd+2*NUM_DIR,:) = nanmean(sdfR_kk(idxAcc & idxErr & idxDD, tPlot)); %re. second
    end
  end%for:direction(dd)
  
  %% Compute mean SDF for response into RF
  meanSDF_Fast_Corr = NaN(NUM_SAMP,3); %sdf re. array | sdf re. primary | sdf re. reward
  meanSDF_Fast_Err = NaN(NUM_SAMP,3); %sdf re. array | sdf re. primary | sdf re. reward
  meanSDF_Acc_Corr = NaN(NUM_SAMP,3);
  meanSDF_Acc_Err = NaN(NUM_SAMP,3);
  
  Octant_Sacc1 = behavData.Sacc_Octant{kk}; %index by saccade octant re. response field (RF)
  Octant_Sacc2 = transpose(behavData.Sacc2_Octant{kk});
  RF = unitData.RF{uu};
  
  if ( isempty(RF) || (ismember(9,RF)) ) %average over all possible directions
    meanSDF_Fast_Corr(:,1) = nanmean(sdfA_kk(idxFast & idxCorr, tPlot)); %re. array
    meanSDF_Fast_Corr(:,2) = nanmean(sdfP_kk(idxFast & idxCorr, tPlot)); %re. primary
    meanSDF_Fast_Corr(:,3) = nanmean(sdfR_kk(idxFast & idxCorr, tPlot)); %re. reward
    meanSDF_Fast_Err(:,1) = nanmean(sdfA_kk(idxFast & idxErr, tPlot)); %re. array
    meanSDF_Fast_Err(:,2) = nanmean(sdfP_kk(idxFast & idxErr, tPlot)); %re. primary
    meanSDF_Fast_Err(:,3) = nanmean(sdfR_kk(idxFast & idxErr, tPlot)); %re. reward
    meanSDF_Acc_Corr(:,1) = nanmean(sdfA_kk(idxAcc & idxCorr, tPlot)); %re. array
    meanSDF_Acc_Corr(:,2) = nanmean(sdfP_kk(idxAcc & idxCorr, tPlot)); %re. primary
    meanSDF_Acc_Corr(:,3) = nanmean(sdfR_kk(idxAcc & idxCorr, tPlot)); %re. reward
    meanSDF_Acc_Err(:,1) = nanmean(sdfA_kk(idxAcc & idxErr, tPlot)); %re. array
    meanSDF_Acc_Err(:,2) = nanmean(sdfP_kk(idxAcc & idxErr, tPlot)); %re. primary
    meanSDF_Acc_Err(:,3) = nanmean(sdfR_kk(idxAcc & idxErr, tPlot)); %re. reward
  else %average only trials with saccade into RF
    idxRF = ismember(Octant_Sacc1, RF);
    meanSDF_Fast_Corr(:,1) = nanmean(sdfA_kk(idxFast & idxCorr & idxRF, tPlot)); %re. array
    meanSDF_Fast_Corr(:,2) = nanmean(sdfP_kk(idxFast & idxCorr & idxRF, tPlot)); %re. primary
    meanSDF_Fast_Corr(:,3) = nanmean(sdfR_kk(idxFast & idxCorr & idxRF, tPlot)); %re. reward
    if (sum(idxFast & idxErr & idxRF) > MIN_TRIAL_COUNT)
      meanSDF_Fast_Err(:,1) = nanmean(sdfA_kk(idxFast & idxErr & idxRF, tPlot)); %re. array
      meanSDF_Fast_Err(:,2) = nanmean(sdfP_kk(idxFast & idxErr & idxRF, tPlot)); %re. primary
      meanSDF_Fast_Err(:,3) = nanmean(sdfR_kk(idxFast & idxErr & idxRF, tPlot)); %re. reward
    end
    meanSDF_Acc_Corr(:,1) = nanmean(sdfA_kk(idxAcc & idxCorr & idxRF, tPlot)); %re. array
    meanSDF_Acc_Corr(:,2) = nanmean(sdfP_kk(idxAcc & idxCorr & idxRF, tPlot)); %re. primary
    meanSDF_Acc_Corr(:,3) = nanmean(sdfR_kk(idxAcc & idxCorr & idxRF, tPlot)); %re. reward
    if (sum(idxAcc & idxErr & idxRF) > MIN_TRIAL_COUNT)
      meanSDF_Acc_Err(:,1) = nanmean(sdfA_kk(idxAcc & idxErr & idxRF, tPlot)); %re. array
      meanSDF_Acc_Err(:,2) = nanmean(sdfP_kk(idxAcc & idxErr & idxRF, tPlot)); %re. primary
      meanSDF_Acc_Err(:,3) = nanmean(sdfR_kk(idxAcc & idxErr & idxRF, tPlot)); %re. reward
    end
  end
  
  figure('visible','off')
  yTickLabel = num2cell(rad2deg(BIN_DIR));
  yTickLabel(2:2:end) = {''};
  
  %% Plotting
  switch (PLOT_TYPE)
    case 'SDF_RF'
      %% Plot: Mean SDF for response into RF
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
      
      ppretty([10,4])
      
    case 'heatmap'
      %% Plot of heatmap: Correct, error and difference plots
      sdfAll = [sdf_Fast_Corr sdf_Fast_Err sdf_Acc_Corr sdf_Acc_Err];
      maxFR = max(sdfAll,[],'all');
      
      sdf_Fast_Diff = (sdf_Fast_Err(2*NUM_DIR+(1:NUM_DIR),:) - sdf_Fast_Corr(2*NUM_DIR+(1:NUM_DIR),:)) / maxFR;
      sdf_Acc_Diff = (sdf_Acc_Err(2*NUM_DIR+(1:NUM_DIR),:) - sdf_Acc_Corr(2*NUM_DIR+(1:NUM_DIR),:)) / maxFR;
      
      cLim = [0, maxFR];
      cLimDiff = [-1 1];
      
      subplot(4,3,1); hold on %Fast re. array
      imagesc(tPlot-3500, BIN_DIR, sdf_Fast_Corr(1:NUM_DIR,:), cLim);
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks(BIN_DIR); yticklabels(yTickLabel)
      
      subplot(4,3,2); hold on %Fast re. primary
      title('Fast - Correct', 'FontSize',9)
      imagesc(tPlot-3500, BIN_DIR, sdf_Fast_Corr(NUM_DIR+(1:NUM_DIR),:), cLim);
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks([])
      
      subplot(4,3,3); hold on %Fast re. reward
      imagesc(tPlot-3500, BIN_DIR, sdf_Fast_Corr(2*NUM_DIR+(1:NUM_DIR),:), cLim);
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks([])
      
      subplot(4,3,4); hold on %Fast re. array
      imagesc(tPlot-3500, BIN_DIR, sdf_Fast_Err(1:NUM_DIR,:), cLim);
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks(BIN_DIR); yticklabels(yTickLabel)
      
      subplot(4,3,5); hold on %Fast re. primary
      title('Fast - Timing error', 'FontSize',9)
      imagesc(tPlot-3500, BIN_DIR, sdf_Fast_Err(NUM_DIR+(1:NUM_DIR),:), cLim);
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks([])
      
      subplot(4,3,6); hold on %Fast re. reward
      imagesc(tPlot-3500, BIN_DIR, sdf_Fast_Err(2*NUM_DIR+(1:NUM_DIR),:), cLim);
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks(BIN_DIR); yticklabels(yTickLabel)
      
      subplot(4,3,7); hold on %Accurate re. array
      imagesc(tPlot-3500, BIN_DIR, sdf_Acc_Corr(1:NUM_DIR,:), cLim);
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks(BIN_DIR); yticklabels(yTickLabel)
      
      subplot(4,3,8); hold on %Accurate re. primary
      title('Accurate - Correct', 'FontSize',9)
      imagesc(tPlot-3500, BIN_DIR, sdf_Acc_Corr(NUM_DIR+(1:NUM_DIR),:), cLim);
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks([])
      
      subplot(4,3,9); hold on %Accurate re. reward
      imagesc(tPlot-3500, BIN_DIR, sdf_Acc_Corr(2*NUM_DIR+(1:NUM_DIR),:), cLim);
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks([])
      
      subplot(4,3,10); hold on %Accurate re. array
      imagesc(tPlot-3500, BIN_DIR, sdf_Acc_Err(1:NUM_DIR,:), cLim);
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks(BIN_DIR); yticklabels(yTickLabel)
      xlabel('Time from array (ms)')
      ylabel('Primary saccade direction (deg)')
      
      subplot(4,3,11); hold on %Accurate re. primary
      title('Accurate - Timing error', 'FontSize',9)
      imagesc(tPlot-3500, BIN_DIR, sdf_Acc_Err(NUM_DIR+(1:NUM_DIR),:), cLim);
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks([])
      xlabel('Time from primary saccade (ms)')
      
      subplot(4,3,12); hold on %Accurate re. reward
      imagesc(tPlot-3500, BIN_DIR, sdf_Acc_Err(2*NUM_DIR+(1:NUM_DIR),:), cLim);
      colorbar('location','east', 'Color','w')
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks(BIN_DIR); yticklabels(yTickLabel)
      xlabel('Time from reward (ms)')
      
      ppretty([13,11])
      
  end
  
  pause(0.1); print([PRINTDIR,unitData.Properties.RowNames{uu},'-',unitData.aArea{uu},'.tif'], '-dtiff')
  pause(0.1); close(); pause(0.1)
  
end%for:cells(cc)

end%fxn:plot_SDF_X_Dir_Heatmap_ErrTime()
