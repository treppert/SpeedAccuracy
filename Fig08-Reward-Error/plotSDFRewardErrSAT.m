function [ varargout ] = plotSDFRewardErrSAT( binfo , moves , movesPP , ninfo , nstats , spikes , varargin )
%plotSDFRewardErrSAT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});
% ROOT_DIR = 'C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\SEF_SAT\Figs\Error-Reward\';
ROOT_DIR = 'C:\Users\Thomas Reppert\Dropbox\SAT-Me\Figs-Error\';

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

% idxErrorGrade = (abs([ninfo.errGrade]) >= 0.5);
idxEfficient = ismember([ninfo.taskType], [1,2]);

idxKeep = (idxArea & idxMonkey & idxEfficient);

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);
NUM_CELLS = length(spikes);

binfo = determine_time_reward_SAT( binfo );

TIME.REWARD = 3500 + (-400 : 600); OFFSET = 401;
TIME.RESPONSE = 3500 + (-300 : 400);
TIME.STIMULUS = 3500 + (-400 : 300);
TIME.BASELINE = 3500 + (-300 : -1);

T_INTERVAL_ESTIMATE_MAG = 200;

%output initializations
tmp = new_struct({'Baseline','Stimulus','Response','Reward'}, 'dim',[1,NUM_CELLS]);
sdfAcc = struct('Corr',tmp, 'Err',tmp, 'ErrBetter',tmp, 'ErrWorse',tmp);
sdfFast = struct('Corr',tmp, 'ErrClear',tmp, 'ErrNoClear',tmp);

for cc = 1:NUM_CELLS
  fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  RespTimeKK = double(moves(kk).resptime);
  RewTimeKK = double(binfo(kk).rewtime + binfo(kk).resptime);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxAcc = (binfo(kk).condition == 1 & ~idxIso);
  idxFast = (binfo(kk).condition == 3 & ~idxIso);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idxErr = (~binfo(kk).err_dir & binfo(kk).err_time);
  %index by screen clear on Fast trials
  idxClear = logical(binfo(kk).clearDisplayFast);
  
  %Accurate: index by error magnitude
  rtAccErrKK = RespTimeKK(idxAcc & idxErr);
  medRTAccErrKK = median(rtAccErrKK);
  idxBetter = (RespTimeKK >= medRTAccErrKK);
  idxWorse = (RespTimeKK < medRTAccErrKK);
  
  %get single-trials SDFs
  trials = struct('AccCorr',find(idxAcc & idxCorr), 'AccErr',find(idxAcc & idxErr), ...
    'AccErrBetter',find(idxAcc & idxErr & idxBetter), 'AccErrWorse',find(idxAcc & idxErr & idxWorse), ...
    'FastCorr',find(idxFast & idxCorr), 'FastErrClear',find(idxFast & idxErr & idxClear), ...
    'FastErrNoClear',find(idxFast & idxErr & ~idxClear));
  [sdfAccST, sdfFastST] = getSingleTrialSDF(RespTimeKK, RewTimeKK, spikes(cc).SAT, trials, TIME);
  
  %compute mean SDFs
  [sdfAcc.Corr(cc),sdfAcc.Err(cc),sdfAcc.ErrBetter(cc),sdfAcc.ErrWorse(cc)] = computeMeanSDF( sdfAccST , 'Acc' );
  [sdfFast.Corr(cc),sdfFast.ErrClear(cc),sdfFast.ErrNoClear(cc)] = computeMeanSDF( sdfFastST , 'Fast' );
    
  %% Parameterize the SDF
  ccNS = ninfo(cc).unitNum;
  
  %latency
  [tErrAcc,tErrFast] = calcTimeErrSignal(sdfAccST, sdfFastST, OFFSET, 'signal','Reward');
  nstats(ccNS).A_Reward_tErrStart_Acc = tErrAcc.Start;
  nstats(ccNS).A_Reward_tErrStart_Fast = tErrFast.Start;
  nstats(ccNS).A_Reward_tErrEnd_Acc = tErrAcc.End;
  nstats(ccNS).A_Reward_tErrEnd_Fast = tErrFast.End;
  
  %magnitude
%   latAcc = nstats(ccNS).A_ChcErr_tErr_Acc + OFFSET;
%   latFast = nstats(ccNS).A_ChcErr_tErr_Fast + OFFSET;
%   ACorr_Acc = sdfAcc.Corr(cc).Reward(latAcc : latAcc + T_INTERVAL_ESTIMATE_MAG);
%   AErr_Acc = sdfAcc.Err(cc).Reward(latAcc : latAcc + T_INTERVAL_ESTIMATE_MAG);
%   ACorr_Fast = sdfFast.Corr(cc).Reward(latFast : latFast + T_INTERVAL_ESTIMATE_MAG);
%   AErr_Fast = sdfFast.Err(cc).Reward(latFast : latFast + T_INTERVAL_ESTIMATE_MAG);
%   nstats(ccNS).A_ChcErr_magErr_Acc = sum( AErr_Acc - ACorr_Acc ) / T_INTERVAL_ESTIMATE_MAG;
%   nstats(ccNS).A_ChcErr_magErr_Fast = sum( AErr_Fast - ACorr_Fast ) / T_INTERVAL_ESTIMATE_MAG;
  
  %plot individual cell activity
  sdfPlotCC = struct('AccCorr',sdfAcc.Corr(cc), 'AccErr',sdfAcc.Err(cc), 'AccErrBetter',sdfAcc.ErrBetter(cc), 'AccErrWorse',sdfAcc.ErrWorse(cc), ...
    'FastCorr',sdfFast.Corr(cc), 'FastErrClear',sdfFast.ErrClear(cc), 'FastErrNoClear',sdfFast.ErrNoClear(cc));
  plotSDFRewErrSATcc(TIME, sdfPlotCC, ninfo(cc), nstats(ccNS))
%   print([ROOT_DIR, ninfo(cc).area,'-',ninfo(cc).sess,'-',ninfo(cc).unit,'.tif'], '-dtiff'); pause(0.1); close()
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = nstats;
end

end%fxn:plotSDFRewardErrSAT()

function [sdfAccST, sdfFastST] = getSingleTrialSDF(RespTime, RewTime, spikes, trials, time)

%compute SDFs and align on primary and secondary saccades
sdfReSTIM = compute_spike_density_fxn(spikes);
sdfReRESPONSE = align_signal_on_response(sdfReSTIM, RespTime);
sdfReREWARD = align_signal_on_response(sdfReSTIM, RewTime);

%isolate single-trial SDFs per group - Fast condition
sdfFastST.Corr.Reward = sdfReREWARD(trials.FastCorr, time.REWARD); %aligned on reward
sdfFastST.ErrClear.Reward = sdfReREWARD(trials.FastErrClear, time.REWARD);
sdfFastST.ErrNoClear.Reward = sdfReREWARD(trials.FastErrNoClear, time.REWARD);
sdfFastST.Corr.Response = sdfReRESPONSE(trials.FastCorr, time.RESPONSE); %aligned on response
sdfFastST.ErrClear.Response = sdfReRESPONSE(trials.FastErrClear, time.RESPONSE);
sdfFastST.ErrNoClear.Response = sdfReRESPONSE(trials.FastErrNoClear, time.RESPONSE);
sdfFastST.Corr.Stimulus = sdfReSTIM(trials.FastCorr, time.STIMULUS); %post-array
sdfFastST.ErrClear.Stimulus = sdfReSTIM(trials.FastErrClear, time.STIMULUS);
sdfFastST.ErrNoClear.Stimulus = sdfReSTIM(trials.FastErrNoClear, time.STIMULUS);
sdfFastST.Corr.Baseline = sdfReSTIM(trials.FastCorr, time.BASELINE); %pre-array
sdfFastST.ErrClear.Baseline = sdfReSTIM(trials.FastErrClear, time.BASELINE);
sdfFastST.ErrNoClear.Baseline = sdfReSTIM(trials.FastErrNoClear, time.BASELINE);

%isolate single-trial SDFs per group - Accurate condition
sdfAccST.Corr.Reward = sdfReREWARD(trials.AccCorr, time.REWARD);
sdfAccST.Err.Reward = sdfReREWARD(trials.AccErr, time.REWARD);
sdfAccST.ErrBetter.Reward = sdfReREWARD(trials.AccErrBetter, time.REWARD);
sdfAccST.ErrWorse.Reward = sdfReREWARD(trials.AccErrWorse, time.REWARD);
sdfAccST.Corr.Response = sdfReRESPONSE(trials.AccCorr, time.RESPONSE);
sdfAccST.Err.Response = sdfReRESPONSE(trials.AccErr, time.RESPONSE);
sdfAccST.ErrBetter.Response = sdfReREWARD(trials.AccErrBetter, time.RESPONSE);
sdfAccST.ErrWorse.Response = sdfReREWARD(trials.AccErrWorse, time.RESPONSE);
sdfAccST.Corr.Stimulus = sdfReSTIM(trials.AccCorr, time.STIMULUS);
sdfAccST.Err.Stimulus = sdfReSTIM(trials.AccErr, time.STIMULUS);
sdfAccST.ErrBetter.Stimulus = sdfReREWARD(trials.AccErrBetter, time.STIMULUS);
sdfAccST.ErrWorse.Stimulus = sdfReREWARD(trials.AccErrWorse, time.STIMULUS);
sdfAccST.Corr.Baseline = sdfReSTIM(trials.AccCorr, time.BASELINE);
sdfAccST.Err.Baseline = sdfReSTIM(trials.AccErr, time.BASELINE);
sdfAccST.ErrBetter.Baseline = sdfReREWARD(trials.AccErrBetter, time.BASELINE);
sdfAccST.ErrWorse.Baseline = sdfReREWARD(trials.AccErrWorse, time.BASELINE);

end%util:getSingleTrialSDF()

function [ sdfCorr , sdfErr , varargout ] = computeMeanSDF( sdfSingleTrial , condition )

sdfCorr.Reward = nanmean(sdfSingleTrial.Corr.Reward)';
sdfCorr.Response = nanmean(sdfSingleTrial.Corr.Response)';
sdfCorr.Stimulus = nanmean(sdfSingleTrial.Corr.Stimulus)';
sdfCorr.Baseline = nanmean(sdfSingleTrial.Corr.Baseline)';

if strcmp(condition, 'Fast')
  sdfErr.Reward = nanmean(sdfSingleTrial.ErrClear.Reward)';
  sdfErr.Response = nanmean(sdfSingleTrial.ErrClear.Response)';
  sdfErr.Stimulus = nanmean(sdfSingleTrial.ErrClear.Stimulus)';
  sdfErr.Baseline = nanmean(sdfSingleTrial.ErrClear.Baseline)';
  tmp.Reward = nanmean(sdfSingleTrial.ErrNoClear.Reward)';
  tmp.Response = nanmean(sdfSingleTrial.ErrNoClear.Response)';
  tmp.Stimulus = nanmean(sdfSingleTrial.ErrNoClear.Stimulus)';
  tmp.Baseline = nanmean(sdfSingleTrial.ErrNoClear.Baseline)';
  varargout{1} = tmp;
elseif strcmp(condition, 'Acc')
  sdfErr.Reward = nanmean(sdfSingleTrial.Err.Reward)';
  sdfErr.Response = nanmean(sdfSingleTrial.Err.Response)';
  sdfErr.Stimulus = nanmean(sdfSingleTrial.Err.Stimulus)';
  sdfErr.Baseline = nanmean(sdfSingleTrial.Err.Baseline)';
  tmp.Reward = nanmean(sdfSingleTrial.ErrBetter.Reward)';
  tmp.Response = nanmean(sdfSingleTrial.ErrBetter.Response)';
  tmp.Stimulus = nanmean(sdfSingleTrial.ErrBetter.Stimulus)';
  tmp.Baseline = nanmean(sdfSingleTrial.ErrBetter.Baseline)';
  varargout{1} = tmp;
  tmp.Reward = nanmean(sdfSingleTrial.ErrWorse.Reward)';
  tmp.Response = nanmean(sdfSingleTrial.ErrWorse.Response)';
  tmp.Stimulus = nanmean(sdfSingleTrial.ErrWorse.Stimulus)';
  tmp.Baseline = nanmean(sdfSingleTrial.ErrWorse.Baseline)';
  varargout{2} = tmp;
end

end%util:computeMeanSDF()
