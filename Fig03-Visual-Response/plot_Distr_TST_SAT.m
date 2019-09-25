function [ ] = plot_Distr_TST_SAT( ninfo , nstats , varargin )
%plot_Distr_TST_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxVis = ([ninfo.visGrade] >= 2);
idxKeep = (idxArea & idxMonkey & idxVis);

idxTST_All = ~(isnan([nstats.VRTSTAcc]) | isnan([nstats.VRTSTFast]));
idxTST_AccOnly = ~isnan([nstats.VRTSTAcc]) & isnan([nstats.VRTSTFast]);
idxTST_FastOnly = isnan([nstats.VRTSTAcc]) & ~isnan([nstats.VRTSTFast]);
idxNoTST = (isnan([nstats.VRTSTAcc]) & isnan([nstats.VRTSTFast]));

%get neurons with RF that spanned the entire viewing screen (esp. SEF)
idxRF_WholeScreen = false(1,length(nstats));
for cc = 1:length(ninfo)
  if ismember(ninfo(cc).visField, 9)
    idxRF_WholeScreen(cc) = true;
  end
end

% fprintf('Number of visually-responsive neurons :: %d\n', sum(idxKeep))
% fprintf('Number of neurons that discriminated tgt in Fast AND Accurate :: %d\n', sum(idxKeep & idxTST_All))
% fprintf('Number of neurons that discriminated tgt in Accurate ONLY :: %d\n', sum(idxKeep & idxTST_AccOnly))
% fprintf('Number of neurons that discriminated tgt in Fast ONLY :: %d\n', sum(idxKeep & idxTST_FastOnly))
% fprintf('Number of neurons that did not discriminate the tgt :: %d\n', sum(idxKeep & idxNoTST))
% fprintf('Number of neurons with RF that spanned the viewing screen :: %d\n', sum(idxKeep & idxRF_WholeScreen))

%% Plotting - Barplot - Neuron TST diversity
%barplot showing diversity of visually=responsive neurons (vis-a-vis TST)
n_None = sum(idxKeep & idxNoTST);       n_Both = sum(idxKeep & idxTST_All);
n_Acc = sum(idxKeep & idxTST_AccOnly);  n_Fast = sum(idxKeep & idxTST_FastOnly);

% figure(); hold on
% hBar = bar([n_None n_Acc n_Fast n_Both ; 0 0 0 0], 'stacked');
% hBar(1).FaceColor = 'k';
% hBar(2).FaceColor = 'r';
% hBar(3).FaceColor = [0 .7 0];
% hBar(4).FaceColor = 'y';
% ppretty([1.5,3]); xticks([]); set(gca, 'YMinorTick','off')

%% Plotting - Distribution of TST for neurons that select the target
idxKeep = (idxKeep & (idxTST_All | idxTST_AccOnly | idxTST_FastOnly));
ninfo = ninfo(idxKeep);
nstats = nstats(idxKeep);

ccMore = ([ninfo.taskType] == 1);   NUM_MORE = sum(ccMore);
ccLess = ([ninfo.taskType] == 2);   NUM_LESS = sum(ccLess);

TST_Acc_More = [nstats(ccMore).VRTSTAcc]; TST_Acc_More(isnan(TST_Acc_More)) = [];
TST_Acc_Less = [nstats(ccLess).VRTSTAcc]; TST_Acc_Less(isnan(TST_Acc_Less)) = [];
TST_Fast_More = [nstats(ccMore).VRTSTFast]; TST_Fast_More(isnan(TST_Fast_More)) = [];
TST_Fast_Less = [nstats(ccLess).VRTSTFast]; TST_Fast_Less(isnan(TST_Fast_Less)) = [];

% figure(); hold on
% cdfplotTR(TST_Fast_More, 'Color',[0 .7 0])
% cdfplotTR(TST_Fast_Less, 'Color',[0 .7 0], 'LineWidth',1.75)
% cdfplotTR(TST_Acc_More, 'Color','r')
% cdfplotTR(TST_Acc_Less, 'Color','r', 'LineWidth',1.75)
% ppretty([3.6,2]); ytickformat('%2.1f')

%stats -- unpaired t-test
[~,pval_More] = ttest2(TST_Acc_More, TST_Fast_More);
[~,pval_Less] = ttest2(TST_Acc_Less, TST_Fast_Less);
fprintf('pval (unpaired) (More efficient) :: %g\n', pval_More)
fprintf('pval (unpaired) (Less efficient) :: %g\n', pval_Less)

%% Plotting - Barplot - TST
y_AM = mean(TST_Acc_More);    se_AM = std(TST_Acc_More)/sqrt(NUM_MORE);
y_AL = mean(TST_Acc_Less);    se_AL = std(TST_Acc_Less)/sqrt(NUM_LESS);
y_FM = mean(TST_Fast_More);   se_FM = std(TST_Fast_More)/sqrt(NUM_MORE);
y_FL = mean(TST_Fast_Less);   se_FL = std(TST_Fast_Less)/sqrt(NUM_LESS);

% figure(); hold on
% bar([y_FM y_AM y_FL y_AL], 'FaceColor',[.3 .3 .3]);
% errorbar(1:4, [y_FM y_AM y_FL y_AL], [se_FM se_AM se_FL se_AL], 'k-', 'CapSize',0)
% ppretty([2.4,3]); xticks([])

end%fxn:plot_Distr_TST_SAT()

