function [ ] = Fig2HJ_Plot_Distr_TST_Simple( unitData , varargin )
%Fig2HJ_Plot_Distr_TST_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}, {'area=',{'SEF'}}});

ANALYZE_PAIRED_ONLY = true; %neurons with TST in both task conditions

idxArea = ismember(unitData.Area, args.area);
idxMonkey = ismember(unitData.Monkey, args.monkey);
idxVisUnit = (abs(unitData.Grade_Vis) >= 3);
idxKeep = (idxArea & idxMonkey & idxVisUnit);

idxTST_All = ~(isnan(unitData.VisResp_TST(:,1)) | isnan(unitData.VisResp_TST(:,2)));
idxTST_AccOnly = ~isnan(unitData.VisResp_TST(:,1)) & isnan(unitData.VisResp_TST(:,2));
idxTST_FastOnly = isnan(unitData.VisResp_TST(:,1)) & ~isnan(unitData.VisResp_TST(:,2));
idxNoTST = (isnan(unitData.VisResp_TST(:,1)) & isnan(unitData.VisResp_TST(:,2)));

if (ANALYZE_PAIRED_ONLY)
  idxKeep = (idxKeep & idxTST_All);
else %group data from neurons with TST in either task condition
  idxKeep = (idxKeep & (idxTST_All | idxTST_AccOnly | idxTST_FastOnly));
end

TST_Acc = unitData.VisResp_TST(idxKeep,1);
TST_Fast = unitData.VisResp_TST(idxKeep,2);
N_Acc = length(TST_Acc);
N_Fast = length(TST_Fast);


%% Plotting
y_AL = mean(TST_Acc);    se_AL = std(TST_Acc)/sqrt(N_Acc);
y_FL = mean(TST_Fast);   se_FL = std(TST_Fast)/sqrt(N_Fast);

figure(); hold on
errorbar([1 2]-.01, [y_FL y_AL], [se_FL se_AL], 'k-', 'CapSize',0, 'LineWidth',0.75)
ppretty([2,3]); xticks([])


%% Stats - Effect of SAT on target discrimination
ttestFull(TST_Acc, TST_Fast)

%% Report the number of visual neurons of each sub-type
idxRF_WholeScreen = false(size(unitData,1),1);
for uu = 1:size(unitData,1)
  if (length(unitData.RF{uu}) == 8); idxRF_WholeScreen(uu) = true; end
end

fprintf('Number of visually-responsive neurons :: %d\n', sum(idxKeep))
fprintf('Number of neurons that discriminated tgt in Fast AND Accurate :: %d\n', sum(idxKeep & idxTST_All))
fprintf('Number of neurons that discriminated tgt in Accurate ONLY :: %d\n', sum(idxKeep & idxTST_AccOnly))
fprintf('Number of neurons that discriminated tgt in Fast ONLY :: %d\n', sum(idxKeep & idxTST_FastOnly))
fprintf('Number of neurons that did not discriminate the tgt :: %d\n', sum(idxKeep & idxNoTST))
fprintf('Number of neurons with RF that spanned the viewing screen :: %d\n', sum(idxKeep & idxRF_WholeScreen))

%% Plotting - Barplot - Neuron TST diversity
%compute neuron counts for barplot of TST diversity
nNeuron_None = sum(idxKeep & idxNoTST);       nNeuron_Both = sum(idxKeep & idxTST_All);
nNeuron_Acc = sum(idxKeep & idxTST_AccOnly);  nNeuron_Fast = sum(idxKeep & idxTST_FastOnly);

%barplot showing diversity of visually-responsive neurons (vis-a-vis TST)
figure(); hold on
hBar = bar([nNeuron_None nNeuron_Acc nNeuron_Fast nNeuron_Both ; 0 0 0 0], 'stacked');
hBar(1).FaceColor = [.7 .7 .7];
hBar(2).FaceColor = 'r';
hBar(3).FaceColor = [0 .7 0];
hBar(4).FaceColor = 'y';
ppretty([1.5,3]); xticks([]); set(gca, 'YMinorTick','off')

end % fxn : plot_Distr_TST_Simple()
