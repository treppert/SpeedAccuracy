function [ varargout ] = plotSDFRewardErrSAT( binfo , ninfo , nstats , spikes )
%plotSDFRewardErrSAT() Summary of this function goes here
%   Detailed explanation goes here

ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\SAT\Figures\Post-Reward\';

idxArea = ismember({ninfo.area}, {'SEF'});
idxMonkey = ismember({ninfo.monkey}, {'D','E'});

idxRew = (abs([ninfo.rewGrade]) >= 2);
idxEfficiency = ismember([ninfo.taskType], [1,2]);

idxKeep = (idxArea & idxMonkey & idxRew & idxEfficiency);

NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

T_REW = 3500 + (-400 : 800); OFFSET = 401;

%output initializations
sdfAcc.Corr = NaN(NUM_CELLS,length(T_REW));   sdfAcc.Err = NaN(NUM_CELLS,length(T_REW));
sdfFast.Corr = NaN(NUM_CELLS,length(T_REW));  sdfFast.Err = NaN(NUM_CELLS,length(T_REW));

for cc = 1:NUM_CELLS
  if ~isempty(nstats(ninfo(cc).unitNum).NormFactor_Rew); continue; end
  fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  trewKK = double(binfo(kk).rewtime) + double(binfo(kk).resptime);
  idxNaN = isnan(trewKK);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxAcc = (binfo(kk).condition == 1 & ~idxIso & ~idxNaN);
  idxFast = (binfo(kk).condition == 3 & ~idxIso & ~idxNaN);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold | binfo(kk).err_nosacc);
  idxErr = (binfo(kk).err_time);
  %index by screen clear on Fast trials
  idxClear = logical(binfo(kk).clearDisplayFast);
  
  %get single-trials SDFs
  trials = struct('AccCorr',find(idxAcc & idxCorr), 'AccErr',find(idxAcc & idxErr), ...
    'FastCorr',find(idxFast & idxCorr), 'FastErr',find(idxFast & idxErr & ~idxClear));
  [sdfAccST, sdfFastST] = getSingleTrialSDF(trewKK, spikes(cc).SAT, trials, T_REW);
  
  %compute mean SDFs
  sdfAcc.Corr(cc,:) = nanmean(sdfAccST.Corr);    sdfFast.Corr(cc,:) = nanmean(sdfFastST.Corr);
  sdfAcc.Err(cc,:) = nanmean(sdfAccST.Err);      sdfFast.Err(cc,:) = nanmean(sdfFastST.Err);
  sdfAll = struct('AccCorr',sdfAcc.Corr(cc,:), 'AccErr',sdfAcc.Err(cc,:), ...
    'FastCorr',sdfFast.Corr(cc,:), 'FastErr',sdfFast.Err(cc,:));
    
  %% Parameterize the SDF
  ccNS = ninfo(cc).unitNum;
  
  if isnan(nstats(ccNS).A_Reward_tErrStart_Acc) %latency
    [tErrAcc,tErrFast] = computeTimeRPE(sdfAccST, sdfFastST, OFFSET);
    nstats(ccNS).A_Reward_tErrStart_Acc = tErrAcc.Start;
    nstats(ccNS).A_Reward_tErrStart_Fast = tErrFast.Start;
    nstats(ccNS).A_Reward_tErrEnd_Acc = tErrAcc.End;
    nstats(ccNS).A_Reward_tErrEnd_Fast = tErrFast.End;
  end
  
  %magnitude
%   [magAcc,magFast] = calcMagRewSignal(sdfAll, OFFSET, nstats(ccNS));
%   nstats(ccNS).A_Reward_magErr_Acc = magAcc;
%   nstats(ccNS).A_Reward_magErr_Fast = magFast;
  
  %normalization factor
  if isempty(nstats(ccNS).NormFactor_Rew)
    nstats(ccNS).NormFactor_All = max(sdfAcc.Corr(cc,:));
  end
  
  %plot individual cell activity
%   plotSDFRewErrSATcc(T_REW, sdfAll, ninfo(cc), nstats(ccNS))
%   print([ROOTDIR, ninfo(cc).sess,'-',ninfo(cc).unit,'-U',num2str(ccNS),'.tif'], '-dtiff')
%   pause(0.1); close()
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = nstats;
end

end%fxn:plotSDFRewardErrSAT()

function [sdfAccST, sdfFastST] = getSingleTrialSDF(RewTime, spikes, trials, tRew)

%compute SDFs and align on primary and secondary saccades
sdfReStim = compute_spike_density_fxn(spikes);
sdfReRew = align_signal_on_response(sdfReStim, RewTime);

%isolate single-trial SDFs per group - Fast condition
sdfFastST.Corr = sdfReRew(trials.FastCorr, tRew); %aligned on reward
sdfFastST.Err = sdfReRew(trials.FastErr, tRew);

%isolate single-trial SDFs per group - Accurate condition
sdfAccST.Corr = sdfReRew(trials.AccCorr, tRew);
sdfAccST.Err = sdfReRew(trials.AccErr, tRew);

end%util:getSingleTrialSDF()

function [ ] = plotSDFRewErrSATcc( TIME , sdfPlot , ninfo , nstats )

%compute y-limits for vertical lines
tmp = [sdfPlot.AccCorr sdfPlot.AccErr sdfPlot.FastCorr sdfPlot.FastErr];
yLim = [min(tmp) max(tmp)];

figure()

%% Fast condition

subplot(2,1,1); hold on
plot([0 0], yLim, 'k:')

plot(TIME-3500, sdfPlot.FastCorr, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME-3500, sdfPlot.FastErr, ':', 'Color',[0 .7 0], 'LineWidth',1.0)

plot(nstats.A_Reward_tErrStart_Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.25)
plot(nstats.A_Reward_tErrEnd_Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.25)

xlim([TIME(1) TIME(end)]-3500)
title(['Mag. = ', num2str(nstats.A_Reward_magErr_Fast), ' sp'])
print_session_unit(gca , ninfo,[])
xticklabels([])

%% Accurate condition

subplot(2,1,2); hold on
plot([0 0], yLim, 'k:')

plot(TIME-3500, sdfPlot.AccCorr, 'r-', 'LineWidth',1.0)
plot(TIME-3500, sdfPlot.AccErr, 'r:', 'LineWidth',1.0)

plot(nstats.A_Reward_tErrStart_Acc*ones(1,2), yLim, 'r:', 'LineWidth',1.25)
plot(nstats.A_Reward_tErrEnd_Acc*ones(1,2), yLim, 'r:', 'LineWidth',1.25)

title(['Mag. = ', num2str(nstats.A_Reward_magErr_Acc), ' sp'])
xlim([TIME(1) TIME(end)]-3500)
xlabel('Time from reward (ms)')

ppretty([4.8,3])

end%util:plotSDFRewErrSATcc()
