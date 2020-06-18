function [ ] = analyzeSpkCt_X_Condition_X_Difficulty( behavInfo , unitInfo , spikes )
%analyzeSpkCt_X_Condition_X_Difficulty Summary of this function goes here
%   Detailed explanation goes here

AREA = {'FEF'};
MONKEY = {'D','E'};
INTERVAL = 'pre'; %either 'pre' = baseline or 'post' = visual response

idxArea = ismember(unitInfo.area, AREA);
idxMonkey = ismember(unitInfo.monkey, MONKEY);
idxVisUnit = (unitInfo.visGrade >= 2);
idxMoveUnit = (unitInfo.moveGrade >= 2);

if strcmp(INTERVAL, 'pre')
  unitTest = (idxArea & idxMonkey & (idxVisUnit | idxMoveUnit));
  T_TEST = 3500 + [-500 +20]; %interval over which to count spikes
elseif strcmp(INTERVAL, 'post')
  unitTest = (idxArea & idxMonkey & idxVisUnit);
  if strcmp(AREA, 'SEF') %testing interval based on VR Latency **
    T_TEST = 3500 + [73 223];
  elseif strcmp(AREA, 'FEF')
    T_TEST = 3500 + [60 210];
  elseif strcmp(AREA, 'SC')
    T_TEST = 3500 + [43 193];
  end
end

NUM_CELLS = sum(unitTest);
unitInfo = unitInfo(unitTest,:);
spikes = spikes(unitTest);

%initialize spike count
spkCt_Acc = NaN(1,NUM_CELLS);
spkCt_Fast = NaN(1,NUM_CELLS);

for cc = 1:NUM_CELLS
  kk = ismember(behavInfo.session, unitInfo.sess{cc});
  
  %compute spike count for all trials
  sc_CC = cellfun(@(x) sum((x > T_TEST(1)) & (x < T_TEST(2))), spikes{cc});
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitInfo.trRemSAT{cc}, behavInfo.num_trials(kk));
  %index by trial outcome
  idxCorr = ~(behavInfo.err_dir{kk} | behavInfo.err_time{kk} | behavInfo.err_hold{kk} | behavInfo.err_nosacc{kk});
  %index by condition
  idxAcc = ((behavInfo.condition{kk} == 1) & idxCorr & ~idxIso);
  idxFast = ((behavInfo.condition{kk} == 3) & idxCorr & ~idxIso);
  
  %split by task condition
  scAccCC = sc_CC(idxAcc);    nAcc = sum(idxAcc);
  scFastCC = sc_CC(idxFast);  nFast = sum(idxFast);
  
  %compute z-scored spike count
  sc_CC = zscore([scAccCC, scFastCC]);
  scAccCC = sc_CC(1:nAcc);
  scFastCC = sc_CC((nAcc+1):(nAcc+nFast));
  
  %save mean spike counts
  spkCt_Acc(cc) = mean(scAccCC);
  spkCt_Fast(cc) = mean(scFastCC);
  
end % for : cell(cc)

%split by search difficulty
cc_More = (unitInfo.taskType == 2);   NUM_MORE = sum(cc_More);
cc_Less = (unitInfo.taskType == 1);   NUM_LESS = sum(cc_Less);

sc_AccMore = spkCt_Acc(cc_More);    sc_AccLess = spkCt_Acc(cc_Less);
sc_FastMore = spkCt_Fast(cc_More);  sc_FastLess = spkCt_Fast(cc_Less);

figure(); hold on
cdfplotTR(sc_AccMore, 'Color','r', 'LineWidth',1.75)
cdfplotTR(sc_FastMore, 'Color',[0 .7 0], 'LineWidth',1.75)
cdfplotTR(sc_AccLess, 'Color','r', 'LineWidth',0.75)
cdfplotTR(sc_FastLess, 'Color',[0 .7 0], 'LineWidth',0.75)
ppretty([6.4,4])

%% Stats - Two-way ANOVA
%write data out for ANOVA in R
rootDir = 'C:\Users\Thomas Reppert\Dropbox\__SEF_SAT_\Stats\';
DV_param = [sc_AccMore sc_AccLess sc_FastMore sc_FastLess]';
F_Difficulty = [ones(1,NUM_MORE) 2*ones(1,NUM_LESS) ones(1,NUM_MORE) 2*ones(1,NUM_LESS)]';
F_Condition = [ones(1,NUM_CELLS) 2*ones(1,NUM_CELLS)]';
F_Neuron = [(1:NUM_CELLS) (1:NUM_CELLS)]';
if strcmp(INTERVAL, 'pre')
  save([rootDir, AREA{1}, '-SpikeCount-Baseline.mat'], 'DV_param','F_Condition','F_Difficulty','F_Neuron')
elseif strcmp(INTERVAL, 'post')
  save([rootDir, AREA{1}, '-SpikeCount-VisResponse.mat'], 'DV_param','F_Condition','F_Difficulty','F_Neuron')
end

%% Plotting -- Show SAT effect separately for more and less efficient search
dSAT_More = sc_FastMore - sc_AccMore;   se_More = std(dSAT_More) / sqrt(NUM_MORE);
dSAT_Less = sc_FastLess - sc_AccLess;   se_Less = std(dSAT_Less) / sqrt(NUM_LESS);

figure(); hold on
errorbar([mean(dSAT_More) mean(dSAT_Less)], [se_More se_Less], 'capsize',0, 'Color','k')
xlim([0.6 2.4]); xticks([]); ytickformat('%3.2f')
ylabel('Sp. ct. diff. (Fast - Accurate) (z)')
ppretty([1.5,3])

end% fxn : analyzeSpkCt_X_Condition_X_Difficulty()

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

