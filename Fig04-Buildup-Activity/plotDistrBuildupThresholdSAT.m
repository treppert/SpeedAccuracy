function [ ] = plotDistrBuildupThresholdSAT( ninfo , nstats , varargin )
%plotDistrBuildupThresholdSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});
ROOTDIR_STAT = 'C:\Users\Thomas Reppert\Dropbox\SAT\Stats\';

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxMove = ([ninfo.moveGrade] >= 2);
idxEfficiency = ([ninfo.taskType] == 1);

idxKeep = (idxArea & idxMonkey & idxMove);

ninfo = ninfo(idxKeep);
nstats = nstats(idxKeep);
NUM_CELLS = sum(idxKeep);

threshAccCorr =  [nstats.A_Buildup_Threshold_AccCorr];
threshAccErr =  [nstats.A_Buildup_Threshold_AccErr];
threshFastCorr = [nstats.A_Buildup_Threshold_FastCorr];
threshFastErr = [nstats.A_Buildup_Threshold_FastErr];

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
  for cc = 1:(4*NUM_CELLS)
    structOut.Condition(cc) = Condition(cc);
    structOut.Efficiency(cc) = Outcome(cc);
  end
  save([ROOTDIR_STAT, args.area,'-BuildupActivity.mat'], 'structOut')
end

end%fxn:plotDistrBuildupThresholdSAT()

