function [ effectSAT ] = compute_spkCt_X_Condition( behavData , unitData , varargin )
%compute_spkCt_X_Condition Summary of this function goes here
%   Detailed explanation goes here

IDX_BASELINE = 3500 + [-600,+50];
IDX_VISRESP  = 3500 + [+50,+400];
GREEN = [0 .7 0];
DEBUG = false;

NUM_UNIT = size(unitData,1);

%initialize spike count
spkCt_Acc = NaN(NUM_UNIT,2); % baseline | visual response
spkCt_Fast = spkCt_Acc;
%initialize vector for significance (p-value of Mann-Whitney)
pvalMW = NaN(NUM_UNIT,2);
%initialize signed SAT effect array [+1 = F>A] [-1 = A>F]
effectSAT = NaN(NUM_UNIT,2);

for uu = 1:NUM_UNIT
  kk = unitData.SessionIndex(uu);
  
  %compute spike count for all trials
  spikes_uu = load_spikes_SAT(unitData.Index(uu));
  spkCt_BL_uu = cellfun(@(x) sum((x > IDX_BASELINE(1)) & (x < IDX_BASELINE(2))), spikes_uu);
  spkCt_VR_uu = cellfun(@(x) sum((x > IDX_VISRESP(1))  & (x < IDX_VISRESP(2))), spikes_uu);
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitData.TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  
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

  if (DEBUG)
    figure()
    subplot(1,2,1); hold on
    histogram(scAcc_BL_uu, 'FaceColor','r'); histogram(scFast_BL_uu, 'FaceColor',GREEN)
    xlabel('BL spike count'); ylabel('No. of trials'); title(unitData.ID{uu})
    subplot(1,2,2); hold on
    histogram(scAcc_VR_uu, 'FaceColor','r'); histogram(scFast_VR_uu, 'FaceColor',GREEN)
    xlabel('VR spike count')
    ppretty([4.8,1.4])
  end

end % for : unit (uu)

dSpkCt = spkCt_Fast - spkCt_Acc; %differences in spike count
effectSize = (spkCt_Fast - spkCt_Acc) ./ (spkCt_Fast + spkCt_Acc);

%% Compute significance and effect size at level of single neurons
%Note - Currently only marking neurons that meet required significance AND
%effect size threshold
P_LEVEL = .05;
T_EFFECT = .04; %threshold for custom effect size
idxSig_BL = (pvalMW(:,1) <= P_LEVEL);
idxSig_VR = (pvalMW(:,2) <= P_LEVEL);
idxEffSize_BL = (abs(effectSize(:,1)) >= T_EFFECT);
idxEffSize_VR = (abs(effectSize(:,2)) >= T_EFFECT);
idxBL_FgA = (idxSig_BL & idxEffSize_BL & (dSpkCt(:,1) > 0)); effectSAT(idxBL_FgA,1) = 1; %1=F>A
idxBL_AgF = (idxSig_BL & idxEffSize_BL & (dSpkCt(:,1) < 0)); effectSAT(idxBL_AgF,1) = 2; %2=A>F
idxVR_FgA = (idxSig_VR & idxEffSize_VR & (dSpkCt(:,2) > 0)); effectSAT(idxVR_FgA,2) = 1;
idxVR_AgF = (idxSig_VR & idxEffSize_VR & (dSpkCt(:,2) < 0)); effectSAT(idxVR_AgF,2) = 2;

%% Plotting
figure(); NUMBIN = 51; %SAT effect size
subplot(1,2,1); hold on; title('Baseline'); xlabel('Effect size'); ylabel('No. of neurons')
histogram(effectSize(~idxSig_BL,1), 'FaceColor','k', 'BinEdges',linspace(-.4,+.6, NUMBIN))
histogram(effectSize( idxSig_BL,1), 'FaceColor','b', 'BinEdges',linspace(-.4,+.6, NUMBIN))
subplot(1,2,2); hold on; title('Visual response'); xlabel('Effect size')
histogram(effectSize(~idxSig_VR,2), 'FaceColor','k', 'BinEdges',linspace(-.4,+.6, NUMBIN))
histogram(effectSize( idxSig_VR,2), 'FaceColor','b', 'BinEdges',linspace(-.4,+.6, NUMBIN))
ppretty([6,1])

figure() %histograms
BINEDGES_1 = linspace(0, 50, 10);
BINEDGES_2 = linspace(-10, 10, 10);
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
