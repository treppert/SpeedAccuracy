function [ ] = plotPupil_Re_Reward( binfoSAT , pupilData )
%plotPupil_Re_Reward Summary of this function goes here
%   Detailed explanation goes here

t_Plot = 3500 + (-400 : +200); %window for viewing pupil dynamics
numSamp = length(t_Plot);

idx_Avg = (-200 : 0) - (t_Plot(1)-3500); %window for mean pupil size

tRew_Max = 1800; %maximum acceptable value of reward time from array

behavInfo = binfoSAT(1:14,:);
numSess = size(behavInfo,1);

%initializations
pupil_Fast = NaN(numSess,numSamp);  pupAvg_Fast = NaN(1,numSess);
pupil_Acc  = NaN(numSess,numSamp);  pupAvg_Acc  = NaN(1,numSess);


%% Align pupil size data on time of reward
for kk = 1:numSess
  
  tReward = double(behavInfo.resptime{kk}) + double(behavInfo.rewtime{kk});
  trialNaN = find(isnan(tReward) | (tReward > tRew_Max));
  
  for jj = 1:behavInfo.num_trials(kk)
    if ismember(jj, trialNaN)
      pupilData{kk}(jj,:) = NaN;
    else
      pupilData{kk}(jj,:) = circshift(pupilData{kk}(jj,:), -tReward(jj), 2);
    end
  end%for:trial(jj)
  
end%for:session(kk)


%% Compute pupil size dynamics X SAT condition
for kk = 1:numSess
  
  %index by task condition
  idxFast = (behavInfo.condition{kk} == 3);
  idxAcc = (behavInfo.condition{kk} == 1);
  %index by trial outcome
  idxCorr = ~(behavInfo.err_time{kk} | behavInfo.err_dir{kk} | behavInfo.err_hold{kk} | behavInfo.err_nosacc{kk});
  
  pupil_Fast_kk = pupilData{kk}(idxFast & idxCorr, t_Plot);
  pupil_Acc_kk =  pupilData{kk}(idxAcc & idxCorr, t_Plot);
  
  pupil_Fast(kk,:) = nanmean(pupil_Fast_kk);
  pupil_Acc(kk,:)  = nanmean(pupil_Acc_kk);
  
  %compute mean estimate of pupil size
  pupAvg_Fast(kk) = mean(pupil_Fast(kk,idx_Avg));
  pupAvg_Acc(kk) = mean(pupil_Acc(kk,idx_Avg));
  
end % for :: session (kk)

%% Plotting - Pupil dynamics
%compute mean and s.e.
mu_Fast = nanmean(pupil_Fast);  se_Fast = nanstd(pupil_Fast) / sqrt(numSess);
mu_Acc  = nanmean(pupil_Acc);   se_Acc  = nanstd(pupil_Acc)  / sqrt(numSess);

figure(); hold on
plot([t_Plot(1) t_Plot(end)] - 3500, [0 0], 'k:')
shaded_error_bar(t_Plot-3500, mu_Fast, se_Fast, {'-', 'Color',[0 .7 0], 'LineWidth',1.0}, true)
shaded_error_bar(t_Plot-3500, mu_Acc,  se_Acc,  {'-', 'Color','r', 'LineWidth',1.0}, true)
xlabel('Time from array (ms)'); ylabel('Pupil diameter (a.u.)')
%ylim([-.02 .1]); ytickformat('%3.2f')
ppretty([6,3])


%% Plotting - Barplot
figure(); hold on %barplot
bar(1, mean(pupAvg_Acc), 'FaceColor','r')
bar(2, mean(pupAvg_Fast), 'FaceColor',[0 .7 0])
errorbar(1, mean(pupAvg_Acc), std(pupAvg_Acc)/sqrt(numSess), 'Color','k', 'CapSize',0)
errorbar(2, mean(pupAvg_Fast), std(pupAvg_Fast)/sqrt(numSess), 'Color','k', 'CapSize',0)
xticks([]); ytickformat('%3.2f'); ppretty([2,4])

%perform a t-test on mean pupil size re. reward
[~,pval] = ttest(pupAvg_Acc', pupAvg_Fast');
fprintf('p-value = %d\n', pval)


end % fxn:plotPupil_Re_Reward()
