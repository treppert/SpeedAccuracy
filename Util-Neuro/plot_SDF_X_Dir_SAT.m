function [  ] = plot_SDF_X_Dir_SAT( binfoSAT , primarySaccade , unitInfo , spikesSAT , varargin )
%plot_SDF_X_Dir_SAT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});
ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\SAT\Figures\SDF-X-Direction\';

idxArea = ismember(unitInfo.area, args.area);
idxMonkey = ismember(unitInfo.monkey, args.monkey);

unitInfo = unitInfo(idxArea & idxMonkey, :); %table
spikesSAT = spikesSAT(idxArea & idxMonkey); %cell array

NUM_CELLS = length(spikesSAT);
T_STIM = 3500 + (-200 : 400);
T_RESP = 3500 + (-400 : 200);

IDX_STIM_PLOT = [11, 5, 3, 1, 7, 13, 15, 17];
IDX_RESP_PLOT = IDX_STIM_PLOT + 1;

for cc = 1:NUM_CELLS
  fprintf('%s - %s\n', unitInfo.sess{cc}, unitInfo.unit{cc})
  kk = ismember(binfoSAT.session, unitInfo.sess{cc});
  RTkk = double(primarySaccade.resptime{kk});
  
  %compute spike density function and align on primary response
  sdfKKstim = compute_spike_density_fxn(spikesSAT{cc});
  sdfKKresp = align_signal_on_response(sdfKKstim, RTkk); 
  
  %index by isolation quality
%   idxIso = identify_trials_poor_isolation_SAT(unitInfo(cc), binfoSAT(kk).num_trials, 'task','SAT');
  %index by condition
  idxAcc = ((binfoSAT.condition{kk} == 1));% & ~idxIso);
  idxFast = ((binfoSAT.condition{kk} == 3));% & ~idxIso);
  %index by trial outcome
  idxCorr = ~(binfoSAT.err_dir{kk} | binfoSAT.err_time{kk} | binfoSAT.err_hold{kk} | binfoSAT.err_nosacc{kk});
  
  %initializations
  sdf_AccStim = NaN(8,length(T_STIM));
  sdf_AccResp = NaN(8,length(T_STIM));
  sdf_FastStim = NaN(8,length(T_STIM));
  sdf_FastResp = NaN(8,length(T_STIM));
  RT_Acc = NaN(1,8);
  RT_Fast = NaN(1,8);
  for dd = 1:8 %loop over response directions
    idxDir = (primarySaccade.octant{kk} == dd);
    sdf_AccStim(dd,:) = nanmean(sdfKKstim(idxAcc & idxCorr & idxDir, T_STIM));
    sdf_AccResp(dd,:) = nanmean(sdfKKresp(idxAcc & idxCorr & idxDir, T_RESP));
    sdf_FastStim(dd,:) = nanmean(sdfKKstim(idxFast & idxCorr & idxDir, T_STIM));
    sdf_FastResp(dd,:) = nanmean(sdfKKresp(idxFast & idxCorr & idxDir, T_RESP));
    RT_Acc(dd) = median(RTkk(idxAcc & idxCorr & idxDir));
    RT_Fast(dd) = median(RTkk(idxFast & idxCorr & idxDir));
  end%for:direction(dd)
  
  %% Plotting
  sdfAll = [sdf_AccStim sdf_AccResp sdf_FastStim sdf_FastResp];
  figure();  yLim = [min(min(sdfAll)) max(max(sdfAll))];
  
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
    elseif (IDX_STIM_PLOT(dd) == 15)
      xlabel('Time from array (ms)');  yticklabels([])
      print_session_unit(gca , unitInfo(cc,:), binfoSAT(kk,:), 'horizontal')
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
    
    if (IDX_RESP_PLOT(dd) == 16)
      xlabel('Time from response (ms)');  yticklabels([])
      print_session_unit(gca , unitInfo(cc,:), binfoSAT(kk,:), 'horizontal')
    else
      xticklabels([]);  yticklabels([])
    end
    
    pause(.05)
  end%for:direction(dd)
  
  ppretty([16,8])
  pause(0.1); print([ROOTDIR, unitInfo.sess{cc},'-',unitInfo.unit{cc},'.tif'], '-dtiff')
  pause(0.1); close(); pause(0.1)
  
end%for:cells(cc)

end%fxn:plotSDFXdirSAT()
