function [ binfo ] = index_timing_errors_SAT( binfo , moves )
%index_timing_errors_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(binfo);

MAX_DLINE_FAST = 600; %enforce a hard deadline on the Fast condition

for kk = 1:NUM_SESSION
  
%   ierr_dir = info(kk).err_dir;
  tgt_dline = binfo(kk).tgt_dline;
  
  idx_acc = (binfo(kk).condition == 1);
  idx_fast = (binfo(kk).condition == 3);
  
  resptime = moves(kk).resptime;
  
  ierr_time_Fast = (idx_fast & ((resptime > tgt_dline) | (resptime > MAX_DLINE_FAST)));
  ierr_time_Acc = (idx_acc & (resptime < tgt_dline));
  
  binfo(kk).err_time(ierr_time_Fast | ierr_time_Acc) = true;
  
end%for:session(kk)

end%function:index_timing_errors_SAT()
