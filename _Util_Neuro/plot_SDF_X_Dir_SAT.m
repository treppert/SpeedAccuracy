function [  ] = plot_SDF_X_Dir_SAT( behavData , unitData , spikesSAT , varargin )
%plot_SDF_X_Dir_SAT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=',{'FEF','SC','SEF'}}, {'monkey=',{'D','E'}}});
PRINTDIR = 'C:\Users\Tom\Dropbox\Speed Accuracy\__SEF_SAT\Figs\SDF_X_Dir_SAT\';

idxArea = ismember(unitData.aArea, args.area);
idxMonkey = ismember(unitData.aMonkey, args.monkey);

unitData = unitData(idxArea & idxMonkey, :); %table
spikesSAT = spikesSAT(idxArea & idxMonkey); %cell array

NUM_CELLS = length(spikesSAT);
T_STIM = 3500 + (-200 : 400);
T_RESP = 3500 + (-400 : 200);

IDX_STIM_PLOT = [11, 5, 3, 1, 7, 13, 15, 17];
IDX_RESP_PLOT = IDX_STIM_PLOT + 1;

for uu = 1:NUM_CELLS
  fprintf('%s - %s\n', unitData.Task_Session{uu}, unitData.aID{uu})
  kk = ismember(behavData.Task_Session, unitData.Task_Session{uu});
  RTkk = double(behavData.Sacc_RT{kk});
  
  %compute spike density function and align on primary response
  sdfKKstim = compute_spike_density_fxn(spikesSAT{uu});
  sdfKKresp = align_signal_on_response(sdfKKstim, RTkk); 
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  
  %initializations
  sdf_AccStim = NaN(8,length(T_STIM));
  sdf_AccResp = NaN(8,length(T_STIM));
  sdf_FastStim = NaN(8,length(T_STIM));
  sdf_FastResp = NaN(8,length(T_STIM));
  RT_Acc = NaN(1,8);
  RT_Fast = NaN(1,8);
  for dd = 1:8 %loop over response directions
    idxDir = (behavData.Sacc_Octant{kk} == dd);
    sdf_AccStim(dd,:) = nanmean(sdfKKstim(idxAcc & idxCorr & idxDir, T_STIM));
    sdf_AccResp(dd,:) = nanmean(sdfKKresp(idxAcc & idxCorr & idxDir, T_RESP));
    sdf_FastStim(dd,:) = nanmean(sdfKKstim(idxFast & idxCorr & idxDir, T_STIM));
    sdf_FastResp(dd,:) = nanmean(sdfKKresp(idxFast & idxCorr & idxDir, T_RESP));
    RT_Acc(dd) = median(RTkk(idxAcc & idxCorr & idxDir));
    RT_Fast(dd) = median(RTkk(idxFast & idxCorr & idxDir));
  end%for:direction(dd)
  
  %% Plotting
  sdfAll = [sdf_AccStim sdf_AccResp sdf_FastStim sdf_FastResp];
  figure('visible','off');  yLim = [min(min(sdfAll)) max(max(sdfAll))];
  
  for dd = 1:8 %loop over directions and plot
    
    %% Plot from ARRAY
    subplot(3,6,IDX_STIM_PLOT(dd)); hold on
    plot([0 0], yLim, 'k:')
    plot(RT_Acc(dd)*ones(1,2), yLim, 'r:')
    plot(RT_Fast(dd)*ones(1,2), yLim, ':', 'Color',[0 .7 0])
    plot(T_STIM-3500, sdf_AccStim(dd,:), 'r-');
    plot(T_STIM-3500, sdf_FastStim(dd,:), '-', 'Color',[0 .7 0]);
    
    xlim([T_STIM(1) T_STIM(end)]-3500)
    xticks((T_STIM(1) : 200 : T_STIM(end)) - 3500)
    
    if (IDX_STIM_PLOT(dd) == 7)
      ylabel('Activity (sp/sec)');  xticklabels([])
    elseif (IDX_STIM_PLOT(dd) == 13)
      xlabel('Time from array (ms)');  yticklabels([])
      print_session_unit(gca , unitData(uu,:), behavData(kk,:))
    else
      xticklabels([]);  yticklabels([])
    end
    
    %% Plot from RESPONSE
    subplot(3,6,IDX_RESP_PLOT(dd)); hold on
    plot([0 0], yLim, 'k:')
    plot(-RT_Acc(dd)*ones(1,2), yLim, 'r:')
    plot(-RT_Fast(dd)*ones(1,2), yLim, ':', 'Color',[0 .7 0])
    plot(T_RESP-3500, sdf_AccResp(dd,:), 'r-');
    plot(T_RESP-3500, sdf_FastResp(dd,:), '-', 'Color',[0 .7 0]);
    
    xlim([T_RESP(1) T_RESP(end)]-3500)
    xticks((T_RESP(1) : 200 : T_RESP(end)) - 3500)
    set(gca, 'YAxisLocation','right')
    
    if (IDX_RESP_PLOT(dd) == 14)
      xlabel('Time from response (ms)');  yticklabels([])
    else
      xticklabels([]);  yticklabels([])
    end
    
    pause(.05)
  end%for:direction(dd)
  
  ppretty([12,6])
  pause(0.1); print([PRINTDIR, unitData.Task_Session{uu},'-',unitData.aID{uu},'.tif'], '-dtiff')
  pause(0.1); close(); pause(0.1)
  
end%for:cells(uu)

end%fxn:plotSDFXdirSAT()
