function [ ] = plotPupil_CorrectVsError( binfoSAT , pupilData )
%plotPupil_CorrectVsError Summary of this function goes here
%   Detailed explanation goes here

t_Plot = 3500 + (-600 : +250); %window for viewing pupil dynamics
numSamp = length(t_Plot);

idx_Early = (-500 : -400) - (t_Plot(1)-3500); %windows for static pupil diameter
idx_Late  = (50 : 150)    - (t_Plot(1)-3500);

behavInfo = binfoSAT(1:14,:); %isolate data for Da and Eu
numSess = size(behavInfo,1);

%initializations
pupil_FC = NaN(numSess,numSamp); %Fast correct
pupil_AC  = NaN(numSess,numSamp); %Accurate correct
pupil_FED = NaN(numSess,numSamp); %Fast error direction
pupil_AET = NaN(numSess,numSamp); %Accurate error time

pupAvg_FC = NaN(numSess,2); %avg. values: early and late
pupAvg_AC = NaN(numSess,2);
pupAvg_FED = NaN(numSess,2);
pupAvg_AET = NaN(numSess,2);

for kk = 1:numSess
  
  %index by task condition
  idxFast = (behavInfo.condition{kk} == 3);
  idxAcc = (behavInfo.condition{kk} == 1);
  
  %index by trial outcome
  idxCorr = ~(behavInfo.err_time{kk} | behavInfo.err_dir{kk} | behavInfo.err_hold{kk} | behavInfo.err_nosacc{kk});
  idxErrChc = (behavInfo.err_dir{kk});
  idxErrTime = (behavInfo.err_time{kk});
  
  %isolate pupil trial-to-trial pupil dynamics
  pupil_FC_kk = pupilData{kk}(idxFast & idxCorr, t_Plot);
  pupil_AC_kk = pupilData{kk}(idxAcc & idxCorr, t_Plot);
  pupil_FED_kk = pupilData{kk}(idxFast & idxErrChc, t_Plot);
  pupil_AET_kk = pupilData{kk}(idxAcc & idxErrTime, t_Plot);
  
  %compute mean pupil dynamics x condition
  pupil_FC(kk,:) = nanmean(pupil_FC_kk);
  pupil_AC(kk,:) = nanmean(pupil_AC_kk);
  pupil_FED(kk,:) = nanmean(pupil_FED_kk);
  pupil_AET(kk,:) = nanmean(pupil_AET_kk);
  
  %compute early and late (mean) pupil diameter estimates
  pupAvg_FC(kk,:) = [ mean(pupil_FC(kk,idx_Early)) , mean(pupil_FC(kk,idx_Late)) ];
  pupAvg_AC(kk,:) = [ mean(pupil_AC(kk,idx_Early)) , mean(pupil_AC(kk,idx_Late)) ];
  pupAvg_FED(kk,:) = [ mean(pupil_FED(kk,idx_Early)) , mean(pupil_FED(kk,idx_Late)) ];
  pupAvg_AET(kk,:) = [ mean(pupil_AET(kk,idx_Early)) , mean(pupil_AET(kk,idx_Late)) ];
  
end % for :: session (kk)

%compute mean and standard error
mu_FC = nanmean(pupil_FC);      se_FC = nanstd(pupil_FC) / sqrt(numSess);
mu_AC = nanmean(pupil_AC);      se_AC = nanmean(pupil_AC) / sqrt(numSess);
mu_FED = nanmean(pupil_FED);     se_FED = nanmean(pupil_FED) / sqrt(numSess);
mu_AET = nanmean(pupil_AET);     se_AET = nanmean(pupil_AET) / sqrt(numSess);


%% Plotting - Dynamics
figure()

subplot(2,1,1); hold on %Fast: Correct vs. choice error
plot([t_Plot(1) t_Plot(end)] - 3500, [0 0], 'k:')
shaded_error_bar(t_Plot-3500, mu_FC, se_FC, {'-', 'Color',[0 .7 0], 'LineWidth',1.0}, true)
shaded_error_bar(t_Plot-3500, mu_FED, se_FED, {'--', 'Color',[0 .7 0], 'LineWidth',1.0}, true)
ylim([-.02 .1]); ytickformat('%3.2f'); xlim([-700 300])

subplot(2,1,2); hold on %Accurate: Correct vs. timing error
plot([t_Plot(1) t_Plot(end)] - 3500, [0 0], 'k:')
shaded_error_bar(t_Plot-3500, mu_AC, se_AC, {'-', 'Color','r', 'LineWidth',1.0}, true)
shaded_error_bar(t_Plot-3500, mu_AET, se_AET, {'--', 'Color','r', 'LineWidth',1.0}, true)
xlabel('Time from array (ms)'); ylabel('Pupil diameter (a.u.)')
ylim([-.02 .1]); ytickformat('%3.2f'); xlim([-700 300])

ppretty([4,6])


%% Summary and stats
pupilAvg_Fast = [ pupAvg_FC(:,1) pupAvg_FED(:,1) pupAvg_FC(:,2) pupAvg_FED(:,2) ];
pupilAvg_Acc =  [ pupAvg_AC(:,1) pupAvg_AET(:,1) pupAvg_AC(:,2) pupAvg_AET(:,2) ];

figure()

subplot(2,1,1); hold on
bar(1:4, mean(pupilAvg_Fast), 'FaceColor',[0 .7 0])
errorbar(1:4, mean(pupilAvg_Fast), std(pupilAvg_Fast)/sqrt(numSess), 'Color','k', 'CapSize',0)
xticks([]); ylim([0 .1]); ytickformat('%3.2f')

subplot(2,1,2); hold on
bar(1:4, mean(pupilAvg_Acc), 'FaceColor','r')
errorbar(1:4, mean(pupilAvg_Acc), std(pupilAvg_Acc)/sqrt(numSess), 'Color','k', 'CapSize',0)
xticks([]); ylim([0 .1]); ytickformat('%3.2f')

ppretty([2,6])

%perform a t-test on mean pupil size for late window
[~,pFast] = ttest(pupilAvg_Fast(:,3), pupilAvg_Fast(:,4));
[~,pAcc]  = ttest(pupilAvg_Acc(:,3), pupilAvg_Acc(:,4));
fprintf('Fast: p = %d\n', pFast)
fprintf('Acc: p = %d\n', pAcc)

end % fxn:plotPupil_CorrectVsError()
