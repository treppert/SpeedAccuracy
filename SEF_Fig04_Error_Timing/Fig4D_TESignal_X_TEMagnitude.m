% function [ ] = Fig4D_TESignal_X_TEMagnitude( behavData , unitData , spikesSAT )
%Fig4D_TESignal_X_TEMagnitude Summary of this function goes here
%   Detailed explanation goes here

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});
idxTErrUnit = (unitData.Grade_Rew == 2);
idxKeep = (idxArea & idxMonkey & idxTErrUnit);

NUM_UNIT = sum(idxKeep);
unitDataTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

MIN_PER_BIN = 5; %minimum number of trials per errRT bin
% T_COUNT_REW = 3500 + [0, 400]; %window over which to count spikes (0 = onset of encoding)
T_COUNT_BASE = 3500 + [-250, 50]; %window for BASELINE CORRECTION

%prepare to bin trials by timing error magnitude
TERR_LIM = linspace(.01, 1, 9); %quantile limits for binning
NUM_BIN = length(TERR_LIM) - 1;

%initializations
spkCt_Fast = NaN(NUM_UNIT,NUM_BIN);
spkCt_AccErr = spkCt_Fast;
spkCt_AccCorr = NaN(NUM_UNIT,1);

tErr_Fast = NaN(NUM_UNIT,NUM_BIN);
tErr_Acc = NaN(NUM_UNIT,NUM_BIN);

for uu = 1:NUM_UNIT
  kk = ismember(behavData.Task_Session, unitDataTest.Task_Session(uu));
  nTrial_kk = behavData.Task_NumTrials(kk);
  
  %get RT and time of reward delivery
  RT_kk = behavData.Sacc_RT{kk};
  tRew_kk = RT_kk + behavData.Task_TimeReward{kk};
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by screen clear on Fast trials
  idxClear = logical(behavData.Task_ClearDisplayFast{kk});
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  idxErr = (behavData.Task_ErrTime{kk} & ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  %index by condition
  idxFast = (behavData.Task_SATCondition{kk} == 3 & ~idxIso & ~idxClear);
  idxAcc = (behavData.Task_SATCondition{kk} == 1 & ~idxIso);
  
  %get response deadline for each condition
  dlineAcc =  median(behavData.Task_Deadline{kk}(idxAcc));
  dlineFast = median(behavData.Task_Deadline{kk}(idxFast));
  
  %get window over which to count spikes
  tCount_Fast = unitDataTest.RewardSignal_Time(uu,1:2) + 3500 + nanmedian(tRew_kk);
  tCount_Acc  = unitDataTest.RewardSignal_Time(uu,3:4) + 3500 + nanmedian(tRew_kk);
  
  %compute spike counts over interval of interest
  spkCt_uu = NaN(nTrial_kk,1);
  spkCt_uu(idxAcc)  = cellfun(@(x) sum((x > tCount_Acc(1)) & (x < tCount_Acc(2))),   spikesTest{uu}(idxAcc));
  spkCt_uu(idxFast) = cellfun(@(x) sum((x > tCount_Fast(1)) & (x < tCount_Fast(2))), spikesTest{uu}(idxFast));
  
  %compute spike counts during baseline interval
  spkCt_Base_uu  = cellfun(@(x) sum((x > T_COUNT_BASE(1)) & (x < T_COUNT_BASE(2))), spikesTest{uu});
  
  %z-score the baseline-corrected spike counts
%   spkCt_uu = spkCt_uu - spkCt_Base_uu;
  spkCt_uu = (spkCt_uu - nanmean(spkCt_uu)) / nanstd(spkCt_uu);
  
  %compute error in RT for each condition
  errRT_kk = NaN(nTrial_kk,1);
  errRT_kk(idxAcc)  = dlineAcc - RT_kk(idxAcc);
  errRT_kk(idxFast) = RT_kk(idxFast) - dlineFast;
  
  %compute RT error quantiles for binning
  errLim_Acc = quantile(errRT_kk(idxAcc & idxErr), TERR_LIM);
  errLim_Fast = quantile(errRT_kk(idxFast & idxErr), TERR_LIM);
  
  %bin trials by timing error magnitude
  for bb = 1:NUM_BIN
    idx_bb = (idxAcc & idxErr & (errRT_kk > errLim_Acc(bb)) & (errRT_kk <= errLim_Acc(bb+1)));
    
    if (sum(idx_bb) >= MIN_PER_BIN)
      spkCt_AccErr(uu,bb) = median( spkCt_uu(idx_bb) );
      tErr_Acc(uu,bb)  = mean( errLim_Acc(bb:bb+1) );
    else
      continue
    end
  end % for : RTerr-bin (bb)
  
  %compute signal magnitude on correct trials
  spkCt_AccCorr(uu) = median( spkCt_uu(idxAcc & idxCorr) );
  
end % for : unit(uu)

%% Stats
% DV_Signal = reshape(spkCT_All', NUM_UNIT*N_BIN,1);
% F_Error = T_ERR; F_Error = repmat(F_Error, 1,NUM_UNIT)';
% anovan(DV_Signal, {F_Error});

%save for ANOVA in R
% save('C:\Users\Thomas Reppert\Dropbox\SAT\Stats\TErrSignalXRTErr.mat', 'F_Error','DV_Signal')

%% Plotting
Xmu = [0, nanmean(tErr_Acc)];
Ymu = [mean(spkCt_AccCorr), nanmean(spkCt_AccErr)];
Xse = [0, nanstd(tErr_Acc)] / sqrt(NUM_UNIT);
Yse = [std(spkCt_AccCorr), nanstd(spkCt_AccErr)] / sqrt(NUM_UNIT);

figure(); hold on
% line([0 0], [0 1], 'Color','k', 'LineStyle',':', 'LineWidth',1.5)
% line(tErr_Acc', spkCt_Acc', 'Color',[.5 .5 .5], 'Marker','.', 'MarkerSize',8, 'LineWidth',0.5)
errorbar(-Xmu,Ymu, Yse,Yse, Xse,Xse, 'o', 'CapSize',0, 'Color','k')
ylabel('Signal magnitude (z)'); ytickformat('%2.1f')
xlabel('RT error (ms)')

ppretty([3.2,2])

clearvars -except behavData unitData spikesSAT ROOTDIR_SAT_DATA
% end % fxn : Fig4D_TESignal_X_TEMagnitude()

