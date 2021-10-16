function [ ] = plotDistrBuildupThresholdSAT( unitData , unitData , varargin )
%plotDistrBuildupThresholdSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});
ROOTDIR_STAT = 'C:\Users\Thomas Reppert\Dropbox\SAT\Stats\';

idxArea = ismember(unitData.aArea, args.area);
idxMonkey = ismember(unitData.aMonkey, args.monkey);
idxMove = (unitData.Basic_MovGrade >= 2);
idxEfficiency = (unitData.Task_LevelDifficulty == 1);

idxKeep = (idxArea & idxMonkey & idxMove);

unitData = unitData(idxKeep);
unitData = unitData(idxKeep);
NUM_CELLS = sum(idxKeep);

threshAccCorr =  [unitData.Buildup_Correct(1)];
threshAccErr =  [unitData.Buildup_Error(1)];
threshFastCorr = [unitData.Buildup_Correct(2)];
threshFastErr = [unitData.Buildup_Error(2)];

%% Plots of absolute values
meanAccCorr = nanmean(threshAccCorr);      SEAccCorr = nanstd(threshAccCorr)/sqrt(NUM_CELLS);
meanAccErr = nanmean(threshAccErr);    SEAccErr = nanstd(threshAccErr)/sqrt(NUM_CELLS);
meanFastCorr = nanmean(threshFastCorr);    SEFastCorr = nanstd(threshFastCorr)/sqrt(NUM_CELLS);
meanFastErr = nanmean(threshFastErr);  SEFastErr = nanstd(threshFastErr)/sqrt(sum(~isnan(threshFastErr)));

%barplot
figure(); hold on
bar(1, meanFastCorr, 0.7, 'FaceColor',[0 .7 0], 'LineStyle',':')
bar(2, meanFastErr, 0.7, 'FaceColor',[0 .7 0])
bar(3, meanAccCorr, 0.7, 'FaceColor','r', 'LineStyle',':')
bar(4, meanAccErr, 0.7, 'FaceColor','r')
errorbar([meanFastCorr meanFastErr meanAccCorr meanAccErr], [SEFastCorr SEFastErr SEAccCorr SEAccErr], 'Color','k', 'CapSize',0)
xticks([]); xticklabels([])
ylabel('Threshold (sp/s)')
ppretty([1,2])
pause(0.1)

%% Plots of difference between conditions
threshDiffCorr = threshFastCorr - threshAccCorr;
threshDiffErr = threshFastErr - threshAccErr;

%CDF of difference between task conditions
figure(); hold on
cdfplotTR(threshDiffCorr, 'Color','k')
cdfplotTR(threshDiffErr, 'Color','k', 'LineStyle',':')
plot([0 0], [0 1], 'k:')
ylim([0 1]); ytickformat('%2.1f')
xlabel('Threshold difference (sp/s)')
ylabel('Cumulative probability')
ppretty([4.8,3])

%% Prep for ANOVA
if (length(args.monkey) > 1) %don't save stats for single monkeys
  Neuron = [(1:NUM_CELLS), (1:NUM_CELLS), (1:NUM_CELLS), (1:NUM_CELLS)]';
  Condition = cell(4*NUM_CELLS,1); Condition(1:2*NUM_CELLS) = {'Accurate'}; Condition(2*NUM_CELLS+1:end) = {'Fast'};
  Outcome = cell(2*NUM_CELLS,1); Outcome(1:NUM_CELLS) = {'Correct'}; Outcome(NUM_CELLS+1:end) = {'Error'}; Outcome = [Outcome; Outcome];
  Threshold = [threshAccCorr threshAccErr threshFastCorr threshFastErr]';
  structOut = struct('Neuron',Neuron', 'Parameter',Threshold');
  for uu = 1:(4*NUM_CELLS)
    structOut.Condition(uu) = Condition(uu);
    structOut.Efficiency(uu) = Outcome(uu);
  end
  save([ROOTDIR_STAT, args.area,'-BuildupActivity.mat'], 'structOut')
end

end%fxn:plotDistrBuildupThresholdSAT()

