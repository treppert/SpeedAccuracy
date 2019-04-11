function [ ] = plotTSTXcondSAT( ninfo , nstats , varargin )
%plotTSTXcondSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
% idxVis = ([ninfo.visGrade] >= 0.5);
idxVis = ismember({ninfo.visType}, {'sustained'});
idxTST = ~(isnan([nstats.VRTSTAcc]) | isnan([nstats.VRTSTFast]));

idxKeep = (idxArea & idxMonkey & idxVis & idxTST);

ninfo = ninfo(idxKeep);
nstats = nstats(idxKeep);

idxEff = ([ninfo.taskType] == 1);
idxIneff = ([ninfo.taskType] == 2);

TSTAccEff = [nstats(idxEff).VRTSTAcc];
TSTAccIneff = [nstats(idxIneff).VRTSTAcc];
TSTFastEff = [nstats(idxEff).VRTSTFast];
TSTFastIneff = [nstats(idxIneff).VRTSTFast];

%% Plotting

%scatterplot
% figure(); hold on
% plot([60 240], [60 240], 'k:', 'LineWidth',0.75)
% plot(TSTAccEff, TSTFastEff, 'k.', 'MarkerSize',25)
% plot(TSTAccIneff, TSTFastIneff, 'ko', 'MarkerSize',7)
% xlabel('Target selection time (ms)')
% ylabel('Target selection time (ms)')
% ppretty([5,4])
% axis square

% pause(0.25)

%histogram
% figure(); hold on
% histogram([TSTAccEff TSTAccIneff]-[TSTFastEff TSTFastIneff], 'BinWidth',10, 'FaceColor',[.5 .5 .5])
% ppretty([5,4])

%cumulative distribution X condition
% TSTAcc = sort([TSTAccEff TSTAccIneff]);     yyCum = (1:sum(idxEff | idxIneff)) / sum(idxEff | idxIneff);
% TSTFast = sort([TSTFastEff TSTFastIneff]);
% 
% figure(); hold on
% plot(TSTAcc, yyCum, 'r-', 'LineWidth',0.5)
% plot(TSTFast, yyCum, '-', 'Color',[0 .7 0], 'LineWidth',0.5)
% xlabel('Target selection time (ms)')
% ylabel('Cumulative probability')
% ytickformat('%2.1f')
% ppretty([5,5])
% 
% fprintf('TST during Acc: %g +/- %g\n', mean(TSTAcc), std(TSTAcc))
% fprintf('TST during Fast: %g +/- %g\n', mean(TSTFast), std(TSTFast))
% [~,pval,~,stat] = ttest(TSTAcc, TSTFast, 'Alpha',.05, 'Tail','both');
% fprintf('p = %g  t_%d = %g\n', pval, stat.df, stat.tstat)

%cumulative distribution X condition X efficiency
TSTAccEff = sort(TSTAccEff);        yyEff = (1:sum(idxEff)) / sum(idxEff);
TSTAccIneff = sort(TSTAccIneff);    yyIneff = (1:sum(idxIneff)) / sum(idxIneff);
TSTFastEff = sort(TSTFastEff);
TSTFastIneff = sort(TSTFastIneff);

figure(); hold on
plot(TSTAccEff, yyEff, 'r-', 'LineWidth',0.5)
plot(TSTAccIneff, yyIneff, 'r-', 'LineWidth',1.25)
plot(TSTFastEff, yyEff, '-', 'Color',[0 .7 0], 'LineWidth',0.5)
plot(TSTFastIneff, yyIneff, '-', 'Color',[0 .7 0], 'LineWidth',1.25)
legend({'AccEff','AccIneff','FastEff','FastIneff'}, 'FontSize',7, 'Location','southeast')
xlabel('Target selection time (ms)')
ylabel('Cumulative probability')
ytickformat('%2.1f')
ppretty([5,5])

fprintf('TST during Acc Eff | Ineff: %g +/- %g | %g +/- %g\n', mean(TSTAccEff),std(TSTAccEff), mean(TSTAccIneff),std(TSTAccIneff))
fprintf('TST during Fast Eff | Ineff: %g +/- %g | %g +/- %g\n', mean(TSTFastEff),std(TSTFastEff), mean(TSTFastIneff),std(TSTFastIneff))
[~,pval,~,stat] = ttest2(TSTAccIneff, TSTAccEff, 'Alpha',.05, 'Tail','both');
fprintf('Acc: p = %g  t_%d = %g\n', pval, stat.df, stat.tstat)
[~,pval,~,stat] = ttest2(TSTFastIneff, TSTFastEff, 'Alpha',.05, 'Tail','both');
fprintf('Fast: p = %g  t_%d = %g\n', pval, stat.df, stat.tstat)

end%fxn:plotTSTXcondSAT()

