function [  ] = Fig06A_Plot_TErrRate_X_Trial( bInfo )
%Fig06A_Plot_TErrRate_X_Trial Summary of this function goes here
%   Detailed explanation goes here

MONKEY = {'D','E'};
TRIAL_PLOT = ( -4 : 3 );
NUM_TRIAL = length(TRIAL_PLOT);

sessKeep = (ismember(bInfo.monkey, MONKEY) & bInfo.recordedSEF);
bInfo = bInfo(sessKeep,:);
NUM_SESS = sum(sessKeep);

%initialize error rate (ER)
ER_A2F = NaN(NUM_SESS,NUM_TRIAL);
ER_F2A = NaN(NUM_SESS,NUM_TRIAL);

trialSwitch = identify_condition_switch( bInfo );

%% Compute probability of error vs trial

for kk = 1:NUM_SESS
  
  %index by trial from condition switch
  jjA2F = trialSwitch.A2F{kk};  numA2F = length(jjA2F);
  jjF2A = trialSwitch.F2A{kk};  numF2A = length(jjF2A);
  
  %index by trial outcome
  jjErr = find(bInfo.err_time{kk});
  
  for jj = 1:NUM_TRIAL    
    jj_ER_A2F = intersect(jjErr, jjA2F + TRIAL_PLOT(jj));
    jj_ER_F2A = intersect(jjErr, jjF2A + TRIAL_PLOT(jj));
    ER_A2F(kk,jj) = length(jj_ER_A2F) / numA2F;
    ER_F2A(kk,jj) = length(jj_ER_F2A) / numF2A;
  end % for : trials(jj)
  
end % for : sessions(kk)

%index by search difficulty
idxMoreDiff = (bInfo.taskType == 2);  numMore = sum(idxMoreDiff);
idxLessDiff = (bInfo.taskType == 1);  numLess = sum(idxLessDiff);

ER_A2F_More = ER_A2F(idxMoreDiff,:);      ER_A2F_Less = ER_A2F(idxLessDiff,:);
ER_F2A_More = ER_F2A(idxMoreDiff,:);      ER_F2A_Less = ER_F2A(idxLessDiff,:);

%% Plotting

% figure(); hold on
% errorbar(TRIAL_PLOT+0.1, mean(ER_F2A_Less), std(ER_F2A_Less)/sqrt(numLess), 'Color','k', 'LineWidth',0.75, 'CapSize',0)
% errorbar(TRIAL_PLOT+NUM_TRIAL+0.1, mean(ER_A2F_Less), std(ER_A2F_Less)/sqrt(numLess), 'Color','k', 'LineWidth',0.75, 'CapSize',0)
% errorbar(TRIAL_PLOT-0.1, mean(ER_F2A_More), std(ER_F2A_More)/sqrt(numMore), 'Color','k', 'LineWidth',1.75, 'CapSize',0)
% errorbar(TRIAL_PLOT+NUM_TRIAL-0.1, mean(ER_A2F_More), std(ER_A2F_More)/sqrt(numMore), 'Color','k', 'LineWidth',1.75, 'CapSize',0)
% xlim([-5 12]); xticks(-5:12); xticklabels(cell(1,12))
% ppretty([3.2,2], 'XMinorTick','off')


%% Stats - One-way ANOVA with Factor Trial (test sudden increase)
errRate_Acc = [ER_F2A_More(:,5:8), ER_A2F_More(:,1:4); ER_F2A_Less(:,5:8), ER_A2F_Less(:,1:4)];
DV_errRate = reshape(errRate_Acc', NUM_SESS*NUM_TRIAL,1);
F_Trial = TRIAL_PLOT; F_Trial = repmat(F_Trial, 1,NUM_SESS)';
anovan(DV_errRate, {F_Trial});
% bf10 = bfFromF(F,df1,df2,n)

end % function : Fig06A_Plot_TErrRate_X_Trial()

