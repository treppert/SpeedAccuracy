function [ ] = plotPupilData_SAT( binfoSAT , pupilData )
%plotPupilData_SAT Summary of this function goes here
%   Detailed explanation goes here

t_Plot = 3500 + (-600 : +200); %window for viewing pupil dynamics
numSamp = length(t_Plot);

idx_Early = (-500 : -400) - (t_Plot(1)-3500); %windows for static pupil diameter
idx_Late  = (50 : 150)    - (t_Plot(1)-3500);

behavInfo = binfoSAT(1:14,:);
numSess = size(behavInfo,1);

%initializations
pupil_Fast = NaN(numSess,numSamp);  pupAvg_Fast = NaN(numSess,2); %early and late
pupil_Acc  = NaN(numSess,numSamp);  pupAvg_Acc = NaN(numSess,2);

for kk = 1:numSess
  
  %index by task condition
  idxFast = (behavInfo.condition{kk} == 3);
  idxAcc = (behavInfo.condition{kk} == 1);
  %index by trial outcome
  idxCorr = ~(behavInfo.err_time{kk} | behavInfo.err_dir{kk} | behavInfo.err_hold{kk} | behavInfo.err_nosacc{kk});
  
  pupil_FastCorr_kk = pupilData{kk}(idxFast & idxCorr, t_Plot);
  pupil_AccCorr_kk =  pupilData{kk}(idxAcc & idxCorr, t_Plot);
  
  pupil_Fast(kk,:) = nanmean(pupil_FastCorr_kk);
  pupil_Acc(kk,:)  = nanmean(pupil_AccCorr_kk);
  
  %compute early and late (static) pupil diameter estimates
  pupAvg_Fast(kk,1) = mean(pupil_Fast(kk,idx_Early));   pupAvg_Fast(kk,2) = mean(pupil_Fast(kk,idx_Late));
  pupAvg_Acc(kk,1) = mean(pupil_Acc(kk,idx_Early));     pupAvg_Acc(kk,2) = mean(pupil_Acc(kk,idx_Late));
  
end % for :: session (kk)

%split sessions by task difficulty
idx_Easy = (behavInfo.taskType == 1); numEasy = sum(idx_Easy); %less difficult
idx_Hard = (behavInfo.taskType == 2); numHard = sum(idx_Hard); %more difficult

pupil_Acc_Easy = pupil_Acc(idx_Easy,:);   pupil_Fast_Easy = pupil_Fast(idx_Easy,:);
pupil_Acc_Hard = pupil_Acc(idx_Hard,:);   pupil_Fast_Hard = pupil_Fast(idx_Hard,:);

%compute mean and s.e.
mu_Fast_Easy = nanmean(pupil_Fast_Easy);    se_Fast_Easy = nanstd(pupil_Fast_Easy) / sqrt(numEasy);
mu_Fast_Hard = nanmean(pupil_Fast_Hard);    se_Fast_Hard = nanstd(pupil_Fast_Hard) / sqrt(numHard);
mu_Acc_Easy =  nanmean(pupil_Acc_Easy);     se_Acc_Easy = nanstd(pupil_Acc_Easy) / sqrt(numEasy);
mu_Acc_Hard =  nanmean(pupil_Acc_Hard);     se_Acc_Hard = nanstd(pupil_Acc_Hard) / sqrt(numHard);


%% Plotting - Pupil dynamics
figure() %dynamic plot

subplot(1,2,1); hold on %less difficult
plot([t_Plot(1) t_Plot(end)] - 3500, [0 0], 'k:')
shaded_error_bar(t_Plot-3500, mu_Fast_Easy, se_Fast_Easy, {'-', 'Color',[0 .7 0], 'LineWidth',1.0}, true)
shaded_error_bar(t_Plot-3500, mu_Acc_Easy, se_Acc_Easy, {'-', 'Color','r', 'LineWidth',1.0}, true)
xlabel('Time from array (ms)'); ylabel('Pupil diameter (a.u.)')
title('Less Difficult')
ylim([-.02 .1]); ytickformat('%3.2f')

subplot(1,2,2); hold on %more difficult
plot([t_Plot(1) t_Plot(end)] - 3500, [0 0], 'k:')
shaded_error_bar(t_Plot-3500, mu_Fast_Hard, se_Fast_Hard, {'-', 'Color',[0 .7 0], 'LineWidth',1.75}, true)
shaded_error_bar(t_Plot-3500, mu_Acc_Hard, se_Acc_Hard, {'-', 'Color','r', 'LineWidth',1.75}, true)
title('More Difficult')
ylim([-.02 .1]); yticks([])

ppretty([6,3])


%% Plotting - Barplot
pupStatic_Acc_Easy = pupAvg_Acc(idx_Easy,:); pupStatic_Fast_Easy = pupAvg_Fast(idx_Easy,:);
pupStatic_Acc_Hard = pupAvg_Acc(idx_Hard,:); pupStatic_Fast_Hard = pupAvg_Fast(idx_Hard,:);

pupEarly = [pupStatic_Acc_Easy(:,1) pupStatic_Fast_Easy(:,1) pupStatic_Acc_Hard(:,1) pupStatic_Fast_Hard(:,1)];
pupLate  = [pupStatic_Acc_Easy(:,2) pupStatic_Fast_Easy(:,2) pupStatic_Acc_Hard(:,2) pupStatic_Fast_Hard(:,2)];

figure(); hold on %barplot
bar((1:4), mean(pupEarly), 'FaceColor',[.5 .5 .5])
bar((6:9), mean(pupLate), 'FaceColor',[.5 .5 .5])
errorbar((1:4), mean(pupEarly), std(pupEarly)/sqrt(numEasy), 'Color','k', 'CapSize',0)
errorbar((6:9), mean(pupLate), std(pupLate)/sqrt(numEasy), 'Color','k', 'CapSize',0)
title('Early :: Late')
xticks([]); ytickformat('%3.2f'); ppretty([4,3])


%% Stats - ANOVA
%run two-way ANOVA on the static windows
windowTest = 1; %1=Early window, 2=Late window
DV_Pupil = [pupStatic_Acc_Easy(:,windowTest); pupStatic_Acc_Hard(:,windowTest); ...
  pupStatic_Fast_Easy(:,windowTest); pupStatic_Fast_Hard(:,windowTest)];
F_Condition = [ones(numEasy+numHard,1); 2*ones(numEasy+numHard,1)];
F_Difficulty = [ones(numEasy,1); 2*ones(numHard,1); ones(numEasy,1); 2*ones(numHard,1)];

[~,tblAnova] = anovan(DV_Pupil, {F_Condition F_Difficulty}, 'model','full', ...
  'varnames',{'Condition','Difficulty'}, 'display','on', 'sstype',2);

end%fxn:plotPupilData_SAT()
