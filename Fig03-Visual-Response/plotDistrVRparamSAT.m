function [ varargout ] = plotDistrVRparamSAT( ninfo , nstats , param , varargin )
%plotDistrVRparamSAT Summary of this function goes here
%   args.writeMat -- Flag. Write a .mat file for stats analysis in R?
% 

args = getopt(varargin, {'writeMat', 'plot', {'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
if strcmp(args.area, 'SEF')
  idxVis = ismember({ninfo.visType}, {'sustained'});
else
  idxVis = ([ninfo.visGrade] >= 0.5);
end
idxTST = ~(isnan([nstats.VRTSTAcc]) | isnan([nstats.VRTSTFast]));

if strcmp(param, 'TST')
  idxKeep = (idxArea & idxMonkey & idxVis & idxTST);
elseif ismember(param, {'Latency','Magnitude'})
  idxKeep = (idxArea & idxMonkey & idxVis);
else
  error('Input "param" not recognized')
end

ninfo = ninfo(idxKeep);
nstats = nstats(idxKeep);

if strcmp(param, 'Latency')
  paramAcc = [nstats.VRlatAcc];
  paramFast = [nstats.VRlatFast];
  unit = '(ms)';
elseif strcmp(param, 'Magnitude')
  paramAcc = [nstats.VRmagAcc];
  paramFast = [nstats.VRmagFast];
  unit = '(sp/s)';
elseif strcmp(param, 'TST')
  paramAcc = [nstats.VRTSTAcc];
  paramFast = [nstats.VRTSTFast];
  unit = '(ms)';
end

%split by task efficiency
idxEff = ([ninfo.taskType] == 1);
idxIneff = ([ninfo.taskType] == 2);

paramAccEff = paramAcc(idxEff);       paramFastEff = paramFast(idxEff);
paramAccIneff = paramAcc(idxIneff);   paramFastIneff = paramFast(idxIneff);

meanAccEff = mean(paramAccEff);       SEAccEff = std(paramAccEff)/sqrt(sum(idxEff));
meanAccIneff = mean(paramAccIneff);   SEAccIneff = std(paramAccIneff)/sqrt(sum(idxIneff));
meanFastEff = mean(paramFastEff);     SEFastEff = std(paramFastEff)/sqrt(sum(idxEff));
meanFastIneff = mean(paramFastIneff); SEFastIneff = std(paramFastIneff)/sqrt(sum(idxIneff));

% fprintf('Efficient:\n')
% fprintf('Acc: %g +- %g\t\t', mean(paramAccEff), std(paramAccEff))
% fprintf('Fast: %g +- %g\n', mean(paramFastEff), std(paramFastEff))
% fprintf('Inefficient:\n')
% fprintf('Acc: %g +- %g\t\t', mean(paramAccIneff), std(paramAccIneff))
% fprintf('Fast: %g +- %g\n', mean(paramFastIneff), std(paramFastIneff))

if (args.writeMat) %output data to run stats in R
  dataMat = struct('AE',paramAccEff', 'AI',paramAccIneff', 'FE',paramFastEff', 'FI',paramFastIneff');
  save(['C:\Users\Thomas Reppert\Documents\R\SEF-SAT\', param,'-',args.area,'.mat'], 'dataMat')
  return
end

if (args.plot)
%% Plots of absolute values
%cumulative distribution
% figure(); hold on
% hAE = cdfplotTR(paramAccEff, 'Color','r', 'LineWidth',0.5); hAE.YData = hAE.YData - .005;
% hAI = cdfplotTR(paramAccIneff, 'Color','r', 'LineWidth',1.25); hAI.YData = hAI.YData - .005;
% hFE = cdfplotTR(paramFastEff, 'Color',[0 .7 0], 'LineWidth',0.5); hFE.YData = hFE.YData + .005;
% hFI = cdfplotTR(paramFastIneff, 'Color',[0 .7 0], 'LineWidth',1.25); hFI.YData = hFI.YData + .005;
% ylim([0 1]); ytickformat('%2.1f')
% xlabel([param, ' ', unit])
% ylabel('Cumulative probability')
% ppretty([5 5])

%barplot
% figure(); hold on
% bar(1, meanFastEff, 0.7, 'FaceColor',[0 .7 0], 'LineWidth',0.25)
% bar(2, meanFastIneff, 0.7, 'FaceColor',[0 .7 0], 'LineWidth',1.25)
% bar(3, meanAccEff, 0.7, 'FaceColor','r', 'LineWidth',0.25)
% bar(4, meanAccIneff, 0.7, 'FaceColor','r', 'LineWidth',1.25)
% errorbar([meanFastEff meanFastIneff meanAccEff meanAccIneff], [SEFastEff SEFastIneff SEAccEff SEAccIneff], 'Color','k', 'CapSize',0)
% xticks([]); xticklabels([])
% ylabel([param, ' ', unit])
% ppretty([2,4])

%% Plots of difference (Acc - Fast)
parmDiffEff = paramFastEff - paramAccEff;        meanDiffEff = mean(parmDiffEff);     SEDiffEff = std(parmDiffEff) / sqrt(sum(idxEff));
parmDiffIneff = paramFastIneff - paramAccIneff;  meanDiffIneff = mean(parmDiffIneff); SEDiffIneff = std(parmDiffIneff) / sqrt(sum(idxIneff));

%cumulative distribution
figure(); hold on
cdfplotTR(parmDiffEff, 'Color','k', 'LineWidth',0.5)
cdfplotTR(parmDiffIneff, 'Color','k', 'LineWidth',1.25)
plot([0 0], [0 1], 'k:')
ylim([0 1]); ytickformat('%2.1f')
xlabel([param, ' diff. (Fast - Acc) ', unit])
ylabel('Cumulative probability')
ppretty([5 5])

%barplot
figure(); hold on
bar(1, meanDiffEff, 0.7, 'FaceColor',[.4 .4 .4], 'LineWidth',0.25)
bar(2, meanDiffIneff, 0.7, 'FaceColor',[.4 .4 .4], 'LineWidth',1.25)
errorbar([meanDiffEff meanDiffIneff], [SEDiffEff SEDiffIneff], 'Color','k', 'CapSize',0)
xticks([1,2]); xticklabels([])
ylabel([param, ' diff. (Fast - Acc) ', unit])
ppretty([2,3])

end%if:(args.plot)

%% Stats
if (nargout > 0)
  %dependent variable - visual response latency
  parm = [paramAccEff, paramAccIneff, paramFastEff, paramFastIneff]';
  %two factors
  condition = [ones(1,sum(idxEff | idxIneff)), 2*ones(1,sum(idxEff | idxIneff))]';
  efficiency = [ones(1,sum(idxEff)), 2*ones(1,sum(idxIneff)), ones(1,sum(idxEff)), 2*ones(1,sum(idxIneff))]';

  [~,ANtbl] = anovan(parm, {condition efficiency}, 'model','interaction', 'varnames',{'Condition','Efficiency'}, 'display','off');
  varargout{1} = ANtbl;
  
end%if:(nargout > 0)

end%util:plotDistrVRparamSAT()

