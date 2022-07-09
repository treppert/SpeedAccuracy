function [  ] = Fig1D_Behav_X_Trial_Simple( behavData , varargin )
%Fig1D_Behav_X_Trial_Simple Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

TRIAL_PLOT = ( -4 : 3 );
NUM_TRIAL = length(TRIAL_PLOT);

%isolate sessions from MONKEY
sessKeep = (ismember(behavData.Monkey, args.monkey) & behavData.Task_RecordedSEF);
NUM_SESS = sum(sessKeep);   behavData = behavData(sessKeep, :);

%initialize response time (RT)
RT_A2F = NaN(NUM_SESS,NUM_TRIAL);
RT_F2A = RT_A2F;
RTerr_A2F = RT_A2F; %RT re. deadline
RTerr_F2A = RT_A2F;
%initialize error rate (ER)
ER_Chc_A2F = NaN(NUM_SESS,NUM_TRIAL);
ER_Chc_F2A = ER_Chc_A2F;
ER_Time_A2F = ER_Chc_A2F;
ER_Time_F2A = ER_Chc_F2A;

trialSwitch = identify_condition_switch( behavData );

%% Compute probability of error vs trial

for kk = 1:NUM_SESS
  RTkk = behavData.Sacc_RT{kk};
  
  %index by trial from condition switch
  jjA2F = trialSwitch.A2F{kk};  numA2F = length(jjA2F);
  jjF2A = trialSwitch.F2A{kk};  numF2A = length(jjF2A);
  
  RT_A2F(kk,:) = median(RTkk(jjA2F+TRIAL_PLOT));
  RT_F2A(kk,:) = median(RTkk(jjF2A+TRIAL_PLOT));
  
  %get RT relative to SAT deadlines
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  dlineAcc = median(double(behavData.Task_Deadline{kk}(idxAcc)));
  dlineFast = median(double(behavData.Task_Deadline{kk}(idxFast)));
  RTerr_A2F(kk,:) = RT_A2F(kk,:) - [repmat(dlineAcc,1,4), repmat(dlineFast,1,4)];
  RTerr_F2A(kk,:) = RT_F2A(kk,:) - [repmat(dlineFast,1,4), repmat(dlineAcc,1,4)];
  
  %index by trial outcome
  jjErrChc  = find(behavData.Task_ErrChoice{kk} & ~behavData.Task_Correct{kk});
  jjErrTime = find(behavData.Task_ErrTime{kk}  & ~behavData.Task_Correct{kk});
  
  ER_Chc_A2F(kk,:) = sum(ismember(jjA2F+TRIAL_PLOT, jjErrChc)) / numA2F;
  ER_Chc_F2A(kk,:) = sum(ismember(jjF2A+TRIAL_PLOT, jjErrChc)) / numF2A;
  ER_Time_A2F(kk,:) = sum(ismember(jjA2F+TRIAL_PLOT, jjErrTime)) / numA2F;
  ER_Time_F2A(kk,:) = sum(ismember(jjF2A+TRIAL_PLOT, jjErrTime)) / numF2A;
  
end % for : sessions(kk)

%% Plotting

XLABEL = {'','-3','','-1','+1','','+3','','','','-3','','-1','+1','','+3',''};
XLIM = [-4,11];
BLUE = [0 0 1];

figure()

subplot(4,1,1); hold on %Response time
errorbar(TRIAL_PLOT, mean(RT_F2A), std(RT_F2A)/sqrt(NUM_SESS), 'Color','k', 'CapSize',0)
errorbar(TRIAL_PLOT+NUM_TRIAL, mean(RT_A2F), std(RT_A2F)/sqrt(NUM_SESS), 'Color','k', 'CapSize',0)
xlim(XLIM); xticks(-5:12); xticklabels(XLABEL)
ylabel('Response time (ms)')

subplot(4,1,2); hold on %Response time re. deadline
errorbar(TRIAL_PLOT, mean(RTerr_F2A), std(RTerr_F2A)/sqrt(NUM_SESS), 'Color','k', 'CapSize',0)
errorbar(TRIAL_PLOT+NUM_TRIAL, mean(RTerr_A2F), std(RTerr_A2F)/sqrt(NUM_SESS), 'Color','k', 'CapSize',0)
xlim([-4 11]); xticks(-5:12); xticklabels(XLABEL)
ylabel('RT re. deadline (ms)')

subplot(4,1,3); hold on %Choice error rate
errorbar(TRIAL_PLOT, mean(ER_Chc_F2A), std(ER_Chc_F2A)/sqrt(NUM_SESS), 'Color','k', 'CapSize',0)
errorbar(TRIAL_PLOT+NUM_TRIAL, mean(ER_Chc_A2F), std(ER_Chc_A2F)/sqrt(NUM_SESS), 'Color','k', 'CapSize',0)
xlim([-4 11]); xticks(-5:12); xticklabels(XLABEL)
ylabel('Choice error rate'); ytickformat('%3.2f')

subplot(4,1,4); hold on %Timing error rate
errorbar(TRIAL_PLOT, mean(ER_Time_F2A), std(ER_Time_F2A)/sqrt(NUM_SESS), 'Color','k', 'CapSize',0)
errorbar(TRIAL_PLOT+NUM_TRIAL, mean(ER_Time_A2F), std(ER_Time_A2F)/sqrt(NUM_SESS), 'Color','k', 'CapSize',0)
xlim([-4 11]); xticks(-5:12); xticklabels(XLABEL)
ylabel('Timing error rate'); ytickformat('%3.2f')
xlabel('Trial from switch')

ppretty([1.75,7])
subplot(4,1,1); set(gca, 'XMinorTick','off', 'XTickLabelRotation',45, 'YColor',BLUE)
subplot(4,1,2); set(gca, 'XMinorTick','off', 'XTickLabelRotation',45, 'YColor',BLUE)
subplot(4,1,3); set(gca, 'XMinorTick','off', 'XTickLabelRotation',45, 'YColor',BLUE)
subplot(4,1,4); set(gca, 'XMinorTick','off', 'XTickLabelRotation',45, 'YColor',BLUE)

end % function : Fig1D_Behav_X_Trial_Simple()

