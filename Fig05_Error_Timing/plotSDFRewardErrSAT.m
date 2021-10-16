function [ varargout ] = plotSDFRewardErrSAT( behavData , unitData , unitData , spikes )
%plotSDFRewardErrSAT() Summary of this function goes here
%   Detailed explanation goes here

ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\SAT\Figures\Post-Reward\';

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});

idxRew = (abs(unitData.Basic_RewGrade) >= 2);
idxEfficiency = ismember(unitData.Task_LevelDifficulty, [1,2]);

idxKeep = (idxArea & idxMonkey & idxRew & idxEfficiency);

NUM_CELLS = sum(idxKeep);
unitData = unitData(idxKeep);
spikes = spikes(idxKeep);

T_REW = 3500 + (-400 : 800); OFFSET = 401;

%output initializations
sdfAcc.Corr = NaN(NUM_CELLS,length(T_REW));   sdfAcc.Err = NaN(NUM_CELLS,length(T_REW));
sdfFast.Corr = NaN(NUM_CELLS,length(T_REW));  sdfFast.Err = NaN(NUM_CELLS,length(T_REW));

for uu = 1:NUM_CELLS
  if ~isempty(unitData(unitData.aIndex(uu)).NormFactor_Rew); continue; end
  fprintf('%s - %s\n', unitData.Task_Session(uu), unitData.aID{uu})
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  
  trewKK = double(behavData.Task_TimeReward{kk}) + double(behavData.Sacc_RT{kk});
  idxNaN = isnan(trewKK);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData(uu,:), behavData.Task_NumTrials{kk});
  %index by condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1 & ~idxIso & ~idxNaN);
  idxFast = (behavData.Task_SATCondition{kk} == 3 & ~idxIso & ~idxNaN);
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  idxErr = (behavData.Task_ErrTime{kk});
  %index by screen clear on Fast trials
  idxClear = logical(behavData.Task_ClearDisplayFast{kk});
  
  %get single-trials SDFs
  trials = struct('AccCorr',find(idxAcc & idxCorr), 'AccErr',find(idxAcc & idxErr), ...
    'FastCorr',find(idxFast & idxCorr), 'FastErr',find(idxFast & idxErr & ~idxClear));
  [sdfAccST, sdfFastST] = getSingleTrialSDF(trewKK, spikes(uu).SAT, trials, T_REW);
  
  %compute mean SDFs
  sdfAcc.Corr(cc,:) = nanmean(sdfAccST.Corr);    sdfFast.Corr(cc,:) = nanmean(sdfFastST.Corr);
  sdfAcc.Err(cc,:) = nanmean(sdfAccST.Err);      sdfFast.Err(cc,:) = nanmean(sdfFastST.Err);
  sdfAll = struct('AccCorr',sdfAcc.Corr(cc,:), 'AccErr',sdfAcc.Err(cc,:), ...
    'FastCorr',sdfFast.Corr(cc,:), 'FastErr',sdfFast.Err(cc,:));
    
  %% Parameterize the SDF
  uuNS = unitData.aIndex(uu);
  
  if isnan(unitData(uuNS).A_Reward_tErrStart_Acc) %latency
    [tErrAcc,tErrFast] = computeTimeRPE(sdfAccST, sdfFastST, OFFSET);
    unitData(uuNS).A_Reward_tErrStart_Acc = tErrAcc.Start;
    unitData(uuNS).A_Reward_tErrStart_Fast = tErrFast.Start;
    unitData(uuNS).A_Reward_tErrEnd_Acc = tErrAcc.End;
    unitData(uuNS).A_Reward_tErrEnd_Fast = tErrFast.End;
  end
  
  %magnitude
%   [magAcc,magFast] = calcMagRewSignal(sdfAll, OFFSET, unitData(uuNS));
%   unitData(uuNS).A_Reward_magErr_Acc = magAcc;
%   unitData(uuNS).A_Reward_magErr_Fast = magFast;
  
  %normalization factor
  if isempty(unitData(uuNS).NormFactor_Rew)
    unitData(uuNS).NormFactor_All = max(sdfAcc.Corr(cc,:));
  end
  
  %plot individual cell activity
%   plotSDFRewErrSATcc(T_REW, sdfAll, unitData(uu,:), unitData(uuNS))
%   print([ROOTDIR, unitData.Task_Session(uu),'-',unitData.aID{uu},'-U',num2str(uuNS),'.tif'], '-dtiff')
%   pause(0.1); close()
  
end%for:cells(uu)

if (nargout > 0)
  varargout{1} = unitData;
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

function [ ] = plotSDFRewErrSATcc( TIME , sdfPlot , unitData , unitData )

%compute y-limits for vertical lines
tmp = [sdfPlot.AccCorr sdfPlot.AccErr sdfPlot.FastCorr sdfPlot.FastErr];
yLim = [min(tmp) max(tmp)];

figure()

%% Fast condition

subplot(2,1,1); hold on
plot([0 0], yLim, 'k:')

plot(TIME-3500, sdfPlot.FastCorr, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME-3500, sdfPlot.FastErr, ':', 'Color',[0 .7 0], 'LineWidth',1.0)

plot(unitData.TimingErrorSignal_Time(2)*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.25)
plot(unitData.TimingErrorSignal_Time(4)*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.25)

xlim([TIME(1) TIME(end)]-3500)
title(['Mag. = ', num2str(unitData.A_Reward_magErr_Fast), ' sp'])
print_session_unit(gca , unitData,[])
xticklabels([])

%% Accurate condition

subplot(2,1,2); hold on
plot([0 0], yLim, 'k:')

plot(TIME-3500, sdfPlot.AccCorr, 'r-', 'LineWidth',1.0)
plot(TIME-3500, sdfPlot.AccErr, 'r:', 'LineWidth',1.0)

plot(unitData.TimingErrorSignal_Time(1)*ones(1,2), yLim, 'r:', 'LineWidth',1.25)
plot(unitData.TimingErrorSignal_Time(3)*ones(1,2), yLim, 'r:', 'LineWidth',1.25)

title(['Mag. = ', num2str(unitData.A_Reward_magErr_Acc), ' sp'])
xlim([TIME(1) TIME(end)]-3500)
xlabel('Time from reward (ms)')

ppretty([4.8,3])

end%util:plotSDFRewErrSATcc()
