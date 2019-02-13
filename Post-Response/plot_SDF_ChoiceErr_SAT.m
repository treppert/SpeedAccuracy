function [  ] = plot_SDF_ChoiceErr_SAT( binfo , moves , ninfo , spikes , varargin )
%plot_SDF_ChoiceErr_SAT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SC'}, {'monkey=','D'}});

idx_area = ismember({ninfo.area}, args.area);
idx_monkey = ismember({ninfo.monkey}, args.monkey);

ninfo = ninfo(idx_area & idx_monkey);
spikes = spikes(idx_area & idx_monkey);

T_PLOT  = 3500 + (-300 : 500);
NUM_SAMP = length(T_PLOT);

NUM_CELLS = length(spikes);
NUM_DIR = 8;

IDX_DD_PLOT = [6, 3, 2, 1, 4, 7, 8, 9];

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  %initializations
  sdfAccCorr = NaN(NUM_DIR,NUM_SAMP);
  sdfAccErr = NaN(NUM_DIR,NUM_SAMP);
  sdfFastCorr = NaN(NUM_DIR,NUM_SAMP);
  sdfFastErr = NaN(NUM_DIR,NUM_SAMP);
  
  %compute spike density function
  sdf_kk = compute_spike_density_fxn(spikes(cc).SAT);
  sdf_kk = align_signal_on_response(sdf_kk, moves(kk).resptime); 
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  
  %index by condition
  idxFast = ((binfo(kk).condition == 3) & ~idxIso);
  idxAcc = ((binfo(kk).condition == 1) & ~idxIso);
  
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  %index by response direction
  for dd = 1:8
    idx_dd = (moves(kk).octant == dd);
    sdfAccCorr(dd,:) = nanmean(sdf_kk(idxAcc & idxCorr & idx_dd, T_PLOT));
    sdfAccErr(dd,:) = nanmean(sdf_kk(idxAcc & idxErr & idx_dd, T_PLOT));
    sdfFastCorr(dd,:) = nanmean(sdf_kk(idxFast & idxCorr & idx_dd, T_PLOT));
    sdfFastErr(dd,:) = nanmean(sdf_kk(idxFast & idxErr & idx_dd, T_PLOT));
  end
  
  %plotting
  figure()
  
  tmp = [sdfAccCorr, sdfAccErr, sdfFastCorr, sdfFastErr];
  yLim = [min(min(tmp)) max(max(tmp))];
  
  for dd = 1:NUM_DIR
    subplot(3,3,IDX_DD_PLOT(dd)); hold on
    
    plot([0 0], yLim, 'k--')
%     plot(T_PLOT-3500, sdfAccErr(dd,:), 'r--', 'LineWidth',1.0);
%     plot(T_PLOT-3500, sdfAccCorr(dd,:), 'r-', 'LineWidth',1.0);
    plot(T_PLOT-3500, sdfFastErr(dd,:), '--', 'Color',[0 .7 0], 'LineWidth',1.0);
    plot(T_PLOT-3500, sdfFastCorr(dd,:), '-', 'Color',[0 .7 0], 'LineWidth',1.0);
    
    if (IDX_DD_PLOT(dd) == 4)
      ylabel('Activity (sp/sec)')
    elseif (IDX_DD_PLOT(dd) == 8)
      xlabel('Time from primary response (ms)')
    end
    
    xlim([T_PLOT(1), T_PLOT(end)] - 3500)
    
    pause(.05)
  end%for:direction(dd)
  
  subplot(3,3,5); xticks([]); yticks([]); print_session_unit(gca , ninfo(cc), binfo(kk), 'horizontal')
  ppretty('image_size',[10,8])
  pause(1.0)
  
end%for:cells(cc)

end%fxn:plot_SDF_ChoiceErr_SAT()
