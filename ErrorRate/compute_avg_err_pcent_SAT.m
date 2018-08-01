function [  ] = compute_avg_err_pcent_SAT( info , moves )
%compute_avg_err_pcent_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(moves);

err_dir = new_struct({'acc','fast'}, 'dim',[1,NUM_SESSION]);
err_time = err_dir;
err_both = err_dir;

for kk = 1:NUM_SESSION
  
  idx_acc = (info(kk).condition == 1);
  idx_fast = (info(kk).condition == 3);
  
  ierr_dir = info(kk).err_dir;
  ierr_time = info(kk).err_time;
  
  err_dir(kk).acc = sum(idx_acc & ierr_dir) / sum(idx_acc);
  err_dir(kk).fast = sum(idx_fast & ierr_dir) / sum(idx_fast);
  
  err_time(kk).acc = sum(idx_acc & ierr_time) / sum(idx_acc);
  err_time(kk).fast = sum(idx_fast & ierr_time) / sum(idx_fast);
  
  err_both(kk).acc = sum(idx_acc & ierr_time & ierr_dir) / sum(idx_acc);
  err_both(kk).fast = sum(idx_fast & ierr_time & ierr_dir) / sum(idx_fast);
  
end%for:sessions(kk)

fprintf('Dir err: ACC %g +- %g  FAST %g +- %g\n', mean([err_dir.acc]), std([err_dir.acc])/sqrt(NUM_SESSION), ...
  mean([err_dir.fast]), std([err_dir.fast])/sqrt(NUM_SESSION))
fprintf('Time err ACC %g +- %g  FAST %g +- %g\n', mean([err_time.acc]), std([err_time.acc])/sqrt(NUM_SESSION), ...
  mean([err_time.fast]), std([err_time.fast])/sqrt(NUM_SESSION))
% fprintf('Da dir + time err Acc/Fast: %g and %g\n', mean([err_both_Da.acc]), mean([err_both_Da.fast]))


end%function:compute_avg_err_pcent_SAT()
