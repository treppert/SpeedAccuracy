function [ time_rew ] = determine_time_reward_SAT( info , moves , varargin )
%determine_time_reward_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {'check_timing'});

MAX_DIFF_TIME = 50; %diff between 0.1 and 0.9 quantiles

NUM_SESSIONS = length(info);
time_rew = NaN(1,NUM_SESSIONS);

for kk = 1:NUM_SESSIONS
  
  vec_time_rew = info(kk).rewtime - moves(kk).resptime;
  
  if (args.check_timing)
    quant_10 = quantile(vec_time_rew, 0.1);
    quant_90 = quantile(vec_time_rew, 0.9);

    %check to see if time of reward shifted during the session
    if ( abs(diff([quant_10, quant_90])) > MAX_DIFF_TIME)
      continue
    end
  end
  
  time_rew(kk) = nanmedian(vec_time_rew);
  
end%for:sessions(kk)


end%util:determine_time_reward_SAT()

