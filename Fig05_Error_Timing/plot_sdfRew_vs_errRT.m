function [  ] = plot_sdfRew_vs_errRT( spikes , unitData , moves , behavData , bline , cond )
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
for uu = 1:NUM_CELLS
  sdf_Err{uu} = NaN(NUM_BIN_RT,NUM_SAMP);
end

sdf_Corr = NaN(NUM_BIN_RT,NUM_SAMP);

%compute expected time of reward for each session
[~,t_rew] = determine_time_reward_SAT(behavData, moves);

for uu = NUM_CELLS:-1:1
  
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  err_RT_kk = moves(kk).resptime - behavData(kk).tgt_dline;
  
  idx_cond = (behavData.Task_SATCondition{kk} == CONDITION);
  idx_corr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk}) & idx_cond;
  idx_err = (~behavData.Task_ErrChoice{kk} & behavData.Task_ErrTime{kk}) & idx_cond;
  
  sdf = compute_spike_density_fxn(spikes(uu).SAT);
  sdf = align_signal_on_response(sdf, moves(kk).resptime + t_rew{kk});
  
  sdf_Corr(cc,:) = nanmean(sdf(idx_corr,TIME_ZERO + TIME_REW));
  
  for jj = 1:NUM_BIN_RT
    
    idx_jj = ((abs(err_RT_kk) > LIM_ERR_RT(jj)) & (abs(err_RT_kk) <= LIM_ERR_RT(jj+1)));
    sdf_Err{uu}(jj,:) = nanmean(sdf(idx_err & idx_jj,TIME_ZERO + TIME_REW));
    
  end%for:RT-bins(jj)
  
  figure(); hold on
  plot([-600 800], bline(uu)*ones(1,2), 'k:')
  plot(TIME_REW, sdf_Corr(cc,:), 'k-')
  plot(TIME_REW, sdf_Err{uu}(1,:), '-', 'Color',[1 0 0])
  plot(TIME_REW, sdf_Err{uu}(2,:), '-', 'Color',[1 .5 .5])
  print_session_unit(gca, unitData(uu,:), 'horizontal')
  xlim([-625 825]); xticks(-600:100:800)
  ppretty('image_size',[4,2])
  
end%for:cells(uu)

end%fxn:plot_sdfRew_vs_errRT()

