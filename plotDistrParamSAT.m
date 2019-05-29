function [ ] = plotDistrParamSAT( ninfo , nstats , param , varargin )
%plotDistrParamSAT Summary of this function goes here
%   args.export -- Write a .mat file for stats analysis in R
% 

args = getopt(varargin, {'export', {'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxVis = ([ninfo.visGrade] >= 2);
idxTST = ~(isnan([nstats.VRTSTAcc]) | isnan([nstats.VRTSTFast]));
idxError = (abs([ninfo.errGrade]) >= 2);
idxReward = (abs([ninfo.rewGrade]) >= 2);

if strcmp(param, 'TST')
  idxKeep = (idxArea & idxMonkey & idxVis & idxTST);
elseif ismember(param, {'VisLat','VisMag'})
  idxKeep = (idxArea & idxMonkey & idxVis);
elseif ismember(param, {'ErrLat','ErrMag'})
  idxKeep = (idxArea & idxMonkey & idxError);
elseif ismember(param, {'RewLat','RewMag'})
  idxKeep = (idxArea & idxMonkey & idxReward);
else
  error('Input "param" not recognized')
end

ninfo = ninfo(idxKeep);
nstats = nstats(idxKeep);
NUM_CELLS = sum(idxKeep);

if strcmp(param, 'VisLat')
  fieldAcc = 'VRlatAcc';
  fieldFast = 'VRlatFast';
elseif strcmp(param, 'VisMag')
  fieldAcc = 'VRmagAcc';
  fieldFast = 'VRmagFast';
elseif strcmp(param, 'TST')
  fieldAcc = 'VRTSTAcc';
  fieldFast = 'VRTSTFast';
elseif strcmp(param, 'ErrLat')
  fieldAcc = 'A_ChcErr_tErr_Acc';
  fieldFast = 'A_ChcErr_tErr_Fast';
elseif strcmp(param, 'ErrMag')
  fieldAcc = 'A_ChcErr_magErr_Acc';
  fieldFast = 'A_ChcErr_magErr_Fast';
elseif strcmp(param, 'RewLat')
  fieldAcc = 'A_Reward_tErrStart_Acc';
  fieldFast = 'A_Reward_tErrStart_Fast';
end

paramAcc = [nstats.(fieldAcc)];
paramFast = [nstats.(fieldFast)];

%split by task efficiency
idxMore = ([ninfo.taskType] == 1);  NUM_MORE = sum(idxMore);
idxLess = ([ninfo.taskType] == 2);  NUM_LESS = sum(idxLess);

paramAccMore = paramAcc(idxMore);   paramFastMore = paramFast(idxMore);
paramAccLess = paramAcc(idxLess);   paramFastLess = paramFast(idxLess);

if (args.export)
  ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\SEF_SAT\Stats\';
  Parameter = [paramAccMore, paramAccLess, paramFastMore, paramFastLess]';
  Condition = cell(2*NUM_CELLS,1); Condition(1:NUM_CELLS) = {'Accurate'}; Condition(NUM_CELLS+1:end) = {'Fast'};
  Efficiency = cell(NUM_CELLS,1); Efficiency(1:NUM_MORE) = {'More'};
  Efficiency(NUM_MORE+1:end) = {'Less'}; Efficiency = [Efficiency; Efficiency];
  Neuron = [(1:NUM_CELLS), (1:NUM_CELLS)]';
  structOut = struct('Neuron',Neuron', 'Parameter',Parameter');
  for cc = 1:(2*NUM_CELLS)
    structOut.Condition(cc) = Condition(cc);
    structOut.Efficiency(cc) = Efficiency(cc);
  end
  save([ROOTDIR, args.area,'-', param,'.mat'], 'structOut')
end%if:export

%% Plots of absolute values
meanAccEff = nanmean(paramAccMore);      SEAccEff = nanstd(paramAccMore)/sqrt(sum(idxMore));
meanAccIneff = nanmean(paramAccLess);    SEAccIneff = nanstd(paramAccLess)/sqrt(sum(idxLess));
meanFastEff = nanmean(paramFastMore);    SEFastEff = nanstd(paramFastMore)/sqrt(sum(idxMore));
meanFastIneff = nanmean(paramFastLess);  SEFastIneff = nanstd(paramFastLess)/sqrt(sum(idxLess));

%barplot
figure(); hold on
bar(1, meanFastEff, 0.7, 'FaceColor',[0 .7 0], 'LineWidth',0.25)
bar(2, meanFastIneff, 0.7, 'FaceColor',[0 .7 0], 'LineWidth',1.25)
bar(3, meanAccEff, 0.7, 'FaceColor','r', 'LineWidth',0.25)
bar(4, meanAccIneff, 0.7, 'FaceColor','r', 'LineWidth',1.25)
errorbar([meanFastEff meanFastIneff meanAccEff meanAccIneff], [SEFastEff SEFastIneff SEAccEff SEAccIneff], 'Color','k', 'CapSize',0)
xticks([]); xticklabels([])
ylabel(param)
ppretty([1,2])
pause(0.1)

%% Plots of difference (Acc - Fast)
if ismember(param, {'VisMag','ErrMag','RewMag'})
  parmDiffEff = paramFastMore - paramAccMore;
  parmDiffIneff = paramFastLess - paramAccLess;
else
  parmDiffEff = paramAccMore - paramFastMore;
  parmDiffIneff = paramAccLess - paramFastLess;
end

% meanDiffEff = nanmean(parmDiffEff);     SEDiffEff = nanstd(parmDiffEff) / sqrt(sum(idxMore));
% meanDiffIneff = nanmean(parmDiffIneff); SEDiffIneff = nanstd(parmDiffIneff) / sqrt(sum(idxLess));

%cumulative distribution
figure(); hold on
cdfplotTR(parmDiffEff, 'Color','k', 'LineWidth',0.5)
cdfplotTR(parmDiffIneff, 'Color','k', 'LineWidth',1.25)
plot([0 0], [0 1], 'k:')
ylim([0 1]); ytickformat('%2.1f')
xlabel([param, ' difference'])
ylabel('Cumulative probability')
ppretty([4.8,3])

end%util:plotDistrParamSAT()
