function [ info ] = index_timing_errors_SAT( info , moves )
%index_timing_errors_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(info);

for kk = 1:NUM_SESSION
  
  ierr_dir = info(kk).err_dir;
  tgt_dline = info(kk).tgt_dline;
  
  idx_acc = (info(kk).condition == 1);
  idx_fast = (info(kk).condition == 3);
  
  resptime = moves(kk).resptime;
  
  ierr_time_Fast = (idx_fast & (resptime > tgt_dline));
  ierr_time_Acc = (idx_acc & (resptime < tgt_dline));
  
  info(kk).err_time(ierr_dir & (ierr_time_Fast | ierr_time_Acc)) = true;
  
end%for:session(kk)

end%function:index_timing_errors_SAT()
