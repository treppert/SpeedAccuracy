function [  ] = compute_avg_RT_SAT( info , moves )
%compute_avg_RT_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSIONS = length(moves);

RT = new_struct({'acc','fast'}, 'dim',[1,NUM_SESSIONS]);

for kk = 1:NUM_SESSIONS
  
  idx_acc = (info(kk).condition == 1);
  idx_fast = (info(kk).condition == 3);
  
  RT(kk).acc = nanmean(moves(kk).resptime(idx_acc));
  RT(kk).fast = nanmean(moves(kk).resptime(idx_fast));
  
end%for:sessions(kk)

fprintf('RT Acc: %g +/- %g ms\n', mean([RT.acc]), std([RT.acc])/sqrt(NUM_SESSIONS))
fprintf('RT Fast: %g +/- %g ms\n', mean([RT.fast]), std([RT.fast])/sqrt(NUM_SESSIONS))

%% Plotting

figure(); hold on

mu = [ mean([RT.acc]) , mean([RT.fast]) ];
err = [ std([RT.acc]) , std([RT.fast]) ] / sqrt(NUM_SESSIONS);

errorbar_no_caps([.95 1.95], mu, 'err',err)

xticks([]); xlim([.90 2.10])
ppretty('image_size',[1.2,3])

end%function:compute_avg_RT_SAT()

