function [ binfo ] = index_timing_errors_SAT( binfo )
%index_timing_errors_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(binfo);

MAX_DLINE_FAST = 600; %enforce a hard deadline on the Fast condition

for kk = 1:NUM_SESSION
  
%   ierr_dir = info(kk).err_dir;
  deadline = binfo(kk).deadline;
  
  idx_acc = (binfo(kk).condition == 1);
  idx_fast = (binfo(kk).condition == 3);
  
  resptime = binfo(kk).resptime;
  
  ierr_time_Fast = (idx_fast & ((resptime > deadline) | (resptime > MAX_DLINE_FAST)));
  ierr_time_Acc = (idx_acc & (resptime < deadline));
  
  binfo(kk).err_time(ierr_time_Fast | ierr_time_Acc) = true;
  
end%for:session(kk)

end%function:index_timing_errors_SAT()
