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

nstats = nstats(idxArea & idxMonkey & idxVis);

latAcc = [nstats.VRlatAcc];
latFast = [nstats.VRlatFast];

%% Histogram of difference
latDiff = latAcc - latFast;

figure(); hold on
histogram(latDiff, 'BinWidth',5, 'FaceColor',[.4 .4 .4], 'Normalization','count')
plot(mean(latDiff)*ones(1,2), [0 5], 'k--') %mark the mean
ppretty([5,5])
pause(0.1)

%% Cumulative distribution
latAcc = sort(latAcc);    yyCum = (1:length(latAcc)) / length(latAcc);
latFast = sort(latFast);

figure(); hold on
plot(latFast, yyCum, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(latAcc, yyCum, 'r-', 'LineWidth',1.0)
ytickformat('%2.1f')
ppretty([5 5])

fprintf('Acc: %g +- %g\n', mean(latAcc), std(latAcc))
fprintf('Fast: %g +- %g\n', mean(latFast), std(latFast))
[~,pval,~,stat] = ttest(latAcc - latFast);
fprintf('Diff: p = %g  t_%d = %g\n', pval, stat.df, stat.tstat)


end%util:plotDistrVisRespLatencySAT()

