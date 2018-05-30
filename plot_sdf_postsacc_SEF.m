function [ ] = plot_sdf_postsacc_SEF( spikes , ninfo , moves , binfo )
%plot_baseline_activity Summary of this function goes here
%   Detailed explanation goes here

TIME_ARRAY = 3500;

T_SACC  = (-600 : 350);
T_REW = (-350 : 500);

NUM_SAMP_SACC = length(T_SACC);
NUM_SAMP_REW = length(T_REW);

NUM_CELLS = length(spikes);

A_rew = new_struct({'corr','errtime','errdir'}, 'dim',[1,NUM_CELLS]);
A_sacc = populate_struct(A_rew, {'corr','errtime','errdir'}, NaN(1,NUM_SAMP_SACC));
A_sacc = struct('acc',A_sacc, 'fast',A_sacc);
A_rew = populate_struct(A_rew, {'corr','errtime','errdir'}, NaN(1,NUM_SAMP_REW));
A_rew = struct('acc',A_rew, 'fast',A_rew);

RTmed_acc = new_struct({'corr','errtime','errdir'}, 'dim',[1,NUM_CELLS]);
RTmed_fast = new_struct({'corr','errtime','errdir'}, 'dim',[1,NUM_CELLS]);

time_rew = determine_time_reward_SAT(binfo, moves);

%% Compute the SDFs split by condition and correct/error

for cc = 1:NUM_CELLS
  
  kk = ismember({binfo.session}, ninfo(cc).sesh);
  
  sdf_kk = compute_spike_density_fxn(spikes(cc).SAT);
  sdf_sacc = align_signal_on_response(sdf_kk, moves(kk).resptime); 
  sdf_rew = align_signal_on_response(sdf_kk, moves(kk).resptime + time_rew(kk));
  
  idx_fast = (binfo(kk).condition == 3);
  idx_acc = (binfo(kk).condition == 1);
  
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time);
  idx_errtime = (~binfo(kk).err_dir & binfo(kk).err_time);
  idx_errdir = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  A_rew.acc(cc).corr = nanmean(sdf_rew(idx_acc & idx_corr,TIME_ARRAY + T_REW));
  A_rew.acc(cc).errtime = nanmean(sdf_rew(idx_acc & idx_errtime,TIME_ARRAY + T_REW));
  A_rew.acc(cc).errdir = nanmean(sdf_rew(idx_acc & idx_errdir,TIME_ARRAY + T_REW));
  
  A_rew.fast(cc).corr = nanmean(sdf_rew(idx_fast & idx_corr,TIME_ARRAY + T_REW));
  A_rew.fast(cc).errtime = nanmean(sdf_rew(idx_fast & idx_errtime,TIME_ARRAY + T_REW));
  A_rew.fast(cc).errdir = nanmean(sdf_rew(idx_fast & idx_errdir,TIME_ARRAY + T_REW));
  
  A_sacc.acc(cc).corr = nanmean(sdf_sacc(idx_acc & idx_corr,TIME_ARRAY + T_SACC));
  A_sacc.acc(cc).errtime = nanmean(sdf_sacc(idx_acc & idx_errtime,TIME_ARRAY + T_SACC));
  A_sacc.acc(cc).errdir = nanmean(sdf_sacc(idx_acc & idx_errdir,TIME_ARRAY + T_SACC));
  
  A_sacc.fast(cc).corr = nanmean(sdf_sacc(idx_fast & idx_corr,TIME_ARRAY + T_SACC));
  A_sacc.fast(cc).errtime = nanmean(sdf_sacc(idx_fast & idx_errtime,TIME_ARRAY + T_SACC));
  A_sacc.fast(cc).errdir = nanmean(sdf_sacc(idx_fast & idx_errdir,TIME_ARRAY + T_SACC));
  
  %save median RTs
  
  RTmed_acc(cc).corr = nanmedian(moves(kk).resptime(idx_acc & idx_corr));
  RTmed_acc(cc).errtime = nanmedian(moves(kk).resptime(idx_acc & idx_errtime));
  RTmed_acc(cc).errdir = nanmedian(moves(kk).resptime(idx_acc & idx_errdir));
  
  RTmed_fast(cc).corr = nanmedian(moves(kk).resptime(idx_fast & idx_corr));
  RTmed_fast(cc).errtime = nanmedian(moves(kk).resptime(idx_fast & idx_errtime));
  RTmed_fast(cc).errdir = nanmedian(moves(kk).resptime(idx_fast & idx_errdir));
  
end%for:cells(kk)

%% Plotting - individual cells

for cc = 1:NUM_CELLS
  
  linmax_acc = max([[A_sacc.acc(cc).errdir], [A_sacc.acc(cc).errtime]]);
  linmax_fast = max([[A_sacc.fast(cc).errdir], [A_sacc.fast(cc).errtime]]);
  
  figure()
  
  %% Activity re. saccade
  
  subplot(2,2,1); hold on
  
  plot([0 0], [0 linmax_acc], 'k--', 'LineWidth',1.5)
  plot(-RTmed_acc(cc).corr*ones(1,2), [0 linmax_acc], 'r-')
  plot(-RTmed_acc(cc).errdir*ones(1,2), [0 linmax_acc], 'r--')
  plot(-RTmed_acc(cc).errtime*ones(1,2), [0 linmax_acc], 'r:')
  
  plot(T_SACC, A_sacc.acc(cc).corr, 'r-', 'LineWidth',1.5)
  plot(T_SACC, A_sacc.acc(cc).errdir, 'r--', 'LineWidth',1.5)
  plot(T_SACC, A_sacc.acc(cc).errtime, 'r:', 'LineWidth',1.5)
  
  xlim([T_SACC(1), T_SACC(end)])
  print_session_unit(gca, ninfo(cc))
  
  pause(0.25)
  
  subplot(2,2,3); hold on
  
  plot([0 0], [0 linmax_fast], 'k--', 'LineWidth',1.5)
  plot(-RTmed_fast(cc).corr*ones(1,2), [0 linmax_fast], '-', 'Color',[0 .7 0])
  plot(-RTmed_fast(cc).errdir*ones(1,2), [0 linmax_fast], '--', 'Color',[0 .7 0])
  plot(-RTmed_fast(cc).errtime*ones(1,2), [0 linmax_fast], ':', 'Color',[0 .7 0])
  
  plot(T_SACC, A_sacc.fast(cc).corr, '-', 'Color',[0 .7 0], 'LineWidth',1.5)
  plot(T_SACC, A_sacc.fast(cc).errdir, '--', 'Color',[0 .7 0], 'LineWidth',1.5)
  plot(T_SACC, A_sacc.fast(cc).errtime, ':', 'Color',[0 .7 0], 'LineWidth',1.5)
  
  xlim([T_SACC(1), T_SACC(end)])
  print_session_unit(gca, ninfo(cc))
  
  pause(0.25)
  
  %% Activity re. reward
  
  subplot(2,2,2); hold on
  
  plot([0 0], [0 linmax_acc], 'k--', 'LineWidth',1.5)
  
  plot(T_REW, A_rew.acc(cc).corr, 'r-', 'LineWidth',1.5)
  plot(T_REW, A_rew.acc(cc).errdir, 'r--', 'LineWidth',1.5)
  plot(T_REW, A_rew.acc(cc).errtime, 'r:', 'LineWidth',1.5)
  
  xlim([T_REW(1), T_REW(end)])
  
  pause(0.25)
  
  subplot(2,2,4); hold on
  
  plot([0 0], [0 linmax_fast], 'k--', 'LineWidth',1.5)
  
  plot(T_REW, A_rew.fast(cc).corr, '-', 'Color',[0 .7 0], 'LineWidth',1.5)
  plot(T_REW, A_rew.fast(cc).errdir, '--', 'Color',[0 .7 0], 'LineWidth',1.5)
  plot(T_REW, A_rew.fast(cc).errtime, ':', 'Color',[0 .7 0], 'LineWidth',1.5)
  
  xlim([T_REW(1), T_REW(end)])
  
  ppretty('image_size',[14,7])
  print(['~/Dropbox/tmp/sdf-reward-Da/', ninfo(cc).sesh,'-',ninfo(cc).unit,'.tif'], '-dtiff')
  pause(0.25)
  close()
  
end

end%function:plot_sdf_error_SEF()
