function [ ] = plotPupilData_FromReward_SAT( pupilData , binfo )
%plotPupilData_FromReward_SAT Summary of this function goes here
%   Detailed explanation goes here
DIR_PRINT = 'C:\Users\Thomas Reppert\Dropbox\SAT\Figures\Pupil\FromReward\';

T_ARRAY = 3500;
T_WIN_PLOT = T_ARRAY + (-1500 : +500); %window for viewing pupil dynamics
NUM_SAMP = length(T_WIN_PLOT);

T_REWARD_MAX = 1800; %maximum acceptable value of reward time from array

binfo = utilIsolateMonkeyBehavior({'D','E'}, binfo);
NUM_SESSION = length(binfo);

%initialization
pupilMat_AccCorr   = NaN(NUM_SESSION,NUM_SAMP);
pupilMat_AccErrTime = NaN(NUM_SESSION,NUM_SAMP);
pupilMat_FastCorr  = NaN(NUM_SESSION,NUM_SAMP);

for kk = 1:NUM_SESSION
  
  tReward = double(binfo(kk).resptime) + double(binfo(kk).rewtime);
  idxNaN = (isnan(tReward) | (tReward > T_REWARD_MAX));
  
  %index by task condition
  idxAcc =  (binfo(kk).condition == 1);
  idxFast =  (binfo(kk).condition == 3);
  
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_time | binfo(kk).err_dir | binfo(kk).err_hold | binfo(kk).err_nosacc);
  idxErrTime = (binfo(kk).err_time & ~binfo(kk).err_dir);
  
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
%   xlabel('Time from array (ms)'); ylabel('Pupil (a.u.)'); title(binfo(kk).session)
%   print([DIR_PRINT, binfo(kk).session, '.tif'], '-dtiff');
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

