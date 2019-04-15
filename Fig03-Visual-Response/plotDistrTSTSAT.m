function [ ] = plotDistrTSTSAT( ninfo , nstats , varargin )
%plotDistrTSTSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
if strcmp(args.area, 'SEF')
  idxVis = ismember({ninfo.visType}, {'sustained'});
else
  idxVis = ([ninfo.visGrade] >= 0.5);
end
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
%cumulative distribution X condition X efficiency
figure(); hold on
hAE = cdfplotTR(TSTAccEff, 'Color','r', 'LineWidth',0.5); hAE.YData = hAE.YData - .005;
hAI = cdfplotTR(TSTAccIneff, 'Color','r', 'LineWidth',1.25); hAI.YData = hAI.YData - .005;
hFE = cdfplotTR(TSTFastEff, 'Color',[0 .7 0], 'LineWidth',0.5); hFE.YData = hFE.YData + .005;
hFI = cdfplotTR(TSTFastIneff, 'Color',[0 .7 0], 'LineWidth',1.25); hFI.YData = hFI.YData + .005;
legend({'Acc-Eff','Acc-Ineff','Fast-Eff','Fast-Ineff'}, 'FontSize',7, 'Location','southeast')
xlabel('Target selection time (ms)'); ylabel('Cumulative probability'); ytickformat('%2.1f'); ylim([0 1])
ppretty([5,5])

fprintf('TST during Acc Eff | Ineff: %g +/- %g | %g +/- %g\n', mean(TSTAccEff),std(TSTAccEff), mean(TSTAccIneff),std(TSTAccIneff))
fprintf('TST during Fast Eff | Ineff: %g +/- %g | %g +/- %g\n', mean(TSTFastEff),std(TSTFastEff), mean(TSTFastIneff),std(TSTFastIneff))
% [~,pval,~,stat] = ttest2(TSTAccIneff, TSTAccEff, 'Alpha',.05, 'Tail','both');
% fprintf('Acc: p = %g  t_%d = %g\n', pval, stat.df, stat.tstat)
% [~,pval,~,stat] = ttest2(TSTFastIneff, TSTFastEff, 'Alpha',.05, 'Tail','both');
% fprintf('Fast: p = %g  t_%d = %g\n', pval, stat.df, stat.tstat)

%% Bar with error
if strcmp(args.area, 'SC')
  errPlot = [std(TSTFastEff)/sqrt(sum(idxEff)) std(TSTFastIneff)/sqrt(sum(idxIneff)) ...
    std(TSTAccEff)/sqrt(sum(idxEff)) std(TSTAccIneff)/sqrt(sum(idxIneff))];
  figure(); hold on
  bar(1, mean(TSTFastEff), 0.7, 'FaceColor',[0 .7 0], 'LineWidth',0.25)
  bar(2, mean(TSTFastIneff), 0.7, 'FaceColor',[0 .7 0], 'LineWidth',1.25)
  bar(3, mean(TSTAccEff), 0.7, 'FaceColor','r', 'LineWidth',0.25)
  bar(4, mean(TSTAccIneff), 0.7, 'FaceColor','r', 'LineWidth',1.25)
  errorbar([mean(TSTFastEff) mean(TSTFastIneff) mean(TSTAccEff) mean(TSTAccIneff)], errPlot, 'Color','k', 'CapSize',0)
  xticks(1:4); xticklabels([])
  ppretty([3,5])
end

end%fxn:plotDistrTSTSAT()

