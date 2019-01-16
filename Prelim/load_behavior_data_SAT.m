function [ info , gaze ] = load_behavior_data_SAT( monkey )
%load_behavior_data_SAT Summary of this function goes here
%   Detailed explanation goes here

global NUM_SAMPLES REMOVE_CLIPPED_DATA

REMOVE_CLIPPED_DATA = false;

% ROOT_DIR = 'C:\Users\Tom\Documents\SpeedAccuracy/';%'D:/SAT/'; %TDT
ROOT_DIR = '/data/search/SAT/';
NUM_SAMPLES = 6001;

if ~ismember(monkey, {'Darwin','Euler','Quincy','Seymour'})
  error('Input "monkey" not recognized')
end

%% Initializations

% num_trials = struct('DET',[], 'MG',[], 'SAT',[]);

[sessions,num_trials] = identify_sessions_SAT(ROOT_DIR, monkey, 'SEARCH');
% [~,num_trials.MG] = identify_sessions_SAT(ROOT_DIR, monkey, 'MG');

NUM_SESSIONS = length(sessions.SAT);

%% Initialize outputs

FIELDS_GAZE = {'x','y','vx','vy','v'};
FIELDS_INFO = {'session','num_trials','condition', ...
  'tgt_octant','tgt_eccen','tgt_dline', ...
  'err_dir','err_time','err_hold','err_nosacc', ...
  'octant','resptime','fixtime','rewtime'};

info = new_struct(FIELDS_INFO, 'dim',[1,NUM_SESSIONS]); info = orderfields(info);
gaze = new_struct(FIELDS_GAZE, 'dim',[1,NUM_SESSIONS]); gaze = orderfields(gaze);
info = struct('MG',info, 'SAT',info);
gaze = struct('MG',gaze, 'SAT',gaze);

for kk = 1:NUM_SESSIONS
  gaze.MG(kk)  = populate_struct(gaze.MG(kk), FIELDS_GAZE, single(NaN*ones(NUM_SAMPLES,num_trials.MG(kk))));
  gaze.MG(kk).clipped = false(NUM_SAMPLES,num_trials.MG(kk)); %include field to ID gaze clipping in Eyelink
  gaze.SAT(kk) = populate_struct(gaze.SAT(kk), FIELDS_GAZE, single(NaN*ones(NUM_SAMPLES,num_trials.SAT(kk))));
  gaze.SAT(kk).clipped = false(NUM_SAMPLES,num_trials.SAT(kk));
end%for:sessions(kk)

%% Load task/TEMPO information

info.MG = load_task_info(info.MG, sessions, num_trials.MG, 'MG');
info.SAT = load_task_info(info.SAT, sessions, num_trials.SAT, 'SEARCH');

%% Load saccade data

gaze.MG = load_gaze_data(info.MG, gaze.MG, sessions, num_trials.MG, FIELDS_GAZE, 'MG');
gaze.SAT = load_gaze_data(info.SAT, gaze.SAT, sessions, num_trials.SAT, FIELDS_GAZE, 'SEARCH');

end%function:load_behavior_data_SAT()


function [ sessions , num_trials ] = identify_sessions_SAT( root_dir , monkey , type )
%initialize_behavior_data Summary of this function goes here
%   Detailed explanation goes here

MIN_TOTAL_TRIALS_PER_SESSION = 700;

%identify recording sessions
sessions.SAT = dir([root_dir, monkey, '/*_SEARCH.mat']);
sessions.MG = dir([root_dir, monkey, '/*_MG.mat']);

%remove sessions without data from SEF (Da & Eu)
if ismember(monkey, {'Darwin','Euler'})
  sessions.SAT(1) = [];
end

num_sessions = length(sessions.SAT);

if isempty(sessions.SAT);  error('No %s sessions found', type);  end

%get the number of trials per session
num_trials = struct('MG',zeros(1,num_sessions), 'SAT',zeros(1,num_sessions));
for kk = 1:num_sessions
  
  file_SAT_kk = [sessions.SAT(kk).folder,'/',sessions.SAT(kk).name];
  vars_SAT_kk = whos('-file', file_SAT_kk);
  
  file_MG_kk = [sessions.MG(kk).folder,'/',sessions.MG(kk).name];
  vars_MG_kk = whos('-file', file_MG_kk);
  
  num_trials.SAT(kk) = vars_SAT_kk(1).size(1);
  num_trials.MG(kk) = vars_MG_kk(1).size(1);
  
end

%remove sessions without enough total trials (Q & S)
if ismember(monkey, {'Quincy','Seymour'})
  
  kkRemove = (num_trials.SAT < MIN_TOTAL_TRIALS_PER_SESSION);
  
  sessions.SAT(kkRemove) = [];
  num_trials.SAT(kkRemove) = [];
  sessions.MG(kkRemove) = [];
  num_trials.MG(kkRemove) = [];
  
end%if(Q-or-S)

end%function:identify_sessions_SAT

function [ info ] = load_task_info( info , sessions , num_trials , type )

NUM_SESSIONS = length(sessions.SAT);

for kk = 1:NUM_SESSIONS
  if strcmp(type, 'MG')
    file_kk = [sessions.MG(kk).folder,'/',sessions.MG(kk).name(1:16),type,'.mat'];
    info(kk).session = sessions.MG(kk).name(1:12);
  else %(SAT)
    file_kk = [sessions.SAT(kk).folder,'/',sessions.SAT(kk).name(1:16),type,'.mat'];
    info(kk).session = sessions.SAT(kk).name(1:12);
  end
  
  load(file_kk, 'SAT_','Errors_','Target_','SRT','saccLoc','FixAcqTime_','JuiceOn_')

  %Session information
  info(kk).num_trials = length(SAT_(:,1));
  info(kk).condition = transpose(uint8(SAT_(:,1))); %1==accurate, 3==fast
  
  %Target/stimulus information
  
  tgt_dline = transpose(SAT_(:,3));
  tgt_dline(tgt_dline > 1000) = NaN;
  
  info(kk).tgt_octant = transpose(uint8(Target_(:,2) + 1));
  info(kk).tgt_eccen = transpose(Target_(:,12));
  info(kk).tgt_dline = tgt_dline;
  
  %Response information
  
  info(kk).err_nosacc = false(1,num_trials(kk));   info(kk).err_nosacc(Errors_(:,2) == 1) = true;
  info(kk).err_hold = false(1,num_trials(kk));   info(kk).err_hold(Errors_(:,4) == 1) = true;
  info(kk).err_dir = false(1,num_trials(kk));    info(kk).err_dir(Errors_(:,5) == 1) = true;
  info(kk).err_time = false(1,num_trials(kk));   info(kk).err_time((Errors_(:,6) == 1) | (Errors_(:,7) == 1)) = true;
  
  info(kk).octant = uint8(saccLoc+1)';
  info(kk).resptime = SRT(:,1)'; %TEMPO estimate of RT
  
  if exist('JuiceOn_', 'var')
    load(file_kk, 'JuiceOn_')
    info(kk).rewtime = JuiceOn_';
  else
    fprintf('Warning -- "JuiceOn_" does not exist -- %s\n', info(kk).session)
    info(kk).rewtime = NaN(1,num_trials(kk));
  end
  
  if exist('FixAcqTime_', 'var')
    load(file_kk, 'FixAcqTime_')
    info(kk).fixtime = FixAcqTime_';
  else %variable FixAcqTime_ does not exist
    fprintf('Warning -- "FixAcqTime_" does not exist -- %s\n', info(kk).session)
    info(kk).fixtime = NaN(1,num_trials(kk));
  end

end%for:sessions

end%function:load_task_info

function [ data ] = load_gaze_data( info , data , sessions , num_trials , fields_gaze , type )

global NUM_SAMPLES REMOVE_CLIPPED_DATA

SAMP_RATE = 1000;
[B_BUTTER, A_BUTTER] = butter(3, 2*80/SAMP_RATE, 'low');
TOL_THRESH = 0.01; %used to identify A/D saturation in EyeX_/EyeY_

if strcmp(type, 'MG')
  TASK = 'MG';
elseif strcmp(type, 'SEARCH')
  TASK = 'SAT';
end

NUM_SESSIONS = length(sessions.(TASK));

for kk = 1:NUM_SESSIONS
  session_file = [sessions.(TASK)(kk).folder,'/',sessions.(TASK)(kk).name(1:16),type,'.mat'];
  
  if ~exist(session_file, 'file'); continue; end
  
  fprintf('Session %d  (%s)\n', kk, [sessions.(TASK)(kk).name(1:16),type])
  load(session_file, 'EyeX_','EyeY_')
  
  gaze_x = 3*transpose(EyeX_);  gaze_y = -3*transpose(EyeY_);
  
  %identify points of saturation in the gaze signal
  miss_x = (abs(abs(gaze_x)-7.5) < TOL_THRESH) & ([diff(gaze_x,1,1)==0; false(1,num_trials(kk))]);
  miss_y = (abs(abs(gaze_y)-7.5) < TOL_THRESH) & ([diff(gaze_y,1,1)==0; false(1,num_trials(kk))]);
  
  %filter gaze data
  gaze_x = single(filtfilt(B_BUTTER, A_BUTTER, gaze_x));
  gaze_y = single(filtfilt(B_BUTTER, A_BUTTER, gaze_y));

  %differentiate gaze data
  vx = diff(gaze_x,1,1) * SAMP_RATE;
  vy = diff(gaze_y,1,1) * SAMP_RATE;

  data(kk).x = gaze_x;
  data(kk).y = gaze_y;
  data(kk).vx = [vx; vx(NUM_SAMPLES-1,:)];
  data(kk).vy = [vy; vy(NUM_SAMPLES-1,:)];
  data(kk).v = sqrt(data(kk).vx.*data(kk).vx + data(kk).vy.*data(kk).vy);
  clear gaze_x gaze_y vx vy vr
  
  data(kk).clipped(miss_x|miss_y) = true; %ID clipped data points
  
  if (REMOVE_CLIPPED_DATA) %remove saturated data points
    for ff = 1:length(fields_gaze)
      data(kk).(fields_gaze{ff})(miss_x|miss_y) = NaN;
    end
  end
  
  %if monkey S, remove trials with missing data during decision interval
  if ismember(info(kk).session(1), {'S'})
    bad_trials = identify_bad_trials_SAT(EyeX_, EyeY_);
    for ff = 1:length(fields_gaze)
      data(kk).(fields_gaze{ff})(:,bad_trials) = NaN;
      info(kk).resptime(bad_trials) = 0;
      info(kk).octant(bad_trials) = 0;
    end
  end
  
end%for:sessions(kk)

end%function:load_behavior_data
