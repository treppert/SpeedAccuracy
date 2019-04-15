function [  ] = plotDistrVisRespLatencySAT( ninfo , nstats , varargin )
%plotDistrVisRespLatencySAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
if strcmp(args.area, 'SEF')
  idxVis = ismember({ninfo.visType}, {'sustained'});
else
  idxVis = ([ninfo.visGrade] >= 0.5);
end

idxKeep = (idxArea & idxMonkey & idxVis);

ninfo = ninfo(idxKeep);
nstats = nstats(idxKeep);

idxEff = ([ninfo.taskType] == 1);
idxIneff = ([ninfo.taskType] == 2);

latAccEff = [nstats(idxEff).VRlatAcc];
latAccIneff = [nstats(idxIneff).VRlatAcc];
latFastEff = [nstats(idxEff).VRlatFast];
latFastIneff = [nstats(idxIneff).VRlatFast];

%% Cumulative distribution
figure(); hold on
hAE = cdfplotTR(latAccEff, 'Color','r', 'LineWidth',0.5); hAE.YData = hAE.YData - .005;
hAI = cdfplotTR(latAccIneff, 'Color','r', 'LineWidth',1.25); hAI.YData = hAI.YData - .005;
hFE = cdfplotTR(latFastEff, 'Color',[0 .7 0], 'LineWidth',0.5); hFE.YData = hFE.YData + .005;
hFI = cdfplotTR(latFastIneff, 'Color',[0 .7 0], 'LineWidth',1.25); hFI.YData = hFI.YData + .005;
ylim([.05 .95]); ytickformat('%2.1f')
ppretty([5 5])

% fprintf('Efficient:\n')
% fprintf('Acc: %g +- %g\n', mean(latAccEff), std(latAccEff))
% fprintf('Fast: %g +- %g\n', mean(latFastEff), std(latFastEff))
% % [~,pval,~,stat] = ttest(latAccEff - latFastEff);
% % fprintf('Diff: p = %g  t_%d = %g\n', pval, stat.df, stat.tstat)
% 
% fprintf('Inefficient:\n')
% fprintf('Acc: %g +- %g\n', mean(latAccIneff), std(latAccIneff))
% fprintf('Fast: %g +- %g\n', mean(latFastIneff), std(latFastIneff))
% % [~,pval,~,stat] = ttest(latAccIneff - latFastIneff);
% % fprintf('Diff: p = %g  t_%d = %g\n', pval, stat.df, stat.tstat)

%% Bar with error
if strcmp(args.area, 'SC')
  errPlot = [std(latFastEff)/sqrt(sum(idxEff)) std(latFastIneff)/sqrt(sum(idxIneff)) ...
    std(latAccEff)/sqrt(sum(idxEff)) std(latAccIneff)/sqrt(sum(idxIneff))];
  figure(); hold on
  bar(1, mean(latFastEff), 0.7, 'FaceColor',[0 .7 0], 'LineWidth',0.25)
  bar(2, mean(latFastIneff), 0.7, 'FaceColor',[0 .7 0], 'LineWidth',1.25)
  bar(3, mean(latAccEff), 0.7, 'FaceColor','r', 'LineWidth',0.25)
  bar(4, mean(latAccIneff), 0.7, 'FaceColor','r', 'LineWidth',1.25)
  errorbar([mean(latFastEff) mean(latFastIneff) mean(latAccEff) mean(latAccIneff)], errPlot, 'Color','k', 'CapSize',0)
  xticks(1:4); xticklabels([])
  ppretty([3,5])
end

end%util:plotDistrVisRespLatencySAT()

