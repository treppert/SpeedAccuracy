function [ ] = Fig1C_ErrRate_X_RT( behavData , varargin )
%Fig1C_ErrRate_X_RT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

PLOT = true;
STATS = true;
PARAM = 'ER'; %{'RT','ER'}

%isolate sessions from MONKEY
kkKeep = (ismember(behavData.Monkey, args.monkey) & behavData.Task_RecordedSEF);
behavData = behavData(kkKeep, :);
NUM_SESS = sum(kkKeep);

%% Compute RT/ER and split on Task Condition
errRate_Acc = NaN(1,NUM_SESS);   rt_Acc = NaN(1,NUM_SESS);
errRate_Fast = NaN(1,NUM_SESS);  rt_Fast = NaN(1,NUM_SESS);

for kk = 1:NUM_SESS
  
  %index by condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1) & ~isnan(behavData.Task_Deadline{kk});
  idxFast = (behavData.Task_SATCondition{kk} == 3) & ~isnan(behavData.Task_Deadline{kk});
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrNoSacc{kk});
  idxErr = (behavData.Task_ErrChoice{kk});
  
  rt_Acc(kk) = median(behavData.Sacc_RT{kk}(idxAcc & idxCorr));
  rt_Fast(kk) = median(behavData.Sacc_RT{kk}(idxFast & idxCorr));
  errRate_Acc(kk) = sum(idxAcc & idxErr) / sum(idxAcc);
  errRate_Fast(kk) = sum(idxFast & idxErr) / sum(idxFast);
  
end%for:session(kk)


%% Split RT/ER on Search Difficulty
idxMore = (behavData.Task_LevelDifficulty == 1); NUM_MORE = sum(idxMore); %more efficient
idxLess = (behavData.Task_LevelDifficulty == 2); NUM_LESS = sum(idxLess); %less efficient

%split RT by condition and efficiency
rt_AccMore = rt_Acc(idxMore);         rt_AccLess = rt_Acc(idxLess);
er_AccMore = errRate_Acc(idxMore);    er_AccLess = errRate_Acc(idxLess);
rt_FastMore = rt_Fast(idxMore);       rt_FastLess = rt_Fast(idxLess);
er_FastMore = errRate_Fast(idxMore);  er_FastLess = errRate_Fast(idxLess);

%compute mean and SE of response time
mu.Sacc_RT_AM = mean(rt_AccMore);    se.Sacc_RT_AM = std(rt_AccMore)/sqrt(NUM_MORE);
mu.Sacc_RT_AL = mean(rt_AccLess);    se.Sacc_RT_AL = std(rt_AccLess)/sqrt(NUM_LESS);
mu.Sacc_RT_FM = mean(rt_FastMore);   se.Sacc_RT_FM = std(rt_FastMore)/sqrt(NUM_MORE);
mu.Sacc_RT_FL = mean(rt_FastLess);   se.Sacc_RT_FL = std(rt_FastLess)/sqrt(NUM_LESS);
%compute mean and SE of error rate
mu.ER_AM = mean(er_AccMore);    se.ER_AM = std(er_AccMore)/sqrt(NUM_MORE);
mu.ER_AL = mean(er_AccLess);    se.ER_AL = std(er_AccLess)/sqrt(NUM_LESS);
mu.ER_FM = mean(er_FastMore);   se.ER_FM = std(er_FastMore)/sqrt(NUM_MORE);
mu.ER_FL = mean(er_FastLess);   se.ER_FL = std(er_FastLess)/sqrt(NUM_LESS);


%% Plotting
if (PLOT)
  figure()

  subplot(1,3,1); hold on
  errorbarxy([mu.Sacc_RT_FM mu.Sacc_RT_AM], [mu.ER_FM mu.ER_AM], [se.Sacc_RT_FM se.Sacc_RT_AM], [se.ER_FM se.ER_AM], {'k-','k','k'})
  errorbarxy([mu.Sacc_RT_FL mu.Sacc_RT_AL], [mu.ER_FL mu.ER_AL], [se.Sacc_RT_FL se.Sacc_RT_AL], [se.ER_FL se.ER_AL], {'k-','k','k'})
  xlim([250 550]); ylim([.05 .45])

  subplot(1,3,2); hold on
  errorbar([mu.Sacc_RT_FM mu.Sacc_RT_AM], [se.Sacc_RT_FM se.Sacc_RT_AM], 'CapSize',0, 'LineWidth',1, 'Color','k')
  errorbar([mu.Sacc_RT_FL mu.Sacc_RT_AL], [se.Sacc_RT_FL se.Sacc_RT_AL], 'CapSize',0, 'LineWidth',2, 'Color','k')
  xlim([0.9 2.1]); xticks([1 2]); xticklabels({'Fast','Accurate'})

  subplot(1,3,3); hold on
  errorbar([mu.ER_FM mu.ER_AM], [se.ER_FM se.ER_AM], 'CapSize',0, 'LineWidth',1, 'Color','k')
  errorbar([mu.ER_FL mu.ER_AL], [se.ER_FL se.ER_AL], 'CapSize',0, 'LineWidth',2, 'Color','k')
  xlim([0.9 2.1]); xticks([1 2]); xticklabels({'Fast','Accurate'})

  ppretty([8,1.8])
end

%% Stats -- Two-way between-subjects ANOVA
if (STATS)
  RespTime = [rt_AccMore rt_AccLess rt_FastMore rt_FastLess]';
  ErrorRate = [er_AccMore er_AccLess er_FastMore er_FastLess]';
  F_Condition = [ones(1,NUM_SESS) 2*ones(1,NUM_SESS)]';
  F_Efficiency = [ones(1,NUM_MORE) 2*ones(1,NUM_LESS) ones(1,NUM_MORE) 2*ones(1,NUM_LESS)]';
  F_Session = [(1:NUM_SESS) (1:NUM_SESS)];
  
  anova_TwoWay_Between_SAT(RespTime, F_Condition, F_Efficiency, 'display','on', 'model','full', 'sstype',3)
  anova_TwoWay_Between_SAT(ErrorRate, F_Condition, F_Efficiency, 'display','on', 'model','full', 'sstype',3)
  
  rootDirStats = 'C:\Users\Tom\Dropbox\Speed Accuracy\__SEF_SAT\Data\Stats\';
  if ~exist([rootDirStats 'Fig1_RespTime.mat'], 'file')
    save([rootDirStats 'Fig1_RespTime.mat'], 'RespTime','F_Condition','F_Efficiency','F_Session')
  end
  if ~exist([rootDirStats 'Fig1_ErrorRate.mat'], 'file')
    save([rootDirStats 'Fig1_ErrorRate.mat'], 'ErrorRate','F_Condition','F_Efficiency','F_Session')
  end
end %if(STATS)

end
