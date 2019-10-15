function [ ] = plotSpkCount_X_Trial_ReStim_SAT( behavInfo , unitInfo , spikes )
%plotSpkCount_X_Trial_ReStim_SAT Summary of this function goes here
%   Detailed explanation goes here

MIN_MEDIAN_SPIKE_COUNT = 2;

INTERVAL_TEST = 'Baseline';
% INTERVAL_TEST = 'visResponse';
AREA_TEST = 'SEF';

TRIAL_TEST = (-3 : +2);
NUM_TRIAL_TEST = length(TRIAL_TEST);
trialSwitch = identify_condition_switch(behavInfo);

idxArea = ismember(unitInfo.area, {AREA_TEST});
idxMonkey = ismember(unitInfo.monkey, {'D','E','Q','S'});
idxVisUnit = (unitInfo.visGrade >= 2);
idxMoveUnit = (unitInfo.moveGrade >= 2);

if strcmp(INTERVAL_TEST, 'Baseline')
  unitTest = (idxArea & idxMonkey & (idxVisUnit | idxMoveUnit));
  T_TEST = 3500 + [-600 20];
elseif strcmp(INTERVAL_TEST, 'visResponse')
  unitTest = (idxArea & idxMonkey & idxVisUnit);
  T_TEST = 3500 + [50 200];
end

NUM_CELLS = sum(unitTest);
unitInfo = unitInfo(unitTest,:);
spikes = spikes(unitTest);

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
  
  %compute z-scored spike count
  sc_CC = zscore(sc_CC);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitInfo.trRemSAT{cc}, behavInfo.num_trials(kk));
  %index by trial outcome
  idxCorr = ~(behavInfo.err_time{kk} | behavInfo.err_hold{kk} | behavInfo.err_nosacc{kk});
  %index by condition
  idxAcc = ((behavInfo.condition{kk} == 1) & idxCorr & ~idxIso);    trialAcc = find(idxAcc);
  idxFast = ((behavInfo.condition{kk} == 3) & idxCorr & ~idxIso);   trialFast = find(idxFast);
  
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
  
end % for : cell (cc)

%cut units based on min spike count
NUM_CELLS = NUM_CELLS - length(ccCut);
unitInfo(ccCut,:) = [];
scA2F_All(ccCut,:) = [];
scF2A_All(ccCut,:) = [];

% %split by search efficiency
% cc_More = (unitInfo.taskType == 1);   NUM_MORE = sum(cc_More);
% cc_Less = (unitInfo.taskType == 2);   NUM_LESS = sum(cc_Less);
% scA2F_More = scA2F_All(cc_More,:);    scA2F_Less = scA2F_All(cc_Less,:);
% scF2A_More = scF2A_All(cc_More,:);    scF2A_Less = scF2A_All(cc_Less,:);


%% Plotting
mu_A2F = mean(scA2F_All);    se_A2F = std(scA2F_All) / sqrt(NUM_CELLS);
mu_F2A = mean(scF2A_All);    se_F2A = std(scF2A_All) / sqrt(NUM_CELLS);

figure()

subplot(1,2,1); hold on
plot([-3 2], [0 0], 'k:')
errorbar(TRIAL_TEST, mu_A2F, se_A2F, 'capsize',0, 'Color','k')
xticks(-3:2); xticklabels({}); ylabel('Spike count (z)')
ppretty([4.8,2.2]); set(gca, 'XMinorTick','off')


%% Stats - Single-trial modulation at cued condition switch
tmp_A2F = [nanmean(scA2F_All(:,[3,4]),2) , nanmean(scA2F_All(:,[5,6]),2)];
tmp_F2A = [nanmean(scF2A_All(:,[3,4]),2) , nanmean(scF2A_All(:,[5,6]),2)];
diffA2F = diff(tmp_A2F, 1, 2);
diffF2A = diff(tmp_F2A, 1, 2);
ttestTom( diffA2F , diffF2A )


end%fxn:plotSpkCount_X_Trial_ReStim_SAT()
