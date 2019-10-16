function [ ] = plot_Distr_VRLatency_SAT( unitInfo , unitStats )
%plot_Distr_VRLatency_SAT Summary of this function goes here
%   Detailed explanation goes here

AREA_TEST = 'SC';

idxArea = ismember(unitInfo.area, {AREA_TEST});
idxMonkey = ismember(unitInfo.monkey, {'D','E','Q','S'});
idxVisUnit = (unitInfo.visGrade >= 2);
idxKeep = (idxArea & idxMonkey & idxVisUnit);
% idxKeep = (idxArea & idxMonkey & idxVisUnit & (unitInfo.taskType == 2));

unitInfo = unitInfo(idxKeep,:);
unitStats = unitStats(idxKeep,:);

%report median visual response latency
fprintf([AREA_TEST, ': median VR latency = %d ms\n'], median(unitStats.VR_Latency))

%split analysis on search efficiency
ccMore = (unitInfo.taskType == 1);
ccLess = (unitInfo.taskType == 2);

Latency_More = unitStats.VR_Latency(ccMore);  numMore = length(Latency_More);
Latency_Less = unitStats.VR_Latency(ccLess);  numLess = length(Latency_Less);


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
