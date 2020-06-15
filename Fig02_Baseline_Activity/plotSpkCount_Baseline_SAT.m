function [ ] = plotSpkCount_Baseline_SAT( behavInfo , unitInfo , spikes )
%plotSpkCount_Baseline_SAT Summary of this function goes here
%   Detailed explanation goes here

AREA = {'SEF'};
MONKEY = {'D','E'};

idxArea = ismember(unitInfo.area, AREA);
idxMonkey = ismember(unitInfo.monkey, MONKEY);
idxVisUnit = (unitInfo.visGrade >= 2);
idxMoveUnit = (unitInfo.moveGrade >= 2);
unitTest = (idxArea & idxMonkey & (idxVisUnit | idxMoveUnit));

NUM_CELLS = sum(unitTest);
unitInfo = unitInfo(unitTest,:);
spikes = spikes(unitTest);

T_TEST = 3500 + [-300 20]; %interval over which to count spikes

%initialize spike count
spkCt_Acc = NaN(1,NUM_CELLS);
spkCt_Fast = NaN(1,NUM_CELLS);

for cc = 1:NUM_CELLS
  kk = ismember(behavInfo.session, unitInfo.sess{cc});
  
  %compute spike count for all trials
  sc_CC = cellfun(@(x) sum((x > T_TEST(1)) & (x < T_TEST(2))), spikes{cc});
  
  %compute z-scored spike count
%   idxNaN = estimate_spread(sc_CC, 3.5);   sc_CC(idxNaN) = NaN;
  sc_CC = zscore(sc_CC);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitInfo.trRemSAT{cc}, behavInfo.num_trials(kk));
  %index by trial outcome
  idxCorr = ~(behavInfo.err_dir{kk} | behavInfo.err_time{kk} | behavInfo.err_hold{kk} | behavInfo.err_nosacc{kk});
  %index by condition
  idxAcc = ((behavInfo.condition{kk} == 1) & idxCorr & ~idxIso);
  idxFast = ((behavInfo.condition{kk} == 3) & idxCorr & ~idxIso);
  
  %split by task condition
  scAccCC = sc_CC(idxAcc);
  scFastCC = sc_CC(idxFast);
  
  %save mean spike counts
  spkCt_Acc(cc) = mean(scAccCC);
  spkCt_Fast(cc) = mean(scFastCC);
  
end%for:cells(cc)

%split by search difficulty
cc_More = (unitInfo.taskType == 2);   NUM_MORE = sum(cc_More);
cc_Less = (unitInfo.taskType == 1);   NUM_LESS = sum(cc_Less);

sc_AccMore = spkCt_Acc(cc_More);    sc_AccLess = spkCt_Acc(cc_Less);
sc_FastMore = spkCt_Fast(cc_More);  sc_FastLess = spkCt_Fast(cc_Less);

figure(); hold on
h_AM = cdfplot(sc_AccMore); h_AM.Color = 'r'; h_AM.LineWidth = 1.75;
h_FM = cdfplot(sc_FastMore); h_FM.Color = [0 .7 0]; h_FM.LineWidth = 1.75;
h_AL = cdfplot(sc_AccLess); h_AL.Color = 'r'; h_AL.LineWidth = 0.75;
h_FL = cdfplot(sc_FastLess); h_FL.Color = [0 .7 0]; h_FL.LineWidth = 0.75;
ppretty([6.4,4])

%% Stats - Two-way ANOVA
%write data out for ANOVA in R
rootDir = 'C:\Users\Thomas Reppert\Dropbox\__SEF_SAT_\Stats\';
DV_param = [sc_AccMore sc_AccLess sc_FastMore sc_FastLess]';
F_Difficulty = [ones(1,NUM_MORE) 2*ones(1,NUM_LESS) ones(1,NUM_MORE) 2*ones(1,NUM_LESS)]';
F_Condition = [ones(1,NUM_CELLS) 2*ones(1,NUM_CELLS)]';
F_Neuron = [(1:NUM_CELLS) (1:NUM_CELLS)]';
save([rootDir, AREA{1}, '-SpikeCount-Baseline.mat'], 'DV_param','F_Condition','F_Difficulty','F_Neuron')
return
% spikeCount = struct('AccMore',sc_AccMore, 'AccLess',sc_AccLess, 'FastMore',sc_FastMore, 'FastLess',sc_FastLess);
% writeData_SplitPlotANOVA_SAT(spikeCount, [AREA{1}, '-SpikeCount-', INTERVAL_TEST, '.mat'], 'compareBetweenANOVA')

%% Plotting -- Show SAT effect separately for more and less efficient search
dSAT_More = sc_FastMore - sc_AccMore;   se_More = std(dSAT_More) / sqrt(NUM_MORE);
dSAT_Less = sc_FastLess - sc_AccLess;   se_Less = std(dSAT_Less) / sqrt(NUM_LESS);

figure(); hold on
errorbar([mean(dSAT_More) mean(dSAT_Less)], [se_More se_Less], 'capsize',0, 'Color','k')
xlim([0.6 2.4]); xticks([]); ytickformat('%3.2f')
ylabel('Sp. ct. diff. (Fast - Accurate) (z)')
ppretty([1.5,3])

end% fxn : plotSpkCount_Baseline_SAT()

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

