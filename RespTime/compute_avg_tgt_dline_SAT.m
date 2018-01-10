function [ varargout ] = compute_avg_tgt_dline_SAT( info )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSIONS = length(info);

deadline = new_struct({'acc','fast'}, 'dim',[1,NUM_SESSIONS]);

for kk = 1:NUM_SESSIONS
  
  idx_acc = (info(kk).condition == 1);
  idx_fast = (info(kk).condition == 3);
  
  deadline(kk).acc = mean(info(kk).deadline(idx_acc));
  deadline(kk).fast = mean(info(kk).deadline(idx_fast));
  
end%for:sessions(kk)

if (nargout > 0)
  varargout{1} = deadline;
end

dline_acc = [deadline.acc];
dline_fast = [deadline.fast];

fprintf('Deadline Acc: %g +/- %g ms\n', mean(dline_acc), std(dline_acc)/sqrt(NUM_SESSIONS))
fprintf('Deadline Fast: %g +/- %g ms\n', mean(dline_fast), std(dline_fast)/sqrt(NUM_SESSIONS))

end%function:compute_avg_RT_SAT()

