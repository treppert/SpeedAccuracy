function [ binfo ] = determine_time_reward_SAT( binfo )
%determine_time_reward_SAT Summary of this function goes here
%   Detailed explanation goes here

LIM_TREW = [600, 900]; %relative to primary saccade initiation

NUM_SESSIONS = length(binfo);

for kk = 1:NUM_SESSIONS
  
  RT_kk = double(binfo(kk).resptime);
  rewtime_kk = binfo(kk).rewtime;
  rewtime_kk(rewtime_kk > 2e3) = NaN;
  
  binfo(kk).rewtime = rewtime_kk - RT_kk;
  
  %set "time of reward" on error trials to be the median time of reward
  %delivered on correct trials
  idxNaN = isnan(binfo(kk).rewtime);
  binfo(kk).rewtime(idxNaN) = median(binfo(kk).rewtime(~idxNaN));
  
  %make sure times of reward relative to RT are reasonable
  idxNaN = ((binfo(kk).rewtime < LIM_TREW(1)) | (binfo(kk).rewtime > LIM_TREW(2)));
  binfo(kk).rewtime(idxNaN) = NaN;
  
end%for:sessions(kk)

end%util:determine_time_reward_SAT()

