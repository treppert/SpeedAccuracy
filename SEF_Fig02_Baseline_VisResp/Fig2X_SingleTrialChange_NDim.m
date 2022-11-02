% function [ ] = Fig2X_SingleTrialChange_NDim( behavData , unitData , spkCorr_ )
%Fig2X_SingleTrialChange_Simultaneous Summary of this function goes here
%   Detailed explanation goes here

DEBUG = true;
GREEN = [0 .7 0];
TLIM_COUNT = [+50,+400] + 3500;
tableSwitch = identify_condition_switch(behavData);

%Gather unit numbers for all groups of neurons SEF-FEF-SC
grp{1} = [39 31 35]'; %D20130828 (SEF FEF FEF)
grp{2} = [40 31 35]'; %D20130828 (SEF FEF FEF)
grp{3} = [93 89 98]'; %D20130926 (SEF FEF SC)
grp{4} = [94 89 98]'; %D20130926 (SEF FEF SC)
grp{5} = [114 117 119]'; %E20130829 (SEF SEF SC)
nGroup = numel(grp);

dA_A2F = NaN(nGroup,3); %X|Y|Z neurons
dA_F2A = dA_A2F;

 for g = 3:3%1:nGroup
  uX = grp{g}(1);   areaX = unitData.Area{uX}; %unit numbers and areas
  uY = grp{g}(2);   areaY = unitData.Area{uY};
  uZ = grp{g}(3);   areaZ = unitData.Area{uZ};
  k = unitData.SessionIndex(uX); %session no.
  kName = unitData.Session{uX}; %session name

  %index by isolation quality
  idxIso = removeTrials_Isolation(unitData.TrialRemoveSAT{uX}, behavData.Task_NumTrials(k));
  %index by condition
  idxAcc = (behavData.Task_SATCondition{k} == 1);   trialAcc = find(idxAcc);
  idxFast = (behavData.Task_SATCondition{k} == 3);  trialFast = find(idxFast);
  %index by trial number
  jjA2F = tableSwitch.A2F; %trials with switch Acc to Fast
  jjF2A = tableSwitch.F2A; %trials with switch Fast to Acc
  jjA2F_pre = jjA2F{k} - 1;  jjA2F_post = jjA2F{k};
  jjF2A_pre = jjF2A{k} - 1;  jjF2A_post = jjF2A{k};

  %compute spike count for all trials
  spikes_X = load_spikes_SAT(uX);
  spikes_Y = load_spikes_SAT(uY);
  spikes_Z = load_spikes_SAT(uZ);

  spkCt_X = cellfun(@(x) sum((x > TLIM_COUNT(1)) & (x < TLIM_COUNT(2))), spikes_X);
  spkCt_Y = cellfun(@(x) sum((x > TLIM_COUNT(1)) & (x < TLIM_COUNT(2))), spikes_Y);
  spkCt_Z = cellfun(@(x) sum((x > TLIM_COUNT(1)) & (x < TLIM_COUNT(2))), spikes_Z);

  %z-score spike counts
  spkCt_X(idxAcc | idxFast) = zscore(spkCt_X(idxAcc | idxFast));
  spkCt_Y(idxAcc | idxFast) = zscore(spkCt_Y(idxAcc | idxFast));
  spkCt_Z(idxAcc | idxFast) = zscore(spkCt_Z(idxAcc | idxFast));

  if (DEBUG)
%     figure(); hold on
%     histogram(spkCt_X(idxAcc | idxFast), DOTSIZE, 'FaceColor','k')
%     histogram(spkCt_Y(idxAcc | idxFast), DOTSIZE, 'FaceColor','b')
%     histogram(spkCt_Z(idxAcc | idxFast), DOTSIZE, 'FaceColor','m')
%     ylabel('Number of trials'); xlabel('Spike count (all trials)')
%     legend({areaX,areaY,areaZ})
%     ppretty([4,2])
  end

  %compute change in spike count at condition switch
  dA_X_p_A2F = spkCt_X(jjA2F_post) - spkCt_X(jjA2F_pre);
  dA_Y_p_A2F = spkCt_Y(jjA2F_post) - spkCt_Y(jjA2F_pre);
  dA_Z_p_A2F = spkCt_Z(jjA2F_post) - spkCt_Z(jjA2F_pre);
  dA_X_p_F2A = spkCt_X(jjF2A_post) - spkCt_X(jjF2A_pre);
  dA_Y_p_F2A = spkCt_Y(jjF2A_post) - spkCt_Y(jjF2A_pre);
  dA_Z_p_F2A = spkCt_Z(jjF2A_post) - spkCt_Z(jjF2A_pre);

  if (DEBUG)
    AXLIM = [-5,+5];  DOTSIZE = 20;  LARGESIZE = 40;
    figure() %3D scatter plot
    scatter3(dA_X_p_A2F, dA_Y_p_A2F, dA_Z_p_A2F, DOTSIZE, GREEN, 'filled', 'o', 'MarkerFaceAlpha',.5)
    hold on; view(-30,10); title([kName,' ',areaX,'-',areaY,'-',areaZ])
    scatter3(dA_X_p_F2A, dA_Y_p_F2A, dA_Z_p_F2A, DOTSIZE, 'r', 'filled', 'o', 'MarkerFaceAlpha',.5)
    scatter3(mean(dA_X_p_A2F), mean(dA_Y_p_A2F), mean(dA_Z_p_A2F), LARGESIZE, [0 .3 0], 'filled', 'o')
    scatter3(mean(dA_X_p_F2A), mean(dA_Y_p_F2A), mean(dA_Z_p_F2A), LARGESIZE, [.5 0 0], 'filled', 'o')
    patch([-5 -5 +5 +5], [+5 -5 -5 +5], [0 0 0 0], 'k', 'FaceAlpha',.12)
    patch([-5 -5 +5 +5], [0 0 0 0], [+5 -5 -5 +5], 'k', 'FaceAlpha',.12)
    patch([0 0 0 0], [-5 -5 +5 +5], [+5 -5 -5 +5], 'k', 'FaceAlpha',.12); grid off
    xlabel([areaX,' change (z)']); ylabel([areaY,' change (z)']); zlabel([areaZ,' change (z)'])
    xlim(AXLIM); ylim(AXLIM); zlim(AXLIM)
    ppretty([3,2])

    figure(); subplot(1,3,1); hold on %2D X-Y
    scatter(dA_X_p_A2F, dA_Y_p_A2F, DOTSIZE, GREEN, 'filled', 'o', 'MarkerFaceAlpha',.5)
    scatter(dA_X_p_F2A, dA_Y_p_F2A, DOTSIZE, 'r', 'filled', 'o', 'MarkerFaceAlpha',.5)
    scatter(mean(dA_X_p_A2F), mean(dA_Y_p_A2F), LARGESIZE, [0 .3 0], 'filled', 'o')
    scatter(mean(dA_X_p_F2A), mean(dA_Y_p_F2A), LARGESIZE, [.5 0 0], 'filled', 'o')
    plot(AXLIM,[0 0], 'k--'); plot([0 0],AXLIM, 'k--')
    xlabel([areaX,' change (z)']); ylabel([areaY,' change (z)'])
    xlim(AXLIM); ylim(AXLIM)

    subplot(1,3,2); hold on %2D X-Z
    scatter(dA_X_p_A2F, dA_Z_p_A2F, DOTSIZE, GREEN, 'filled', 'o', 'MarkerFaceAlpha',.5)
    scatter(dA_X_p_F2A, dA_Z_p_F2A, DOTSIZE, 'r', 'filled', 'o', 'MarkerFaceAlpha',.5)
    scatter(mean(dA_X_p_A2F), mean(dA_Z_p_A2F), LARGESIZE, [0 .3 0], 'filled', 'o')
    scatter(mean(dA_X_p_F2A), mean(dA_Z_p_F2A), LARGESIZE, [.5 0 0], 'filled', 'o')
    plot(AXLIM,[0 0], 'k--'); plot([0 0],AXLIM, 'k--')
    xlabel([areaX,' change (z)']); ylabel([areaZ,' change (z)'])
    xlim(AXLIM); ylim(AXLIM)

    subplot(1,3,3); hold on %2D Y-Z
    scatter(dA_Y_p_A2F, dA_Z_p_A2F, DOTSIZE, GREEN, 'filled', 'o', 'MarkerFaceAlpha',.5)
    scatter(dA_Y_p_F2A, dA_Z_p_F2A, DOTSIZE, 'r', 'filled', 'o', 'MarkerFaceAlpha',.5)
    scatter(mean(dA_Y_p_A2F), mean(dA_Z_p_A2F), LARGESIZE, [0 .3 0], 'filled', 'o')
    scatter(mean(dA_Y_p_F2A), mean(dA_Z_p_F2A), LARGESIZE, [.5 0 0], 'filled', 'o')
    plot(AXLIM,[0 0], 'k--'); plot([0 0],AXLIM, 'k--')
    xlabel([areaY,' change (z)']); ylabel([areaZ,' change (z)'])
    xlim(AXLIM); ylim(AXLIM)

    drawnow; ppretty([8,1.6])
  end

  dA_A2F(g,:) = [mean(dA_X_p_A2F), mean(dA_Y_p_A2F), mean(dA_Z_p_A2F)];
  dA_F2A(g,:) = [mean(dA_X_p_F2A), mean(dA_Y_p_F2A), mean(dA_Z_p_F2A)];

end % for : pair(p)

[rho,pval] = corrcoef([dA_X_p_A2F;dA_X_p_F2A] , [dA_Y_p_A2F;dA_Y_p_F2A]);
clearvars -except ROOTDIR_SAT behavData unitData spkCorr_
return

%% Plotting
AXLIM = [-1.5,+1.5];

figure(); hold on %scatterplot (FEF/SC vs SEF)
scatter(dA_X(:,1), dA_Y(:,1), 10, GREEN, 'filled', 'o') %A2F
scatter(dA_X(:,2), dA_Y(:,2), 10, 'r', 'filled', 'o') %F2A
plot([-1 +1],[0 0], 'k--'); plot([0 0],[-1 +1], 'k--')
xlabel('SEF single-trial change (z)')
ylabel('FEF/SC single-trial change (z)')
xlim(AXLIM); ylim(AXLIM)

ppretty([2,1.6])


% end % fxn : Fig2X_SingleTrialChange_NDim()
