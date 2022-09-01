function [ effectSAT ] = compute_spkCt_X_Condition( behavData , unitTest , varargin )
%compute_spkCt_X_Condition Summary of this function goes here
%   Detailed explanation goes here

IDX_BASELINE = 3500 + [-600,+50];
IDX_VISRESP  = 3500 + [+50,+400];

NUM_UNIT = size(unitTest,1);

%initialize spike count
spkCt_Acc = NaN(NUM_UNIT,2); % baseline | visual response
spkCt_Fast = spkCt_Acc;
%initialize vector for significance (p-value of Mann-Whitney)
pvalMW = NaN(NUM_UNIT,2);
%initialize signed SAT effect array [+1 = F>A] [-1 = A>F]
effectSAT = NaN(NUM_UNIT,2);

for uu = 1:NUM_UNIT
  kk = unitTest.SessionIndex(uu);
  
  %compute spike count for all trials
  spikes_uu = load_spikes_SAT(unitTest.Index(uu));
  spkCt_BL_uu = cellfun(@(x) sum((x > IDX_BASELINE(1)) & (x < IDX_BASELINE(2))), spikes_uu);
  spkCt_VR_uu = cellfun(@(x) sum((x > IDX_VISRESP(1))  & (x < IDX_VISRESP(2))), spikes_uu);
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitTest.TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);
  
  %compute mean spike count by condition
  scAcc_BL_uu = spkCt_BL_uu(idxAcc);    spkCt_Acc(uu,1) = mean(scAcc_BL_uu);
  scFast_BL_uu = spkCt_BL_uu(idxFast);  spkCt_Fast(uu,1) = mean(scFast_BL_uu);
  scAcc_VR_uu = spkCt_VR_uu(idxAcc);    spkCt_Acc(uu,2) = mean(scAcc_VR_uu);
  scFast_VR_uu = spkCt_VR_uu(idxFast);  spkCt_Fast(uu,2) = mean(scFast_VR_uu);
  
  pvalMW(uu,1) = ranksum(scAcc_BL_uu, scFast_BL_uu, 'tail','both');
  pvalMW(uu,2) = ranksum(scAcc_VR_uu, scFast_VR_uu, 'tail','both');

end % for : unit (uu)

dSpkCt = spkCt_Fast - spkCt_Acc; %differences in spike count
effectSize = (spkCt_Fast - spkCt_Acc) ./ (spkCt_Fast + spkCt_Acc);

%% Compute significance at level of single neurons
P_LEVEL = .05;
idxBL_FgA = ((pvalMW(:,1) <= P_LEVEL) & (dSpkCt(:,1) > 0)); effectSAT(idxBL_FgA,1) = +1;
idxBL_AgF = ((pvalMW(:,1) <= P_LEVEL) & (dSpkCt(:,1) < 0)); effectSAT(idxBL_AgF,1) = -1;
idxVR_FgA = ((pvalMW(:,2) <= P_LEVEL) & (dSpkCt(:,2) > 0)); effectSAT(idxVR_FgA,2) = +1;
idxVR_AgF = ((pvalMW(:,2) <= P_LEVEL) & (dSpkCt(:,2) < 0)); effectSAT(idxVR_AgF,2) = -1;

%% Plotting

figure() %normalized SAT effect size
subplot(1,2,1); hold on; title('Baseline')
histogram(effectSize(:,1), 'FaceColor','b', 'BinEdges',linspace(-.4,+.6, 21))
subplot(1,2,2); hold on; title('Visual response')
histogram(effectSize(:,2), 'FaceColor','b', 'BinEdges',linspace(-.4,+.6, 21))
ppretty([4,1])

figure() %histograms
BINEDGES_1 = linspace(0, 50, 10);
BINEDGES_2 = linspace(-10, 10, 10);
GREEN = [0 .7 0];
GRAY = [.5 .5 .5];

subplot(1,4,1); hold on; title('Baseline')
histogram(spkCt_Acc(:,1), 'FaceColor','r', 'FaceAlpha',0.5, 'BinEdges',BINEDGES_1)
histogram(spkCt_Fast(:,1), 'FaceColor',GREEN, 'FaceAlpha',0.5, 'BinEdges',BINEDGES_1)
xlabel('Spike count')
subplot(1,4,2); hold on
histogram(spkCt_Fast(:,1) - spkCt_Acc(:,1), 'FaceColor',GRAY, 'BinEdges',BINEDGES_2);
xlabel('Spike count difference')

subplot(1,4,3); hold on; title('Visual response')
histogram(spkCt_Acc(:,2), 'FaceColor','r', 'FaceAlpha',0.5, 'BinEdges',BINEDGES_1)
histogram(spkCt_Fast(:,2), 'FaceColor',GREEN, 'FaceAlpha',0.5, 'BinEdges',BINEDGES_1)
xlabel('Spike count')
subplot(1,4,4); hold on
histogram(spkCt_Fast(:,2) - spkCt_Acc(:,2), 'FaceColor',GRAY, 'BinEdges',BINEDGES_2);
xlabel('Spike count difference')

ppretty([7,1])
for ii = 1:4
  subplot(1,4,ii); set(gca, 'yminortick','off')
end

end % fxn : compute_spkCt_X_Condition
