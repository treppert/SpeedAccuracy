function [ varargout ] = plotSDFRewardErrSAT( binfo , moves , movesPP , ninfo , nstats , spikes , varargin )
%plotSDFRewardErrSAT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});
% ROOT_DIR = 'C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\SEF_SAT\Figs\Error-Reward\';
ROOT_DIR = 'C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\SEF_SAT\Figs\6-Reward\';

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxReward = ~isnan([nstats.A_Reward_tErrStart_Acc]);
idxEfficient = ismember([ninfo.taskType], [1,2]);

idxKeep = (idxArea & idxMonkey & ~idxReward & idxEfficient);

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);
NUM_CELLS = length(spikes);

binfo = determine_time_reward_SAT( binfo );

TIME.REWARD = 3500 + (-200 : 800); OFFSET = 201;
TIME.RESPONSE = 3500 + (-300 : 400);
TIME.STIMULUS = 3500 + (-400 : 300);
TIME.BASELINE = 3500 + (-300 : -1);

T_INTERVAL_ESTIMATE_MAG = 200;

%output initializations
tmp = new_struct({'Baseline','Stimulus','Response','Reward'}, 'dim',[1,NUM_CELLS]);
sdfAcc = struct('Corr',tmp, 'Err',tmp);
sdfFast = struct('Corr',tmp, 'Err',tmp);

for cc = 1:NUM_CELLS
  fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  RespTimeKK = double(moves(kk).resptime);
  RewTimeKK = double(binfo(kk).rewtime + binfo(kk).resptime);
  idxNaN = isnan(RewTimeKK);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxAcc = (binfo(kk).condition == 1 & ~idxIso & ~idxNaN);
  idxFast = (binfo(kk).condition == 3 & ~idxIso & ~idxNaN);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idxErr = (~binfo(kk).err_dir & binfo(kk).err_time);
  %index by screen clear on Fast trials
  idxClear = logical(binfo(kk).clearDisplayFast);
  
  %get single-trials SDFs
  trials = struct('AccCorr',find(idxAcc & idxCorr), 'AccErr',find(idxAcc & idxErr), ...
    'FastCorr',find(idxFast & idxCorr), 'FastErr',find(idxFast & idxErr & ~idxClear));
  [sdfAccST, sdfFastST] = getSingleTrialSDF(RespTimeKK, RewTimeKK, spikes(cc).SAT, trials, TIME);
  
  %compute mean SDFs
  [sdfAcc.Corr(cc),sdfAcc.Err(cc)] = computeMeanSDF( sdfAccST );
  [sdfFast.Corr(cc),sdfFast.Err(cc)] = computeMeanSDF( sdfFastST );
    
  %% Parameterize the SDF
  ccNS = ninfo(cc).unitNum;
  
  %latency
%   [tErrAcc,tErrFast] = computeTimeRPE(sdfAccST, sdfFastST, OFFSET);
%   nstats(ccNS).A_Reward_tErrStart_Acc = tErrAcc.Start;
%   nstats(ccNS).A_Reward_tErrStart_Fast = tErrFast.Start;
%   nstats(ccNS).A_Reward_tErrEnd_Acc = tErrAcc.End;
%   nstats(ccNS).A_Reward_tErrEnd_Fast = tErrFast.End;
  
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
  sdfPlotCC = struct('AccCorr',sdfAcc.Corr(cc), 'AccErr',sdfAcc.Err(cc), ...
    'FastCorr',sdfFast.Corr(cc), 'FastErr',sdfFast.Err(cc));
  plotSDFRewErrSATcc(TIME, sdfPlotCC, ninfo(cc), nstats(ccNS))
  print([ROOT_DIR, ninfo(cc).area,'-',ninfo(cc).sess,'-',ninfo(cc).unit,'.tif'], '-dtiff')
  pause(0.1); close()
  
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
sdfFastST.Err.Reward = sdfReREWARD(trials.FastErr, time.REWARD);
sdfFastST.Corr.Response = sdfReRESPONSE(trials.FastCorr, time.RESPONSE); %aligned on response
sdfFastST.Err.Response = sdfReRESPONSE(trials.FastErr, time.RESPONSE);
sdfFastST.Corr.Stimulus = sdfReSTIM(trials.FastCorr, time.STIMULUS); %post-array
sdfFastST.Err.Stimulus = sdfReSTIM(trials.FastErr, time.STIMULUS);
sdfFastST.Corr.Baseline = sdfReSTIM(trials.FastCorr, time.BASELINE); %pre-array
sdfFastST.Err.Baseline = sdfReSTIM(trials.FastErr, time.BASELINE);

%isolate single-trial SDFs per group - Accurate condition
sdfAccST.Corr.Reward = sdfReREWARD(trials.AccCorr, time.REWARD);
sdfAccST.Err.Reward = sdfReREWARD(trials.AccErr, time.REWARD);
sdfAccST.Corr.Response = sdfReRESPONSE(trials.AccCorr, time.RESPONSE);
sdfAccST.Err.Response = sdfReRESPONSE(trials.AccErr, time.RESPONSE);
sdfAccST.Corr.Stimulus = sdfReSTIM(trials.AccCorr, time.STIMULUS);
sdfAccST.Err.Stimulus = sdfReSTIM(trials.AccErr, time.STIMULUS);
sdfAccST.Corr.Baseline = sdfReSTIM(trials.AccCorr, time.BASELINE);
sdfAccST.Err.Baseline = sdfReSTIM(trials.AccErr, time.BASELINE);

end%util:getSingleTrialSDF()

function [ sdfCorr , sdfErr ] = computeMeanSDF( sdfSingleTrial )
Epoch = {'Reward','Response','Stimulus','Baseline'};

for ee = 1:4 %loop over trial epochs
  sdfCorr.(Epoch{ee}) = nanmean(sdfSingleTrial.Corr.(Epoch{ee}))';
  sdfErr.(Epoch{ee}) = nanmean(sdfSingleTrial.Err.(Epoch{ee}))';
end

end%util:computeMeanSDF()

