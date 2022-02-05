function [  ] = plot_SDF_ChcErr_X_Dir_SAT( behavData , unitData , spikesSAT )
%plot_SDF_ChcErr_X_Dir_SAT() Summary of this function goes here
%   Detailed explanation goes here

PRINTDIR = 'C:\Users\Tom\Documents\Figs - SAT\';

idxArea = ismember(unitData.aArea, {'SC'});
idxMonkey = ismember(unitData.aMonkey, {'E'});
idxErrUnit = (unitData.Grade_Err >= 2);
idxKeep = (idxArea & idxMonkey);

NUM_CELLS = sum(idxKeep);
unitData = unitData(idxKeep,:);
spikesSAT = spikesSAT(idxKeep);

tPlot = 3500 + (-200 : 400); %plot time vector
NUM_SAMP = length(tPlot);

RT_MAX = 900; %hard ceiling on primary RT
IDX_SACC1_PLOT = [11, 5, 3, 1, 7, 13, 15, 17]; %indexes for each plot
IDX_SACC2_PLOT = IDX_SACC1_PLOT + 1;

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
  sdf_Fast_Corr = NaN(16, NUM_SAMP); %index 1-8: sdf re. primary | index 9-16: sdf re. second
  sdf_Fast_Err = sdf_Fast_Corr;
  sdf_Acc_Corr = sdf_Fast_Corr;
  sdf_Acc_Err = sdf_Fast_Corr;
  med_ISI = NaN(2,8); %median inter-saccade interval (Fast;Acc)
  
  for dd = 1:8 %loop over directions
    %index by direction
    idxDD = (behavData.Task_TgtOctant{kk} == dd); %target direction
    idxDD = (behavData.Sacc2_{kk} == dd); %second saccade direction
    %compute median inter-saccade interval
    med_ISI(1,dd) = nanmedian(ISI_kk(idxFast & idxErrChc & idxDD));
    med_ISI(2,dd) = nanmedian(ISI_kk(idxAcc  & idxErrChc & idxDD));
    %compute SDFs
    sdf_Fast_Corr(dd,:) = nanmean(sdfP_kk(idxFast & idxCorr & idxDD, tPlot)); %re. primary
    sdf_Fast_Corr(dd+8,:) = nanmean(sdfS_kk(idxFast & idxCorr & idxDD, tPlot)); %re. second
    sdf_Fast_Err(dd,:) = nanmean(sdfP_kk(idxFast & idxErrChc & idxDD, tPlot));
    sdf_Fast_Err(dd+8,:) = nanmean(sdfS_kk(idxFast & idxErrChc & idxDD, tPlot));
    sdf_Acc_Corr(dd,:) = nanmean(sdfP_kk(idxAcc & idxCorr & idxDD, tPlot));
    sdf_Acc_Corr(dd+8,:) = nanmean(sdfS_kk(idxAcc & idxCorr & idxDD, tPlot));
    sdf_Acc_Err(dd,:) = nanmean(sdfP_kk(idxAcc & idxErrChc & idxDD, tPlot));
    sdf_Acc_Err(dd+8,:) = nanmean(sdfS_kk(idxAcc & idxErrChc & idxDD, tPlot));
  end%for:direction(dd)
  
  %% Plotting
  sdfAll = [sdf_Fast_Corr sdf_Fast_Err sdf_Acc_Corr sdf_Acc_Err];
  yLim = [min(min(min(sdfAll))) max(max(max(sdfAll)))];
  figure('visible','off');
  
  %color-code plot axes by neuron functional type and response field
  colorAxis = ['k','k','k','k','k','k','k','k'];
  if ((abs(unitData.Grade_Vis(cc)) >= 3) && (unitData.Grade_Mov(cc) >= 3))
    colorAxis(unitData.Field_Vis{cc}) = 'b';
  elseif (abs(unitData.Grade_Vis(cc)) >= 3)
    colorAxis(unitData.Field_Vis{cc}) = 'm';
  elseif (unitData.Grade_Mov(cc) >= 3)
    colorAxis(unitData.Field_Vis{cc}) = 'm';
  end
  
  for dd = 1:8 %loop over directions and plot
    
    %% Plot from PRIMARY SACCADE
    subplot(3,6,IDX_SACC1_PLOT(dd)); hold on
    set(gca, 'XColor',colorAxis(dd)); set(gca, 'YColor',colorAxis(dd))
    plot([0 0], yLim, 'k:')
    plot(med_ISI(1,dd)*ones(1,2), yLim, ':', 'Color',[0 .7 0])
    plot(med_ISI(2,dd)*ones(1,2), yLim, 'r:')
    plot(tPlot-3500, sdf_Fast_Corr(dd,:), '-', 'Color',[0 .7 0]);
    plot(tPlot-3500, sdf_Acc_Corr(dd,:), 'r-');
    plot(tPlot-3500, sdf_Fast_Err(dd,:), ':', 'Color',[0 .7 0]);
    plot(tPlot-3500, sdf_Acc_Err(dd,:), 'r:');
    
    xlim([tPlot(1) tPlot(end)]-3500)
    xticks((tPlot(1) : 200 : tPlot(end)) - 3500)
    
    if (IDX_SACC1_PLOT(dd) == 7)
      ylabel('Activity (sp/sec)');  xticklabels([])
    elseif (IDX_SACC1_PLOT(dd) == 13)
      xlabel('Time from primary (ms)');  yticklabels([])
      print_session_unit(gca , unitData(cc,:), behavData(kk,:))
    else
      xticklabels([]);  yticklabels([])
    end
    
    %% Plot from SECOND SACCADE
    subplot(3,6,IDX_SACC2_PLOT(dd)); hold on
    set(gca, 'XColor',colorAxis(dd)); set(gca, 'YColor',colorAxis(dd))
    plot([0 0], yLim, 'k:')
    plot(-med_ISI(1,dd)*ones(1,2), yLim, ':', 'Color',[0 .7 0])
    plot(-med_ISI(2,dd)*ones(1,2), yLim, 'r:')
%     plot(tPlot-3500, sdf_Fast_Corr(dd+8,:), '-', 'Color',[0 .7 0]);
%     plot(tPlot-3500, sdf_Acc_Corr(dd+8,:), 'r-');
    plot(tPlot-3500, sdf_Fast_Err(dd+8,:), ':', 'Color',[0 .7 0]);
    plot(tPlot-3500, sdf_Acc_Err(dd+8,:), 'r:');
    
    xlim([tPlot(1) tPlot(end)]-3500)
    xticks((tPlot(1) : 200 : tPlot(end)) - 3500)
    set(gca, 'YAxisLocation','right')
    
    if (IDX_SACC2_PLOT(dd) == 14)
      xlabel('Time from second (ms)');  yticklabels([])
    else
      xticklabels([]);  yticklabels([])
    end
    
  end%for:direction(dd)
  
  ppretty([12,6])
  pause(0.1); print([PRINTDIR,unitData.Properties.RowNames{cc},'-',unitData.aArea{cc},'.tif'], '-dtiff')
  pause(0.1); close(); pause(0.1)
  
end%for:cells(cc)

end%fxn:plot_SDF_ChcErr_X_Dir_SAT()
