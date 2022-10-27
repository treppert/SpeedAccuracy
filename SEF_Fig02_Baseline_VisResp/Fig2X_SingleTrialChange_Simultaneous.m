% function [ ] = Fig2X_SingleTrialChange_Simultaneous( behavData , unitData , spkCorr_ )
%Fig2X_SingleTrialChange_Simultaneous Summary of this function goes here
%   Detailed explanation goes here

DEBUG = false;
TLIM_COUNT = [+50,+400] + 3500;
% TLIM_COUNT = [-600,+50] + 3500;
tableSwitch = identify_condition_switch(behavData);
rscAcc = spkCorr_.Acc;

unitX = unitData(rscAcc.X_Index,1:25);
unitY = unitData(rscAcc.Y_Index,1:25);

%criteria for pairs to assess
i_Monkey = ismember(rscAcc.Monkey, {'D','E'}); %{'D','E'}
i_yArea = ismember(rscAcc.Y_Area, {'FEF','SC'}); %{'SC','FEF'}
i_xGradeVis = ismember(unitX.Grade_Vis, [+3,+4]);
i_yGradeVis = ismember(unitY.Grade_Vis, [+3,+4]);
i_xSATeffect = ismember(unitX.SAT_Effect(:,2), +1);
i_ySATeffect = ismember(unitY.SAT_Effect(:,2), +1);
idxPairKeep = (i_Monkey & i_yArea & i_xGradeVis & i_yGradeVis & ...
  i_xSATeffect & i_ySATeffect);

rscAcc = rscAcc(idxPairKeep,:);
nPair = size(rscAcc,1);

dA_X = NaN(nPair,2);  %SEF (mean single-trial modulation A2F|F2A)
dA_Y = dA_X;          %FEF/SC

pval_rtest = NaN(nPair,2); %p-value for Rayleigh test of circular uniformity (A2F|F2A)
dRT = NaN(nPair,2); %magnitude of change in at condition switch

for p = 1:nPair
  uX = rscAcc.X_Index(p); %SEF unit no.
  uY = rscAcc.Y_Index(p); %FEF/SC unit no.
  yArea = rscAcc.Y_Area{p}; %FEF or SC
  k = unitData.SessionIndex(uX); %Session no.
  RTk = double(behavData.Sacc_RT{k}); %response time

  %index by condition
  idxAcc = (behavData.Task_SATCondition{k} == 1);   trialAcc = find(idxAcc);
  idxFast = (behavData.Task_SATCondition{k} == 3);  trialFast = find(idxFast);
  %index by trial number
  jjA2F = tableSwitch.A2F; %trials with switch Acc to Fast
  jjF2A = tableSwitch.F2A; %trials with switch Fast to Acc
  jjA2F_pre = jjA2F{k} - 1;  jjA2F_post = jjA2F{k};
  jjF2A_pre = jjF2A{k} - 1;  jjF2A_post = jjF2A{k};

  %compute dRT at condition switch
  dRT_A2F_p = RTk(jjA2F_post) - RTk(jjA2F_pre);
  dRT_F2A_p = RTk(jjF2A_post) - RTk(jjF2A_pre);

  %compute spike count for all trials
  spikes_X = load_spikes_SAT(unitData.Index(uX));
  spikes_Y = load_spikes_SAT(unitData.Index(uY));
  spkCt_X = cellfun(@(x) sum((x > TLIM_COUNT(1)) & (x < TLIM_COUNT(2))), spikes_X);
  spkCt_Y = cellfun(@(x) sum((x > TLIM_COUNT(1)) & (x < TLIM_COUNT(2))), spikes_Y);

  %z-score spike counts
  spkCt_X(idxAcc | idxFast) = zscore(spkCt_X(idxAcc | idxFast));
  spkCt_Y(idxAcc | idxFast) = zscore(spkCt_Y(idxAcc | idxFast));

  if (DEBUG)
%     figure(); hold on
%     histogram(spkCt_X(idxAcc | idxFast), 20, 'FaceColor','k')
%     histogram(spkCt_Y(idxAcc | idxFast), 20, 'FaceColor','b')
%     ylabel('Number of trials'); xlabel('Spike count')
%     legend({'SEF',yArea})
%     ppretty([4,2])
  end

  %compute change in spike count at condition switch
  dA_X_p_A2F = spkCt_X(jjA2F_post) - spkCt_X(jjA2F_pre);
  dA_Y_p_A2F = spkCt_Y(jjA2F_post) - spkCt_Y(jjA2F_pre);
  dA_X_p_F2A = spkCt_X(jjF2A_post) - spkCt_X(jjF2A_pre);
  dA_Y_p_F2A = spkCt_Y(jjF2A_post) - spkCt_Y(jjF2A_pre);
  nA2F = numel(dA_X_p_A2F);

  if (DEBUG)
%     pairID = [rscAcc.PairID{p}(1:4),' ',rscAcc.PairID{p}(6:9)];
%     figure(); hold on; title(pairID)
%     scatter(dA_X_p_A2F, dA_Y_p_A2F, 20, [0 .6 0], 'filled', 'o', 'MarkerFaceAlpha',.5)
%     scatter(dA_X_p_F2A, dA_Y_p_F2A, 20, 'r', 'filled', 'o', 'MarkerFaceAlpha',.5)
%     scatter(mean(dA_X_p_A2F), mean(dA_Y_p_A2F), 40, [0 .3 0], 'filled', 'o')
%     scatter(mean(dA_X_p_F2A), mean(dA_Y_p_F2A), 40, [.5 0 0], 'filled', 'o')
%     plot([-4 +4],[0 0], 'k--'); plot([0 0],[-4 +4], 'k--')
%     axis equal
%     xlabel('SEF single-trial change (z)')
%     ylabel([yArea,' single-trial change (z)'])
  end

  %correlation between dRT and dA_X/dA_Y
  [~,pval_X_A2F] = corr(dRT_A2F_p, dA_X_p_A2F, 'type','Pearson');
  [~,pval_X_F2A] = corr(dRT_F2A_p, dA_X_p_F2A, 'type','Pearson');
  [~,pval_Y_A2F] = corr(dRT_A2F_p, dA_Y_p_A2F, 'type','Pearson');
  [~,pval_Y_F2A] = corr(dRT_F2A_p, dA_Y_p_F2A, 'type','Pearson');

  if (DEBUG)
    figure()
    subplot(2,2,1); hold on; title(['PAIR ',rscAcc.PairID{p}(6:9),'  SEF - A2F'])
    scatter(dRT_A2F_p, dA_X_p_A2F, 20, [0 .6 0], 'filled', 'o', 'MarkerFaceAlpha',.5)
    text(0,0,['p = ',num2str(pval_X_A2F)])
    ylabel('Change in spike count (z)')

    subplot(2,2,2); hold on; title('SEF - F2A')
    scatter(dRT_F2A_p, dA_X_p_F2A, 20, 'r', 'filled', 'o', 'MarkerFaceAlpha',.5)
    text(0,0,num2str(pval_X_F2A))

    subplot(2,2,3); hold on; title([yArea,' - A2F'])
    scatter(dRT_A2F_p, dA_Y_p_A2F, 20, [0 .6 0], 'filled', 'o', 'MarkerFaceAlpha',.5)
    xlabel('Change in RT (ms)'); ylabel('Change in spike count (z)')
    text(0,0,num2str(pval_Y_A2F))

    subplot(2,2,4); hold on; title([yArea,' - F2A'])
    scatter(dRT_F2A_p, dA_Y_p_F2A, 20, 'r', 'filled', 'o', 'MarkerFaceAlpha',.5)
    xlabel('Change in RT (ms)')
    text(0,0,num2str(pval_Y_F2A))
  end

  dA_X(p,:) = [mean(dA_X_p_A2F) , mean(dA_X_p_F2A)]; %A2F|F2A
  dA_Y(p,:) = [mean(dA_Y_p_A2F) , mean(dA_Y_p_F2A)];

  %compute vector angles for Rayleigh (circular) test
  theta_A2F_p = atan2(dA_Y_p_A2F,dA_X_p_A2F);
  theta_F2A_p = atan2(dA_Y_p_F2A,dA_X_p_F2A);
  pval_rtest(p,1) = circ_rtest(theta_A2F_p);
  pval_rtest(p,2) = circ_rtest(theta_F2A_p);

end % for : pair(p)

%% Plotting
GREEN = [0 .7 0];
XLIM = [-1.5,+1.5];

figure(); hold on %scatterplot (FEF/SC vs SEF)
scatter(dA_X(:,1), dA_Y(:,1), 10, GREEN, 'filled', 'o') %A2F
scatter(dA_X(:,2), dA_Y(:,2), 10, 'r', 'filled', 'o') %F2A
plot([-1 +1],[0 0], 'k--'); plot([0 0],[-1 +1], 'k--')
xlabel('SEF single-trial change (z)')
ylabel('FEF/SC single-trial change (z)')
xlim(XLIM); ylim(XLIM)

ppretty([2,1.6])

clear i_* idx* dA_* spkCt_* spkes_* jj* k p nPair
% end % fxn : Fig2X_SingleTrialChange_Simultaneous()
