function [ ] = Fig03F_analyzeTST_X_Cond_X_Diff( unitInfo , unitStats )
%Fig03F_analyzeTST_X_Cond_X_Diff Summary of this function goes here
%   Detailed explanation goes here

AREA_TEST = 'FEF';
MONKEY_TEST = {'D','E','Q','S'};

TST_Acc = unitStats.TargetSelectionTime(:,1);
TST_Fast = unitStats.TargetSelectionTime(:,2);

idxArea = ismember(unitInfo.area, {AREA_TEST});
idxMonkey = ismember(unitInfo.monkey, MONKEY_TEST);
idxVisUnit = (unitInfo.visGrade >= 2);
idxKeep = (idxArea & idxMonkey & idxVisUnit);

idxTST_All = ~(isnan(TST_Acc) | isnan(TST_Fast));
idxTST_AccOnly = ~isnan(TST_Acc) & isnan(TST_Fast);
idxTST_FastOnly = isnan(TST_Acc) & ~isnan(TST_Fast);
idxNoTST = (isnan(TST_Acc) & isnan(TST_Fast));

%plot number of neurons that signal TST in each condition
nNeuron_None = sum(idxKeep & idxNoTST);       nNeuron_Both = sum(idxKeep & idxTST_All);
nNeuron_Acc = sum(idxKeep & idxTST_AccOnly);  nNeuron_Fast = sum(idxKeep & idxTST_FastOnly);
plot_TST_Diversity(nNeuron_None, nNeuron_Acc, nNeuron_Fast, nNeuron_Both)

idxKeep = (idxKeep & idxTST_All); %only neurons with TST in both conditions

unitInfo = unitInfo(idxKeep,:);
TST_Acc = TST_Acc(idxKeep);
TST_Fast = TST_Fast(idxKeep);
NUM_CELLS = sum(idxKeep);

%% Split data on factor search difficulty
ccLessDiff = (unitInfo.taskType == 1);  NUM_LESS = sum(ccLessDiff);
ccMoreDiff = (unitInfo.taskType == 2);  NUM_MORE = sum(ccMoreDiff);

TST_AccLess = TST_Acc(ccLessDiff);    TST_AccLess(isnan(TST_AccLess)) = [];
TST_AccMore = TST_Acc(ccMoreDiff);    TST_AccMore(isnan(TST_AccMore)) = [];
TST_FastLess = TST_Fast(ccLessDiff);  TST_FastLess(isnan(TST_FastLess)) = [];
TST_FastMore = TST_Fast(ccMoreDiff);  TST_FastMore(isnan(TST_FastMore)) = [];
nAM = length(TST_AccLess);     nAL = length(TST_AccMore);
nFM = length(TST_FastLess);    nFL = length(TST_FastMore);


%% Plotting
y_AM = mean(TST_AccLess);    se_AM = std(TST_AccLess)/sqrt(nAM);
y_AL = mean(TST_AccMore);    se_AL = std(TST_AccMore)/sqrt(nAL);
y_FM = mean(TST_FastLess);   se_FM = std(TST_FastLess)/sqrt(nFM);
y_FL = mean(TST_FastMore);   se_FL = std(TST_FastMore)/sqrt(nFL);

figure(); hold on
errorbar([1 2]-.01, [y_FM y_AM], [se_FM se_AM], 'k-', 'CapSize',0, 'LineWidth',0.75)
errorbar([1 2]+.01, [y_FL y_AL], [se_FL se_AL], 'k-', 'CapSize',0, 'LineWidth',1.75)
ppretty([2,3]); xticks([]); xlim([.9 2.1])


%% Stats - Two-way ANOVA
rootDir = 'C:\Users\Thomas Reppert\Dropbox\__SEF_SAT_\Stats\';
DV_param = [TST_AccMore; TST_AccLess; TST_FastMore; TST_FastLess];
F_Difficulty = [ones(1,NUM_MORE) 2*ones(1,NUM_LESS) ones(1,NUM_MORE) 2*ones(1,NUM_LESS)]';
F_Condition = [ones(1,NUM_CELLS) 2*ones(1,NUM_CELLS)]';
% F_Neuron = [(1:NUM_CELLS) (1:NUM_CELLS)]';
save([rootDir, AREA_TEST, '-TST.mat'], 'DV_param','F_Condition','F_Difficulty')

end % fxn : Fig03F_analyzeTST_X_Cond_X_Diff()


%% Plotting - Barplot - Neuron TST diversity
%barplot showing diversity of visually-responsive neurons (vis-a-vis TST)
function [] = plot_TST_Diversity( nNone, nAcc, nFast, nBoth )

figure(); hold on
hBar = bar([nNone nAcc nFast nBoth ; 0 0 0 0], 'stacked');
hBar(1).FaceColor = [.7 .7 .7];
hBar(2).FaceColor = 'r';
hBar(3).FaceColor = [0 .7 0];
hBar(4).FaceColor = 'y';
ppretty([1.5,3]); xticks([]); set(gca, 'YMinorTick','off')

end % util : plot_TST_Diversity()

%% Plotting
% figure(); hold on
% cdfplotTR(TST_Fast_More, 'Color',[0 .7 0])
% cdfplotTR(TST_Fast_Less, 'Color',[0 .7 0], 'LineWidth',1.75)
% cdfplotTR(TST_Acc_More, 'Color','r')
% cdfplotTR(TST_Acc_Less, 'Color','r', 'LineWidth',1.75)
% ppretty([3.6,2]); ytickformat('%2.1f')
