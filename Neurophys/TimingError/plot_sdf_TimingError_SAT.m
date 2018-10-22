function [  ] = plot_sdf_TimingError_SAT( spikes , ninfo , moves , binfo )
%plot_baseline_activity Summary of this function goes here
%   Detailed explanation goes here

binfo = index_timing_errors_SAT(binfo, moves);

PLOT_INDIVIDUAL_CELLS = true;

TIME_POSTSACC  = 3500 + (-600 : 400);
NSAMP_POSTSACC = length(TIME_POSTSACC);

NUM_CELLS = 10;%length(spikes);

%activity re. saccade initiation
A_corr = NaN(NUM_CELLS,NSAMP_POSTSACC);
A_err_small  = NaN(NUM_CELLS,NSAMP_POSTSACC);
A_err_large  = NaN(NUM_CELLS,NSAMP_POSTSACC);

%median RT for each condition X trial outcome
RT_corr = NaN(1,NUM_CELLS);
RT_err = NaN(1,NUM_CELLS);

%% Compute the SDFs split by condition and correct/error

for cc = 1:NUM_CELLS
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  TRIAL_POOR_ISOLATION = false(1,binfo(kk).num_trials);
  
  sdf_kk = compute_spike_density_fxn(spikes(cc).SAT);
  sdf_kk = align_signal_on_response(sdf_kk, moves(kk).resptime); 
  
  %remove trials with poor unit isolation
  if (ninfo(cc).iRem1)
    TRIAL_POOR_ISOLATION(ninfo(cc).iRem1 : ninfo(cc).iRem2) = true;
  end
  
  %index by condition
  idx_cond = ((binfo(kk).condition == 1) & ~TRIAL_POOR_ISOLATION);
  
  %index by trial outcome
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idx_err = (binfo(kk).err_time & ~binfo(kk).err_dir);
  
  %control for choice error direction
  [idx_err, idx_corr] = equate_respdir_err_vs_corr(idx_err, idx_corr, moves(kk).octant);
  
  %*****split by magnitude of timing error -- NOTE - needs to be finished
  idx_err = find(idx_cond & idx_err);
  RT_err = moves(kk).resptime(idx_err);
  
  A_corr(cc,:) = nanmean(sdf_kk(idx_cond & idx_corr,TIME_POSTSACC));
  A_err_small(cc,:) = nanmean(sdf_kk(idx_cond & idx_err,TIME_POSTSACC));
  
  %save median RTs
  RT_corr(cc) = nanmedian(moves(kk).resptime(idx_cond & idx_corr));
  RT_err(cc) = nanmedian(moves(kk).resptime(idx_cond & idx_err));
  
end%for:cells(cc)



%% Plotting - individual cells
if (PLOT_INDIVIDUAL_CELLS)

TIME_PLOT = TIME_POSTSACC - 3500;

for cc = 1:NUM_CELLS
%   if ~strcmp(dir_sep_err{cc}, 'C'); continue; end
  lim_lin = [min([A_corr(cc,:), A_err_small(cc,:)]), max([A_corr(cc,:), A_err_small(cc,:)])];
  
  figure(); hold on
  
  plot([0 0], lim_lin, 'k--', 'LineWidth',1.0)
  plot(-RT_corr(cc)*ones(1,2), lim_lin, '-', 'Color',[.5 0 0])
  plot(-RT_err(cc)*ones(1,2), lim_lin, ':', 'Color',[.5 0 0])
  
  plot(TIME_PLOT, A_corr(cc,:), 'r-', 'LineWidth',1.5)
  plot(TIME_PLOT, A_err_small(cc,:), 'r:', 'LineWidth',1.5)
  
  xlim([TIME_PLOT(1), TIME_PLOT(end)])
  xlabel('Time re. saccade (ms)')
  ylabel('Activity (sp/sec)')
  print_session_unit(gca, ninfo(cc))
  
  ppretty('image_size',[5,3])
%   print_fig_SAT(ninfo(cc), gcf, '-dtiff')
  
  pause(0.5)
  
end%for:cells(cc)
end%if(PLOT_INDIVIDUAL_CELLS)


end%function:plot_sdf_TimingError_SAT()
