function [ ] = plotPupilData_FromReward_SAT( pupilData , behavData )
%plotPupilData_FromReward_SAT Summary of this function goes here
%   Detailed explanation goes here
DIR_PRINT = 'C:\Users\Thomas Reppert\Dropbox\SAT\Figures\Pupil\FromReward\';

T_ARRAY = 3500;
T_WIN_PLOT = T_ARRAY + (-1500 : +500); %window for viewing pupil dynamics
NUM_SAMP = length(T_WIN_PLOT);

T_REWARD_MAX = 1800; %maximum acceptable value of reward time from array

behavData = utilIsolateMonkeyBehavior({'D','E'}, behavData);
NUM_SESSION = length(behavData);

%initialization
pupilMat_AccCorr   = NaN(NUM_SESSION,NUM_SAMP);
pupilMat_AccErrTime = NaN(NUM_SESSION,NUM_SAMP);
pupilMat_FastCorr  = NaN(NUM_SESSION,NUM_SAMP);

for kk = 1:NUM_SESSION
  
  tReward = double(behavData.Sacc_RT{kk}) + double(behavData.Task_TimeReward{kk});
  idxNaN = (isnan(tReward) | (tReward > T_REWARD_MAX));
  
  %index by task condition
  idxAcc =  (behavData.Task_SATCondition{kk} == 1);
  idxFast =  (behavData.Task_SATCondition{kk} == 3);
  
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrChoice{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  idxErrTime = (behavData.Task_ErrTime{kk} & ~behavData.Task_ErrChoice{kk});
  
  %combine indexes
  trial_AC = find(idxAcc & idxCorr & ~idxNaN);      n_AC = length(trial_AC);
  trial_AE = find(idxAcc & idxErrTime & ~idxNaN);   n_AE = length(trial_AE);
  trial_FC = find(idxFast & idxCorr & ~idxNaN);     n_FC = length(trial_FC);
  
  %initialization -- single-session
  pup_AC_kk = NaN(n_AC, NUM_SAMP);
  pup_AE_kk = NaN(n_AE, NUM_SAMP);
  pup_FC_kk = NaN(n_FC, NUM_SAMP);
  
  %loop over trials and sync time on reward
  for jj = 1:n_AC %ACCURATE-CORRECT
    idx_Rew_jj = T_WIN_PLOT + tReward(trial_AC(jj));
    pup_AC_kk(jj,:) = pupilData{kk}(trial_AC(jj), idx_Rew_jj);
  end
  for jj = 1:n_AE %ACCURATE-TIMING-ERROR
    idx_Rew_jj = T_WIN_PLOT + tReward(trial_AE(jj));
    pup_AE_kk(jj,:) = pupilData{kk}(trial_AE(jj), idx_Rew_jj);
  end
  for jj = 1:n_FC %FAST-CORRECT
    idx_Rew_jj = T_WIN_PLOT + tReward(trial_FC(jj));
    pup_FC_kk(jj,:) = pupilData{kk}(trial_FC(jj), idx_Rew_jj);
  end
  
  pupilMat_AccCorr(kk,:)  = nanmean(pup_AC_kk);
  pupilMat_AccErrTime(kk,:)  = nanmean(pup_AE_kk);
  pupilMat_FastCorr(kk,:)  = nanmean(pup_FC_kk);
  
  %plotting
%   figure(); hold on; ppretty([4.8,3])
%   shadedErrorBar(T_WIN_PLOT-3500, pup_AC_kk, {@nanmean,@nanstd}, 'lineprops',{'-', 'Color','r'}, 'transparent',true);
%   shadedErrorBar(T_WIN_PLOT-3500, pup_AE_kk, {@nanmean,@nanstd}, 'lineprops',{':', 'Color','r'}, 'transparent',true);
%   shadedErrorBar(T_WIN_PLOT-3500, pup_FC_kk, {@nanmean,@nanstd}, 'lineprops',{'-', 'Color',[0 .7 0]}, 'transparent',true);
%   xlabel('Time from array (ms)'); ylabel('Pupil (a.u.)'); title(behavData.Task_Session{kk})
%   print([DIR_PRINT, behavData.Task_Session{kk}, '.tif'], '-dtiff');
%   pause(0.25); close()
  
end % for :: session (kk)

%% Plotting - Across sessions
mu_AC = nanmean(pupilMat_AccCorr);    se_AC = nanstd(pupilMat_AccCorr) / sqrt(NUM_SESSION);
mu_AE = nanmean(pupilMat_AccErrTime); se_AE = nanstd(pupilMat_AccErrTime) / sqrt(NUM_SESSION);
mu_FC = nanmean(pupilMat_FastCorr);   se_FC = nanstd(pupilMat_FastCorr) / sqrt(NUM_SESSION);

figure(); hold on; ppretty([4.8,3])
plot([T_WIN_PLOT(1) T_WIN_PLOT(end)] - T_ARRAY, [0 0], 'k:')
shadedErrorBar(T_WIN_PLOT-3500, mu_AC, se_AC, 'lineprops', {'-', 'Color','r', 'LineWidth',1.5}, 'transparent',true)
shadedErrorBar(T_WIN_PLOT-3500, mu_AE, se_AE, 'lineprops', {':', 'Color','r', 'LineWidth',1.5}, 'transparent',true)
shadedErrorBar(T_WIN_PLOT-3500, mu_FC, se_FC, 'lineprops', {'-', 'Color',[0 .7 0], 'LineWidth',1.5}, 'transparent',true)
xlabel('Time from reward (ms)'); ylabel('Pupil diameter (a.u.)')

end % fxn : plotPupilData_FromReward_SAT()

