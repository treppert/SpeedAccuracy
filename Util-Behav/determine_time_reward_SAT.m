function [ binfo ] = determine_time_reward_SAT( binfo )
%determine_time_reward_SAT Summary of this function goes here
%   Detailed explanation goes here

LIM_TREW = [600, 900]; %relative to primary saccade initiation

NUM_SESSIONS = length(binfo);

for kk = 1:NUM_SESSIONS
  
  RT_kk = double(binfo(kk).resptime);
  rewtime_kk = binfo(kk).rewtime;
  
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idx_errtime = (~binfo(kk).err_dir & binfo(kk).err_time);
  idx_errdir = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  %get estimate of expected time of reward on error trials
  med_t_rew_kk = round(nanmedian(rewtime_kk));
  
  binfo(kk).rewtime(idx_corr) = rewtime_kk(idx_corr) - RT_kk(idx_corr);
  binfo(kk).rewtime(idx_errtime) = med_t_rew_kk - RT_kk(idx_errtime);
  binfo(kk).rewtime(idx_errdir) = med_t_rew_kk - RT_kk(idx_errdir);
  binfo(kk).rewtime(~(idx_corr | idx_errtime | idx_errdir)) = NaN;
  
  %make sure times are reasonable
  idx_nan = ((binfo(kk).rewtime < LIM_TREW(1)) | (binfo(kk).rewtime > LIM_TREW(2)));
  binfo(kk).rewtime(idx_nan) = NaN;
  
end%for:sessions(kk)

end%util:determine_time_reward_SAT()

