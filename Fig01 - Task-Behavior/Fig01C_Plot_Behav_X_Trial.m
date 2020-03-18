function [  ] = Fig01C_Plot_Behav_X_Trial( binfo )
%Fig01C_Plot_Behav_X_Trial Summary of this function goes here
%   Detailed explanation goes here

TRIAL_PLOT = ( -4 : 3 );
NUM_TRIAL = length(TRIAL_PLOT);

%isolate sessions from MONKEY
MONKEY = {'D','E'};         sessKeep = ismember(binfo.monkey, MONKEY);
NUM_SESS = sum(sessKeep);   binfo = binfo(sessKeep, :);

%initialize error rate (ER)
ER_A2F = NaN(NUM_SESS,NUM_TRIAL);
ER_F2A = NaN(NUM_SESS,NUM_TRIAL);
%initialize response time (RT)
RT_A2F = NaN(NUM_SESS,NUM_TRIAL);
RT_F2A = NaN(NUM_SESS,NUM_TRIAL);

trialSwitch = identify_condition_switch( binfo );

%% Compute probability of error vs trial

for kk = 1:NUM_SESS
  
  jjErr = find(binfo.err_dir{kk}); %note: err_dir OR err_time
  
  jjA2F = trialSwitch.A2F{kk};  numA2F = length(jjA2F);
  jjF2A = trialSwitch.F2A{kk};  numF2A = length(jjF2A);
  
  for jj = 1:NUM_TRIAL
    ER_A2F(kk,jj) = length(intersect(jjErr,jjA2F + TRIAL_PLOT(jj))) / numA2F;
    ER_F2A(kk,jj) = length(intersect(jjErr,jjF2A + TRIAL_PLOT(jj))) / numF2A;
    RT_A2F(kk,jj) = nanmean(binfo.resptime{kk}(jjA2F + TRIAL_PLOT(jj)));
    RT_F2A(kk,jj) = nanmean(binfo.resptime{kk}(jjF2A + TRIAL_PLOT(jj)));
  end % for : trials(jj)
  
end % for : sessions(kk)

%index by search difficulty
idxMoreDiff = (binfo.taskType == 2);  numMore = sum(idxMoreDiff);
idxLessDiff = (binfo.taskType == 1);  numLess = sum(idxLessDiff);

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

ppretty([6.4,7])

end%function:plot_ErrRate_X_Trial()

