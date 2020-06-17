function [ ] = Fig02B_plotBaselineSpkCt_X_Trial( behavInfo , unitInfo , unitStats , spikes )
%Fig02B_plotBaselineSpkCt_X_Trial Summary of this function goes here
%   Detailed explanation goes here

MIN_MEDIAN_SPIKE_COUNT = 0;

MONKEY = {'D','E'};
AREA_TEST = 'SEF';
T_TEST = 3500 + [-600 20];

TRIAL_TEST = (-4 : +3);
NUM_TRIAL_TEST = length(TRIAL_TEST);
trialSwitch = identify_condition_switch(behavInfo);

idxArea = ismember(unitInfo.area, {AREA_TEST});
idxMonkey = ismember(unitInfo.monkey, MONKEY);
idxVisUnit = (unitInfo.visGrade >= 2);
idxMoveUnit = (unitInfo.moveGrade >= 2);
idxSATEffect = (unitStats.Baseline_SAT_Effect == 1);

unitTest = (idxArea & idxMonkey & (idxVisUnit | idxMoveUnit) & idxSATEffect);
unitInfo = unitInfo(unitTest,:);
spikes = spikes(unitTest);
NUM_CELLS = sum(unitTest);

%initialize spike count
scA2F_All = NaN(NUM_CELLS,NUM_TRIAL_TEST);
scF2A_All = NaN(NUM_CELLS,NUM_TRIAL_TEST);
%initialize unit cuts
ccCut = [];

for cc = 1:NUM_CELLS
  kk = ismember(behavInfo.session, unitInfo.sess{cc});
  
  %compute spike count for all trials
  sc_CC = cellfun(@(x) sum((x > T_TEST(1)) & (x < T_TEST(2))), spikes{cc});
  
  %compute median spike count
  medSC_CC = median(sc_CC);
  if (medSC_CC < MIN_MEDIAN_SPIKE_COUNT)
    fprintf('Skipping Unit %s-%s due to minimum spike count\n', unitInfo.sess{cc}, unitInfo.unit{cc})
    ccCut = cat(2, ccCut, cc);  continue
  end
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitInfo.trRemSAT{cc}, behavInfo.num_trials(kk));
  %index by trial outcome
  idxCorr = ~(behavInfo.err_dir{kk} | behavInfo.err_time{kk} | behavInfo.err_hold{kk} | behavInfo.err_nosacc{kk});
  %index by condition
  idxAcc = ((behavInfo.condition{kk} == 1) & idxCorr & ~idxIso);    trialAcc = find(idxAcc);
  idxFast = ((behavInfo.condition{kk} == 3) & idxCorr & ~idxIso);   trialFast = find(idxFast);
  
  %split by task condition
  scAccCC = sc_CC(idxAcc);    nAcc = sum(idxAcc);
  scFastCC = sc_CC(idxFast);  nFast = sum(idxFast);
  
  %compute z-scored spike count
  sc_CC = zscore([scAccCC, scFastCC]);
  scAccCC = sc_CC(1:nAcc);
  scFastCC = sc_CC((nAcc+1):(nAcc+nFast));
  
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
  
end % for : cell (cc)

%cut units based on min spike count
NUM_CELLS = NUM_CELLS - length(ccCut);
unitInfo(ccCut,:) = [];
scA2F_All(ccCut,:) = [];
scF2A_All(ccCut,:) = [];


%% Plotting
mu_A2F = nanmean(scA2F_All);    se_A2F = nanstd(scA2F_All) / sqrt(NUM_CELLS);
mu_F2A = nanmean(scF2A_All);    se_F2A = nanstd(scF2A_All) / sqrt(NUM_CELLS);

figure()

subplot(1,2,1); hold on
plot([-3 2], [0 0], 'k:')
% plot(TRIAL_TEST, scA2F_All)
errorbar(TRIAL_TEST, mu_A2F, se_A2F, 'capsize',0, 'Color','k')
xticks(-3:2); xticklabels({}); ylabel('Spike count (z)'); 

subplot(1,2,2); hold on
plot([-3 2], [0 0], 'k:')
% plot(TRIAL_TEST, scF2A_All)
errorbar(TRIAL_TEST, mu_F2A, se_F2A, 'capsize',0, 'Color','k')
xticks(-3:2); xticklabels({}); yticks([])

ppretty([4.8,2.2], 'XMinorTick','off'); 


%% Stats - Single-trial modulation at cued condition switch
singleTrialMod_A2F =  diff(scA2F_All(:,[4,5]),1,2);
singleTrialMod_F2A = -diff(scF2A_All(:,[4,5]),1,2); %negative for comparison
ttestTom( singleTrialMod_A2F , singleTrialMod_F2A , 'paired' )
fprintf('A2F: %3.2f +- %3.2f\n', mean(singleTrialMod_A2F), std(singleTrialMod_A2F)/sqrt(NUM_CELLS))
fprintf('F2A: %3.2f +- %3.2f\n', mean(singleTrialMod_F2A), std(singleTrialMod_F2A)/sqrt(NUM_CELLS))

end % fxn : Fig02B_plotBaselineSpkCt_X_Trial()
