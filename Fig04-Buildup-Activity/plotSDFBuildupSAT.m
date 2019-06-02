function [ varargout ] = plotSDFBuildupSAT( binfo , moves , ninfo , nstats , spikes , varargin )
%plotSDFBuildupSAT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});
ROOTDIR = 'C:\Users\Tom\Dropbox\Speed Accuracy\SEF_SAT\Figs\4-Buildup\';

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxMove = ([ninfo.moveGrade] >= 2);
idxEfficiency = ismember([ninfo.taskType], [2]);

idxKeep = (idxArea & idxMonkey & idxMove & idxEfficiency);

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);
NUM_CELLS = length(spikes);

tVec.Stim = 3500 + (-100 : 300);
tVec.Resp = 3500 + (-300 : 100); IDX_EST_THRESH = (290 : 305);
IDX_PLOT = (1:300); %cut at time of saccade

%if desired, isolate one neuron of interest
% sessionPlot = {'E20130827001'};   unitPlot = {'16a'};
sessionPlot = [];   unitPlot = [];

tmp = NaN(NUM_CELLS,length(tVec.Resp));
sdfAll = struct('AccCorr',tmp, 'AccErr',tmp, 'FastCorr',tmp, 'FastErr',tmp);

for cc = 1:NUM_CELLS
  if ~isempty(sessionPlot) && ~(ismember(ninfo(cc).sess, sessionPlot) && ismember(ninfo(cc).unit, unitPlot))
    continue %if desired, isolate one neuron of interest
  end
  fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  RespTimeKK = double(moves(kk).resptime);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxAcc = (binfo(kk).condition == 1 & ~idxIso);
  idxFast = (binfo(kk).condition == 3 & ~idxIso);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold | binfo(kk).err_nosacc);
  idxErr = (~(binfo(kk).err_dir | binfo(kk).err_hold | binfo(kk).err_nosacc) & binfo(kk).err_time);
  %index by saccade direction (relative to MF)
  idxMF = ismember(moves(kk).octant, ninfo(cc).moveField);
  %index by screen clear on Fast trials
%   idxClear = logical(binfo(kk).clearDisplayFast);
  
  %get single-trials SDFs
  trials = struct('AccCorr',find(idxAcc & idxCorr & idxMF), 'AccErr',find(idxAcc & idxErr & idxMF), ...
    'FastCorr',find(idxFast & idxCorr & idxMF), 'FastErr',find(idxFast & idxErr & idxMF));
  
  %compute mean SDFs
  [sdfAccST, sdfFastST] = getSingleTrialSDF(RespTimeKK, spikes(cc).SAT, trials, tVec);
  sdfMeanAcc = computeMeanSDF( sdfAccST );
  sdfMeanFast = computeMeanSDF( sdfFastST );
    
  %% Parameterize the SDF
  ccNS = ninfo(cc).unitNum;
  
  %discharge rate at saccade initiation
  nstats(ccNS).A_Buildup_Threshold_AccCorr = mean(sdfMeanAcc.Resp.Corr(IDX_EST_THRESH));
  nstats(ccNS).A_Buildup_Threshold_AccErr = mean(sdfMeanAcc.Resp.Err(IDX_EST_THRESH));
  nstats(ccNS).A_Buildup_Threshold_FastCorr = mean(sdfMeanFast.Resp.Corr(IDX_EST_THRESH));
  nstats(ccNS).A_Buildup_Threshold_FastErr = mean(sdfMeanFast.Resp.Err(IDX_EST_THRESH));
  
  %plot individual cell activity
%   plotSDFcc(tVec, sdfMeanAcc, sdfMeanFast, ninfo(cc), nstats(ccNS), IDX_PLOT)
%   print([ROOTDIR, ninfo(cc).area,'-',ninfo(cc).sess,'-',ninfo(cc).unit,'.tif'], '-dtiff')
%   pause(0.05); close()
  
  sdfAll.AccCorr(cc,:) = sdfMeanAcc.Resp.Corr;
  sdfAll.AccErr(cc,:) =  sdfMeanAcc.Resp.Err;
  sdfAll.FastCorr(cc,:) = sdfMeanFast.Resp.Corr;
  sdfAll.FastErr(cc,:) =  sdfMeanFast.Resp.Err;
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = nstats;
end

%% Plotting - Across neurons
NSEM_FAST_ERR = sum(~isnan(sdfAll.FastErr(:,1)));
NSEM_ACC_ERR = sum(~isnan(sdfAll.AccErr(:,1)));

%normalization
for cc = 1:NUM_CELLS
  normFactor = max(sdfAll.FastCorr(cc,:));
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

function [ ] = plotSDFcc( tVec , sdfAcc , sdfFast , ninfo , nstats , IDX_PLOT )
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
% print_session_unit(gca , ninfo,[])

% subplot(1,2,2); hold on %buildup activity
figure(); hold on
plot([0 0], yLim, 'k:')

plot(tVec.Resp, sdfAcc.Resp.Corr(IDX_PLOT), 'r-', 'LineWidth',1.0)
plot(tVec.Resp, sdfFast.Resp.Corr(IDX_PLOT), '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(tVec.Resp, sdfAcc.Resp.Err(IDX_PLOT), 'r:', 'LineWidth',1.0)
plot(tVec.Resp, sdfFast.Resp.Err(IDX_PLOT), ':', 'Color',[0 .7 0], 'LineWidth',1.0)

xlim([tVec.Resp(1) 25])
xlabel('Time from response (ms)')
print_session_unit(gca , ninfo, [], 'horizontal')

title(['Acc=', num2str(nstats.A_Buildup_Threshold_AccCorr), '   Fast=', ...
  num2str(nstats.A_Buildup_Threshold_FastCorr), ' sp/s'], 'FontSize',8)

ppretty([6,3],'yRight')

end%util:plotSDFcc()

