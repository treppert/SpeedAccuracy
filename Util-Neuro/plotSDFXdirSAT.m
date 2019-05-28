function [  ] = plotSDFXdirSAT( binfo , moves , ninfo , spikes , varargin )
%plotSDFXdirSAT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});
ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\SEF_SAT\Figs\1-Classification\SDFXdir-SAT\';

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

ninfo = ninfo(idxArea & idxMonkey);
spikes = spikes(idxArea & idxMonkey);

NUM_CELLS = length(spikes);
T_STIM = 3500 + (-400 : 400);
T_RESP = 3500 + (-400 : 400);

IDX_STIM_PLOT = [11, 5, 3, 1, 7, 13, 15, 17];
IDX_RESP_PLOT = IDX_STIM_PLOT + 1;

for cc = 1:NUM_CELLS
  fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  kk = ismember({binfo.session}, ninfo(cc).sess);
  RTkk = double(moves(kk).resptime);
  
  %compute spike density function and align on primary response
  sdfKKstim = compute_spike_density_fxn(spikes(cc).SAT);
  sdfKKresp = align_signal_on_response(sdfKKstim, RTkk); 
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials, 'task','SAT');
  %index by condition
  idxAcc = ((binfo(kk).condition == 1) & ~idxIso);
  idxFast = ((binfo(kk).condition == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold | binfo(kk).err_nosacc);
  
  %initializations
  sdfAccStim = NaN(8,length(T_STIM));
  sdfAccResp = NaN(8,length(T_STIM));
  sdfFastStim = NaN(8,length(T_STIM));
  sdfFastResp = NaN(8,length(T_STIM));
  RTAcc = NaN(1,8);
  RTFast = NaN(1,8);
  for dd = 1:8 %loop over response directions
    idxDir = (moves(kk).octant == dd);
    sdfAccStim(dd,:) = nanmean(sdfKKstim(idxAcc & idxCorr & idxDir, T_STIM));
    sdfAccResp(dd,:) = nanmean(sdfKKresp(idxAcc & idxCorr & idxDir, T_RESP));
    sdfFastStim(dd,:) = nanmean(sdfKKstim(idxFast & idxCorr & idxDir, T_STIM));
    sdfFastResp(dd,:) = nanmean(sdfKKresp(idxFast & idxCorr & idxDir, T_RESP));
    RTAcc(dd) = median(RTkk(idxAcc & idxCorr & idxDir));
    RTFast(dd) = median(RTkk(idxFast & idxCorr & idxDir));
  end%for:direction(dd)
  
  %% Plotting
  sdfAll = [sdfAccStim sdfAccResp sdfFastStim sdfFastResp];
  figure();  yLim = [min(min(sdfAll)) max(max(sdfAll))];
  
  for dd = 1:8 %loop over directions and plot
    
    %plot from array
    subplot(3,6,IDX_STIM_PLOT(dd)); hold on
    plot([0 0], yLim, 'k-')
    plot(RTAcc(dd)*ones(1,2), yLim, 'r:')
    plot(RTFast(dd)*ones(1,2), yLim, ':', 'Color',[0 .7 0])
    plot(T_STIM-3500, sdfAccStim(dd,:), 'r-');
    plot(T_STIM-3500, sdfFastStim(dd,:), '-', 'Color',[0 .7 0]);
    
    xlim([T_STIM(1) T_STIM(end)]-3500)
    xticks((T_STIM(1) : 200 : T_STIM(end)) - 3500)
    
    if (IDX_STIM_PLOT(dd) == 7)
      ylabel('Activity (sp/sec)');  xticklabels([])
    elseif (IDX_STIM_PLOT(dd) == 15)
      xlabel('Time from array (ms)');  yticklabels([])
      print_session_unit(gca , ninfo(cc), binfo(kk), 'horizontal')
    else
      xticklabels([]);  yticklabels([])
    end
    
    %plot from response
    subplot(3,6,IDX_RESP_PLOT(dd)); hold on
    plot([0 0], yLim, 'k-')
    plot(-RTAcc(dd)*ones(1,2), yLim, 'r:')
    plot(-RTFast(dd)*ones(1,2), yLim, ':', 'Color',[0 .7 0])
    plot(T_RESP-3500, sdfAccResp(dd,:), 'r-');
    plot(T_RESP-3500, sdfFastResp(dd,:), '-', 'Color',[0 .7 0]);
    
    xlim([T_RESP(1) T_RESP(end)]-3500)
    xticks((T_RESP(1) : 200 : T_RESP(end)) - 3500)
    set(gca, 'YAxisLocation','right')
    
    if (IDX_RESP_PLOT(dd) == 16)
      xlabel('Time from response (ms)');  yticklabels([])
      print_session_unit(gca , ninfo(cc), binfo(kk), 'horizontal')
    else
      xticklabels([]);  yticklabels([])
    end
    
    pause(.05)
  end%for:direction(dd)
  
  ppretty([16,8])
  pause(0.1); print([ROOTDIR, ninfo(cc).sess,'-',ninfo(cc).unit,'.tif'], '-dtiff')
  pause(0.1); close(); pause(0.1)
  
end%for:cells(cc)

end%fxn:plotSDFXdirSAT()
