function [ varargout ] = plotSDFChoiceErrXisiSAT( binfo , moves , movesPP , ninfo , nstats , spikes , varargin )
%plotSDFChoiceErrXisiSAT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});
ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\SEF_SAT\Figs\5-Error\SDF-ChoiceErr-xISI-Test-2\';

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxErrorGrade = (abs([ninfo.errGrade]) >= 1);

% idxEfficient = ismember([ninfo.taskType], [1,2]);

idxKeep = (idxArea & idxMonkey & idxErrorGrade);% & idxEfficient);

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);
NUM_CELLS = length(spikes);

TIME.PRIMARY = 3500 + (-200 : 200); OFFSET = 200; %time from primary saccade
TIME.SECONDARY = 3500 + (-200 : 200); %time from secondary saccade
TIME.BASELINE = 3500 + (-300 : -1); %time from array

T_INTERVAL_ESTIMATE_MAG = 200; %interval over which we compute the integral of error signal

%output initializations
sdfAccSH = new_struct({'RePrimary','ReSecondary','Baseline'}, 'dim',[1,NUM_CELLS]);
sdfAccSH = struct('Corr',sdfAccSH, 'Err',sdfAccSH); %short ISI
sdfAccLO = sdfAccSH; %long ISI
sdfFastSH = sdfAccSH; %short ISI
sdfFastLO = sdfAccSH; %long ISI

for cc = 1:NUM_CELLS
  fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  RTkk = double(moves(kk).resptime);
  ISIkk = double(movesPP(kk).resptime) - RTkk;
  ISIkk(ISIkk < 0) = NaN; %trials with no secondary saccade
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials, 'task','SAT');
  %index by condition
  idxAcc = ((binfo(kk).condition == 1) & ~idxIso);
  idxFast = ((binfo(kk).condition == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold | binfo(kk).err_nosacc);
  idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  %index by ISI
  medISI = nanmedian(ISIkk(idxErr));
  idxSH = (ISIkk <= medISI);
  idxLO = (ISIkk > medISI);
  
  %perform RT matching and group trials by condition and outcome
  trialsSH = groupTrialsRTmatched(RTkk, idxAcc, idxFast, idxCorr, (idxErr & idxSH));
  trialsLO = groupTrialsRTmatched(RTkk, idxAcc, idxFast, idxCorr, (idxErr & idxLO));
  
  %set "ISI" on correct trials as median ISI of choice error trials
  ISIkk(trialsSH.FastCorr) = round(nanmedian(ISIkk(trialsSH.FastErr)));
  ISIkk(trialsSH.AccCorr)  = round(nanmedian(ISIkk(trialsSH.AccErr)));
  ISIkk(trialsLO.FastCorr) = round(nanmedian(ISIkk(trialsLO.FastErr)));
  ISIkk(trialsLO.AccCorr)  = round(nanmedian(ISIkk(trialsLO.AccErr)));
  
  %save ISI for plotting
%   ISIplot = struct('AccSH',ISIkk(trialsSH.AccCorr(1)), 'FastSH',ISIkk(trialsSH.FastCorr(1)), ...
%     'AccLO',ISIkk(trialsLO.AccCorr(1)), 'FastLO',ISIkk(trialsLO.FastCorr(1)));
  
  %get single-trials SDFs
  [sdfAccST_SH, sdfFastST_SH] = getSingleTrialSDF(RTkk, ISIkk, spikes(cc).SAT, trialsSH, TIME);
  [sdfAccST_LO, sdfFastST_LO] = getSingleTrialSDF(RTkk, ISIkk, spikes(cc).SAT, trialsLO, TIME);
  
  %compute mean SDFs
  [sdfAccSH.Corr(cc),sdfAccSH.Err(cc)] = computeMeanSDF( sdfAccST_SH );
  [sdfFastSH.Corr(cc),sdfFastSH.Err(cc)] = computeMeanSDF( sdfFastST_SH );
  [sdfAccLO.Corr(cc),sdfAccLO.Err(cc)] = computeMeanSDF( sdfAccST_LO );
  [sdfFastLO.Corr(cc),sdfFastLO.Err(cc)] = computeMeanSDF( sdfFastST_LO );
    
  %% Parameterize the SDF
  ccNS = ninfo(cc).unitNum;
  
  %latency
%   [tErrAcc,tErrFast] = calcTimeErrSignal(sdfAccST, sdfFastST, OFFSET);
%   nstats(ccNS).A_ChcErr_tErrEnd_Acc = tErrAcc.End;
%   nstats(ccNS).A_ChcErr_tErrEnd_Fast = tErrFast.End;
  
  %plot individual cell activity
  sdfPlotCC = struct('AccCorrSH',sdfAccSH.Corr(cc), 'AccErrSH',sdfAccSH.Err(cc), ... %short ISI
    'FastCorrSH',sdfFastSH.Corr(cc), 'FastErrSH',sdfFastSH.Err(cc), ...
  	'AccCorrLO',sdfAccLO.Corr(cc), 'AccErrLO',sdfAccLO.Err(cc), ... %long ISI
    'FastCorrLO',sdfFastLO.Corr(cc), 'FastErrLO',sdfFastLO.Err(cc));
  plotSDFChcErrXisiSATcc(TIME, sdfPlotCC, ninfo(cc), nstats(ccNS))
  print([ROOTDIR, ninfo(cc).sess,'-',ninfo(cc).unit,'.tif'], '-dtiff')
  pause(0.1); close(); pause(0.1)
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = nstats;
end

end%fxn:plotSDFChoiceErrXisiSAT2()

function [ trialsGrouped ] = groupTrialsRTmatched(RT, idxAcc, idxFast, idxCorr, idxErr)

%Fast condition
trial_FC = find(idxFast & idxCorr);    RT_FC = RT(idxFast & idxCorr);
trial_FE = find(idxFast & idxErr);     RT_FE = RT(idxFast & idxErr);
[OLdist1, OLdist2, ~,~] = DistOverlap_Amir([trial_FC;RT_FC]', [trial_FE;RT_FE]');
trial_FC = OLdist1(:,1);
trial_FE = OLdist2(:,1);

%Accurate condition
trial_AC = find(idxAcc & idxCorr);    RT_AC = RT(idxAcc & idxCorr);
trial_AE = find(idxAcc & idxErr);     RT_AE = RT(idxAcc & idxErr);
[OLdist1, OLdist2, ~,~] = DistOverlap_Amir([trial_AC;RT_AC]', [trial_AE;RT_AE]');
trial_AC = OLdist1(:,1);
trial_AE = OLdist2(:,1);

%output
trialsGrouped = struct('AccCorr',trial_AC, 'AccErr',trial_AE, 'FastCorr',trial_FC, 'FastErr',trial_FE);

end%util:groupTrialsRTmatched()

function [sdfAccST, sdfFastST] = getSingleTrialSDF(RT, ISI, spikes, trials, time)

%compute SDFs and align on primary and secondary saccades
sdfReSTIM = compute_spike_density_fxn(spikes);
sdfRePRIMARY = align_signal_on_response(sdfReSTIM, RT);
sdfReSECONDARY = align_signal_on_response(sdfReSTIM, RT + ISI);

%isolate single-trial SDFs per group - Fast condition
sdfFastST.Corr.RePrimary = sdfRePRIMARY(trials.FastCorr, time.PRIMARY); %aligned on primary
sdfFastST.Err.RePrimary = sdfRePRIMARY(trials.FastErr, time.PRIMARY);
sdfFastST.Corr.ReSecondary = sdfReSECONDARY(trials.FastCorr, time.SECONDARY); %aligned on secondary
sdfFastST.Err.ReSecondary = sdfReSECONDARY(trials.FastErr, time.SECONDARY);
sdfFastST.Corr.ReStim = sdfReSTIM(trials.FastCorr, time.BASELINE); %aligned on array
sdfFastST.Err.ReStim = sdfReSTIM(trials.FastErr, time.BASELINE);

%isolate single-trial SDFs per group - Accurate condition
sdfAccST.Corr.RePrimary = sdfRePRIMARY(trials.AccCorr, time.PRIMARY); %aligned on primary
sdfAccST.Err.RePrimary = sdfRePRIMARY(trials.AccErr, time.PRIMARY);
sdfAccST.Corr.ReSecondary = sdfReSECONDARY(trials.AccCorr, time.SECONDARY); %aligned on secondary
sdfAccST.Err.ReSecondary = sdfReSECONDARY(trials.AccErr, time.SECONDARY);
sdfAccST.Corr.ReStim = sdfReSTIM(trials.AccCorr, time.BASELINE); %aligned on array
sdfAccST.Err.ReStim = sdfReSTIM(trials.AccErr, time.BASELINE);

end%util:getSingleTrialSDF()

function [ sdfCorr , sdfErr ] = computeMeanSDF( sdfSingleTrial )

sdfCorr.RePrimary = nanmean(sdfSingleTrial.Corr.RePrimary)';
sdfCorr.ReSecondary = nanmean(sdfSingleTrial.Corr.ReSecondary)';
sdfCorr.Baseline = nanmean(sdfSingleTrial.Corr.ReStim)';

sdfErr.RePrimary = nanmean(sdfSingleTrial.Err.RePrimary)';
sdfErr.ReSecondary = nanmean(sdfSingleTrial.Err.ReSecondary)';
sdfErr.Baseline = nanmean(sdfSingleTrial.Err.ReStim)';

end%util:computeMeanSDF()
