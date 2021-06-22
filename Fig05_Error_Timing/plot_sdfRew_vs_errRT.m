function [  ] = plot_sdfRew_vs_errRT( spikes , ninfo , moves , binfo , bline , cond )
%plot_sdfRew_vs_errRT Summary of this function goes here
%   Detailed explanation goes here

if strcmp(cond, 'acc')
  CONDITION = 1;
elseif strcmp(cond, 'fast')
  CONDITION = 3;
else
  error('Input "cond" not recognized')
end

TIME_ZERO = 3500;

TIME_REW = (-600 : 800);
NUM_SAMP = length(TIME_REW);

NUM_CELLS = length(spikes);

LIM_ERR_RT = [0, 50, 250];
NUM_BIN_RT = length(LIM_ERR_RT) - 1;

sdf_Err = cell(1,NUM_CELLS);
for cc = 1:NUM_CELLS
  sdf_Err{cc} = NaN(NUM_BIN_RT,NUM_SAMP);
end

sdf_Corr = NaN(NUM_BIN_RT,NUM_SAMP);

%compute expected time of reward for each session
[~,t_rew] = determine_time_reward_SAT(binfo, moves);

for cc = NUM_CELLS:-1:1
  
  kk = ismember({binfo.session}, ninfo(cc).sesh);
  err_RT_kk = moves(kk).resptime - binfo(kk).tgt_dline;
  
  idx_cond = (binfo(kk).condition == CONDITION);
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time) & idx_cond;
  idx_err = (~binfo(kk).err_dir & binfo(kk).err_time) & idx_cond;
  
  sdf = compute_spike_density_fxn(spikes(cc).SAT);
  sdf = align_signal_on_response(sdf, moves(kk).resptime + t_rew{kk});
  
  sdf_Corr(cc,:) = nanmean(sdf(idx_corr,TIME_ZERO + TIME_REW));
  
  for jj = 1:NUM_BIN_RT
    
    idx_jj = ((abs(err_RT_kk) > LIM_ERR_RT(jj)) & (abs(err_RT_kk) <= LIM_ERR_RT(jj+1)));
    sdf_Err{cc}(jj,:) = nanmean(sdf(idx_err & idx_jj,TIME_ZERO + TIME_REW));
    
  end%for:RT-bins(jj)
  
  figure(); hold on
  plot([-600 800], bline(cc)*ones(1,2), 'k:')
  plot(TIME_REW, sdf_Corr(cc,:), 'k-')
  plot(TIME_REW, sdf_Err{cc}(1,:), '-', 'Color',[1 0 0])
  plot(TIME_REW, sdf_Err{cc}(2,:), '-', 'Color',[1 .5 .5])
  print_session_unit(gca, ninfo(cc), 'horizontal')
  xlim([-625 825]); xticks(-600:100:800)
  ppretty('image_size',[4,2])
  
end%for:cells(cc)

end%fxn:plot_sdfRew_vs_errRT()

