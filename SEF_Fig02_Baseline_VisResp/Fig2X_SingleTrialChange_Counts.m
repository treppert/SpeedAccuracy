% function [ ] = Fig2X_SingleTrialChange_Counts( behavData , unitData , spkCorr_ )
%Fig2X_SingleTrialChange_Simultaneous Summary of this function goes here
%   Detailed explanation goes here

DEBUG = true;
TLIM_COUNT = [+50,+400] + 3500;
tableSwitch = identify_condition_switch(behavData);

pair = {[2,11], [27 29], [31 39], [31 40], [35 39], [35 40], [45 47], ...
  [77 85], [89 93], [89 94], [93 98], [94 98], [106 111], [114 119], [117 119]};
nPair = numel(pair);

dA_X = NaN(nPair,2);  %SEF (mean single-trial modulation A2F|F2A)
dA_Y = dA_X;          %FEF/SC

for p = 1:nPair
  uX = unitData.Index(pair{p}(1)); %X unit no.
  uY = unitData.Index(pair{p}(2)); %Y unit no.
  xArea = unitData.Area{uX};
  yArea = unitData.Area{uY};
  k = unitData.SessionIndex(uX); %Session no.
  kstr = unitData.Session{uX};
  
  %index by isolation quality
  %index by condition
  idxAcc = (behavData.Task_SATCondition{k} == 1);
  idxFast = (behavData.Task_SATCondition{k} == 3);
  %index by trial number
  jjA2F = tableSwitch.A2F; %trials with switch Acc to Fast
  jjF2A = tableSwitch.F2A; %trials with switch Fast to Acc
  jjA2F_pre  = jjA2F{k} - 1; %Acc->Fast pre-change
  jjA2F_post = jjA2F{k} + 0; %Acc->Fast post-change
  jjF2A_pre  = jjF2A{k} - 1;
  jjF2A_post = jjF2A{k} + 0;

  %compute spike count for all trials
  spikes_X = load_spikes_SAT(unitData.Index(uX));
  spikes_Y = load_spikes_SAT(unitData.Index(uY));
  spkCt_X = cellfun(@(x) sum((x > TLIM_COUNT(1)) & (x < TLIM_COUNT(2))), spikes_X);
  spkCt_Y = cellfun(@(x) sum((x > TLIM_COUNT(1)) & (x < TLIM_COUNT(2))), spikes_Y);

  %z-score spike counts
  spkCt_X(idxAcc | idxFast) = zscore(spkCt_X(idxAcc | idxFast));
  spkCt_Y(idxAcc | idxFast) = zscore(spkCt_Y(idxAcc | idxFast));
  
  %TODO - Fix this issue
  spkCt_X(abs(spkCt_X) > 10) = NaN;
  spkCt_Y(abs(spkCt_Y) > 10) = NaN;

  %compute change in spike count at condition switch
  dA_X_p_A2F = spkCt_X(jjA2F_post) - spkCt_X(jjA2F_pre); nA2F = numel(jjA2F_pre);
  dA_Y_p_A2F = spkCt_Y(jjA2F_post) - spkCt_Y(jjA2F_pre);
  dA_X_p_F2A = spkCt_X(jjF2A_post) - spkCt_X(jjF2A_pre); nF2A = numel(jjF2A_pre);
  dA_Y_p_F2A = spkCt_Y(jjF2A_post) - spkCt_Y(jjF2A_pre);
  
  %COUNTS PER QUADRANT
  quadA2F = false(nA2F,4);
  jjQ1 = (dA_X_p_A2F > 0) & (dA_Y_p_A2F > 0); quadA2F(jjQ1,1) = true;
  jjQ2 = (dA_X_p_A2F < 0) & (dA_Y_p_A2F > 0); quadA2F(jjQ2,2) = true;
  jjQ3 = (dA_X_p_A2F < 0) & (dA_Y_p_A2F < 0); quadA2F(jjQ3,3) = true;
  jjQ4 = (dA_X_p_A2F > 0) & (dA_Y_p_A2F < 0); quadA2F(jjQ4,4) = true;
  quadA2F = sum(quadA2F);
  
  quadF2A = false(nF2A,4);
  jjQ1 = (dA_X_p_F2A > 0) & (dA_Y_p_F2A > 0); quadF2A(jjQ1,1) = true;
  jjQ2 = (dA_X_p_F2A < 0) & (dA_Y_p_F2A > 0); quadF2A(jjQ2,2) = true;
  jjQ3 = (dA_X_p_F2A < 0) & (dA_Y_p_F2A < 0); quadF2A(jjQ3,3) = true;
  jjQ4 = (dA_X_p_F2A > 0) & (dA_Y_p_F2A < 0); quadF2A(jjQ4,4) = true;
  quadF2A = sum(quadF2A);
  
  if (DEBUG)
    figure(); hold on; title([kstr,'-',xArea,'-',yArea])
    scatter(dA_X_p_A2F, dA_Y_p_A2F, 20, [0 .6 0], 'filled', 'o', 'MarkerFaceAlpha',.5)
    scatter(dA_X_p_F2A, dA_Y_p_F2A, 20, 'r', 'filled', 'o', 'MarkerFaceAlpha',.5)
    scatter(mean(dA_X_p_A2F), mean(dA_Y_p_A2F), 40, [0 .3 0], 'filled', 'o')
    scatter(mean(dA_X_p_F2A), mean(dA_Y_p_F2A), 40, [.5 0 0], 'filled', 'o')
    plot([-5 +5],[0 0], 'k--'); plot([0 0],[-5 +5], 'k--')
    xlabel([xArea,' change (z)'])
    ylabel([yArea,' change (z)'])
    ppretty([3.5,3]); set(gca, 'yminortick','off'); drawnow
    
    figure(); hold on; title([kstr,'-',xArea,'-',yArea])
    bar([quadA2F;quadF2A], 1.0)
    xticks([1,2]); xticklabels({'A2F','F2A'})
    ylabel('Trial count')
    legend({'Q1','Q2','Q3','Q4'}, 'location','north')
    ppretty([2,2]); drawnow
  end

  dA_X(p,:) = [mean(dA_X_p_A2F) , mean(dA_X_p_F2A)]; %A2F|F2A
  dA_Y(p,:) = [mean(dA_Y_p_A2F) , mean(dA_Y_p_F2A)];

end % for : pair(p)

return

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

clearvars -except behavData unitData spkCorr_ ROOTDIR_DATA_SAT
% end % fxn : Fig2X_SingleTrialChange_Counts()
