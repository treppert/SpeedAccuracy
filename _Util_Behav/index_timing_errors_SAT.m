function [ behavData ] = index_timing_errors_SAT( behavData )
%index_timing_errors_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(behavData);

MAX_DLINE_FAST = 600; %enforce a hard deadline on the Fast condition

for kk = 1:NUM_SESSION
  
%   ierr_dir = info(kk).Task_ErrChoice;
  deadline = behavData(kk).deadline;
  
  idx_acc = (behavData(kk).condition == 1);
  idx_fast = (behavData(kk).condition == 3);
  
  resptime = behavData(kk).resptime;
  
  ierr_time_Fast = (idx_fast & ((resptime > deadline) | (resptime > MAX_DLINE_FAST)));
  ierr_time_Acc = (idx_acc & (resptime < deadline));
  
  behavData(kk).Task_ErrTime(ierr_time_Fast | ierr_time_Acc) = true;
  
end%for:session(kk)

end%function:index_timing_errors_SAT()
