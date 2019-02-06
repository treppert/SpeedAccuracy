function [  ] = plot_distr_errRT_SAT( moves , binfo )
%plot_distr_errRT_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(moves);

QUANTILE = (.1 : .1 : .9);
NUM_QUANTILE = length(QUANTILE);

errRT = NaN(NUM_SESSION, NUM_QUANTILE);

%compute expected/actual time of reward for each session
binfo = determine_time_reward_SAT(binfo);

% figure()

for kk = 1:NUM_SESSION
  
  respTime = double(moves(kk).resptime);
  deadLine = double(binfo(kk).tgt_dline);
  
  %index by condition
  idxAcc = (binfo(kk).condition == 1);
  
  %index by trial outcome
  idxErr = (~binfo(kk).err_dir & binfo(kk).err_time);
  
  %compute and quantify errRT
  errRT_kk = deadLine(idxErr & idxAcc) - respTime(idxErr & idxAcc);
  errRT(kk,:) = quantile(errRT_kk, QUANTILE);
  
%   subplot(3,3,kk)
%   histogram(errRT_kk, 'FaceColor','r')
%   pause(0.25)
  
end%for:session(kk)


%% Plotting

figure(); hold on
errorbar_no_caps(QUANTILE, mean(errRT), 'err',std(errRT)/sqrt(NUM_SESSION), 'color','r')
ppretty('image_size',[3,4.8])

end%fxn:plot_distr_errRT_SAT()

