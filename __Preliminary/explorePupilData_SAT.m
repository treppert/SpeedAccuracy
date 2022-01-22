%explorePupilData_SAT.m
if (0)
MONKEY = 'Darwin';
behavData = load('C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\SEF_SAT\Data\behavData_moves_SAT.mat','behavData');
behavData = behavData.behavData.SAT;    tmp = length(behavData);
behavData = utilIsolateMonkeyBehavior(behavData, zeros(1,tmp), zeros(1,tmp), {MONKEY(1)});

ROOT_DIR = ['T:\data\', MONKEY, '\SAT\Matlab\'];
DIR_PRINT = 'C:\Users\Thomas Reppert\Dropbox\SAT\Figures\Pupil\';

[sessions,num_trials] = identify_sessions_SAT(ROOT_DIR, MONKEY, 'SEARCH');
sessions = struct2table(sessions.SAT);    NUM_SESSION = size(sessions,1);
num_trials = num_trials.SAT;
end

%parameters
T_ARRAY = 3500;
T_WIN_PLOT = T_ARRAY + (-650 : +250); %window for viewing pupil dynamics
T_WIN_AVG = T_ARRAY + (-650 : -400); %window for computing trial-wise mean
[B_BUTTER, A_BUTTER] = butter(3, 2*50/1000, 'low'); %low-pass filter

%output initialization
NUM_SAMP = length(T_WIN_PLOT);
pupilMat_FastCorr = NaN(NUM_SESSION,NUM_SAMP);
pupilMat_AccCorr  = NaN(NUM_SESSION,NUM_SAMP);

for kk = 1:NUM_SESSION
  sessFile = [sessions.folder{kk}, filesep, sessions.name{kk}];
  fprintf('Session %d  (%s)\n', kk, sessions.name{kk})
  pupil = load(sessFile, 'Pupil_'); pupil = pupil.Pupil_;

  %low-pass filter the pupil data
%   pupil = filtfilt(B_BUTTER, A_BUTTER, pupil);

  %for each trial, subtract off value at time of array appearance
  %NOTE: this is a control for trial number
  pupil = pupil - repmat(nanmean(pupil(:,T_WIN_AVG),2), 1,6001);
  
  %clean the data (remove outliers)
  pupil(pupil < -1.5) = NaN;
%   figure(); plot(pupil(1:100,T_WIN_PLOT)')
  
  %index by task condition
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  idxAcc =  (behavData.Task_SATCondition{kk} == 1);

  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrChoice{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});

  pupil_FastCorr = pupil(idxFast & idxCorr, T_WIN_PLOT);
  pupil_AccCorr =  pupil(idxAcc & idxCorr, T_WIN_PLOT);
  
  pupilMat_FastCorr(kk,:) = nanmean(pupil_FastCorr);
  pupilMat_AccCorr(kk,:)  = nanmean(pupil_AccCorr);
  
  %plotting
%   figure(); hold on; ppretty([4.8,3])
%   shadedErrorBar(T_WIN_PLOT-3500, pupil_FastCorr, {@nanmean,@nanstd}, 'lineprops',{'-', 'Color',[0 .7 0]}, 'transparent',true);
%   shadedErrorBar(T_WIN_PLOT-3500, pupil_AccCorr, {@nanmean,@nanstd},  'lineprops',{'-', 'Color','r'}, 'transparent',true);
%   xlabel('Time from array (ms)'); ylabel('Pupil (a.u.)'); title(sessions.name{kk}(1:end-11))
%   print([DIR_PRINT, sessions.name{kk}(1:end-4), '.tif'], '-dtiff');
%   pause(0.25); close()
  
end % for :: session (kk)


%% Plotting - Across sessions
mu_FC = nanmean(pupilMat_FastCorr);   se_FC = nanstd(pupilMat_FastCorr) / sqrt(NUM_SESSION);
mu_AC = nanmean(pupilMat_AccCorr);    se_AC = nanstd(pupilMat_AccCorr) / sqrt(NUM_SESSION);

figure(); hold on; ppretty([4.8,3])
shadedErrorBar(T_WIN_PLOT-3500, mu_FC, se_FC, 'lineprops', {'-', 'Color',[0 .7 0]}, 'transparent',true)
shadedErrorBar(T_WIN_PLOT-3500, mu_AC, se_AC, 'lineprops', {'-', 'Color','r'}, 'transparent',true)
xlabel('Time from array (ms)'); ylabel('Pupil (a.u.)')





