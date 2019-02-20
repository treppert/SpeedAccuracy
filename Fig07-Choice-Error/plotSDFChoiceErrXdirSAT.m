function [  ] = plotSDFChoiceErrXdirSAT( binfo , moves , movesPP , ninfo , spikes , varargin )
%plotSDFChoiceErrXdirSAT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idx_area = ismember({ninfo.area}, args.area);
idx_monkey = ismember({ninfo.monkey}, args.monkey);

ninfo = ninfo(idx_area & idx_monkey);
spikes = spikes(idx_area & idx_monkey);

NUM_CELLS = length(spikes);
T_PLOT  = 3500 + (-400 : 800);

IDX_DD_PLOT = [6, 3, 2, 1, 4, 7, 8, 9];

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  RTkk = double(moves(kk).resptime);
  ISIkk = double(movesPP(kk).resptime) - RTkk;
  
  %compute spike density function and align on primary response
  sdfSess = compute_spike_density_fxn(spikes(cc).SAT);
  sdfSess = align_signal_on_response(sdfSess, RTkk); 
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxFast = ((binfo(kk).condition == 3) & ~idxIso);
  %index by trial outcome
  idxErr = (binfo(kk).err_dir);
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_hold);
  
  %initializations
  sdfCorr = NaN(8,length(T_PLOT));
  sdfErr = NaN(8,length(T_PLOT));
  rtCorr = NaN(1,8);
  rtErr = NaN(1,8);
  isiErr = NaN(1,8);
  
  for dd = 1:8 %loop over response directions
    idxDir = (moves(kk).octant == dd);
    
    sdfCorr(dd,:) = nanmean(sdfSess(idxFast & idxCorr & idxDir, T_PLOT));
    sdfErr(dd,:) = nanmean(sdfSess(idxFast & idxErr & idxDir, T_PLOT));
    rtCorr(dd) = median(RTkk(idxFast & idxCorr & idxDir));
    rtErr(dd) = median(RTkk(idxFast & idxErr & idxDir));
    isiErr(dd) = median(ISIkk(idxFast & idxErr & idxDir));
  end%for:direction(dd)
  
  %% Plotting
  figure()
  
  tmp = [sdfCorr, sdfErr];
  yLim = [min(min(tmp)) max(max(tmp))];
  
  for dd = 1:8
    subplot(3,3,IDX_DD_PLOT(dd)); hold on
    
    plot([0 0], yLim, 'k-', 'LineWidth',1.0)
    plot(-rtCorr(dd)*ones(1,2), yLim, 'k-')
    plot(-rtErr(dd)*ones(1,2), yLim, 'k--')
    plot(isiErr(dd)*ones(1,2), yLim, 'k--')
    
    plot(T_PLOT-3500, sdfCorr(dd,:), '-', 'Color',[0 .7 0], 'LineWidth',1.25);
    plot(T_PLOT-3500, sdfErr(dd,:), '--', 'Color',[0 .7 0], 'LineWidth',1.25);
    
    if (IDX_DD_PLOT(dd) == 4)
      ylabel('Activity (sp/sec)')
      xticklabels([])
    elseif (IDX_DD_PLOT(dd) == 8)
      xlabel('Time from response (ms)')
      yticklabels([])
    else
      xticklabels([])
      yticklabels([])
    end
    
    xlim([T_PLOT(1) T_PLOT(end)]-3500)
    xticks((T_PLOT(1) : 200 : T_PLOT(end)) - 3500)
    
    pause(.05)
  end%for:direction(dd)
  
  subplot(3,3,5); xticks([]); yticks([]); print_session_unit(gca , ninfo(cc), binfo(kk), 'horizontal')
  ppretty('image_size',[12,8])
%   pause(0.1); print(['~/Dropbox/Speed Accuracy/SEF_SAT/Figs/Error-Choice/SDF-PostChoiceError-xDir-FAST/', ...
  pause(0.1); print(['C:\Users\thoma\Dropbox\Speed Accuracy\SEF_SAT\Figs\Error-Choice\SDF-PostChoiceError-xDir-FAST\', ...
    ninfo(cc).area,'-',ninfo(cc).sess,'-',ninfo(cc).unit,'.tif'], '-dtiff')
  pause(0.1); close()
%   pause()
  
end%for:cells(cc)

end%fxn:plotSDFChoiceErrXdirSAT()
