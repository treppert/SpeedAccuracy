function [  ] = Fig1D_Behav_X_Trial( behavData , varargin )
%Fig1D_Behav_X_Trial Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

TRIAL_PLOT = ( -4 : 3 );
NUM_TRIAL = length(TRIAL_PLOT);

%isolate sessions from MONKEY
sessKeep = (ismember(behavData.Monkey, args.monkey) & behavData.Task_RecordedSEF);
NUM_SESS = sum(sessKeep);   behavData = behavData(sessKeep, :);

%initialize error rate (ER)
ER_A2F = NaN(NUM_SESS,NUM_TRIAL);
ER_F2A = NaN(NUM_SESS,NUM_TRIAL);
%initialize response time (RT)
RT_A2F = NaN(NUM_SESS,NUM_TRIAL);
RT_F2A = NaN(NUM_SESS,NUM_TRIAL);

trialSwitch = identify_condition_switch( behavData );

%% Compute probability of error vs trial

for kk = 1:NUM_SESS
  RTkk = behavData.Sacc_RT{kk};
  
  %index by condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  dlineAcc = nanmedian(behavData.Task_Deadline{kk}(idxAcc));
  dlineFast = nanmedian(behavData.Task_Deadline{kk}(idxFast));
  dlineA2F = [repmat(dlineAcc,1,4), repmat(dlineFast,1,4)];
  dlineF2A = [repmat(dlineFast,1,4), repmat(dlineAcc,1,4)];
  
  %index by trial from condition switch
  jjA2F = trialSwitch.A2F{kk};  numA2F = length(jjA2F);
  jjF2A = trialSwitch.F2A{kk};  numF2A = length(jjF2A);
  
  %index by trial outcome
  jjCorr  = find(behavData.Task_Correct{kk});
  jjErrChc = find(behavData.Task_ErrChoice{kk} & ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  jjErrTime = find(behavData.Task_ErrTime{kk} & ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  
  for jj = 1:NUM_TRIAL    
    jj_RT_A2F = intersect(jjCorr, jjA2F + TRIAL_PLOT(jj));
    jj_RT_F2A = intersect(jjCorr, jjF2A + TRIAL_PLOT(jj));
    RT_A2F(kk,jj) = median(RTkk(jj_RT_A2F)) - dlineA2F(jj);
    RT_F2A(kk,jj) = median(RTkk(jj_RT_F2A)) - dlineF2A(jj);
    
    jj_ER_A2F = intersect(jjErrTime, jjA2F + TRIAL_PLOT(jj));
    jj_ER_F2A = intersect(jjErrTime, jjF2A + TRIAL_PLOT(jj));
    ER_A2F(kk,jj) = length(jj_ER_A2F) / numA2F;
    ER_F2A(kk,jj) = length(jj_ER_F2A) / numF2A;
  end % for : trials(jj)
  
end % for : sessions(kk)

%index by search difficulty
idxMoreDiff = (behavData.Task_LevelDifficulty == 2);  numMore = sum(idxMoreDiff);
idxLessDiff = (behavData.Task_LevelDifficulty == 1);  numLess = sum(idxLessDiff);

RT_A2F_More = RT_A2F(idxMoreDiff,:);      RT_A2F_Less = RT_A2F(idxLessDiff,:);
RT_F2A_More = RT_F2A(idxMoreDiff,:);      RT_F2A_Less = RT_F2A(idxLessDiff,:);
ER_A2F_More = ER_A2F(idxMoreDiff,:);      ER_A2F_Less = ER_A2F(idxLessDiff,:);
ER_F2A_More = ER_F2A(idxMoreDiff,:);      ER_F2A_Less = ER_F2A(idxLessDiff,:);

%% Plotting

figure()

subplot(2,1,1); hold on %Response Time
errorbar(TRIAL_PLOT+0.1, mean(RT_F2A_Less), std(RT_F2A_Less)/sqrt(numLess), 'Color','k', 'LineWidth',0.75, 'CapSize',0)
errorbar(TRIAL_PLOT+NUM_TRIAL+0.1, mean(RT_A2F_Less), std(RT_A2F_Less)/sqrt(numLess), 'Color','k', 'LineWidth',0.75, 'CapSize',0)
errorbar(TRIAL_PLOT-0.1, mean(RT_F2A_More), std(RT_F2A_More)/sqrt(numMore), 'Color','k', 'LineWidth',1.75, 'CapSize',0)
errorbar(TRIAL_PLOT+NUM_TRIAL-0.1, mean(RT_A2F_More), std(RT_A2F_More)/sqrt(numMore), 'Color','k', 'LineWidth',1.75, 'CapSize',0)
xlim([-5 12]); xticks(-5:12); xticklabels(cell(1,12))

subplot(2,1,2); hold on %Error Rate
errorbar(TRIAL_PLOT+0.1, mean(ER_F2A_Less), std(ER_F2A_Less)/sqrt(numLess), 'Color','k', 'LineWidth',0.75, 'CapSize',0)
errorbar(TRIAL_PLOT+NUM_TRIAL+0.1, mean(ER_A2F_Less), std(ER_A2F_Less)/sqrt(numLess), 'Color','k', 'LineWidth',0.75, 'CapSize',0)
errorbar(TRIAL_PLOT-0.1, mean(ER_F2A_More), std(ER_F2A_More)/sqrt(numMore), 'Color','k', 'LineWidth',1.75, 'CapSize',0)
errorbar(TRIAL_PLOT+NUM_TRIAL-0.1, mean(ER_A2F_More), std(ER_A2F_More)/sqrt(numMore), 'Color','k', 'LineWidth',1.75, 'CapSize',0)
xlim([-5 12]); xticks(-5:12); xticklabels(cell(1,12))

ppretty([4,4.8])

end%function:plot_ErrRate_X_Trial()

