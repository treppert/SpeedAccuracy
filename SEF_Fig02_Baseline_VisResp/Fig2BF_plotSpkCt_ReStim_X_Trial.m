function [ ] = Fig2BF_plotSpkCt_ReStim_X_Trial( behavData , unitData , spikesSAT )
%Fig2BF_plotSpkCt_ReStim_X_Trial Summary of this function goes here
%   Detailed explanation goes here

MIN_MEDIAN_SPIKE_COUNT = 5;
INTERVAL = 'visResponse';

TRIAL_TEST = (-4 : +3);
NUM_TRIAL_TEST = length(TRIAL_TEST);
trialSwitch = identify_condition_switch(behavData);

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});
idxVisUnit = (unitData.Grade_Vis >= 3);
idxMoveUnit = (unitData.Grade_Mov >= 3);

if strcmp(INTERVAL, 'Baseline')
  unitTest = (idxArea & idxMonkey & (idxVisUnit | idxMoveUnit) & (unitData.SAT_Effect_Baseline == 1));
  T_TEST = 3500 + [-600 20];
elseif strcmp(INTERVAL, 'visResponse')
  unitTest = (idxArea & idxMonkey & idxVisUnit & unitData.SAT_Effect_VisResp);
  T_TEST = 3500 + [50 200];
end

NUM_UNIT = sum(unitTest);
unitData = unitData(unitTest,:);
spikesSAT = spikesSAT(unitTest);

%initialize spike count
scA2F_All = NaN(NUM_UNIT,NUM_TRIAL_TEST);
scF2A_All = NaN(NUM_UNIT,NUM_TRIAL_TEST);
%initialize unit cuts
uuCut = [];

for uu = 1:NUM_UNIT
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  
  %compute spike count for all trials
  spkCnt_uu = cellfun(@(x) sum((x > T_TEST(1)) & (x < T_TEST(2))), spikesSAT{uu});
  
  %compute median spike count
  medSC_uu = median(spkCnt_uu);
  if (medSC_uu < MIN_MEDIAN_SPIKE_COUNT)
    fprintf('Skipping Unit %s-%s due to minimum spike count\n', unitData.Task_Session{uu}, unitData.aID{uu})
    uuCut = cat(2, uuCut, uu);  continue
  end
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  
  %compute z-scored spike count
  spkCnt_uu(idxCorr & ~idxIso) = zscore(spkCnt_uu(idxCorr & ~idxIso));
  
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & idxCorr & ~idxIso);    trialAcc = find(idxAcc);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & idxCorr & ~idxIso);   trialFast = find(idxFast);
  
  %split by task condition
  spkCntAcc_uu = spkCnt_uu(idxAcc);
  spkCntFast_uu = spkCnt_uu(idxFast);
  
  %index by trial number
  for jj = 1:NUM_TRIAL_TEST
    if (TRIAL_TEST(jj) < 0) %Before condition switch
      %get all trials at this index
      idxJJ_A2F = ismember(trialAcc, trialSwitch.A2F{kk} + TRIAL_TEST(jj));
      idxJJ_F2A = ismember(trialFast, trialSwitch.F2A{kk} + TRIAL_TEST(jj));
      %compute mean spike count for this trial
      scA2F_All(uu,jj) = mean(spkCntAcc_uu(idxJJ_A2F));
      scF2A_All(uu,jj) = mean(spkCntFast_uu(idxJJ_F2A));
    else %After condition switch
      idxJJ_A2F = ismember(trialFast, trialSwitch.A2F{kk} + TRIAL_TEST(jj));
      idxJJ_F2A = ismember(trialAcc, trialSwitch.F2A{kk} + TRIAL_TEST(jj));
      scA2F_All(uu,jj) = mean(spkCntFast_uu(idxJJ_A2F));
      scF2A_All(uu,jj) = mean(spkCntAcc_uu(idxJJ_F2A));
    end
  end % for : trial (jj)
  
end % for : unit (uu)

%cut units based on min spike count
NUM_UNIT = NUM_UNIT - length(uuCut);
scA2F_All(uuCut,:) = [];
scF2A_All(uuCut,:) = [];


%% Plotting
mu_A2F = mean(scA2F_All);    se_A2F = std(scA2F_All) / sqrt(NUM_UNIT);
mu_F2A = mean(scF2A_All);    se_F2A = std(scF2A_All) / sqrt(NUM_UNIT);

figure()

subplot(1,2,1); hold on
plot([-3 2], [0 0], 'k:')
errorbar(TRIAL_TEST, mu_A2F, se_A2F, 'capsize',0, 'Color','k')
xticks(-4:3); xticklabels({}); ylabel('Spike count (z)')
xlim([-4.5 3.5]); set(gca, 'XMinorTick','off')

subplot(1,2,2); hold on
plot([-3 2], [0 0], 'k:')
errorbar(TRIAL_TEST, mu_F2A, se_F2A, 'capsize',0, 'Color','k')
xticks(-4:3); xticklabels({}); ylabel('Spike count (z)')
xlim([-4.5 3.5]); set(gca, 'XMinorTick','off'); ppretty([4.8,2.2]);

%% Stats - Single-trial modulation at cued condition switch
tmp_A2F = [nanmean(scA2F_All(:,[3,4]),2) , nanmean(scA2F_All(:,[5,6]),2)];
tmp_F2A = [nanmean(scF2A_All(:,[3,4]),2) , nanmean(scF2A_All(:,[5,6]),2)];
diffA2F =  diff(tmp_A2F, 1, 2);
diffF2A = -diff(tmp_F2A, 1, 2);
ttestTom( diffA2F , diffF2A )


end%fxn:plotSpkCount_X_Trial_ReStim_SAT()
