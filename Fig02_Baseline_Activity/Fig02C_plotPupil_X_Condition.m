function [ ] = Fig02C_plotPupil_X_Condition( bInfo , pupilData )
%Fig02C_plotPupil_X_Condition Summary of this function goes here
%   Detailed explanation goes here

%only for Da and Eu (no pupil data for Q or S)
bInfo(17:end,:) = [];
bInfo([1,10],:) = []; %remove first session for Da/Eu (one SC neuron)
pupilData([1,10]) = [];

t_Plot = 3500 + (-600 : +200); %window for viewing pupil dynamics
numSamp = length(t_Plot);

idx_Early = (-500 : -400) - (t_Plot(1)-3500); %windows for static pupil diameter
idx_Late  = (50 : 150)    - (t_Plot(1)-3500);

MONKEY = {'D','E'};

idxMonkey = ismember(bInfo.monkey, MONKEY);
idxAreaRecorded = (bInfo.recordedSC);
idxKeep = (idxMonkey & idxAreaRecorded);

bInfo = bInfo(idxKeep,:);
pupilData = pupilData(idxKeep);
numSess = sum(idxKeep);

%initializations
pupil_Fast = NaN(numSess,numSamp);  pupAvg_Fast = NaN(numSess,2); %early and late
pupil_Acc  = NaN(numSess,numSamp);  pupAvg_Acc = NaN(numSess,2);

for kk = 1:numSess
  
  %index by task condition
  idxFast = (bInfo.condition{kk} == 3);
  idxAcc = (bInfo.condition{kk} == 1);
  %index by trial outcome
  idxCorr = ~(bInfo.err_time{kk} | bInfo.err_dir{kk} | bInfo.err_hold{kk} | bInfo.err_nosacc{kk});
  
  pupil_FastCorr_kk = pupilData{kk}(idxFast & idxCorr, t_Plot);
  pupil_AccCorr_kk =  pupilData{kk}(idxAcc & idxCorr, t_Plot);
  
  pupil_Fast(kk,:) = nanmean(pupil_FastCorr_kk);
  pupil_Acc(kk,:)  = nanmean(pupil_AccCorr_kk);
  
  %compute early and late (static) pupil diameter estimates
  pupAvg_Fast(kk,1) = mean(pupil_Fast(kk,idx_Early));   pupAvg_Fast(kk,2) = mean(pupil_Fast(kk,idx_Late));
  pupAvg_Acc(kk,1) = mean(pupil_Acc(kk,idx_Early));     pupAvg_Acc(kk,2) = mean(pupil_Acc(kk,idx_Late));
  
end % for :: session (kk)

%compute mean and s.e.
mu_Fast = nanmean(pupil_Fast);    se_Fast = nanstd(pupil_Fast) / sqrt(numSess);
mu_Acc =  nanmean(pupil_Acc);     se_Acc = nanstd(pupil_Acc) / sqrt(numSess);


%% Plotting - Pupil dynamics
figure(); hold on %dynamic plot
plot([t_Plot(1) t_Plot(end)] - 3500, [0 0], 'k:')
shaded_error_bar(t_Plot-3500, mu_Fast, se_Fast, {'-', 'Color',[0 .7 0], 'LineWidth',1.0}, true)
shaded_error_bar(t_Plot-3500, mu_Acc, se_Acc, {'-', 'Color','r', 'LineWidth',1.0}, true)
xlabel('Time from array (ms)'); ylabel('Pupil diameter (a.u.)')
ylim([-.02 .1]); ytickformat('%3.2f')
ppretty([4.8,3])


%% Plotting - Barplot
pupEarly = [pupAvg_Acc(:,1) pupAvg_Fast(:,1)];
pupLate  = [pupAvg_Acc(:,2) pupAvg_Fast(:,2)];

figure(); hold on %barplot
bar((1:2), mean(pupEarly), 'FaceColor',[.5 .5 .5])
bar((3:4), mean(pupLate), 'FaceColor',[.5 .5 .5])
errorbar((1:2), mean(pupEarly), std(pupEarly)/sqrt(numSess), 'Color','k', 'CapSize',0)
errorbar((3:4), mean(pupLate), std(pupLate)/sqrt(numSess), 'Color','k', 'CapSize',0)
xticks([]); ytickformat('%3.2f'); ppretty([2,3])


%% Stats - Paired t-test
% fprintf('Early epoch:\n')
% ttestTom(pupAvg_Acc(:,1), pupAvg_Fast(:,1), 'paired')
fprintf('Late epoch:\n')
ttestTom(pupAvg_Acc(:,2), pupAvg_Fast(:,2), 'paired')

end % fxn : Fig02C_plotPupil_X_Condition()
