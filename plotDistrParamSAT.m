function [ ] = plotDistrParamSAT( ninfo , nstats , parmName , varargin )
%plotDistrParamSAT Summary of this function goes here
%   args.export -- Write a .mat file for stats analysis in R
% 

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

ROOTDIR_FIG = 'C:\Users\Thomas Reppert\Dropbox\ZZtmp\';
ROOTDIR_STAT = 'C:\Users\Thomas Reppert\Dropbox\SAT\Stats\';

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxVis = ([ninfo.visGrade] >= 2);   idxMove = ([ninfo.moveGrade] >= 2);
idxErr = ([ninfo.errGrade] >= 2);   idxRew = (abs([ninfo.rewGrade]) >= 2);

idxRF = false(1,length(ninfo)); %has a finite RF (not the entire screen)
for cc = 1:length(ninfo)
  if ~ismember(ninfo(cc).visField, 9); idxRF(cc) = true; end
end

if strcmp(parmName, 'TST')
  idxTST = ~(isnan([nstats.VRTSTAcc]) | isnan([nstats.VRTSTFast]));
  idxKeep = (idxArea & idxMonkey & idxVis & idxTST);
elseif ismember(parmName, {'VisLat','VisMag'})
  idxTST = ~(isnan([nstats.VRTSTAcc]) | isnan([nstats.VRTSTFast]));
  idxKeep = (idxArea & idxMonkey & idxVis & ~idxTST);
elseif ismember(parmName, {'ErrLat','ErrMag'})
  idxKeep = (idxArea & idxMonkey & idxErr);
elseif ismember(parmName, {'RewLat','RewMag'})
  idxKeep = (idxArea & idxMonkey & idxRew);
elseif ismember(parmName, {'Buildup'})
  idxKeep = (idxArea & idxMonkey & idxMove);
elseif ismember(parmName, {'Baseline'})
  idxKeep = (idxArea & idxMonkey & (idxVis | idxMove | idxErr | idxRew));
else
  error('Input "param" not recognized')
end

NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
nstats = nstats(idxKeep);

if strcmp(parmName, 'VisLat')
  fieldAcc = 'VRlatAcc';
  fieldFast = 'VRlatFast';
elseif strcmp(parmName, 'VisMag')
  fieldAcc = 'VRmagAcc';
  fieldFast = 'VRmagFast';
elseif strcmp(parmName, 'TST')
  fieldAcc = 'VRTSTAcc';
  fieldFast = 'VRTSTFast';
elseif strcmp(parmName, 'ErrLat')
  fieldAcc = 'A_ChcErr_tErr_Acc';
  fieldFast = 'A_ChcErr_tErr_Fast';
elseif strcmp(parmName, 'ErrMag')
  fieldAcc = 'A_ChcErr_magErr_Acc';
  fieldFast = 'A_ChcErr_magErr_Fast';
elseif strcmp(parmName, 'RewLat')
  fieldAcc = 'A_Reward_tErrStart_Acc';
  fieldFast = 'A_Reward_tErrStart_Fast';
elseif strcmp(parmName, 'RewMag')
  fieldAcc = 'A_Reward_magErr_Acc';
  fieldFast = 'A_Reward_magErr_Fast';
elseif strcmp(parmName, 'Buildup')
  fieldAcc = 'A_Buildup_Threshold_AccCorr';
  fieldFast = 'A_Buildup_Threshold_FastCorr';
elseif strcmp(parmName, 'Baseline')
  fieldAcc = 'blineAccMEAN';
  fieldFast = 'blineFastMEAN';
end

paramAcc = [nstats.(fieldAcc)];
paramFast = [nstats.(fieldFast)];

inan = (isnan(paramAcc) | isnan(paramFast));
ninfo(inan) = []; paramAcc(inan) = []; paramFast(inan) = [];
NUM_CELLS = NUM_CELLS - sum(inan);

%split by task efficiency
idxMore = ([ninfo.taskType] == 1);  NUM_MORE = sum(idxMore);
idxLess = ([ninfo.taskType] == 2);  NUM_LESS = sum(idxLess);

param.AccMore = paramAcc(idxMore);   param.FastMore = paramFast(idxMore);
param.AccLess = paramAcc(idxLess);   param.FastLess = paramFast(idxLess);


%% Plots of absolute values
meanAccEff = nanmean(param.AccMore);      SEAccEff = nanstd(param.AccMore)/sqrt(sum(idxMore));
meanAccIneff = nanmean(param.AccLess);    SEAccIneff = nanstd(param.AccLess)/sqrt(sum(idxLess));
meanFastEff = nanmean(param.FastMore);    SEFastEff = nanstd(param.FastMore)/sqrt(sum(idxMore));
meanFastIneff = nanmean(param.FastLess);  SEFastIneff = nanstd(param.FastLess)/sqrt(sum(idxLess));

%barplot
figure(); hold on
bar(1, meanFastEff, 0.7, 'FaceColor',[0 .7 0], 'LineWidth',0.25)
bar(2, meanFastIneff, 0.7, 'FaceColor',[0 .7 0], 'LineWidth',1.25)
bar(3, meanAccEff, 0.7, 'FaceColor','r', 'LineWidth',0.25)
bar(4, meanAccIneff, 0.7, 'FaceColor','r', 'LineWidth',1.25)
errorbar([meanFastEff meanFastIneff meanAccEff meanAccIneff], [SEFastEff SEFastIneff SEAccEff SEAccIneff], 'Color','k', 'CapSize',0)
xticks([]); xticklabels([])
ylabel(parmName)
ppretty([1,2])
% print([ROOTDIR_FIG,args.area,'-',param,'-ZBar.pdf'], '-dpdf'); pause(0.1)

%% Plots of difference (Acc - Fast)
if ismember(parmName, {'VisMag','ErrMag','RewMag'})
  parmDiffEff = param.FastMore - param.AccMore;
  parmDiffIneff = param.FastLess - param.AccLess;
else
  parmDiffEff = param.AccMore - param.FastMore;
  parmDiffIneff = param.AccLess - param.FastLess;
end

% meanDiffEff = nanmean(parmDiffEff);     SEDiffEff = nanstd(parmDiffEff) / sqrt(sum(idxMore));
% meanDiffIneff = nanmean(parmDiffIneff); SEDiffIneff = nanstd(parmDiffIneff) / sqrt(sum(idxLess));

%cumulative distribution
% figure(); hold on
% cdfplotTR(parmDiffEff, 'Color','k', 'LineWidth',0.5)
% cdfplotTR(parmDiffIneff, 'Color','k', 'LineWidth',1.25)
% plot([0 0], [0 1], 'k:', 'LineWidth',1.25)
% ylim([0 1]); ytickformat('%2.1f')
% xlabel([param, ' difference'])
% ylabel('Cumulative probability')
% yticklabels({'0.0','','0.2','','0.4','','0.6','','0.8','','1.0'})
% ppretty([4.8,3])
% print([ROOTDIR_FIG,args.area,'-',param,'-CDF.pdf'], '-dpdf')

%% Write data for ANOVA
if (length(args.monkey) > 1) %don't save stats for single monkeys
  writeFile = [ROOTDIR_STAT, 'Fig03-VisResponse\', args.area,'-', parmName,'-NoTST.mat'];
  writeData( param , writeFile , 'ttest' )
end

end%util:plotDistrParamSAT()


function [ ] = writeData( param , writeFile , varargin )

args = getopt(varargin, {'ttest'});

N_MORE_EFF = length(param.AccMore);
N_LESS_EFF = length(param.AccLess);
N_CELL = N_MORE_EFF + N_LESS_EFF;

%dependent variable
DV_Parameter = [ param.AccMore param.AccLess param.FastMore param.FastLess ]';

%factors
F_Condition = [ ones(1,N_CELL) 2*ones(1,N_CELL) ]';
F_Efficiency = [ ones(1,N_MORE_EFF) 2*ones(1,N_LESS_EFF) ones(1,N_MORE_EFF) 2*ones(1,N_LESS_EFF) ]';
F_Neuron = [ (1:N_CELL) , (1:N_CELL) ]';

%write data
save(writeFile, 'DV_Parameter','F_Condition','F_Efficiency','F_Neuron')

%if desired, perform separate t-tests for main effect of SAT condition
%during more efficient and less efficient search
if (args.ttest)
  fprintf('More efficient:\n')
  ttestTom(param.AccMore, param.FastMore)
  fprintf('\nLess efficient:\n')
  ttestTom(param.AccLess, param.FastLess)
end

end%util:writeData()





