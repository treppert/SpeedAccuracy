function [ ] = Fig2C_plotPupilData_SAT( behavData , pupilData )
%Fig2C_plotPupilData_SAT.m

t_Plot = 3500 + (-600 : +200); %window for viewing pupil dynamics
numSamp = length(t_Plot);

idx_Early = (-500 : -400) - (t_Plot(1)-3500); %windows for static pupil diameter
idx_Late  = (  50 :  150) - (t_Plot(1)-3500);

idxSessKeep = (ismember(behavData.Monkey, {'D','E'}) & behavData.Task_RecordedSEF);
behavData = behavData(idxSessKeep,:);
pupilData = pupilData(idxSessKeep,:);
numSess = size(behavData,1);

%initializations
pupil_Fast = NaN(numSess,numSamp);  pupStatic_Fast = NaN(numSess,2); %early and late
pupil_Acc  = NaN(numSess,numSamp);  pupStatic_Acc = NaN(numSess,2);

for kk = 1:numSess
  
  %index by task condition
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  
  pupil_FastCorr_kk = pupilData{kk}(idxFast & idxCorr, t_Plot);
  pupil_AccCorr_kk =  pupilData{kk}(idxAcc & idxCorr, t_Plot);
  
  pupil_Fast(kk,:) = nanmean(pupil_FastCorr_kk);
  pupil_Acc(kk,:)  = nanmean(pupil_AccCorr_kk);
  
  %compute early and late (static) pupil diameter estimates
  pupStatic_Fast(kk,1) = mean(pupil_Fast(kk,idx_Early));   pupStatic_Fast(kk,2) = mean(pupil_Fast(kk,idx_Late));
  pupStatic_Acc(kk,1) = mean(pupil_Acc(kk,idx_Early));     pupStatic_Acc(kk,2) = mean(pupil_Acc(kk,idx_Late));
  
end % for :: session (kk)

%compute mean and SE
mu_Fast = nanmean(pupil_Fast);                mu_Acc = nanmean(pupil_Acc);
se_Fast = nanstd(pupil_Fast)/sqrt(numSess);   se_Acc = nanstd(pupil_Acc)/sqrt(numSess);

figure(); hold on %dynamic plot
shaded_error_bar(t_Plot-3500, mu_Fast, se_Fast, {'-', 'Color',[0 .7 0], 'LineWidth',1.0}, true)
shaded_error_bar(t_Plot-3500, mu_Acc, se_Acc, {'-', 'Color','r', 'LineWidth',1.0}, true)
xlabel('Time from array (ms)'); ylabel('Pupil diameter (a.u.)')
ylim([-.02 .1]); ytickformat('%3.2f')
ppretty([4.8,3])


pupEarly = [ pupStatic_Acc(:,1) pupStatic_Fast(:,1) ];
pupLate  = [ pupStatic_Acc(:,2) pupStatic_Fast(:,2) ];

figure(); hold on %barplot
bar([1 2], mean(pupEarly), 'FaceColor',[.5 .5 .5])
bar([4 5], mean(pupLate), 'FaceColor',[.5 .5 .5])
errorbar([1 2], mean(pupEarly), std(pupEarly)/sqrt(numSess), 'Color','k', 'CapSize',0)
errorbar([4 5], mean(pupLate), std(pupLate)/sqrt(numSess), 'Color','k', 'CapSize',0)
title('Early :: Late')
xticks([]); ytickformat('%3.2f'); ppretty([4,3])

%run t-test on the late static measure of pupil
ttestFull(pupLate(:,1), pupLate(:,2), 'ylabel','Pupil', 'xticklabels',{'Acc','Fast'})

end % function : Fig2C_plotPupilData_SAT()

