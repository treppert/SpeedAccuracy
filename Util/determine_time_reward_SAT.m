function [ time_rew , varargout ] = determine_time_reward_SAT( binfo , moves )
%determine_time_reward_SAT Summary of this function goes here
%   Detailed explanation goes here

LIM_TREW = [600, 900];

NUM_SESSIONS = length(binfo);
time_rew = NaN(1,NUM_SESSIONS);

%output combined vector of expected t_rew(err) and actual t_err(corr)
trew_cell = cell(1,NUM_SESSIONS);
for kk = 1:NUM_SESSIONS
  trew_cell{kk} = NaN(1,binfo(kk).num_trials);
end

for kk = 1:NUM_SESSIONS
  
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idx_errtime = (~binfo(kk).err_dir & binfo(kk).err_time); %trials with error in timing
  idx_errdir = (binfo(kk).err_dir & ~binfo(kk).err_time); %trials with error in direction
  resptime_kk = double(moves(kk).resptime);
  
  %get estimate of expected time of reward on error trials
  time_rew(kk) = round(nanmedian(binfo(kk).rewtime));
  
  trew_cell{kk}(idx_corr) = binfo(kk).rewtime(idx_corr) - resptime_kk(idx_corr);
  trew_cell{kk}(idx_errtime) = time_rew(kk) - resptime_kk(idx_errtime);
  trew_cell{kk}(idx_errdir) = time_rew(kk) - resptime_kk(idx_errdir);
  
  %make sure times are reasonable
  idx_nan = ((trew_cell{kk} < LIM_TREW(1)) | (trew_cell{kk} > LIM_TREW(2)));
  trew_cell{kk}(idx_nan) = NaN;
  
end%for:sessions(kk)

if (nargout > 1)
  varargout{1} = trew_cell;
end

end%util:determine_time_reward_SAT()

