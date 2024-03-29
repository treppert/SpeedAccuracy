function [ ] = plot_SpkCt( behavData , unitData , spikes )
%plot_SpkCt Summary of this function goes here
%   Detailed explanation goes here

MIN_MEDIAN_SPIKE_COUNT = 2;

% INTERVAL_TEST = 'Baseline';
INTERVAL_TEST = 'visResponse';
AREA_TEST = 'SC';

idxArea = ismember(unitData.aArea, {AREA_TEST});
idxMonkey = ismember(unitData.aMonkey, {'D','E','Q','S'});
idxVisUnit = (unitData.Basic_VisGrade >= 2);
idxMoveUnit = (unitData.Basic_MovGrade >= 2);

if strcmp(INTERVAL_TEST, 'Baseline')
  unitTest = (idxArea & idxMonkey & (idxVisUnit | idxMoveUnit));
  T_TEST = 3500 + [-600 20];
elseif strcmp(INTERVAL_TEST, 'visResponse')
  unitTest = (idxArea & idxMonkey & idxVisUnit);
  if strcmp(AREA_TEST, 'SEF') %testing interval based on VR Latency **
    T_TEST = 3500 + [73 223];
  elseif strcmp(AREA_TEST, 'FEF')
    T_TEST = 3500 + [60 210];
  elseif strcmp(AREA_TEST, 'SC')
    T_TEST = 3500 + [43 193];
  end
end

NUM_CELLS = sum(unitTest);
unitData = unitData(unitTest,:);
spikes = spikes(unitTest);

%initialize spike count
scAcc_All = NaN(1,NUM_CELLS);
scFast_All = NaN(1,NUM_CELLS);
%initialize unit cuts
ccCut = [];

for uu = 1:NUM_CELLS
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  
  %compute spike count for all trials
  sc_CC = cellfun(@(x) sum((x > T_TEST(1)) & (x < T_TEST(2))), spikes{uu});
  
  %compute median spike count
  medSC_CC = median(sc_CC);
  if (medSC_CC < MIN_MEDIAN_SPIKE_COUNT)
    fprintf('Skipping Unit %s-%s due to minimum spike count\n', unitData.Task_Session(uu), unitData.unit{uu})
    ccCut = cat(2, ccCut, cc);  continue
  end
  
  %compute z-scored spike count
%   idxNaN = estimate_spread(sc_CC, 3.5);   sc_CC(idxNaN) = NaN;
  sc_CC = zscore(sc_CC);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & idxCorr & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & idxCorr & ~idxIso);
  
  %split by task condition
  scAccCC = sc_CC(idxAcc);
  scFastCC = sc_CC(idxFast);
  
  %save mean spike counts
  scAcc_All(uu) = mean(scAccCC);
  scFast_All(uu) = mean(scFastCC);
  
end%for:cells(uu)

%cut units based on min spike count
unitData(ccCut,:) = [];
scAcc_All(ccCut) = [];
scFast_All(ccCut) = [];

%split by search efficiency
cc_More = (unitData.Task_LevelDifficulty == 1);   NUM_MORE = sum(cc_More);
cc_Less = (unitData.Task_LevelDifficulty == 2);   NUM_LESS = sum(cc_Less);

sc_AccMore = scAcc_All(cc_More);    sc_AccLess = scAcc_All(cc_Less);
sc_FastMore = scFast_All(cc_More);  sc_FastLess = scFast_All(cc_Less);

%% Stats - Two-way split-plot ANOVA
spikeCount = struct('AccMore',sc_AccMore, 'AccLess',sc_AccLess, 'FastMore',sc_FastMore, 'FastLess',sc_FastLess);
writeData_SplitPlotANOVA_SAT(spikeCount, [AREA_TEST, '-SpikeCount-', INTERVAL_TEST, '.mat'])

%% Plotting -- Show SAT effect separately for more and less efficient search
dSAT_More = sc_FastMore - sc_AccMore;   se_More = std(dSAT_More) / sqrt(NUM_MORE);
dSAT_Less = sc_FastLess - sc_AccLess;   se_Less = std(dSAT_Less) / sqrt(NUM_LESS);

figure(); hold on
errorbar([mean(dSAT_More) mean(dSAT_Less)], [se_More se_Less], 'capsize',0, 'Color','k')
xlim([0.6 2.4]); xticks([]); ytickformat('%3.2f')
ylabel('Sp. ct. diff. (Fast - Accurate) (z)')
ppretty([1.5,3])

end%fxn:plot_SpkCt()

% %plotting - show each level of Condition*Efficiency separately
% mu_AccMore = mean(sc_AccMore);       se_AccMore = std(sc_AccMore) / sqrt(NUM_MORE);
% mu_AccLess = mean(sc_AccLess);       se_AccLess = std(sc_AccLess) / sqrt(NUM_LESS);
% mu_FastMore = mean(sc_FastMore);     se_FastMore = std(sc_FastMore) / sqrt(NUM_MORE);
% mu_FastLess = mean(sc_FastLess);     se_FastLess = std(sc_FastLess) / sqrt(NUM_LESS);
% 
% figure(); hold on
% bar((1:4), [mu_AccMore mu_FastMore mu_AccLess mu_FastLess], 0.6, 'FaceColor',[.4 .4 .4], 'LineWidth',0.25)
% errorbar((1:4), [mu_AccMore mu_FastMore mu_AccLess mu_FastLess], [se_AccMore se_FastMore se_AccLess se_FastLess], 'Color','k', 'CapSize',0)
% ppretty([1.5,3])

