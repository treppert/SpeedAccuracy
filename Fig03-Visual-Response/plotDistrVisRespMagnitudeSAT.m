function [  ] = plotDistrVisRespMagnitudeSAT( ninfo , nstats , varargin )
%plotDistrVisRespMagnitudeSAT Summary of this function goes here
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

magAccEff = [nstats(idxEff).VRmagAcc];
magAccIneff = [nstats(idxIneff).VRmagAcc];
magFastEff = [nstats(idxEff).VRmagFast];
magFastIneff = [nstats(idxIneff).VRmagFast];

% %plot distribution of difference in response magnitude
% ccFgA = ([nstats.VReffect] == 1); %cells with VR Fast > Acc
% ccAgF = ([nstats.VReffect] == -1); %cells with VR Acc > Fast

%% Cumulative distribution
figure(); hold on
hAE = cdfplotTR(magAccEff, 'Color','r', 'LineWidth',0.5); hAE.YData = hAE.YData - .005;
hAI = cdfplotTR(magAccIneff, 'Color','r', 'LineWidth',1.25); hAI.YData = hAI.YData - .005;
hFE = cdfplotTR(magFastEff, 'Color',[0 .7 0], 'LineWidth',0.5); hFE.YData = hFE.YData + .005;
hFI = cdfplotTR(magFastIneff, 'Color',[0 .7 0], 'LineWidth',1.25); hFI.YData = hFI.YData + .005;
ylim([.05 .95]); ytickformat('%2.1f')
ppretty([5 5])

%% Bar with error
if strcmp(args.area, 'SC')
  errPlot = [std(magFastEff)/sqrt(sum(idxEff)) std(magFastIneff)/sqrt(sum(idxIneff)) ...
    std(magAccEff)/sqrt(sum(idxEff)) std(magAccIneff)/sqrt(sum(idxIneff))];
  figure(); hold on
  bar(1, mean(magFastEff), 0.7, 'FaceColor',[0 .7 0], 'LineWidth',0.25)
  bar(2, mean(magFastIneff), 0.7, 'FaceColor',[0 .7 0], 'LineWidth',1.25)
  bar(3, mean(magAccEff), 0.7, 'FaceColor','r', 'LineWidth',0.25)
  bar(4, mean(magAccIneff), 0.7, 'FaceColor','r', 'LineWidth',1.25)
  errorbar([mean(magFastEff) mean(magFastIneff) mean(magAccEff) mean(magAccIneff)], errPlot, 'Color','k', 'CapSize',0)
  xticks(1:4); xticklabels([])
  ppretty([3,5])
end

end%util:plotDistrVisRespMagnitudeSAT()

