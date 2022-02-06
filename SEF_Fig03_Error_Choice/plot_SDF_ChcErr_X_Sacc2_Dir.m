function [  ] = plot_SDF_ChcErr_X_Sacc2_Dir( behavData , unitData , spikesSAT )
%plot_SDF_ChcErr_X_Sacc2_Dir() Summary of this function goes here
%   Detailed explanation goes here

PRINTDIR = 'C:\Users\Tom\Documents\Figs - SAT\';

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'E'});
idxErrUnit = (unitData.Grade_Err >= 2);
idxKeep = (idxArea & idxMonkey);

NUM_CELLS = sum(idxKeep);
unitData = unitData(idxKeep,:);
spikesSAT = spikesSAT(idxKeep);

tPlot = 3500 + (-200 : 400); %plot time vector
NUM_SAMP = length(tPlot);

RT_MAX = 900; %hard ceiling on primary RT

NUM_DIR = 17; %binning by saccade direction for heatmap
BIN_DIR = linspace(-pi, pi, NUM_DIR);
H_DIFF_DIR = diff(BIN_DIR([1,2]))/2;

for cc = 1:NUM_CELLS
  fprintf('%s \n', unitData.Properties.RowNames{cc})
  kk = ismember(behavData.Task_Session, unitData.Task_Session(cc));
  
  RTP_kk = double(behavData.Sacc_RT{kk}); %RT of primary saccade
  RTP_kk(RTP_kk > RT_MAX) = NaN; %hard limit on primary RT
  
  RTS_kk = double(behavData.Sacc2_RT{kk}); %Time of second re. array
  RTS_kk(RTS_kk == 0) = NaN; %trials with no second saccade
  
  ISI_kk = RTS_kk - RTP_kk; %inter-saccade interval
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData.Task_TrialRemoveSAT{cc}, behavData.Task_NumTrials(kk));
  %index by condition
  idxFast = (behavData.Task_SATCondition{kk} == 3 & ~idxIso);
  idxAcc = (behavData.Task_SATCondition{kk} == 1 & ~idxIso);
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  idxErrChc = (behavData.Task_ErrChoice{kk} & ~behavData.Task_ErrTime{kk});
  
  %compute spike density function and align on primary response
  sdf_kk = compute_spike_density_fxn(spikesSAT{cc});
  sdfP_kk = align_signal_on_response(sdf_kk, RTP_kk); %sdf from primary
  sdfS_kk = align_signal_on_response(sdf_kk, RTS_kk); %sdf from second
  
  %initializations
  sdf_Fast_Corr = NaN(2*NUM_DIR, NUM_SAMP); %index 1-8: sdf re. primary | index 9-16: sdf re. second
  sdf_Fast_Err = sdf_Fast_Corr;
  sdf_Acc_Corr = sdf_Fast_Corr;
  sdf_Acc_Err = sdf_Fast_Corr;
  med_ISI = NaN(2,8); %median inter-saccade interval (Fast;Acc)
  
  Sacc2_Direction = behavData.Sacc2_Direction{kk};
  Sacc1_Direction = behavData.Sacc_Direction{kk};
  for dd = 1:NUM_DIR %loop over directions
    %index by direction
    if ((dd == 1) || (dd == NUM_DIR))
      binLimDD = [(BIN_DIR(1)+H_DIFF_DIR) , (BIN_DIR(end)-H_DIFF_DIR) ];
      idxDD = transpose((Sacc2_Direction < binLimDD(1) | Sacc2_Direction > binLimDD(2)));
%       idxDD = transpose((Sacc1_Direction < binLimDD(1) | Sacc1_Direction > binLimDD(2)));
    else
      binLimDD = [(BIN_DIR(dd)-H_DIFF_DIR) , (BIN_DIR(dd)+H_DIFF_DIR) ];
      idxDD = transpose((Sacc2_Direction > binLimDD(1) & Sacc2_Direction < binLimDD(2)));
%       idxDD = transpose((Sacc1_Direction > binLimDD(1) & Sacc1_Direction < binLimDD(2)));
    end
    %compute median inter-saccade interval
    med_ISI(1,dd) = nanmedian(ISI_kk(idxFast & idxErrChc & idxDD));
    med_ISI(2,dd) = nanmedian(ISI_kk(idxAcc  & idxErrChc & idxDD));
    %compute SDFs
    sdf_Fast_Corr(dd,:) = nanmean(sdfP_kk(idxFast & idxCorr & idxDD, tPlot)); %re. primary
    sdf_Fast_Err(dd,:) = nanmean(sdfP_kk(idxFast & idxErrChc & idxDD, tPlot));
    sdf_Fast_Err(dd+NUM_DIR,:) = nanmean(sdfS_kk(idxFast & idxErrChc & idxDD, tPlot));
    sdf_Acc_Corr(dd,:) = nanmean(sdfP_kk(idxAcc & idxCorr & idxDD, tPlot));
    sdf_Acc_Err(dd,:) = nanmean(sdfP_kk(idxAcc & idxErrChc & idxDD, tPlot));
    sdf_Acc_Err(dd+NUM_DIR,:) = nanmean(sdfS_kk(idxAcc & idxErrChc & idxDD, tPlot));
  end%for:direction(dd)
  
  %% Plotting
  sdfAll = [sdf_Fast_Corr sdf_Fast_Err sdf_Acc_Corr sdf_Acc_Err];
  cLim = [min(min(min(sdfAll))) max(max(max(sdfAll)))];
  figure('visible','off')
  yTickLabel = num2cell(rad2deg(BIN_DIR));
  yTickLabel(2:2:end) = {''};
  
  subplot(2,2,1); hold on %Fast re. primary
  title('Fast - Choice error', 'FontSize',9)
  imagesc(tPlot-3500, BIN_DIR, sdf_Fast_Err(1:NUM_DIR,:), cLim);
  plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
  plot(med_ISI(1,dd)*ones(1,2), [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.2)
  xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
  yticks(BIN_DIR); yticklabels(yTickLabel)
  ylabel('Second saccade direction (deg)')
%   ylabel('Primary saccade direction (deg)')
  
  subplot(2,2,2); hold on %Fast re. second
  title('Fast - Choice error', 'FontSize',9)
  imagesc(tPlot-3500, BIN_DIR, sdf_Fast_Err(NUM_DIR+1:end,:), cLim);
  plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
  plot(-med_ISI(1,dd)*ones(1,2), [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.2)
  xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
  set(gca, 'YAxisLocation','right'); yticks([])
  
  subplot(2,2,3); hold on %Accurate re. primary
  title('Accurate - Choice error', 'FontSize',9)
  imagesc(tPlot-3500, BIN_DIR, sdf_Acc_Err(1:NUM_DIR,:), cLim);
  plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
  plot(med_ISI(2,dd)*ones(1,2), [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.2)
  xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
  yticks(BIN_DIR); yticklabels(yTickLabel)
  xlabel('Time from primary saccade(ms)')
  ylabel('Second saccade direction (deg)')
%   ylabel('Primary saccade direction (deg)')
  
  subplot(2,2,4); hold on %Accurate re. second
  title('Accurate - Choice error', 'FontSize',9)
  imagesc(tPlot-3500, BIN_DIR, sdf_Acc_Err(NUM_DIR+1:end,:), cLim)
  colorbar('location','east', 'Color','w')
  plot([0 0], [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.5)
  plot(-med_ISI(2,dd)*ones(1,2), [BIN_DIR(1) BIN_DIR(end)], 'k:', 'LineWidth',1.2)
  xlim(tPlot([1,NUM_SAMP])-3500); ylim(BIN_DIR([1,end]))
  set(gca, 'YAxisLocation','right'); yticks([])
  xlabel('Time from second saccade (ms)')
    
  ppretty([12,8])
  pause(0.1); print([PRINTDIR,unitData.Properties.RowNames{cc},'-',unitData.aArea{cc},'.tif'], '-dtiff')
  pause(0.1); close(); pause(0.1)
  
end%for:cells(cc)

end%fxn:plot_SDF_ChcErr_X_Sacc2_Dir()
