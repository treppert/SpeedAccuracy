function [ ] = plot_Distr_TST_SAT( unitInfo , unitStats )
%plot_Distr_TST_SAT Summary of this function goes here
%   Detailed explanation goes here

ANALYZE_PAIRED_ONLY = true;
AREA_TEST = 'SC';

idxArea = ismember(unitInfo.area, {AREA_TEST});
idxMonkey = ismember(unitInfo.monkey, {'D','E','Q','S'});
idxVisUnit = (unitInfo.visGrade >= 2);
idxKeep = (idxArea & idxMonkey & idxVisUnit);
% idxKeep = (idxArea & idxMonkey & idxVisUnit & (unitInfo.taskType == 2));

idxTST_All = ~(isnan(unitStats.VRTSTAcc) | isnan(unitStats.VRTSTFast));
idxTST_AccOnly = ~isnan(unitStats.VRTSTAcc) & isnan(unitStats.VRTSTFast);
idxTST_FastOnly = isnan(unitStats.VRTSTAcc) & ~isnan(unitStats.VRTSTFast);
idxNoTST = (isnan(unitStats.VRTSTAcc) & isnan(unitStats.VRTSTFast));

%compute neuron counts for barplot of TST diversity
nNeuron_None = sum(idxKeep & idxNoTST);       nNeuron_Both = sum(idxKeep & idxTST_All);
nNeuron_Acc = sum(idxKeep & idxTST_AccOnly);  nNeuron_Fast = sum(idxKeep & idxTST_FastOnly);

if (ANALYZE_PAIRED_ONLY) %group data from neurons with TST in both task conditions
  idxKeep = (idxKeep & idxTST_All);
else %group data from neurons with TST in either task condition
  idxKeep = (idxKeep & (idxTST_All | idxTST_AccOnly | idxTST_FastOnly));
end
unitInfo = unitInfo(idxKeep,:);
unitStats = unitStats(idxKeep,:);

%split analysis on search efficiency
ccMore = (unitInfo.taskType == 1);
ccLess = (unitInfo.taskType == 2);

TST_Acc_More = unitStats.VRTSTAcc(ccMore);    TST_Acc_More(isnan(TST_Acc_More)) = [];
TST_Acc_Less = unitStats.VRTSTAcc(ccLess);    TST_Acc_Less(isnan(TST_Acc_Less)) = [];
TST_Fast_More = unitStats.VRTSTFast(ccMore);  TST_Fast_More(isnan(TST_Fast_More)) = [];
TST_Fast_Less = unitStats.VRTSTFast(ccLess);  TST_Fast_Less(isnan(TST_Fast_Less)) = [];
nAM = length(TST_Acc_More);     nAL = length(TST_Acc_Less);
nFM = length(TST_Fast_More);    nFL = length(TST_Fast_Less);


%% Plotting
y_AM = mean(TST_Acc_More);    se_AM = std(TST_Acc_More)/sqrt(nAM);
y_AL = mean(TST_Acc_Less);    se_AL = std(TST_Acc_Less)/sqrt(nAL);
y_FM = mean(TST_Fast_More);   se_FM = std(TST_Fast_More)/sqrt(nFM);
y_FL = mean(TST_Fast_Less);   se_FL = std(TST_Fast_Less)/sqrt(nFL);

figure(); hold on
errorbar([1 2]-.01, [y_FM y_AM], [se_FM se_AM], 'k-', 'CapSize',0, 'LineWidth',0.75)
errorbar([1 2]+.01, [y_FL y_AL], [se_FL se_AL], 'k-', 'CapSize',0, 'LineWidth',1.75)
ppretty([2,3]); xticks([])


%% Stats - Two-way split-plot ANOVA
if (ANALYZE_PAIRED_ONLY)
  TST_All = struct('AccMore',TST_Acc_More', 'AccLess',TST_Acc_Less', 'FastMore',TST_Fast_More', 'FastLess',TST_Fast_Less');
  writeData_SplitPlotANOVA_SAT(TST_All, [AREA_TEST, '-TST.mat'], 'compareBetweenANOVA')
end


%% Report the number of visual neurons of each sub-type
% idxRF_WholeScreen = false(1,length(unitStats));
% for cc = 1:length(unitInfo)
%   if ismember(unitInfo(cc).visField, 9); idxRF_WholeScreen(cc) = true; end
% end
% 
% fprintf('Number of visually-responsive neurons :: %d\n', sum(idxKeep))
% fprintf('Number of neurons that discriminated tgt in Fast AND Accurate :: %d\n', sum(idxKeep & idxTST_All))
% fprintf('Number of neurons that discriminated tgt in Accurate ONLY :: %d\n', sum(idxKeep & idxTST_AccOnly))
% fprintf('Number of neurons that discriminated tgt in Fast ONLY :: %d\n', sum(idxKeep & idxTST_FastOnly))
% fprintf('Number of neurons that did not discriminate the tgt :: %d\n', sum(idxKeep & idxNoTST))
% fprintf('Number of neurons with RF that spanned the viewing screen :: %d\n', sum(idxKeep & idxRF_WholeScreen))


%% Plotting - Barplot - Neuron TST diversity
%barplot showing diversity of visually-responsive neurons (vis-a-vis TST)
figure(); hold on
hBar = bar([nNeuron_None nNeuron_Acc nNeuron_Fast nNeuron_Both ; 0 0 0 0], 'stacked');
hBar(1).FaceColor = [.7 .7 .7];
hBar(2).FaceColor = 'r';
hBar(3).FaceColor = [0 .7 0];
hBar(4).FaceColor = 'y';
ppretty([1.5,3]); xticks([]); set(gca, 'YMinorTick','off')


end%fxn:plot_Distr_TST_SAT()


%% Plotting
% figure(); hold on
% cdfplotTR(TST_Fast_More, 'Color',[0 .7 0])
% cdfplotTR(TST_Fast_Less, 'Color',[0 .7 0], 'LineWidth',1.75)
% cdfplotTR(TST_Acc_More, 'Color','r')
% cdfplotTR(TST_Acc_Less, 'Color','r', 'LineWidth',1.75)
% ppretty([3.6,2]); ytickformat('%2.1f')

%% Stats
% %Unpaired t-test -- SAT effect at each level of efficiency
% %Note - this *should* be post-hoc test after two-way ANOVA
% [~,pval_More] = ttest2(TST_Acc_More, TST_Fast_More);
% [~,pval_Less] = ttest2(TST_Acc_Less, TST_Fast_Less);
% fprintf('SAT effect :: More efficient :: pval (unpaired) :: %g\n', pval_More)
% fprintf('SAT effect :: Less efficient :: pval (unpaired) :: %g\n', pval_Less)

% %Two-way between-subjects ANOVA -- main effects of SAT/efficiency
% tmp = [TST_Acc_More' TST_Acc_Less' TST_Fast_More' TST_Fast_Less']';
% Condition = [ones(1,nAM+nAL) 2*ones(1,nFM+nFL)]';
% Efficiency = [ones(1,nAM) 2*ones(1,nAL) ones(1,nFM) 2*ones(1,nFL)]';
% anovan(tmp, {Condition Efficiency}, 'model','interaction', 'varnames',{'Condition','Efficiency'});
