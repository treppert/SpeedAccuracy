function [ behavData ] = determine_time_reward_SAT( behavData )
%determine_time_reward_SAT Summary of this function goes here
%   Detailed explanation goes here

LIM_TREW = [600, 900]; %relative to primary saccade initiation

NUM_SESSIONS = length(behavData);

for kk = 1:NUM_SESSIONS
  
  RT_kk = double(behavData.Sacc_RT{kk});
  rewtime_kk = behavData.Task_TimeReward{kk};
  rewtime_kk(rewtime_kk > 2e3) = NaN;
  
  behavData.Task_TimeReward{kk} = rewtime_kk - RT_kk;
  
  %set "time of reward" on error trials to be the median time of reward
  %delivered on correct trials
  idxNaN = isnan(behavData.Task_TimeReward{kk});
  behavData.Task_TimeReward{kk}(idxNaN) = median(behavData.Task_TimeReward{kk}(~idxNaN));
  
  %make sure times of reward relative to RT are reasonable
  idxNaN = ((behavData.Task_TimeReward{kk} < LIM_TREW(1)) | (behavData.Task_TimeReward{kk} > LIM_TREW(2)));
  behavData.Task_TimeReward{kk}(idxNaN) = NaN;
  
end%for:sessions(kk)

end%util:determine_time_reward_SAT()

