function [ moves , binfo , varargout ] = parse_saccades_SAT( gaze , binfo )
%[ moves ] = parse_saccades_vandy( data , info )

global DEBUG VEL_CUT MIN_IMI MIN_HOLD ALLOT APPEND IDX_SURVEY
global LIM_DURATION LIM_RESPTIME LIM_PEAKVEL MAX_RINIT MIN_RFIN MIN_DISP MAX_SKEW
global FIELDS_LOGICAL FIELDS_UINT16 FIELDS_SINGLE FIELDS_VECTOR
global ALLOC_ALL NUM_SAMPLES_SURVEY

DEBUG = false;

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
ALLOT = 80;
APPEND = 10;

FIELDS_LOGICAL = {'clipped'};
FIELDS_UINT16 = {'duration','octant','resptime','trial','index'};
FIELDS_SINGLE = {'amplitude','displacement','peakvel','skew','vigor','x_init','y_init','x_fin','y_fin'};
FIELDS_VECTOR = {'zz_x','zz_y','zz_v'};

FIELDS_ALL = [FIELDS_LOGICAL, FIELDS_UINT16, FIELDS_SINGLE, FIELDS_VECTOR];


%% Initialize output movement arrays
moves = new_struct(FIELDS_ALL, 'dim',[1,NUM_SESSIONS]);

for kk = 1:NUM_SESSIONS
  moves(kk) = populate_struct(moves(kk), FIELDS_LOGICAL, false(1,binfo(kk).num_trials));
  moves(kk) = populate_struct(moves(kk), FIELDS_UINT16, uint16(zeros(1,binfo(kk).num_trials)));
  moves(kk) = populate_struct(moves(kk), FIELDS_SINGLE, single(NaN(1,binfo(kk).num_trials)));
  moves(kk) = populate_struct(moves(kk), FIELDS_VECTOR, single(NaN(ALLOT,binfo(kk).num_trials)));
end%for:sessions(kk)

moves = orderfields(moves);
moves_all = moves; %struct array for all movements, regardless of task relevance


%% **** Movement identification ****

for kk = 1:NUM_SESSIONS
  fprintf('***Session %d -- %s (%d trials)\n', kk, binfo(kk).session, binfo(kk).num_trials)
  
  ALLOC_ALL = binfo(kk).num_trials;
  idx_all = 1; %index for saving all saccades (task-rel. and irrel.)
  
  %start with estimate of response time and octant from TEMPO
  moves(kk).resptime(:) = uint16(binfo(kk).resptime);
  moves(kk).octant(:) = uint16(binfo(kk).octant);
  
  %keep track of trials w/o candidates and/or responses
  idx_sin_cand = false(1,binfo(kk).num_trials);
  idx_sin_sacc = false(1,binfo(kk).num_trials);
  idx_sin_resp = false(1,binfo(kk).num_trials);

  for jj = 1:binfo(kk).num_trials

    %% Initialize trial-specific saccade kinematics
    kin_jj = initialize_saccade_kinematics(gaze(kk), jj);

    %% Identify saccade candidates
    cands_jj = identify_saccade_candidates(kin_jj);
    if isempty(cands_jj)
      idx_sin_cand(jj) = true; continue
    end

    %% Identify all saccades
    [moves_all(kk), cands_jj, idx_all] = identify_all_saccades(moves_all(kk), cands_jj, idx_all);
    if isempty(cands_jj); idx_sin_sacc(jj) = true; continue; end

    %% Identify task-relevant saccade
    [moves(kk), flag_tr] = identify_taskrel_saccade(moves(kk), cands_jj, jj);
    if (~flag_tr)
      idx_sin_resp(jj) = true; continue
    end

  end%for:trials(jj)

  fprintf('num_trials_wo_[cand,sacc,taskrel] = [%d, %d, %d] / %d\n', sum(idx_sin_cand), ...
    sum(idx_sin_sacc), sum(idx_sin_resp), binfo(kk).num_trials)

  %remove extra memory from struct with all saccades
  for ff = 1:length(FIELDS_LOGICAL)
    moves_all(kk).(FIELDS_LOGICAL{ff})(idx_all:ALLOC_ALL) = [];
  end
  for ff = 1:length(FIELDS_UINT16)
    moves_all(kk).(FIELDS_UINT16{ff})(idx_all:ALLOC_ALL) = [];
  end
  for ff = 1:length(FIELDS_SINGLE)
    moves_all(kk).(FIELDS_SINGLE{ff})(idx_all:ALLOC_ALL) = [];
  end
  for ff = 1:length(FIELDS_VECTOR)
    moves_all(kk).(FIELDS_VECTOR{ff})(:,idx_all:ALLOC_ALL) = [];
  end
  
end%for:sessions(kk)

%make sure indexing of timing errors is correct
binfo = index_timing_errors_SAT(binfo, moves);

if (nargout > 2)
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
clipped = data_kk.clipped(IDX_SURVEY,trial);

kin = struct('x',x, 'y',y, 'vx',vx, 'vy',vy, 'vel',vel, 'clipped',clipped, 'trial',trial);

end%util:init_movement_kinematics()

function [ cands ] = identify_saccade_candidates( kin )

global ALLOT APPEND VEL_CUT MIN_IMI MIN_HOLD NUM_SAMPLES_SURVEY
global FIELDS_LOGICAL FIELDS_UINT16 FIELDS_SINGLE FIELDS_VECTOR

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
cands = new_struct([FIELDS_LOGICAL, FIELDS_UINT16, FIELDS_SINGLE, FIELDS_VECTOR], 'dim',[1,NUM_CAND]);
cands = populate_struct(cands, FIELDS_LOGICAL, false);
cands = populate_struct(cands, FIELDS_UINT16, 0);
cands = populate_struct(cands, FIELDS_VECTOR, single(NaN(ALLOT,1)));
cands = populate_struct(cands, FIELDS_SINGLE, single(NaN));

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

%% Vectors of candidate kinematics
idx_vec = idx_move(1) - APPEND : idx_move(1)  + ALLOT - (APPEND + 1);
idx_vec(idx_vec < 1) = 1;
candidate.zz_x(:) = single(kin.x(idx_vec));
candidate.zz_y(:) = single(kin.y(idx_vec));
candidate.zz_v(:) = single(kin.vel(idx_vec));

%check for saccade clipping
candidate.clipped = any(kin.clipped(idx_vec));

%% Scalar parameters independent of clipping
candidate.peakvel = single(max(kin.vel(idx_move(1):idx_move(2))));
candidate.resptime = uint16(idx_move(1));
candidate.x_init = single(kin.x(idx_move(1)));
candidate.y_init = single(kin.y(idx_move(1)));
candidate.trial = uint16(kin.trial);

%% Scalar parameters with min values given clipping
amp_x = kin.x(idx_move(2)) - kin.x(idx_move(1));
amp_y = kin.y(idx_move(2)) - kin.y(idx_move(1));
candidate.amplitude = single(sqrt(amp_x*amp_x + amp_y*amp_y));
disp_x = sum(abs(diff(kin.x(idx_move(1):idx_move(2)))));
disp_y = sum(abs(diff(kin.y(idx_move(1):idx_move(2)))));
candidate.displacement = single(sqrt(disp_x*disp_x + disp_y*disp_y));
candidate.duration = uint16(idx_move(2) - idx_move(1));

%% Scalar parameters only valid without clipping
candidate.x_fin = single(kin.x(idx_move(2)));
candidate.y_fin = single(kin.y(idx_move(2)));

kin_th = atan2(kin.y, kin.x);
candidate.octant = uint16(convert_angle_to_octant(kin_th(idx_move(2)-1)));

[~, idx_pv] = max(kin.vel(idx_move(1):idx_move(2)));
candidate.skew = single(idx_pv / (idx_move(2) - idx_move(1)));

end%function:save_candidate_parm()

function [ moves , cands , index ] = identify_all_saccades( moves , cands , index )

global DEBUG LIM_DURATION LIM_PEAKVEL MIN_DISP MAX_SKEW
global FIELDS_LOGICAL FIELDS_UINT16 FIELDS_SINGLE FIELDS_VECTOR
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
  
  for ff = 1:length(FIELDS_LOGICAL)
    moves.(FIELDS_LOGICAL{ff}) = [moves.(FIELDS_LOGICAL{ff}), false(1,NUM_TRIAL)];
  end
  for ff = 1:length(FIELDS_UINT16)
    moves.(FIELDS_UINT16{ff}) = [moves.(FIELDS_UINT16{ff}), zeros(1,NUM_TRIAL)];
  end
  for ff = 1:length(FIELDS_SINGLE)
    moves.(FIELDS_SINGLE{ff}) = [moves.(FIELDS_SINGLE{ff}), single(NaN(1,NUM_TRIAL))];
  end
  for ff = 1:length(FIELDS_VECTOR)
    moves.(FIELDS_VECTOR{ff}) = [moves.(FIELDS_VECTOR{ff}), single(NaN(ALLOT,NUM_TRIAL))];
  end
end

%save all saccades for this trial
for ff = 1:length(FIELDS_LOGICAL)
  moves.(FIELDS_LOGICAL{ff})(index:index+num_saccade-1) = [cands(idx_saccade).(FIELDS_LOGICAL{ff})];
end
for ff = 1:length(FIELDS_UINT16)
  moves.(FIELDS_UINT16{ff})(index:index+num_saccade-1) = [cands(idx_saccade).(FIELDS_UINT16{ff})];
end
for ff = 1:length(FIELDS_SINGLE)
  moves.(FIELDS_SINGLE{ff})(index:index+num_saccade-1) = [cands(idx_saccade).(FIELDS_SINGLE{ff})];
end
for ff = 1:length(FIELDS_VECTOR)
  moves.(FIELDS_VECTOR{ff})(:,index:index+num_saccade-1) = [cands(idx_saccade).(FIELDS_VECTOR{ff})];
end

cands = cands(idx_saccade);

%save the within-trial saccade index
moves.index(index:index+num_saccade-1) = (1 : num_saccade);

if (DEBUG)
  for jj = 1:length(cands)
    figure(44)
    plot(cands(jj).zz_x, 'k-'); hold on
    plot(cands(jj).zz_y, 'b-');
    hold off
    ylim([-9 9])
    title([num2str(cands(jj).trial),' ',num2str(jj),' ',num2str(cands(jj).clipped)], 'FontSize',8)
    pause(2.0)
  end%for:candidates(jj)
end%if(DEBUG)

index = index + num_saccade;

end%function:identify_all_saccades()

function [ moves , flag_tr ] = identify_taskrel_saccade( moves , cands , trial )

global LIM_RESPTIME MAX_RINIT MIN_RFIN
global FIELDS_LOGICAL FIELDS_UINT16 FIELDS_SINGLE FIELDS_VECTOR

flag_tr = false;

resptime = [cands.resptime];
r_init = sqrt([cands.x_init].^2 + [cands.y_init].^2);
r_fin = sqrt([cands.x_fin].^2 + [cands.y_fin].^2);

idx_cut_rt = (resptime < LIM_RESPTIME(1)) | (resptime > LIM_RESPTIME(2));
idx_cut_rinit = (r_init > MAX_RINIT);
idx_cut_rfin = (r_fin < MIN_RFIN) ;

idx_cut_tr = (idx_cut_rt | idx_cut_rinit | idx_cut_rfin);

idx_taskrel = find(~idx_cut_tr, 1,'first');
num_taskrel = length(idx_taskrel);

if (num_taskrel == 1)
  
  for ff = 1:length(FIELDS_LOGICAL)
    moves.(FIELDS_LOGICAL{ff})(trial) = cands(idx_taskrel).(FIELDS_LOGICAL{ff});
  end
  for ff = 1:length(FIELDS_UINT16)
    moves.(FIELDS_UINT16{ff})(trial) = cands(idx_taskrel).(FIELDS_UINT16{ff});
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
