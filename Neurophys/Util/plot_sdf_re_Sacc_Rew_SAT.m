function [  ] = plot_sdf_re_Sacc_Rew_SAT( spikes , ninfo , moves , movesAll , binfo )
%plot_sdf_ChoiceError_SAT Summary of this function goes here
%   Detailed explanation goes here

binfo = index_timing_errors_SAT(binfo, moves);

TIME_POSTSACC  = 3500 + (-400 : 400);
NSAMP_POSTSACC = length(TIME_POSTSACC);

TIME_REW = 3500 + (-400 : 400);
NUM_SAMP = length(TIME_REW);

NUM_CELLS = length(spikes);

%activity post-primary saccade
A_Corr_Sacc = NaN(NUM_CELLS,NSAMP_POSTSACC);
A_Err_Sacc  = NaN(NUM_CELLS,NSAMP_POSTSACC);

%activity from time of reward / expected reward
A_Corr_Rew = NaN(NUM_CELLS, NUM_SAMP);
A_Err_Rew = NaN(NUM_CELLS, NUM_SAMP);

%median RT for each condition X trial outcome
RT_corr = NaN(1,NUM_CELLS);
RT_err = NaN(1,NUM_CELLS);

%compute expected/actual time of reward for each session
[~,time_rew] = determine_time_reward_SAT(binfo, moves);

%% Compute the SDFs split by condition and correct/error

for cc = 1:NUM_CELLS
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  TRIAL_POOR_ISOLATION = false(1,binfo(kk).num_trials);
  
  sdf_kk = compute_spike_density_fxn(spikes(cc).SAT);
  sdf_sacc = align_signal_on_response(sdf_kk, moves(kk).resptime); 
  sdf_rew = align_signal_on_response(sdf_kk, double(moves(kk).resptime) + time_rew{kk});
  
  %remove trials with poor unit isolation
  if (ninfo(cc).iRem1)
    TRIAL_POOR_ISOLATION(ninfo(cc).iRem1 : ninfo(cc).iRem2) = true;
  end
  
  %index by condition
  idx_cond = ((binfo(kk).condition == 3) & ~TRIAL_POOR_ISOLATION);
  
  %index by trial outcome
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idx_err = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  %control for choice error direction
  [idx_err, idx_corr] = equate_respdir_err_vs_corr(idx_err, idx_corr, moves(kk).octant);
  
  %remove any activity related to corrective saccade initiation
  trial_err = find(idx_cond & idx_err);
  sdf_sacc(idx_cond & idx_err,:) = rem_spikes_post_corrective_SAT(sdf_sacc(idx_cond & idx_err,:), movesAll(kk), trial_err);
  
  %save activity post-primary saccade
  A_Corr_Sacc(cc,:) = nanmean(sdf_sacc(idx_cond & idx_corr,TIME_POSTSACC));
  A_Err_Sacc(cc,:) = nanmean(sdf_sacc(idx_cond & idx_err,TIME_POSTSACC));
  
  %save activity from time of reward
  A_Corr_Rew(cc,:) = nanmean(sdf_rew(idx_cond & idx_corr,TIME_REW));
  A_Err_Rew(cc,:) = nanmean(sdf_rew(idx_cond & idx_err,TIME_REW));
  
  %save median RTs
  RT_corr(cc) = nanmedian(moves(kk).resptime(idx_cond & idx_corr));
  RT_err(cc) = nanmedian(moves(kk).resptime(idx_cond & idx_err));
  
end%for:cells(cc)



%% Plotting - individual cells

for cc = 1:NUM_CELLS
  min_lin = min([A_Corr_Sacc(cc,:), A_Err_Sacc(cc,:), A_Corr_Rew(cc,:), A_Err_Rew(cc,:)]);
  max_lin = max([A_Corr_Sacc(cc,:), A_Err_Sacc(cc,:), A_Corr_Rew(cc,:), A_Err_Rew(cc,:)]);
  lim_lin = [min_lin, max_lin];
  
  figure()
  
  subplot(1,2,1); hold on %activity post-primary saccade
  
  plot([0 0], lim_lin, 'k--', 'LineWidth',1.0)
  plot(-RT_corr(cc)*ones(1,2), lim_lin, '-', 'Color',[0 .5 0])
  plot(-RT_err(cc)*ones(1,2), lim_lin, ':', 'Color',[0 .5 0])
  plot(TIME_POSTSACC-3500, A_Corr_Sacc(cc,:), '-', 'Color',[0 .7 0], 'LineWidth',1.5)
  plot(TIME_POSTSACC-3500, A_Err_Sacc(cc,:), ':', 'Color',[0 .7 0], 'LineWidth',1.5)
  
  xlabel('Time from primary saccade (ms)')
  ylabel('Activity (sp/sec)')
  print_session_unit(gca, ninfo(cc), 'horizontal')
  
  pause(0.1)
  
  subplot(1,2,2); hold on %activity from reward / expected reward
  
  plot([0 0], lim_lin, 'k--', 'LineWidth',1.0)
  plot(TIME_REW-3500, A_Corr_Rew(cc,:), '-', 'Color',[0 .7 0], 'LineWidth',1.5)
  plot(TIME_REW-3500, A_Err_Rew(cc,:), ':', 'Color',[0 .7 0], 'LineWidth',1.5)
  
  xlabel('Time from reward (ms)')
  print_session_unit(gca, ninfo(cc), 'horizontal')
  
  ppretty('image_size',[12,4])
  pause(0.1)
  print_fig_SAT(ninfo(cc), gcf, '-dtiff')
  
  pause(0.25)
  
end%for:cells(cc)

end%function:plot_sdf_error_SEF()
