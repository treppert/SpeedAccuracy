function [ info ] = determine_errors_SAT( info )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSIONS = length(info);

%initialize error fields
for kk = 1:NUM_SESSIONS
  info(kk).err_dir = false(1,info(kk).num_trials);
  info(kk).err_time = false(1,info(kk).num_trials);
end%for:sessions(kk)


%mark trials with errors (both direction & timing)
for kk = 1:NUM_SESSIONS
  info(kk).err_dir(info(kk).errors == 3) = true;
  info(kk).err_time(info(kk).errors == 4) = true;
end%for:sessions(kk)

end%function:determine_errors_SAT()
