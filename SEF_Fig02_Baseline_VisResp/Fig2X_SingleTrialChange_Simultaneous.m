% function [ ] = Fig2X_SingleTrialChange_Simultaneous( behavData , unitData , spkCorr_ )
%Fig2X_SingleTrialChange_Simultaneous Summary of this function goes here
%   Detailed explanation goes here

DEBUG = false;
TLIM_VR = [+50,+400] + 3500;
tableSwitch = identify_condition_switch(behavData);
rscAcc = spkCorr_.Acc;

%criteria for pairs to assess
i_Monkey = ismember(rscAcc.Monkey, {'D'}); %{'D','E'}
i_yArea = ismember(rscAcc.Y_Area, {'FEF'}); %{'SC','FEF'}
i_xGradeVis = ismember(rscAcc.X_Grade_Vis, [+3,+4]);
i_yGradeVis = ismember(rscAcc.Y_Grade_Vis, [+3,+4]);
idxPairKeep = (i_Monkey & i_yArea & i_xGradeVis & i_yGradeVis);

rscAcc = rscAcc(idxPairKeep,:);
nPair = size(rscAcc,1);

dA_X = NaN(nPair,2);  %SEF (mean single-trial modulation A2F|F2A)
dA_Y = dA_X;          %FEF/SC

for p = 1:nPair
  uX = rscAcc.X_Index(p); %SEF unit no.
  uY = rscAcc.Y_Index(p); %FEF/SC unit no.
  k = unitData.SessionIndex(uX); %Session no.

  %index by isolation quality
  idxIso = removeTrials_Isolation(unitData.TrialRemoveSAT{uX}, behavData.Task_NumTrials(k));
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{k} == 1) & ~idxIso);   trialAcc = find(idxAcc);
  idxFast = ((behavData.Task_SATCondition{k} == 3) & ~idxIso);  trialFast = find(idxFast);
  %index by trial number
  jjA2F = tableSwitch.A2F; %trials with switch Acc to Fast
  jjF2A = tableSwitch.F2A; %trials with switch Fast to Acc
  jjA2F_pre  = intersect(trialAcc,  jjA2F{k} - 1); %Acc->Fast pre-change
  jjA2F_post = intersect(trialFast, jjA2F{k} + 0); %Acc->Fast post-change
  jjF2A_pre  = intersect(trialFast, jjF2A{k} - 1);
  jjF2A_post = intersect(trialAcc,  jjF2A{k} + 0);
  if (numel(jjF2A_pre) ~= numel(jjF2A_post))
    jjF2A_post(1) = []; %"stitch" fix for a single session (k=7)
  end

  %compute spike count for all trials
  spikes_X = load_spikes_SAT(unitData.Index(uX));
  spikes_Y = load_spikes_SAT(unitData.Index(uY));
  spkCt_X = cellfun(@(x) sum((x > TLIM_VR(1)) & (x < TLIM_VR(2))), spikes_X);
  spkCt_Y = cellfun(@(x) sum((x > TLIM_VR(1)) & (x < TLIM_VR(2))), spikes_Y);

  if (DEBUG)
    figure(); hold on
    histogram(spkCt_X(~idxIso), 20, 'FaceColor','k')
    histogram(spkCt_Y(~idxIso), 20, 'FaceColor','m')
    ppretty([4,2])
  end

  %compute z-scored spike count
  spkCt_X(~idxIso) = zscore(spkCt_X(~idxIso));
  spkCt_Y(~idxIso) = zscore(spkCt_Y(~idxIso));
  
  %compute change in spike count at condition switch
  dA_X_p_A2F = spkCt_X(jjA2F_post) - spkCt_X(jjA2F_pre);
  dA_Y_p_A2F = spkCt_Y(jjA2F_post) - spkCt_Y(jjA2F_pre);
  dA_X_p_F2A = spkCt_X(jjF2A_post) - spkCt_X(jjF2A_pre);
  dA_Y_p_F2A = spkCt_Y(jjF2A_post) - spkCt_Y(jjF2A_pre);

  if (DEBUG)
    figure(); hold on; title(rscAcc.PairID{p})
    scatter(dA_X_p_A2F, dA_Y_p_A2F, 10, GREEN, 'filled', 'o')
    scatter(dA_X_p_F2A, dA_Y_p_F2A, 10, 'r', 'filled', 'o')
    xlabel('SEF single-trial change (z)')
    ylabel('FEF/SC single-trial change (z)')
  end

  dA_X(p,:) = [mean(dA_X_p_A2F) , mean(dA_X_p_F2A)]; %A2F|F2A
  dA_Y(p,:) = [mean(dA_Y_p_A2F) , mean(dA_Y_p_F2A)];

end % for : pair(p)


figure()
GREEN = [0 .7 0];
XLIM = [-1.2,+1.2];

subplot(1,3,1); hold on %scatterplot (FEF/SC vs SEF)
scatter(dA_X(:,1), dA_Y(:,1), 10, GREEN, 'filled', 'o') %A2F
scatter(dA_X(:,2), dA_Y(:,2), 10, 'r', 'filled', 'o') %F2A
xlabel('SEF single-trial change (z)')
ylabel('FEF/SC single-trial change (z)')
xlim(XLIM); ylim(XLIM)

subplot(1,3,2); hold on %histogram (SEF)
histogram(dA_X(:,1), 'BinEdges',linspace(XLIM(1), XLIM(2), 21), 'FaceColor','black', 'EdgeColor',GREEN) %A2F
histogram(dA_X(:,2), 'BinEdges',linspace(XLIM(1), XLIM(2), 21), 'FaceColor','black', 'EdgeColor','r') %F2A
xlabel('SEF single-trial change (z)')

subplot(1,3,3); hold on %histogram (FEF/SC)
histogram(dA_Y(:,1), 'BinEdges',linspace(XLIM(1), XLIM(2), 21), 'FaceColor','black', 'EdgeColor',GREEN)
histogram(dA_Y(:,2), 'BinEdges',linspace(XLIM(1), XLIM(2), 21), 'FaceColor','black', 'EdgeColor','r')
xlabel('FEF/SC single-trial change (z)')

ppretty([8,1.6])

clear i_* idx* dA_* spkCt_* spkes_* jj* k p nPair
% end % fxn : Fig2X_SingleTrialChange_Simultaneous()