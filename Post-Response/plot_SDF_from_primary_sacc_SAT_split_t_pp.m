function [ ] = plot_SDF_from_primary_sacc_SAT_split_t_pp( binfo , moves , ninfo , spikes , t_pp )
%plot_SDF_from_primary_sacc_SAT Summary of this function goes here
%   Detailed explanation goes here

LIM_T_PP = [100 300 500];
NUM_BIN = length(LIM_T_PP) - 1;

NUM_CELLS = length(spikes);

TIME_POSTSACC  = 3500 + (-300 : 500);
NUM_SAMP_PS = length(TIME_POSTSACC);

A_POSTSACC_Corr = NaN(NUM_CELLS,NUM_SAMP_PS);

A_POSTSACC_ErrDir = cell(1,NUM_CELLS);
for cc = 1:NUM_CELLS
  A_POSTSACC_ErrDir{cc} = NaN(NUM_BIN,NUM_SAMP_PS);
end

for cc = 1:NUM_CELLS
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  sdf_kk = compute_spike_density_fxn(spikes(cc).SAT);
  sdf_kk = align_signal_on_response(sdf_kk, moves(kk).resptime); 
  
  %index by isolation quality
  idx_iso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  
  %index by condition
  idx_fast = ((binfo(kk).condition == 3) & ~idx_iso);
%   idx_acc = ((binfo(kk).condition == 1) & ~idx_iso);
  
  %index by trial outcome
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idx_errdir = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  %control for choice error direction
%   [idx_errdir, idx_corr] = equate_respdir_err_vs_corr(idx_errdir, idx_corr, moves(kk).octant);
  
  %save activity on correct trials
  A_POSTSACC_Corr(cc,:) = nanmean(sdf_kk(idx_fast & idx_corr, TIME_POSTSACC));
  
  %index by time of the post-primary saccade and save activity
  for ii = 1:NUM_BIN
    idx_ii = ((t_pp{kk} > LIM_T_PP(ii)) & (t_pp{kk} < LIM_T_PP(ii+1)));
    A_POSTSACC_ErrDir{cc}(ii,:) = nanmean(sdf_kk(idx_fast & idx_errdir & idx_ii, TIME_POSTSACC));
  end%for:bin-t-pp(ii)
  
end%for:cells(cc)

%% Plotting
COLOR_PLOT = {[0 .8 0], [0 .3 0]};

for cc = 1:NUM_CELLS
  
  lim_lin = [min(A_POSTSACC_ErrDir{cc}(1,:)), max(A_POSTSACC_ErrDir{cc}(1,:))];
  
  figure(); hold on
  plot([0 0], lim_lin, 'k--', 'LineWidth',1.0)
  
  plot(TIME_POSTSACC-3500, A_POSTSACC_Corr(cc,:), '-', 'Color',[0 .7 0], 'LineWidth',1.0)
  
  for ii = 1:NUM_BIN
    plot(TIME_POSTSACC-3500, A_POSTSACC_ErrDir{cc}(ii,:), '--', 'Color',COLOR_PLOT{ii}, 'LineWidth',1.0)
  end
  
  xlabel('Time from primary saccade (ms)')
  ylabel('Activity (sp/sec)')
  print_session_unit(gca, ninfo(cc), 'horizontal')
  ppretty()
  
  pause(0.5)
  print_fig_SAT(ninfo(cc), gcf, '-dtiff')
  pause(0.5)
  
end%for:cells(cc)

end%fxn:plot_SDF_from_primary_sacc_SAT()


