function [ ] = plot_SAT( binfoSAT , primarySacc )
%plot_SAT() Summary of this function goes here
%   Detailed explanation goes here

MONKEY = {'D','E'};
sessKeep = ismember(binfoSAT.monkey, MONKEY);

%isolate sessions from MONKEY(s)
binfoSAT = binfoSAT(sessKeep, :);
primarySacc = primarySacc(sessKeep, :);

%% Compute error rate and RT X task condition
NUM_SESS = sum(sessKeep);
errRate_Acc = NaN(1,NUM_SESS);   rt_Acc = NaN(1,NUM_SESS);
errRate_Fast = NaN(1,NUM_SESS);  rt_Fast = NaN(1,NUM_SESS);

for kk = 1:NUM_SESS
  
  %index by condition
  idxAcc = (binfoSAT.condition{kk} == 1);
  idxFast = (binfoSAT.condition{kk} == 3);
  %index by trial outcome
  idxErr = (binfoSAT.err_dir{kk});
  
  rt_Acc(kk) = nanmedian(primarySacc.resptime{kk}(idxAcc));
  rt_Fast(kk) = nanmedian(primarySacc.resptime{kk}(idxFast));
  errRate_Acc(kk) = sum(idxAcc & idxErr) / sum(idxAcc);
  errRate_Fast(kk) = sum(idxFast & idxErr) / sum(idxFast);
  
end%for:session(kk)

%% Compute error rate and RT X condition X efficiency
idxMore = (binfoSAT.taskType == 1); NUM_MORE = sum(idxMore); %more efficient
idxLess = (binfoSAT.taskType == 2); NUM_LESS = sum(idxLess); %less efficient

%split RT by condition and efficiency
rt_AccMore = rt_Acc(idxMore);         rt_AccLess = rt_Acc(idxLess);
er_AccMore = errRate_Acc(idxMore);    er_AccLess = errRate_Acc(idxLess);
rt_FastMore = rt_Fast(idxMore);       rt_FastLess = rt_Fast(idxLess);
er_FastMore = errRate_Fast(idxMore);  er_FastLess = errRate_Fast(idxLess);

%compute mean and SE of response time
mu.RT_AM = mean(rt_AccMore);    se.RT_AM = std(rt_AccMore)/sqrt(NUM_MORE);
mu.RT_AL = mean(rt_AccLess);    se.RT_AL = std(rt_AccLess)/sqrt(NUM_LESS);
mu.RT_FM = mean(rt_FastMore);   se.RT_FM = std(rt_FastMore)/sqrt(NUM_MORE);
mu.RT_FL = mean(rt_FastLess);   se.RT_FL = std(rt_FastLess)/sqrt(NUM_LESS);
%compute mean and SE of error rate
mu.ER_AM = mean(er_AccMore);    se.ER_AM = std(er_AccMore)/sqrt(NUM_MORE);
mu.ER_AL = mean(er_AccLess);    se.ER_AL = std(er_AccLess)/sqrt(NUM_LESS);
mu.ER_FM = mean(er_FastMore);   se.ER_FM = std(er_FastMore)/sqrt(NUM_MORE);
mu.ER_FL = mean(er_FastLess);   se.ER_FL = std(er_FastLess)/sqrt(NUM_LESS);

%% Plotting
figure(); hold on
errorbarxy([mu.RT_FM mu.RT_AM], [mu.ER_FM mu.ER_AM], [se.RT_FM se.RT_AM], [se.ER_FM se.ER_AM], {'k-','k','k'})
errorbarxy([mu.RT_FL mu.RT_AL], [mu.ER_FL mu.ER_AL], [se.RT_FL se.RT_AL], [se.ER_FL se.ER_AL], {'k-','k','k'})
xlim([245 550]); ylim([.05 .45])
ppretty([4.8,3])

%% Stats
DIR_WRITE = 'C:\Users\Thomas Reppert\Dropbox\__SEF_SAT_\Stats\Behavior\';

DV_respTime = [rt_AccMore rt_AccLess rt_FastMore rt_FastLess];
DV_errRate = [er_AccMore er_AccLess er_FastMore er_FastLess];
F_Condition = [ones(1,NUM_SESS) 2*ones(1,NUM_SESS)];
F_Efficiency = [ones(1,NUM_MORE) 2*ones(1,NUM_LESS) ones(1,NUM_MORE) 2*ones(1,NUM_LESS)];

save([DIR_WRITE 'RT_X_Condition_X_Efficiency.mat'], 'DV_respTime','F_Condition','F_Efficiency')
save([DIR_WRITE 'ER_X_Condition_X_Efficiency.mat'], 'DV_errRate','F_Condition','F_Efficiency')

%compute stats for effect of condition
% ttestTom(rt_Acc, rt_Fast) %RT
% ttestTom(errRate_Acc, errRate_Fast) %error rate

end % fxn :: plot_SAT()

