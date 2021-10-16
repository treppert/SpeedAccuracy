function [ ] = Fig2BF_plotSpkCt_ReStim_X_Trial( behavData , unitData , spikesSAT )
%Fig2BF_plotSpkCt_ReStim_X_Trial Summary of this function goes here
%   Detailed explanation goes here

MIN_MEDIAN_SPIKE_COUNT = 4;
INTERVAL = 'Baseline';
AREA = 'SEF';

TRIAL_TEST = (-4 : +3);
NUM_TRIAL_TEST = length(TRIAL_TEST);
trialSwitch = identify_condition_switch(behavData);

idxArea = ismember(unitData.aArea, {AREA});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});
idxVisUnit = (unitData.Basic_VisGrade >= 2);
idxMoveUnit = (unitData.Basic_MovGrade >= 2);

if strcmp(INTERVAL, 'Baseline')
  unitTest = (idxArea & idxMonkey & (idxVisUnit | idxMoveUnit) & unitData.Baseline_SAT_Effect);
  T_TEST = 3500 + [-600 20];
elseif strcmp(INTERVAL, 'visResponse')
  unitTest = (idxArea & idxMonkey & idxVisUnit & unitData.VisualResponse_SAT_Effect);
  T_TEST = 3500 + [50 200];
end

NUM_CELLS = sum(unitTest);
unitData = unitData(unitTest,:);
spikesSAT = spikesSAT(unitTest);

%initialize spike count
scA2F_All = NaN(NUM_CELLS,NUM_TRIAL_TEST);
scF2A_All = NaN(NUM_CELLS,NUM_TRIAL_TEST);
%initialize unit cuts
ccCut = [];

for uu = 1:NUM_CELLS
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  
  %compute spike count for all trials
  sc_CC = cellfun(@(x) sum((x > T_TEST(1)) & (x < T_TEST(2))), spikesSAT{uu});
  
  %compute median spike count
  medSC_CC = median(sc_CC);
  if (medSC_CC < MIN_MEDIAN_SPIKE_COUNT)
    fprintf('Skipping Unit %s-%s due to minimum spike count\n', unitData.Task_Session(uu), unitData.aID{uu})
    ccCut = cat(2, ccCut, cc);  continue
  end
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  
  %compute z-scored spike count
  sc_CC(idxCorr & ~idxIso) = zscore(sc_CC(idxCorr & ~idxIso));
  
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & idxCorr & ~idxIso);    trialAcc = find(idxAcc);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & idxCorr & ~idxIso);   trialFast = find(idxFast);
  
  %split by task condition
  scAccCC = sc_CC(idxAcc);
  scFastCC = sc_CC(idxFast);
  
  %index by trial number
  for jj = 1:NUM_TRIAL_TEST
    if (TRIAL_TEST(jj) < 0) %Before condition switch
      %get all trials at this index
      idxJJ_A2F = ismember(trialAcc, trialSwitch.A2F{kk} + TRIAL_TEST(jj));
      idxJJ_F2A = ismember(trialFast, trialSwitch.F2A{kk} + TRIAL_TEST(jj));
      %compute mean spike count for this trial
      scA2F_All(cc,jj) = mean(scAccCC(idxJJ_A2F));
      scF2A_All(cc,jj) = mean(scFastCC(idxJJ_F2A));
    else %After condition switch
      idxJJ_A2F = ismember(trialFast, trialSwitch.A2F{kk} + TRIAL_TEST(jj));
      idxJJ_F2A = ismember(trialAcc, trialSwitch.F2A{kk} + TRIAL_TEST(jj));
      scA2F_All(cc,jj) = mean(scFastCC(idxJJ_A2F));
      scF2A_All(cc,jj) = mean(scAccCC(idxJJ_F2A));
    end
  end % for : trial (jj)
  
end % for : cell (uu)

%cut units based on min spike count
NUM_CELLS = NUM_CELLS - length(ccCut);
scA2F_All(ccCut,:) = [];
scF2A_All(ccCut,:) = [];


%% Plotting
mu_A2F = mean(scA2F_All);    se_A2F = std(scA2F_All) / sqrt(NUM_CELLS);
mu_F2A = mean(scF2A_All);    se_F2A = std(scF2A_All) / sqrt(NUM_CELLS);

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
