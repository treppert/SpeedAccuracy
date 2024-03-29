function [  ] = plot_SDF_X_Dir_Heatmap_ErrChoice( behavData , unitData , spikesSAT )
%plot_SDF_X_Dir_Heatmap_ErrChoice() Summary of this function goes here
%   Detailed explanation goes here

MIN_TRIAL_COUNT = 3;
PRINTDIR = 'C:\Users\Tom\Documents\Figs - SAT\';

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D'});
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
H_DIFF_DIR = diff(BIN_DIR([1,2]))/2;

for uu = 1:NUM_UNITS
  fprintf('%s \n', unitData.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  
  RTP_kk = behavData.Sacc_RT{kk}; %Primary saccade RT
  RTP_kk(RTP_kk > RT_MAX) = NaN; %hard limit on primary RT
  RTS_kk = behavData.Sacc2_RT{kk}; %Second saccade RT
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
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  idxErr = (behavData.Task_ErrChoice{kk} & ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
%   idxErr = (idxErr & idxShort);
  
  %% Compute SDF heatmaps across all 8 directions
  sdf_Fast_Corr = NaN(3*NUM_DIR, NUM_SAMP); %sdf re. array | sdf re. primary | sdf re. second
  sdf_Acc_Corr = sdf_Fast_Corr;
  sdf_Fast_Err = sdf_Fast_Corr;
  sdf_Acc_Err = sdf_Fast_Corr;
  
  Dir_Sacc1 = behavData.Sacc_Direction{kk};
  Dir_Sacc2 = behavData.Sacc2_Direction{kk};
  
  for dd = 1:NUM_DIR
    %index by direction
    if ((dd == 1) || (dd == NUM_DIR))
      binLimDD = [(BIN_DIR(1)+H_DIFF_DIR) , (BIN_DIR(end)-H_DIFF_DIR) ];
      idxDD1 = (Dir_Sacc1 < binLimDD(1) | Dir_Sacc1 > binLimDD(2));
      idxDD2 = (Dir_Sacc2 < binLimDD(1) | Dir_Sacc2 > binLimDD(2));
    else
      binLimDD = [(BIN_DIR(dd)-H_DIFF_DIR) , (BIN_DIR(dd)+H_DIFF_DIR) ];
      idxDD1 = (Dir_Sacc1 > binLimDD(1) & Dir_Sacc1 < binLimDD(2));
      idxDD2 = (Dir_Sacc2 > binLimDD(1) & Dir_Sacc2 < binLimDD(2));
    end
    
    %compute SDFs - Correct trial outcome
    sdf_Fast_Corr(dd,:) = nanmean(sdfA_kk(idxFast & idxCorr & idxDD1, tPlot)); %re. array
    sdf_Fast_Corr(dd+NUM_DIR,:) = nanmean(sdfP_kk(idxFast & idxCorr & idxDD1, tPlot)); %re. primary
    sdf_Acc_Corr(dd,:) = nanmean(sdfA_kk(idxAcc & idxCorr & idxDD1, tPlot)); %re. array
    sdf_Acc_Corr(dd+NUM_DIR,:) = nanmean(sdfP_kk(idxAcc & idxCorr & idxDD1, tPlot)); %re. primary
    
    %compute SDFs - Error trial outcome
    if (sum(idxFast & idxErr & idxDD1) >= MIN_TRIAL_COUNT)
      sdf_Fast_Err(dd,:) = nanmean(sdfA_kk(idxFast & idxErr & idxDD1, tPlot)); %re. array
      sdf_Fast_Err(dd+NUM_DIR,:) = nanmean(sdfP_kk(idxFast & idxErr & idxDD1, tPlot)); %re. primary
    end
    if (sum(idxFast & idxErr & idxDD2) >= MIN_TRIAL_COUNT)
      sdf_Fast_Err(dd+2*NUM_DIR,:) = nanmean(sdfS_kk(idxFast & idxErr & idxDD2, tPlot)); %re. second
    end
    if (sum(idxAcc & idxErr & idxDD1) >= MIN_TRIAL_COUNT)
      sdf_Acc_Err(dd,:) = nanmean(sdfA_kk(idxAcc & idxErr & idxDD1, tPlot)); %re. array
      sdf_Acc_Err(dd+NUM_DIR,:) = nanmean(sdfP_kk(idxAcc & idxErr & idxDD1, tPlot)); %re. primary
    end
    if (sum(idxAcc & idxErr & idxDD2) >= MIN_TRIAL_COUNT)
      sdf_Acc_Err(dd+2*NUM_DIR,:) = nanmean(sdfS_kk(idxAcc & idxErr & idxDD2, tPlot)); %re. second
    end
  end%for:direction(dd)
  
  hFig = figure('visible','on');
  yTickLabel = num2cell(rad2deg(BIN_DIR));
  yTickLabel(2:2:end) = {''};
  
  %% Plot of heatmap: Correct, error and difference plots
  sdfAll = [sdf_Fast_Corr sdf_Fast_Err sdf_Acc_Corr sdf_Acc_Err];
  maxFR = max(sdfAll,[],'all');

  sdf_Fast_Diff = (sdf_Fast_Err(NUM_DIR+(1:NUM_DIR),:) - sdf_Fast_Corr(NUM_DIR+(1:NUM_DIR),:)) / maxFR;
  sdf_Acc_Diff = (sdf_Acc_Err(NUM_DIR+(1:NUM_DIR),:) - sdf_Acc_Corr(NUM_DIR+(1:NUM_DIR),:)) / maxFR;

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

  subplot(4,3,3); hold on %Fast: Diff plot - Error vs correct re. primary
  title('Fast - Difference', 'FontSize',9)
  imagesc(tPlot-3500, BIN_DIR, sdf_Fast_Diff, cLimDiff);
  plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end])); set(gca, 'XColor',[0 0 .9])
  yticks([]); set(gca, 'YColor',[0 0 .9])

  subplot(4,3,4); hold on %Fast re. array
  imagesc(tPlot-3500, BIN_DIR, sdf_Fast_Err(1:NUM_DIR,:), cLim);
  plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
  yticks(BIN_DIR); yticklabels(yTickLabel)

  subplot(4,3,5); hold on %Fast re. primary
  title('Fast - Choice error', 'FontSize',9)
  imagesc(tPlot-3500, BIN_DIR, sdf_Fast_Err(NUM_DIR+(1:NUM_DIR),:), cLim);
  plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
  yticks([])

  subplot(4,3,6); hold on %Accurate: Diff plot - Error vs correct re. primary
  title('Accurate - Difference', 'FontSize',9)
  imagesc(tPlot-3500, BIN_DIR, sdf_Acc_Diff, cLimDiff);
  colorbar('location','east', 'Color','w')
  plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end])); set(gca, 'XColor',[0 0 .9])
  yticks(BIN_DIR); yticklabels(yTickLabel); set(gca, 'YColor',[0 0 .9])
  xlabel('Time from primary saccade (ms)')
  ylabel('Primary saccade direction (deg)')

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

  subplot(4,3,10); hold on %Accurate re. array
  imagesc(tPlot-3500, BIN_DIR, sdf_Acc_Err(1:NUM_DIR,:), cLim);
  plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
  yticks(BIN_DIR); yticklabels(yTickLabel)
  xlabel('Time from array (ms)')
  ylabel('Primary saccade direction (deg)')

  subplot(4,3,11); hold on %Accurate re. primary
  title('Accurate - Choice error', 'FontSize',9)
  imagesc(tPlot-3500, BIN_DIR, sdf_Acc_Err(NUM_DIR+(1:NUM_DIR),:), cLim);
  plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
  yticks([])
  xlabel('Time from primary saccade (ms)')

  subplot(4,3,9); hold on %Fast re. second
  title('Fast - Choice error', 'FontSize',9)
  imagesc(tPlot-3500, BIN_DIR, sdf_Fast_Err(2*NUM_DIR+(1:NUM_DIR),:), cLim);
  plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
  yticks([])
  set(gca, 'XColor',[.8 0 0]); set(gca, 'YColor',[.8 0 0])

  subplot(4,3,12); hold on %Accurate re. second
  title('Accurate - Choice error', 'FontSize',9)
  imagesc(tPlot-3500, BIN_DIR, sdf_Acc_Err(2*NUM_DIR+(1:NUM_DIR),:), cLim);
  colorbar('location','east', 'Color','w')
  plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
  yticks(BIN_DIR); yticklabels(yTickLabel)
  set(gca, 'XColor',[.8 0 0]); set(gca, 'YColor',[.8 0 0])
  xlabel('Time from second saccade (ms)')
  ylabel('Second saccade direction (deg)')

  ppretty([13,11])
  
%   pause(0.1); print([PRINTDIR,unitData.Properties.RowNames{uu},'-',unitData.aArea{uu},'.tif'], '-dtiff')
%   pause(0.1); close(hFig); pause(0.1)
  
end%for:cells(uu)

end%fxn:plot_SDF_X_Dir_Heatmap_ErrChoice()
