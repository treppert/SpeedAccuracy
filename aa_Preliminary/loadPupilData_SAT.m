function [ pupilData ] = loadPupilData_SAT( )

% binfo = load('C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\SEF_SAT\Data\binfo_moves_SAT.mat', 'binfo');
% binfo = utilIsolateMonkeyBehavior({'D','E'}, binfo.binfo.SAT);

%locate recording sessions for Da & Eu
dataDir_Da = 'T:\data\Darwin\SAT\Matlab\';
dataDir_Eu = 'T:\data\Euler\SAT\Matlab\';

[sessions_Da, nTrials_Da] = identify_sessions_SAT(dataDir_Da, 'SEARCH');
[sessions_Eu, nTrials_Eu] = identify_sessions_SAT(dataDir_Eu, 'SEARCH');
sessions = struct2table([sessions_Da.SAT; sessions_Eu.SAT]);
nTrials = [nTrials_Da.SAT, nTrials_Eu.SAT];   NUM_SESSION = length(nTrials);

T_ARRAY = 3500;
T_WIN_AVG = T_ARRAY + (-650 : -400); %window for computing trial-wise mean
% [B_BUTTER, A_BUTTER] = butter(3, 2*50/1000, 'low'); %low-pass filter

%initializations
pupilData = cell(1,NUM_SESSION);

for kk = 1:NUM_SESSION
  fprintf('Session %d  (%s)\n', kk, sessions.name{kk})
  sessFile = [sessions.folder{kk}, filesep, sessions.name{kk}];
  pupil = load(sessFile, 'Pupil_'); pupil = pupil.Pupil_;
  
  %low-pass filter the pupil data
%   pupil = filtfilt(B_BUTTER, A_BUTTER, pupil);

  %for each trial, subtract off value at time of array appearance
  %NOTE: this is a control for trial number
  pupil = pupil - repmat(nanmean(pupil(:,T_WIN_AVG),2), 1,6001);
  
  %clean the data (remove outliers)
  pupil(pupil < -1.5) = NaN;
  
  %collect the session pupil data
  pupilData{kk} = pupil;
  
end % for :: session (kk)

%save the data
%TODO - Save to a .mat file

end % function :: loadPupilData_SAT()