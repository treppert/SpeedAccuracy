function [ ] = plotPupilData_SAT( pupilData , binfo )
%plotPupilData_SAT Summary of this function goes here
%   Detailed explanation goes here

T_ARRAY = 3500;
T_WIN_PLOT = T_ARRAY + (-650 : +1500); %window for viewing pupil dynamics
NUM_SAMP = length(T_WIN_PLOT);

binfo = utilIsolateMonkeyBehavior({'D','E'}, binfo);
NUM_SESSION = length(binfo);

%initialization
pupilMat_FastCorr = NaN(NUM_SESSION,NUM_SAMP);    pupilMat_FastErrChc = NaN(NUM_SESSION,NUM_SAMP);
pupilMat_AccCorr  = NaN(NUM_SESSION,NUM_SAMP);    pupilMat_AccErrTime = NaN(NUM_SESSION,NUM_SAMP);

for kk = 1:NUM_SESSION
  
  %index by task condition
  idxFast = (binfo(kk).condition == 3);
  idxAcc =  (binfo(kk).condition == 1);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_time | binfo(kk).err_dir | binfo(kk).err_hold | binfo(kk).err_nosacc);
  idxErrChc = (binfo(kk).err_dir & ~binfo(kk).err_time);
  idxErrTime = (binfo(kk).err_time & ~binfo(kk).err_dir);
  
  pupil_FastCorr = pupilData{kk}(idxFast & idxCorr, T_WIN_PLOT);
  pupil_FastErrChc = pupilData{kk}(idxFast & idxErrChc, T_WIN_PLOT);
  pupil_AccCorr =  pupilData{kk}(idxAcc & idxCorr, T_WIN_PLOT);
  pupil_AccErrTime =  pupilData{kk}(idxAcc & idxErrTime, T_WIN_PLOT);
  
  pupilMat_FastCorr(kk,:) = nanmean(pupil_FastCorr);
  pupilMat_FastErrChc(kk,:) = nanmean(pupil_FastErrChc);
  pupilMat_AccCorr(kk,:)  = nanmean(pupil_AccCorr);
  pupilMat_AccErrTime(kk,:)  = nanmean(pupil_AccErrTime);
  
  %plotting
%   figure(); hold on; ppretty([4.8,3])
%   shadedErrorBar(T_WIN_PLOT-3500, pupil_FastCorr, {@nanmean,@nanstd}, 'lineprops',{'-', 'Color',[0 .7 0]}, 'transparent',true);
%   shadedErrorBar(T_WIN_PLOT-3500, pupil_FastErrChc, {@nanmean,@nanstd},  'lineprops',{':', 'Color',[0 .7 0]}, 'transparent',true);
%   xlabel('Time from array (ms)'); ylabel('Pupil (a.u.)'); title(binfo(kk).session)
%   print([DIR_PRINT, sessions.name{kk}(1:end-4), '.tif'], '-dtiff');
%   pause(0.25); close()
  
end % for :: session (kk)

%% Plotting - Across sessions
mu_FC = nanmean(pupilMat_FastCorr);   se_FC = nanstd(pupilMat_FastCorr) / sqrt(NUM_SESSION);
mu_FE = nanmean(pupilMat_FastErrChc); se_FE = nanstd(pupilMat_FastErrChc) / sqrt(NUM_SESSION);
mu_AC = nanmean(pupilMat_AccCorr);    se_AC = nanstd(pupilMat_AccCorr) / sqrt(NUM_SESSION);
mu_AE = nanmean(pupilMat_AccErrTime); se_AE = nanstd(pupilMat_AccErrTime) / sqrt(NUM_SESSION);

figure(); hold on; ppretty([4.8,3])
plot([T_WIN_PLOT(1) T_WIN_PLOT(end)] - T_ARRAY, [0 0], 'k:')
shadedErrorBar(T_WIN_PLOT-3500, mu_FC, se_FC, 'lineprops', {'-', 'Color',[0 .7 0], 'LineWidth',1.5}, 'transparent',true)
shadedErrorBar(T_WIN_PLOT-3500, mu_AC, se_AC, 'lineprops', {'-', 'Color','r', 'LineWidth',1.5}, 'transparent',true)
shadedErrorBar(T_WIN_PLOT-3500, mu_AE, se_AE, 'lineprops', {':', 'Color','r', 'LineWidth',1.5}, 'transparent',true)
xlabel('Time from array (ms)'); ylabel('Pupil diameter (a.u.)')

end % fxn : plotPupilData_SAT()

