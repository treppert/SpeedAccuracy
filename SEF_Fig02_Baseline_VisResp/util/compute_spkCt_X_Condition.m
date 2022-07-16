function [ varargout ] = compute_spkCt_X_Condition( behavData , unitData , varargin )
%compute_spkCt_X_Condition Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'interval=',[-600 50]}, {'monkey=',{'D','E'}}, {'area=',{'SEF'}}});

IDX_TEST = 3500 + args.interval;

idxArea = ismember(unitData.Area, args.area);
idxMonkey = ismember(unitData.Monkey, args.monkey);
idxVisUnit = (unitData.Grade_Vis >= 3);

idxTest = (idxArea & idxMonkey & idxVisUnit);
unitTest = unitData(idxTest,:);
NUM_UNIT = sum(idxTest);

%initialize spike count
spkCt_Acc = NaN(NUM_UNIT,1);
spkCt_Fast = spkCt_Acc;
%initialize vector for significance (p-value of Mann-Whitney)
pvalMW = NaN(NUM_UNIT,1);

for uu = 1:NUM_UNIT
  kk = ismember(behavData.Task_Session, unitTest.Session(uu));
  
  %compute spike count for all trials
  spikes_uu = load_spikes_SAT(unitTest.Index(uu));
  spkCt_uu = cellfun(@(x) sum((x > IDX_TEST(1)) & (x < IDX_TEST(2))), spikes_uu);
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitTest.TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  
  %compute z-scored spike count
%   spkCt_uu(~idxIso) = zscore(spkCt_uu(~idxIso));
  
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);
  
  scAcc_uu = spkCt_uu(idxAcc);    spkCt_Acc(uu) = mean(scAcc_uu);
  scFast_uu = spkCt_uu(idxFast);  spkCt_Fast(uu) = mean(scFast_uu);
  
  pvalMW(uu) = ranksum(scAcc_uu, scFast_uu, 'tail','both');

end % for : unit (uu)

if (nargout > 0) %return MW test levels of significance
  varargout{1} = pvalMW;
  if (nargout > 1) %return vector of spike count differences
    varargout{2} = spkCt_Fast - spkCt_Acc;
  end
end

%% Plotting
figure()
BINEDGES_1 = linspace(0, 50, 10);
BINEDGES_2 = linspace(-10, 10, 10);
GREEN = [0 .7 0];
GRAY = [.5 .5 .5];

subplot(1,2,1); hold on
histogram(spkCt_Acc, 'FaceColor','r', 'FaceAlpha',0.5, 'BinEdges',BINEDGES_1)
histogram(spkCt_Fast, 'FaceColor',GREEN, 'FaceAlpha',0.5, 'BinEdges',BINEDGES_1)
xlabel('Spike count')

subplot(1,2,2); hold on
histogram(spkCt_Fast - spkCt_Acc, 'FaceColor',GRAY, 'BinEdges',BINEDGES_2);
xlabel('Spike count difference')

ppretty([3,1.4])
subplot(1,2,1); set(gca, 'yminortick','off')
subplot(1,2,2); set(gca, 'yminortick','off')

end % fxn : compute_spkCt_X_Condition

