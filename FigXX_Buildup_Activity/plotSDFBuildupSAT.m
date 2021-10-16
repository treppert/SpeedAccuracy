function [ varargout ] = plotSDFBuildupSAT( behavData , moves , unitData , unitData , spikes , varargin )
%plotSDFBuildupSAT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});
% ROOTDIR = 'C:\Users\Tom\Dropbox\SAT\Figs-SDF-All-TaskRel';

idxArea = ismember(unitData.aArea, args.area);
idxMonkey = ismember(unitData.aMonkey, args.monkey);

idxVis = ([unitData.Basic_VisGrade] >= 2);   idxMove = (unitData.Basic_MovGrade >= 2);
idxErr = (unitData.Basic_ErrGrade >= 2);   idxRew = (abs(unitData.Basic_RewGrade) >= 2);
idxTaskRel = (idxVis | idxMove | idxErr | idxRew);

idxKeep = (idxArea & idxMonkey & idxTaskRel);

unitData = unitData(idxKeep);
spikes = spikes(idxKeep);
NUM_CELLS = length(spikes);

tVec.Stim = 3500 + (-100 : 300);
tVec.Resp = 3500 + (-300 : 100); IDX_EST_THRESH = (290 : 305);
IDX_PLOT = (1:300); %cut at time of saccade

%if desired, isolate one neuron of interest
% sessionPlot = {'E20130827001'};   unitPlot = {'16a'};
% sessionPlot = [];   unitPlot = [];

tmp = NaN(NUM_CELLS,length(tVec.Resp));
sdfAll = struct('AccCorr',tmp, 'AccErr',tmp, 'FastCorr',tmp, 'FastErr',tmp);

for uu = 1:NUM_CELLS
  fprintf('%s - %s\n', unitData.Task_Session(uu), unitData.aID{uu})
  
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  RespTimeKK = double(moves(kk).resptime);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData(uu,:), behavData.Task_NumTrials{kk});
  %index by condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1 & ~idxIso);
  idxFast = (behavData.Task_SATCondition{kk} == 3 & ~idxIso);
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  idxErr = (~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}) & behavData.Task_ErrTime{kk});
  %index by saccade direction (relative to MF)
  if isempty(unitData.Basic_MovField{uu})
    idxMF = true(1,behavData.Task_NumTrials{kk});
  else
    idxMF = ismember(moves(kk).octant, unitData.Basic_MovField{uu});
  end
  %index by screen clear on Fast trials
%   idxClear = logical(behavData.Task_ClearDisplayFast{kk});
  
  %get single-trials SDFs
  trials = struct('AccCorr',find(idxAcc & idxCorr & idxMF), 'AccErr',find(idxAcc & idxErr & idxMF), ...
    'FastCorr',find(idxFast & idxCorr & idxMF), 'FastErr',find(idxFast & idxErr & idxMF));
  
  %compute mean SDFs
  [sdfAccST, sdfFastST] = getSingleTrialSDF(RespTimeKK, spikes(uu).SAT, trials, tVec);
  sdfMeanAcc = computeMeanSDF( sdfAccST );
  sdfMeanFast = computeMeanSDF( sdfFastST );
    
  %% Parameterize the SDF
  uuNS = unitData.aIndex(uu);
  
  %discharge rate at saccade initiation
%   unitData(uuNS).A_Buildup_Threshold_AccCorr = mean(sdfMeanAcc.Resp.Corr(IDX_EST_THRESH));
%   unitData(uuNS).A_Buildup_Threshold_AccErr = mean(sdfMeanAcc.Resp.Err(IDX_EST_THRESH));
%   unitData(uuNS).A_Buildup_Threshold_FastCorr = mean(sdfMeanFast.Resp.Corr(IDX_EST_THRESH));
%   unitData(uuNS).A_Buildup_Threshold_FastErr = mean(sdfMeanFast.Resp.Err(IDX_EST_THRESH));
  
  %normalization factor
%   unitData(uuNS).NormFactor_Move = max(sdfMeanFast.Resp.Corr);
  
  %plot individual cell activity
%   plotSDFcc(tVec, sdfMeanAcc, sdfMeanFast, unitData(uu,:), unitData(uuNS), IDX_PLOT)
%   print([ROOTDIR, unitData.aArea{uu},'-',unitData.Task_Session(uu),'-',unitData.aID{uu},'.tif'], '-dtiff')
%   pause(0.05); close()
  
  sdfAll.AccCorr(cc,:) = sdfMeanAcc.Resp.Corr;
  sdfAll.AccErr(cc,:) =  sdfMeanAcc.Resp.Err;
  sdfAll.FastCorr(cc,:) = sdfMeanFast.Resp.Corr;
  sdfAll.FastErr(cc,:) =  sdfMeanFast.Resp.Err;
end%for:cells(uu)

if (nargout > 0)
  varargout{1} = unitData;
end

%% Plotting - Across neurons
unitData = unitData(idxKeep);

NSEM_FAST_ERR = sum(~isnan(sdfAll.FastErr(:,1)));
NSEM_ACC_ERR = sum(~isnan(sdfAll.AccErr(:,1)));

%normalization
for uu = 1:NUM_CELLS
%   normFactor = max(sdfAll.FastCorr(cc,:));
  normFactor = unitData(uu).NormFactor_Move;
  sdfAll.AccCorr(cc,:) = sdfAll.AccCorr(cc,:) / normFactor;
  sdfAll.FastCorr(cc,:) = sdfAll.FastCorr(cc,:) / normFactor;
  sdfAll.AccErr(cc,:) = sdfAll.AccErr(cc,:) / normFactor;
  sdfAll.FastErr(cc,:) = sdfAll.FastErr(cc,:) / normFactor;
end

%prep data for plotting
muFC = nanmean(sdfAll.FastCorr);  seFC = nanstd(sdfAll.FastCorr)/sqrt(NUM_CELLS);
muAC = nanmean(sdfAll.AccCorr);   seAC = nanstd(sdfAll.AccCorr)/sqrt(NUM_CELLS);
muFE = nanmean(sdfAll.FastErr);   seFE = nanstd(sdfAll.FastErr)/sqrt(NSEM_FAST_ERR);
muAE = nanmean(sdfAll.AccErr);    seAE = nanstd(sdfAll.AccErr)/sqrt(NSEM_ACC_ERR);

figure(); hold on
tVec.Resp = tVec.Resp(IDX_PLOT) - 3500;

plot([0 0], [.4 .8], 'k:', 'LineWidth',1.25)

plot(tVec.Resp, muFC(IDX_PLOT), 'Color',[0 .7 0], 'LineWidth',1.0)
plot(tVec.Resp, muFE(IDX_PLOT), 'Color',[0 .7 0], 'LineWidth',1.0, 'LineStyle',':')
plot(tVec.Resp, muAC(IDX_PLOT), 'Color','r', 'LineWidth',1.0)
plot(tVec.Resp, muAE(IDX_PLOT), 'Color','r', 'LineWidth',1.0, 'LineStyle',':')

%plot single errorbar at time of saccade
errorbar(5, muFC(300), seFC(300), 'Color',[0 .7 0], 'LineWidth',1.25)
errorbar(10, muFE(300), seFE(300), 'Color',[0 .7 0], 'LineWidth',0.75)
errorbar(15, muAC(300), seAC(300), 'Color','r', 'LineWidth',1.25)
errorbar(20, muAE(300), seAE(300), 'Color','r', 'LineWidth',0.75)

xlim([-300 25]); ytickformat('%2.1f')
set(gca, 'YAxisLocation','right')
ppretty([6,3])


end%fxn:plotSDFBuildupSAT()

function [sdfAccST, sdfFastST] = getSingleTrialSDF(RespTime, spikes, trials, time)

%compute SDFs and align on primary and secondary saccades
sdfReStim = compute_spike_density_fxn(spikes);
sdfReResp = align_signal_on_response(sdfReStim, RespTime);

%isolate single-trial SDFs per group - Fast condition
sdfFastST.Stim.Corr = sdfReStim(trials.FastCorr, time.Stim);
sdfFastST.Stim.Err = sdfReStim(trials.FastErr, time.Stim);
sdfFastST.Resp.Corr = sdfReResp(trials.FastCorr, time.Resp);
sdfFastST.Resp.Err = sdfReResp(trials.FastErr, time.Resp);

%isolate single-trial SDFs per group - Accurate condition
sdfAccST.Stim.Corr = sdfReStim(trials.AccCorr, time.Stim);
sdfAccST.Stim.Err = sdfReStim(trials.AccErr, time.Stim);
sdfAccST.Resp.Corr = sdfReResp(trials.AccCorr, time.Resp);
sdfAccST.Resp.Err = sdfReResp(trials.AccErr, time.Resp);

end%util:getSingleTrialSDF()

function [ sdfAverage ] = computeMeanSDF( sdfSingleTrial )
MIN_NUM_TRIAL = 10;

[NUM_ERR,NUM_SAMP] = size(sdfSingleTrial.Resp.Err);

sdfAverage.Stim.Corr = mean(sdfSingleTrial.Stim.Corr);
sdfAverage.Resp.Corr = mean(sdfSingleTrial.Resp.Corr);

if (NUM_ERR >= MIN_NUM_TRIAL)
  sdfAverage.Stim.Err =  mean(sdfSingleTrial.Stim.Err);
  sdfAverage.Resp.Err =  mean(sdfSingleTrial.Resp.Err);
else
  sdfAverage.Stim.Err =  NaN(1,NUM_SAMP);
  sdfAverage.Resp.Err =  NaN(1,NUM_SAMP);
end

end%util:computeMeanSDF()

function [ ] = plotSDFcc( tVec , sdfAcc , sdfFast , unitData , unitData , IDX_PLOT )
%plotSDFcc Summary of this function goes here
%   Detailed explanation goes here

tVec.Stim = tVec.Stim - 3500;
tVec.Resp = tVec.Resp(IDX_PLOT) - 3500;

% figure()

tmp = [sdfAcc.Stim.Corr sdfAcc.Stim.Err sdfFast.Stim.Corr sdfFast.Stim.Err ...
  sdfAcc.Resp.Corr sdfAcc.Resp.Err sdfFast.Resp.Corr sdfFast.Resp.Err];
yLim = [min(tmp) max(tmp)];

% subplot(1,2,1); hold on %visual response
% plot([0 0], yLim, 'k--')
% 
% plot(tVec.Stim, sdfAcc.Stim.Corr, 'r-', 'LineWidth',1.0)
% plot(tVec.Stim, sdfFast.Stim.Corr, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
% plot(tVec.Stim, sdfAcc.Stim.Err, 'r:', 'LineWidth',1.0)
% plot(tVec.Stim, sdfFast.Stim.Err, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
% 
% xlabel('Time from array (ms)'); xlim([tVec.Stim(1) tVec.Stim(end)])
% ylabel('Activity (sp/sec)')
% print_session_unit(gca , unitData,[])

% subplot(1,2,2); hold on %buildup activity
figure(); hold on
plot([0 0], yLim, 'k:')

plot(tVec.Resp, sdfAcc.Resp.Corr(IDX_PLOT), 'r-', 'LineWidth',1.0)
plot(tVec.Resp, sdfFast.Resp.Corr(IDX_PLOT), '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(tVec.Resp, sdfAcc.Resp.Err(IDX_PLOT), 'r:', 'LineWidth',1.0)
plot(tVec.Resp, sdfFast.Resp.Err(IDX_PLOT), ':', 'Color',[0 .7 0], 'LineWidth',1.0)

xlim([tVec.Resp(1) 25])
xlabel('Time from response (ms)')
print_session_unit(gca , unitData, [], 'horizontal')

title(['Acc=', num2str(unitData.Buildup_Correct(1)), '   Fast=', ...
  num2str(unitData.Buildup_Correct(2)), ' sp/s'], 'FontSize',8)

ppretty([6,3],'yRight')

end%util:plotSDFcc()

