function [ ] = plot_Distr_VRLatency_SAT( unitData , unitData )
%plot_Distr_VRLatency_SAT Summary of this function goes here
%   Detailed explanation goes here

AREA_TEST = 'SC';

idxArea = ismember(unitData.aArea, {AREA_TEST});
idxMonkey = ismember(unitData.aMonkey, {'D','E','Q','S'});
idxVisUnit = (unitData.Basic_VisGrade >= 2);
idxKeep = (idxArea & idxMonkey & idxVisUnit);
% idxKeep = (idxArea & idxMonkey & idxVisUnit & (unitData.Task_LevelDifficulty == 2));

unitData = unitData(idxKeep,:);
unitData = unitData(idxKeep,:);

%report median visual response latency
fprintf([AREA_TEST, ': median VR latency = %d ms\n'], median(unitData.VisualResponse_Latency))

%split analysis on search efficiency
ccMore = (unitData.Task_LevelDifficulty == 1);
ccLess = (unitData.Task_LevelDifficulty == 2);

Latency_More = unitData.VisualResponse_Latency(ccMore);  numMore = length(Latency_More);
Latency_Less = unitData.VisualResponse_Latency(ccLess);  numLess = length(Latency_Less);


%% Plotting
y_More = mean(Latency_More);    se_More = std(Latency_More) / sqrt(numMore);
y_Less = mean(Latency_Less);    se_Less = std(Latency_Less) / sqrt(numLess);

figure(); hold on
bar([1 2], [y_More y_Less], 'FaceColor',[.5 .5 .5], 'LineStyle','none', 'BarWidth',0.5)
errorbar([1 2], [y_More y_Less], [se_More se_Less], 'k-', 'CapSize',0, 'LineWidth',0.75)
ppretty([2,3]); xticks([])


%% Stats - Unpaired t-test
ttestTom(Latency_More, Latency_Less, 'unpaired')

end%fxn:plot_Distr_VRLatency_SAT()
