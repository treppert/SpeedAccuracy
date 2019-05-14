function [ ] = plotDistrParamSAT( ninfo , nstats , param , varargin )
%plotDistrParamSAT Summary of this function goes here
%   args.export -- Write a .mat file for stats analysis in R
% 

args = getopt(varargin, {'export', {'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxErrorGrade = (abs([ninfo.errGrade]) >= 0.5);
if strcmp(args.area, 'SEF')
  idxVisGrade = ismember({ninfo.visType}, {'sustained','phasic'});
else
  idxVisGrade = ([ninfo.visGrade] >= 0.5);
end
idxTST = ~(isnan([nstats.VRTSTAcc]) | isnan([nstats.VRTSTFast]));
idxReward = ~(isnan([nstats.A_Reward_tErrStart_Acc]) & isnan([nstats.A_Reward_tErrStart_Fast]));


if strcmp(param, 'TST')
  idxKeep = (idxArea & idxMonkey & idxVisGrade & idxTST);
elseif ismember(param, {'VisLat','VisMag'})
  idxKeep = (idxArea & idxMonkey & idxVisGrade);
elseif ismember(param, {'ErrLat','ErrMag'})
  idxKeep = (idxArea & idxMonkey & idxErrorGrade);
elseif ismember(param, {'RewLat','RewMag'})
  idxKeep = (idxArea & idxMonkey & idxReward);
else
  error('Input "param" not recognized')
end

ninfo = ninfo(idxKeep);
nstats = nstats(idxKeep);
NUM_CELLS = sum(idxKeep);

if strcmp(param, 'VisLat')
  paramAcc = [nstats.VRlatAcc];
  paramFast = [nstats.VRlatFast];
elseif strcmp(param, 'VisMag')
  paramAcc = [nstats.VRmagAcc];
  paramFast = [nstats.VRmagFast];
elseif strcmp(param, 'TST')
  paramAcc = [nstats.VRTSTAcc];
  paramFast = [nstats.VRTSTFast];
elseif strcmp(param, 'ErrLat')
  paramAcc = [nstats.A_ChcErr_tErr_Acc];
  paramFast = [nstats.A_ChcErr_tErr_Fast];
elseif strcmp(param, 'ErrMag')
  paramAcc = [nstats.A_ChcErr_magErr_Acc];
  paramFast = [nstats.A_ChcErr_magErr_Fast];
elseif strcmp(param, 'RewLat')
  paramAcc = [nstats.A_Reward_tErrStart_Acc];
  paramFast = [nstats.A_Reward_tErrStart_Fast];
elseif strcmp(param, 'RewMag')
%   paramAcc = [nstats.A_ChcErr_magErr_Acc];
%   paramFast = [nstats.A_ChcErr_magErr_Fast];
end

%split by task efficiency
idxMore = ([ninfo.taskType] == 1);  NUM_MORE = sum(idxMore);
idxLess = ([ninfo.taskType] == 2);  NUM_LESS = sum(idxLess);

paramAccMore = paramAcc(idxMore);   paramFastMore = paramFast(idxMore);
paramAccLess = paramAcc(idxLess);   paramFastLess = paramFast(idxLess);

if (args.export)
  Parameter = [paramAccMore, paramAccLess, paramFastMore, paramFastLess]';
  Condition = cell(2*NUM_CELLS,1); Condition(1:NUM_CELLS) = {'Accurate'}; Condition(NUM_CELLS+1:end) = {'Fast'};
  Efficiency = cell(NUM_CELLS,1); Efficiency(1:NUM_MORE) = {'More'}; Efficiency(NUM_MORE+1:end) = {'Less'}; Efficiency = [Efficiency; Efficiency];
  Neuron = [(1:NUM_CELLS), (1:NUM_CELLS)]';
  structOut = struct('Neuron',Neuron', 'Parameter',Parameter');
  for cc = 1:(2*NUM_CELLS)
    structOut.Condition(cc) = Condition(cc);
    structOut.Efficiency(cc) = Efficiency(cc);
  end
  save(['C:\Users\Thomas Reppert\Dropbox\SAT-Me\Data\',args.area, '-', param,'.mat'], 'structOut')
  return
end%if:export

%% Plots of absolute values
meanAccEff = nanmean(paramAccMore);      SEAccEff = nanstd(paramAccMore)/sqrt(sum(idxMore));
meanAccIneff = nanmean(paramAccLess);    SEAccIneff = nanstd(paramAccLess)/sqrt(sum(idxLess));
meanFastEff = nanmean(paramFastMore);    SEFastEff = nanstd(paramFastMore)/sqrt(sum(idxMore));
meanFastIneff = nanmean(paramFastLess);  SEFastIneff = nanstd(paramFastLess)/sqrt(sum(idxLess));

figure()
%cumulative distribution
subplot(1,2,1); hold on
hAE = cdfplotTR(paramAccMore, 'Color','r', 'LineWidth',0.5); hAE.YData = hAE.YData - .005;
hAI = cdfplotTR(paramAccLess, 'Color','r', 'LineWidth',1.25); hAI.YData = hAI.YData - .005;
hFE = cdfplotTR(paramFastMore, 'Color',[0 .7 0], 'LineWidth',0.5); hFE.YData = hFE.YData + .005;
hFI = cdfplotTR(paramFastLess, 'Color',[0 .7 0], 'LineWidth',1.25); hFI.YData = hFI.YData + .005;
ylim([0 1]); ytickformat('%2.1f'); ylabel('Cumulative probability')
xlabel(param)

%barplot
subplot(1,2,2); hold on
bar(1, meanFastEff, 0.7, 'FaceColor',[0 .7 0], 'LineWidth',0.25)
bar(2, meanFastIneff, 0.7, 'FaceColor',[0 .7 0], 'LineWidth',1.25)
bar(3, meanAccEff, 0.7, 'FaceColor','r', 'LineWidth',0.25)
bar(4, meanAccIneff, 0.7, 'FaceColor','r', 'LineWidth',1.25)
errorbar([meanFastEff meanFastIneff meanAccEff meanAccIneff], [SEFastEff SEFastIneff SEAccEff SEAccIneff], 'Color','k', 'CapSize',0)
xticks([]); xticklabels([])
ylabel(param)

ppretty([8,3])
pause(0.1)

%% Plots of difference (Acc - Fast)
if ismember(param, {'VisMag','ErrMag','RewMag'})
  parmDiffEff = paramFastMore - paramAccMore;
  parmDiffIneff = paramFastLess - paramAccLess;
else
  parmDiffEff = paramAccMore - paramFastMore;
  parmDiffIneff = paramAccLess - paramFastLess;
end

meanDiffEff = nanmean(parmDiffEff);     SEDiffEff = nanstd(parmDiffEff) / sqrt(sum(idxMore));
meanDiffIneff = nanmean(parmDiffIneff); SEDiffIneff = nanstd(parmDiffIneff) / sqrt(sum(idxLess));

%cumulative distribution
figure()
subplot(1,2,1); hold on
cdfplotTR(parmDiffEff, 'Color','k', 'LineWidth',0.5)
cdfplotTR(parmDiffIneff, 'Color','k', 'LineWidth',1.25)
plot([0 0], [0 1], 'k:')
ylim([0 1]); ytickformat('%2.1f')
xlabel([param, ' difference'])
ylabel('Cumulative probability')

%barplot
subplot(1,2,2); hold on
bar(1, meanDiffEff, 0.7, 'FaceColor',[.4 .4 .4], 'LineWidth',0.25)
bar(2, meanDiffIneff, 0.7, 'FaceColor',[.4 .4 .4], 'LineWidth',1.25)
errorbar([meanDiffEff meanDiffIneff], [SEDiffEff SEDiffIneff], 'Color','k', 'CapSize',0)
xticks([1,2]); xticklabels([])
ylabel([param, ' difference'])

ppretty([8,3])

end%util:plotDistrParamSAT()
