function [  ] = plotSDFChoiceErrXdirSAT( behavData , unitData , spikesSAT )
%plotSDFChoiceErrXdirSAT() Summary of this function goes here
%   Detailed explanation goes here

idxSEF = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});
idxErr = (unitData.Basic_ErrGrade >= 2);

idxKeep = (idxSEF & idxMonkey & idxErr);

NUM_CELLS = sum(idxKeep);
unitData = unitData(idxKeep,:);
spikesSAT = spikesSAT(idxKeep);

T_PRIMARY = 3500 + (-200 : 400); %time from primary saccade
% T_SECOND  = 3500 + (-200 : 400); %time from secondary saccade

IDX_DD_PLOT = [6, 3, 2, 1, 4, 7, 8, 9];

for cc = 1:NUM_CELLS
  kk = ismember(behavData.Task_Session, unitData.Task_Session(cc));
  
  RTPkk = double(behavData.Sacc_RT{kk}); %RT of primary saccade
  RTPkk(RTPkk > 900) = NaN; %hard limit on primary RT
  RTSkk = double(behavData.Sacc2_RT{kk}) - RTPkk; %RT of second saccade
  RTSkk(RTSkk < 0) = NaN; %trials with no secondary saccade
  
  %compute spike density function and align on primary response
  sdfKK = compute_spike_density_fxn(spikesSAT{cc});
  sdfKK = align_signal_on_response(sdfKK, RTPkk); 
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData.Task_TrialRemoveSAT{cc}, behavData.Task_NumTrials(kk));
  %index by condition
  idxFast = (behavData.Task_SATCondition{kk} == 3) & ~idxIso;
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  idxErr = (behavData.Task_ErrChoice{kk} & ~behavData.Task_ErrTime{kk});
  
  %initializations
  sdf.corr.P = NaN(8,length(T_PRIMARY));    sdf.err.P = NaN(8,length(T_PRIMARY));
  isiXdir = NaN(1,8);
  
  for dd = 1:8 %loop over response directions
    %index this direction
    idxDD = (behavData.Task_TgtOctant{kk} == dd);
    %compute median RT
    isiXdir(dd) = median(RTSkk(idxFast & idxErr & idxDD));
    %compute SDFs
    sdf.corr.P(dd,:) = nanmean(sdfKK(idxFast & idxCorr & idxDD, T_PRIMARY));
    sdf.err.P(dd,:)  = nanmean(sdfKK(idxFast & idxErr & idxDD, T_PRIMARY));
  end%for:direction(dd)
  
  %% Plotting - Individual neurons
  figure()
  
  tmp = [sdf.corr.P sdf.err.P];
  yLim = [min(min(tmp)) max(max(tmp))];
  
  for dd = 1:8
    subplot(3,3,IDX_DD_PLOT(dd)); hold on
    
    plot([0 0], yLim, 'k-', 'LineWidth',1.0)
    plot(isiXdir(dd)*ones(1,2), yLim, 'k--')
    
    plot(T_PRIMARY-3500, sdf.corr.P(dd,:), '-', 'Color',[0 .7 0], 'LineWidth',1.25);
    plot(T_PRIMARY-3500, sdf.err.P(dd,:), ':', 'Color',[0 .7 0], 'LineWidth',1.25);
    
    plot(unitData.ChoiceErrorSignal_Time(cc,3)*ones(1,2), yLim, '-.', 'Color',[0 .7 0], 'LineWidth',1.0)
    plot(unitData.ChoiceErrorSignal_Time(cc,4)*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
    
    if (IDX_DD_PLOT(dd) == 4)
      ylabel('Activity (sp/sec)')
      xticklabels([])
    elseif (IDX_DD_PLOT(dd) == 8)
      xlabel('Time from response (ms)')
      yticklabels([])
      legend({'','2ndSacc','Corr','Err','Start','End'}, 'Location','northoutside', 'Orientation','horizontal')
    else
      xticklabels([])
      yticklabels([])
    end
    
    xlim([T_PRIMARY(1) T_PRIMARY(end)]-3500)
    xticks((T_PRIMARY(1) : 200 : T_PRIMARY(end)) - 3500)
    
    pause(.05)
  end%for:direction(dd)
  
  subplot(3,3,5); xticks([]); yticks([]); print_session_unit(gca , unitData(cc,:), behavData(kk,:), 'horizontal')
  ppretty([10,7])
  pause(0.1); print(['C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\__SEF_SAT\Data\Figs_ChoiceErrorSignal\', ...
    unitData.aArea{cc},'-',unitData.Properties.RowNames{cc},'.tif'], '-dtiff')
  pause(0.1); close()
  
end%for:cells(cc)

end%fxn:plotSDFChoiceErrXdirSAT()
