function [ moves_SAT , varargout ] = parse_saccades_SAT( gaze , info , varargin )
%[ moves ] = parse_saccades_vandy( data , info )

DEBUG = false;

if (DEBUG)
  gaze_unclipped = varargin{1};
end

global VEL_CUT MIN_IMI MIN_HOLD ALLOT APPEND IDX_SURVEY
global LIM_DURATION LIM_RESPTIME LIM_PEAKVEL MAX_RINIT MIN_RFIN MIN_DISP MAX_SKEW
global FIELDS_SINGLE FIELDS_DOUBLE FIELDS_VECTOR
global ALLOC_ALL NUM_SAMPLES_SURVEY

%% Initializations

NUM_SESSIONS = length(gaze);
TIME_ARRAY = 3500;

VEL_CUT = [30, 50, 100];
MIN_HOLD = 20;
MIN_IMI = 40;

LIM_DURATION = [5, 80];
LIM_PEAKVEL = [200, 1200];
MIN_DISP = 2.0;
MAX_SKEW = 0.80;

MAX_RINIT = 2.5;
MIN_RFIN = 3.0;
LIM_RESPTIME = [0, 1500];

NUM_SAMPLES_SURVEY = 2500;
IDX_SURVEY = ( TIME_ARRAY : TIME_ARRAY + NUM_SAMPLES_SURVEY - 1 ); %indexes used to look for movements
ALLOT = 150;
APPEND = 20;

FIELDS_DOUBLE = {'displacement','duration','peakvel','resptime'};
FIELDS_SINGLE = {'x_init','y_init','r_init','x_fin','y_fin','r_fin','th_fin','skew','vigor','octant'};
FIELDS_VECTOR = {'r','th','vr','vel'};

FIELDS_ALL = [FIELDS_DOUBLE, FIELDS_SINGLE, FIELDS_VECTOR];


%% Initialize output movement arrays

moves_SAT = new_struct(FIELDS_ALL, 'dim',[1,NUM_SESSIONS]);

for kk = 1:NUM_SESSIONS
  moves_SAT(kk) = populate_struct(moves_SAT(kk), FIELDS_VECTOR, single(NaN(ALLOT,info(kk).num_trials)));
  moves_SAT(kk) = populate_struct(moves_SAT(kk), FIELDS_SINGLE, single(NaN(1,info(kk).num_trials)));
  moves_SAT(kk) = populate_struct(moves_SAT(kk), FIELDS_DOUBLE, double(NaN(1,info(kk).num_trials)));
end%for:sessions(kk)

moves_all = moves_SAT; %struct array for all movements, regardless of task relevance


%% **** Movement identification ****

for kk = 1:NUM_SESSIONS
  fprintf('***Session %s (%d trials)\n', info(kk).session, info(kk).num_trials)

  ALLOC_ALL = info(kk).num_trials;
  idx_all = 1; %index for saving all saccades (task-rel. and irrel.)

  %start with estimate of response time and octant from TEMPO
  moves_SAT(kk).resptime(:) = info(kk).resptime;
  moves_SAT(kk).octant(:) = info(kk).octant;

  idx_sin_cand = false(1,info(kk).num_trials); %keep track of trials w/o candidates and/or responses
  idx_sin_sacc = false(1,info(kk).num_trials);
  idx_sin_resp = false(1,info(kk).num_trials);

  for jj = 1:info(kk).num_trials

    %% Initialize trial-specific saccade kinematics
    kin_jj = initialize_saccade_kinematics(gaze(kk), jj);

    %% Identify saccade candidates
    cands_jj = identify_saccade_candidates(kin_jj);
    if isempty(cands_jj)
%       if (DEBUG)
%         figure(); hold on
%         plot(gaze_unclipped(kk).x(IDX_SURVEY,jj), 'k-', 'LineWidth',2.0)
%         plot(gaze_unclipped(kk).y(IDX_SURVEY,jj), 'b-', 'LineWidth',2.0)
%         plot(kin_jj.x, 'r-')
%         plot(kin_jj.y, 'r-')
%         pause()
%       end
      idx_sin_cand(jj) = true; continue
    end

    %% Identify all saccades
    [moves_all(kk), cands_jj, idx_all] = identify_all_saccades(moves_all(kk), cands_jj, idx_all);
    if isempty(cands_jj); idx_sin_sacc(jj) = true; continue; end

    %% Identify task-relevant saccade
    [moves_SAT(kk), flag_tr] = identify_taskrel_saccade(moves_SAT(kk), cands_jj, jj);
    if (~flag_tr)
      if (DEBUG)
        figure(); hold on
        plot(kin_jj.x, 'k-')
        plot(kin_jj.y, 'b-')
        pause()
      end
      idx_sin_resp(jj) = true; continue
    end

  end%for:trials(jj)

  fprintf('num_trials_wo_cand = %d/%d\n', sum(idx_sin_cand),info(kk).num_trials)
  fprintf('num_trials_wo_sacc = %d/%d\n', sum(idx_sin_sacc),info(kk).num_trials)
  fprintf('num_trials_wo_resp = %d/%d\n', sum(idx_sin_resp),info(kk).num_trials)

  %remove extra memory from struct with all saccades
  for ff = 1:length(FIELDS_SINGLE)
    moves_all(kk).(FIELDS_SINGLE{ff})(idx_all:ALLOC_ALL) = [];
  end
  for ff = 1:length(FIELDS_DOUBLE)
    moves_all(kk).(FIELDS_DOUBLE{ff})(idx_all:ALLOC_ALL) = [];
  end
  for ff = 1:length(FIELDS_VECTOR)
    moves_all(kk).(FIELDS_VECTOR{ff})(:,idx_all:ALLOC_ALL) = [];
  end
  
  fprintf('Number of trials with isolated response = %d/%d\n\n', sum(~isnan(moves_SAT(kk).peakvel)), info(kk).num_trials)
  
  pause(1.0)
  
end%for:sessions(kk)

%make sure we are only saving movements with non-NaN displacement
% if (sum(isnan([moves_all.displacement])))
%   error('Movements with NaN values for displacement')
% end

if (nargout > 0)
  varargout{1} = moves_all;
end

end%function:parse_saccades_SAT()


function [ kin ] = initialize_saccade_kinematics( data_kk, trial )

global IDX_SURVEY

x = data_kk.x(IDX_SURVEY,trial);
y = data_kk.y(IDX_SURVEY,trial);
vx = data_kk.vx(IDX_SURVEY,trial);
vy = data_kk.vy(IDX_SURVEY,trial);
vel = data_kk.v(IDX_SURVEY,trial);

th = atan2(y, x);
r = sqrt(x.^2 + y.^2);
vr = vx.*cos(th) + vy.*sin(th);

kin = struct('x',x, 'y',y, 'vx',vx, 'vy',vy, 'r',r, 'th',th, 'vr',vr, 'vel',vel);

end%util:init_movement_kinematics()

function [ cands ] = identify_saccade_candidates( kin )

global ALLOT APPEND VEL_CUT MIN_IMI MIN_HOLD NUM_SAMPLES_SURVEY
global FIELDS_SINGLE FIELDS_DOUBLE FIELDS_VECTOR

cands = [];

%% Find potential saccade candidates

idx_prelim = find(kin.vel > VEL_CUT(3)); %all samples with velocity greater than cutoff
if isempty(idx_prelim); return; end

idx_jump = find(diff(idx_prelim) > MIN_IMI);
idx_start = [idx_prelim(1); idx_prelim(idx_jump + 1)]';
idx_end   = [idx_prelim(idx_jump); idx_prelim(end)]';

idx_clipped = ((idx_start < APPEND) | (idx_end > (NUM_SAMPLES_SURVEY-ALLOT+1)));
idx_start(idx_clipped) = [];
idx_end(idx_clipped) = [];

if isempty(idx_start); return; end %make sure we have potential candidates
idx_lim = transpose([ idx_start ; idx_end ]);

%% Identify actual saccade candidates

NUM_CAND = size(idx_lim,1);
cands = new_struct([FIELDS_SINGLE, FIELDS_DOUBLE, FIELDS_VECTOR], 'dim',[1,NUM_CAND]);
cands = populate_struct(cands, FIELDS_VECTOR, single(NaN(ALLOT,1)));
cands = populate_struct(cands, FIELDS_SINGLE, single(NaN));
cands = populate_struct(cands, FIELDS_DOUBLE, NaN);

for jj = NUM_CAND:-1:1
  
  [idx_lim(jj,1), idx_lim(jj,2), skip] = identify_movement_bounds(kin.vel, idx_lim(jj,1), ...
    idx_lim(jj,2), 'v_cut',VEL_CUT(2), 'min_hold',MIN_HOLD);
  
  if (skip); cands(jj) = []; continue; end %make sure we still have a candidate
  
  %provide precise account of RT
  offset_init = find(kin.vel(idx_lim(jj,1) : -1 : idx_lim(jj,1)-APPEND+1) < VEL_CUT(1), 1, 'first');
  if isempty(offset_init)
    cands(jj) = []; continue
  else
    idx_lim(jj,1) = idx_lim(jj,1) - offset_init + 1;
  end
  
  cands(jj) = save_candidate_parm(cands(jj), kin, idx_lim(jj,:));
  
end%for:candidates(jj)


end%function:identify_movement_candidates()

function [ candidate ] = save_candidate_parm( candidate , kin , idx_move )

global ALLOT APPEND

%parameters that do not depend upon clipping
candidate.octant = convert_angle_to_octant(kin.th(idx_move(2)-1));
candidate.peakvel = double(max(kin.vel(idx_move(1):idx_move(2))));
candidate.resptime = double(idx_move(1));
candidate.r_init = kin.r(idx_move(1));
candidate.x_init = kin.x(idx_move(1));
candidate.y_init = kin.y(idx_move(1));

%save all movement parameters
idx_kin = idx_move(1) - APPEND : idx_move(1)  + ALLOT - (APPEND + 1);
idx_kin(idx_kin < 1) = 1;

candidate.r(:) = (kin.r(idx_kin));
candidate.th(:) = (kin.th(idx_kin));
candidate.vr(:) = (kin.vr(idx_kin));
candidate.vel(:) = (kin.vel(idx_kin));

candidate.duration = double(idx_move(2) - idx_move(1));

candidate.x_fin = kin.x(idx_move(2));
candidate.y_fin = kin.y(idx_move(2));
candidate.r_fin = kin.r(idx_move(2));
candidate.th_fin = kin.th(idx_move(2));

disp_x = sum(abs(diff(kin.x(idx_move(1):idx_move(2)))));
disp_y = sum(abs(diff(kin.y(idx_move(1):idx_move(2)))));
candidate.displacement = double(sqrt(disp_x*disp_x + disp_y*disp_y));

[~, idx_pv] = max(kin.vel(idx_move(1):idx_move(2)));
candidate.skew = idx_pv / (idx_move(2) - idx_move(1));

end%function:save_candidate_parm()

function [ moves , cands , index ] = identify_all_saccades( moves , cands , index )

global LIM_DURATION LIM_PEAKVEL MIN_DISP MAX_SKEW
global FIELDS_DOUBLE FIELDS_SINGLE FIELDS_VECTOR
global NUM_TRIAL ALLOT ALLOC_ALL

idx_cut_nan = isnan([cands.displacement]);
idx_cut_disp = ([cands.displacement] < MIN_DISP);
idx_cut_dur = ([cands.duration] < LIM_DURATION(1)) | ([cands.duration] > LIM_DURATION(2));
idx_cut_pv = ([cands.peakvel] < LIM_PEAKVEL(1)) | ([cands.peakvel] > LIM_PEAKVEL(2));
idx_cut_skew = ([cands.skew] > MAX_SKEW);

icut_saccade = (idx_cut_nan | idx_cut_disp | idx_cut_dur | idx_cut_pv | idx_cut_skew);

idx_saccade = find(~icut_saccade);
num_saccade  = length(idx_saccade);

%check for memory re-alloc
if (index + num_saccade > ALLOC_ALL)
  ALLOC_ALL = ALLOC_ALL + NUM_TRIAL;
  
  for ff = 1:length(FIELDS_DOUBLE)
    moves.(FIELDS_DOUBLE{ff}) = [moves.(FIELDS_DOUBLE{ff}), NaN(1,NUM_TRIAL)];
  end
  for ff = 1:length(FIELDS_SINGLE)
    moves.(FIELDS_SINGLE{ff}) = [moves.(FIELDS_SINGLE{ff}), single(NaN(1,NUM_TRIAL))];
  end
  for ff = 1:length(FIELDS_VECTOR)
    moves.(FIELDS_VECTOR{ff}) = [moves.(FIELDS_VECTOR{ff}), single(NaN(ALLOT,NUM_TRIAL))];
  end
end

%save all saccades for this trial
for ff = 1:length(FIELDS_DOUBLE)
  moves.(FIELDS_DOUBLE{ff})(index:index+num_saccade-1) = [cands(idx_saccade).(FIELDS_DOUBLE{ff})];
end
for ff = 1:length(FIELDS_SINGLE)
  moves.(FIELDS_SINGLE{ff})(index:index+num_saccade-1) = [cands(idx_saccade).(FIELDS_SINGLE{ff})];
end
for ff = 1:length(FIELDS_VECTOR)
  moves.(FIELDS_VECTOR{ff})(:,index:index+num_saccade-1) = [cands(idx_saccade).(FIELDS_VECTOR{ff})];
end

cands = cands(idx_saccade);

index = index + num_saccade;

end%function:identify_all_saccades()

function [ moves , flag_tr ] = identify_taskrel_saccade( moves , cands , trial )

global LIM_RESPTIME MAX_RINIT MIN_RFIN
global FIELDS_DOUBLE FIELDS_SINGLE FIELDS_VECTOR

flag_tr = false;

resptime = [cands.resptime];
r_init = [cands.r_init];
r_fin = [cands.r_fin];

idx_cut_rt = (resptime < LIM_RESPTIME(1)) | (resptime > LIM_RESPTIME(2));
idx_cut_rinit = (r_init > MAX_RINIT);
idx_cut_rfin = (r_fin < MIN_RFIN) ;

idx_cut_tr = (idx_cut_rt | idx_cut_rinit | idx_cut_rfin);

idx_taskrel = find(~idx_cut_tr, 1,'first');
num_taskrel = length(idx_taskrel);

if (num_taskrel == 1)
  
  for ff = 1:length(FIELDS_DOUBLE)
    moves.(FIELDS_DOUBLE{ff})(trial) = cands(idx_taskrel).(FIELDS_DOUBLE{ff});
  end
  for ff = 1:length(FIELDS_SINGLE)
    moves.(FIELDS_SINGLE{ff})(trial) = cands(idx_taskrel).(FIELDS_SINGLE{ff});
  end
  for ff = 1:length(FIELDS_VECTOR)
    moves.(FIELDS_VECTOR{ff})(:,trial) = cands(idx_taskrel).(FIELDS_VECTOR{ff});
  end
  
  flag_tr = true;
  
elseif (num_taskrel > 1)
  
  fprintf('*** Warning: Multiple task-relevant saccades on Trial %d\n', trial)
  
end

end%function:identify_taskrel_movement
