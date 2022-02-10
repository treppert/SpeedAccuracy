function [  ] = plot_SDF_X_Dir_Heatmap( behavData , unitData , spikesSAT )
%plot_SDF_X_Dir_Heatmap() Summary of this function goes here
%   Detailed explanation goes here

MIN_TRIAL_COUNT = 3;
TRIAL_OUTCOME_PLOT = 'difference'; %{'correct','error','difference'}
PRINTDIR = 'C:\Users\Tom\Documents\Figs - SAT\';

idxArea = ismember(unitData.aArea, {'SC','SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});
idxErrUnit = (unitData.Grade_Err >= 2);
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
  
  RTS_kk = double(behavData.Sacc2_RT{kk}); %Time of second re. array
  RTS_kk(RTS_kk == 0) = NaN; %trials with no second saccade
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by condition
  idxFast = (behavData.Task_SATCondition{kk} == 3 & ~idxIso);
  idxAcc = (behavData.Task_SATCondition{kk} == 1 & ~idxIso);
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  idxErrChc = (behavData.Task_ErrChoice{kk} & ~behavData.Task_ErrTime{kk});
  
  %compute spike density function and align on primary response
  sdfA_kk = compute_spike_density_fxn(spikesSAT{uu});  %sdf from Array
  sdfP_kk = align_signal_on_response(sdfA_kk, RTP_kk); %sdf from Primary
  sdfS_kk = align_signal_on_response(sdfA_kk, RTS_kk); %sdf from Second
  
  %initializations
  sdf_Fast_Corr = NaN(2*NUM_DIR, NUM_SAMP); %1st half: sdf re. array | 2nd half: sdf re. primary
  sdf_Acc_Corr = sdf_Fast_Corr;
  sdf_Fast_Err = sdf_Fast_Corr; %1st half: sdf re. primary | 2nd half: sdf re. second
  sdf_Acc_Err = sdf_Fast_Corr;
  
  Dir_Sacc1 = behavData.Sacc_Direction{kk};
  Dir_Sacc2 = behavData.Sacc2_Direction{kk};
  
  for dd = 1:NUM_DIR
    %index by direction
    if ((dd == 1) || (dd == NUM_DIR))
      binLimDD = [(BIN_DIR(1)+H_DIFF_DIR) , (BIN_DIR(end)-H_DIFF_DIR) ];
      idxDD1 = transpose((Dir_Sacc1 < binLimDD(1) | Dir_Sacc1 > binLimDD(2)));
      idxDD2 = transpose((Dir_Sacc2 < binLimDD(1) | Dir_Sacc2 > binLimDD(2)));
    else
      binLimDD = [(BIN_DIR(dd)-H_DIFF_DIR) , (BIN_DIR(dd)+H_DIFF_DIR) ];
      idxDD1 = transpose((Dir_Sacc1 > binLimDD(1) & Dir_Sacc1 < binLimDD(2)));
      idxDD2 = transpose((Dir_Sacc2 > binLimDD(1) & Dir_Sacc2 < binLimDD(2)));
    end
    
    %compute SDFs - Correct trial outcome
    sdf_Fast_Corr(dd,:) = nanmean(sdfA_kk(idxFast & idxCorr & idxDD1, tPlot)); %re. array
    sdf_Fast_Corr(dd+NUM_DIR,:) = nanmean(sdfP_kk(idxFast & idxCorr & idxDD1, tPlot)); %re. primary
    sdf_Acc_Corr(dd,:) = nanmean(sdfA_kk(idxAcc & idxCorr & idxDD1, tPlot)); %re. array
    sdf_Acc_Corr(dd+NUM_DIR,:) = nanmean(sdfP_kk(idxAcc & idxCorr & idxDD1, tPlot)); %re. primary
    
    %compute SDFs - Choice error trial outcome
    if (sum(idxFast & idxErrChc & idxDD1) >= MIN_TRIAL_COUNT)
      sdf_Fast_Err(dd,:) = nanmean(sdfP_kk(idxFast & idxErrChc & idxDD1, tPlot)); %re. primary
    end
    if (sum(idxFast & idxErrChc & idxDD2) >= MIN_TRIAL_COUNT)
      sdf_Fast_Err(dd+NUM_DIR,:) = nanmean(sdfS_kk(idxFast & idxErrChc & idxDD2, tPlot)); %re. second
    end
    if (sum(idxAcc & idxErrChc & idxDD1) >= MIN_TRIAL_COUNT)
      sdf_Acc_Err(dd,:) = nanmean(sdfP_kk(idxAcc & idxErrChc & idxDD1, tPlot)); %re. primary
    end
    if (sum(idxAcc & idxErrChc & idxDD2) >= MIN_TRIAL_COUNT)
      sdf_Acc_Err(dd+NUM_DIR,:) = nanmean(sdfS_kk(idxAcc & idxErrChc & idxDD2, tPlot)); %re. second
    end
  end%for:direction(dd)
    
%   figure('visible','on')
  figure('visible','off')
  yTickLabel = num2cell(rad2deg(BIN_DIR));
  yTickLabel(2:2:end) = {''};
  
  %% Plotting
  switch (TRIAL_OUTCOME_PLOT)
    case 'correct'
      %% Trial outcome -- Correct
      sdfAll = [sdf_Fast_Corr sdf_Fast_Err sdf_Acc_Corr sdf_Acc_Err];
      cLim = [0, max(sdfAll,[],'all')];
      
      subplot(2,2,1); hold on %Fast re. array
      title('Fast - Correct', 'FontSize',9)
      imagesc(tPlot-3500, BIN_DIR, sdf_Fast_Corr(1:NUM_DIR,:), cLim);
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks(BIN_DIR); yticklabels(yTickLabel)
      
      subplot(2,2,2); hold on %Fast re. primary
      title('Fast - Correct', 'FontSize',9)
      imagesc(tPlot-3500, BIN_DIR, sdf_Fast_Corr(NUM_DIR+1:end,:), cLim);
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks([])
      
      subplot(2,2,3); hold on %Accurate re. array
      title('Accurate - Correct', 'FontSize',9)
      imagesc(tPlot-3500, BIN_DIR, sdf_Fast_Corr(1:NUM_DIR,:), cLim);
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks(BIN_DIR); yticklabels(yTickLabel)
      ylabel('Primary saccade direction (deg)')
      xlabel('Time from array (ms)')
      
      subplot(2,2,4); hold on %Accurate re. primary
      title('Accurate - Correct', 'FontSize',9)
      imagesc(tPlot-3500, BIN_DIR, sdf_Acc_Corr(NUM_DIR+1:end,:), cLim);
      colorbar('location','east', 'Color','w')
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks([])
      xlabel('Time from primary saccade (ms)')
      
      ppretty([11,7])
      
    case 'error'
      %% Trial outcome -- Choice error
      sdfAll = [sdf_Fast_Corr sdf_Fast_Err sdf_Acc_Corr sdf_Acc_Err];
      cLim = [0, max(sdfAll,[],'all')];
      
      subplot(2,2,1); hold on %Fast re. primary
      title('Fast - Choice error', 'FontSize',9)
      imagesc(tPlot-3500, BIN_DIR, sdf_Fast_Err(1:NUM_DIR,:), cLim);
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks(BIN_DIR); yticklabels(yTickLabel)
      
      subplot(2,2,2); hold on %Fast re. second
      title('Fast - Choice error', 'FontSize',9)
      imagesc(tPlot-3500, BIN_DIR, sdf_Fast_Err(NUM_DIR+1:end,:), cLim);
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks([])
      
      subplot(2,2,3); hold on %Accurate re. primary
      title('Accurate - Choice error', 'FontSize',9)
      imagesc(tPlot-3500, BIN_DIR, sdf_Acc_Err(1:NUM_DIR,:), cLim);
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks(BIN_DIR); yticklabels(yTickLabel)
      xlabel('Time from primary saccade (ms)')
      ylabel('Primary saccade direction (deg)')
      
      subplot(2,2,4); hold on %Accurate re. second
      title('Accurate - Choice error', 'FontSize',9)
      imagesc(tPlot-3500, BIN_DIR, sdf_Acc_Err(NUM_DIR+1:end,:), cLim);
      colorbar('location','east', 'Color','w')
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks([])
      xlabel('Time from second saccade (ms)')
      ylabel('Second saccade direction (deg)')
      
      ppretty([11,7])
      
    case 'difference'
      %% Plot: Difference in activation between error and correct trials
      %normalize to the maximum firing rate across all groups
      sdfAll = [sdf_Fast_Corr sdf_Fast_Err sdf_Acc_Corr sdf_Acc_Err];
      maxFR = max(sdfAll,[],'all');
      
      sdf_Fast_Diff = (sdf_Fast_Err(1:NUM_DIR,:) - sdf_Fast_Corr(NUM_DIR+1:end,:)) / maxFR;
      sdf_Acc_Diff = (sdf_Acc_Err(1:NUM_DIR,:) - sdf_Acc_Corr(NUM_DIR+1:end,:)) / maxFR;
      
      cLim = [-1 1];
      
      subplot(2,1,1); hold on %Fast re. primary
      title('Fast - Difference (Error - Correct)', 'FontSize',9)
      imagesc(tPlot-3500, BIN_DIR, sdf_Fast_Diff(1:NUM_DIR,:), cLim);
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks(BIN_DIR); yticklabels(yTickLabel)
      
      subplot(2,1,2); hold on %Accurate re. primary
      title('Accurate - Difference (Error - Correct)', 'FontSize',9)
      imagesc(tPlot-3500, BIN_DIR, sdf_Acc_Diff(1:NUM_DIR,:), cLim);
      colorbar('location','east', 'Color','w')
      plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
      xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
      yticks(BIN_DIR); yticklabels(yTickLabel)
      xlabel('Time from primary saccade (ms)')
      ylabel('Primary saccade direction (deg)')
      
      ppretty([6,8])
      
  end
  
  pause(0.1); print([PRINTDIR,unitData.Properties.RowNames{uu},'-',unitData.aArea{uu},'.tif'], '-dtiff')
  pause(0.1); close(); pause(0.1)
  
end%for:cells(cc)

end%fxn:plot_SDF_X_Dir_Heatmap()
