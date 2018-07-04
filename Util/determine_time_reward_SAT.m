function [ time_rew , varargout ] = determine_time_reward_SAT( info , moves )
%determine_time_reward_SAT Summary of this function goes here
%   Detailed explanation goes here

LIM_TREW = [600, 900];

NUM_SESSIONS = length(info);
time_rew = NaN(1,NUM_SESSIONS);

%output combined vector of expected t_rew(err) and actual t_err(corr)
trew_cell = cell(1,NUM_SESSIONS);
for kk = 1:NUM_SESSIONS
  trew_cell{kk} = NaN(1,info(kk).num_trials);
end

for kk = 1:NUM_SESSIONS
  
  idx_err = info(kk).err_time; %trials with error in timing
  
  %get estimate of expected time of reward on error trials
  time_rew(kk) = round(nanmedian(info(kk).rewtime));
  
  trew_cell{kk}(idx_err) = time_rew(kk) - moves(kk).resptime(idx_err);
  trew_cell{kk}(~idx_err) = info(kk).rewtime(~idx_err) - moves(kk).resptime(~idx_err);
  
  %make sure times are reasonable
  idx_nan = ((trew_cell{kk} < LIM_TREW(1)) | (trew_cell{kk} > LIM_TREW(2)));
  trew_cell{kk}(idx_nan) = NaN;
  
end%for:sessions(kk)

if (nargout > 1)
  varargout{1} = trew_cell;
end

end%util:determine_time_reward_SAT()

