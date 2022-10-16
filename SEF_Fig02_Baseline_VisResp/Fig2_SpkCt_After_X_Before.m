function [ ] = Fig2_SpkCt_After_X_Before( behavData , unitData )
%Fig2_SpkCt_After_X_Before Summary of this function goes here
%   Detailed explanation goes here

TLIM_VR = [+50,+400] + 3500;

tmp = identify_condition_switch(behavData);
jjA2F = tmp.A2F; %trials with switch Acc to Fast
jjF2A = tmp.F2A; %trials with switch Fast to Acc

NUM_UNIT = size(unitData,1);

%initialize spike count
spkCt_A2F = NaN(NUM_UNIT,2); %before|after
spkCt_F2A = spkCt_A2F;

for uu = 1:NUM_UNIT
  kk = ismember(behavData.Task_Session, unitData.Session(uu));
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitData.TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);
  trialAcc = find(idxAcc);
  trialFast = find(idxFast);

  %index by trial number
  jjA2F_pre  = intersect(trialAcc,  jjA2F{kk} - 1); %Acc->Fast pre-change
  jjA2F_post = intersect(trialFast, jjA2F{kk} + 0); %Acc->Fast post-change
  jjF2A_pre  = intersect(trialFast, jjF2A{kk} - 1);
  jjF2A_post = intersect(trialAcc,  jjF2A{kk} + 0);

  %compute spike count for all trials
  spikes_uu = load_spikes_SAT(unitData.Index(uu));
  spkCt_uu = cellfun(@(x) sum((x > TLIM_VR(1)) & (x < TLIM_VR(2))), spikes_uu);

  %compute z-scored spike count
  spkCt_uu(~idxIso) = zscore(spkCt_uu(~idxIso));
  
  spkCt_A2F(uu,:) = [mean(spkCt_uu(jjA2F_pre)) , mean(spkCt_uu(jjA2F_post))];
  spkCt_F2A(uu,:) = [mean(spkCt_uu(jjF2A_pre)) , mean(spkCt_uu(jjF2A_post))];

end % for: unit(uu)

%% Plotting
%index plotting by area
idxSEF = ismember(unitData.Area, {'SEF'});
idxFEF = ismember(unitData.Area, {'FEF'});
idxSC  = ismember(unitData.Area, {'SC'});

%compute mean
mu_SEF_A2F = mean(spkCt_A2F(idxSEF,:));   se_SEF_A2F = std(spkCt_A2F(idxSEF,:))/sqrt(sum(idxSEF));
mu_FEF_A2F = mean(spkCt_A2F(idxFEF,:));   se_FEF_A2F = std(spkCt_A2F(idxFEF,:))/sqrt(sum(idxFEF));
mu_SC_A2F = mean(spkCt_A2F(idxSC,:));     se_SC_A2F = std(spkCt_A2F(idxSC,:))/sqrt(sum(idxSC));
%compute standard error
mu_SEF_F2A = mean(spkCt_F2A(idxSEF,:));   se_SEF_F2A = std(spkCt_F2A(idxSEF,:))/sqrt(sum(idxSEF));
mu_FEF_F2A = mean(spkCt_F2A(idxFEF,:));   se_FEF_F2A = std(spkCt_F2A(idxFEF,:))/sqrt(sum(idxFEF));
mu_SC_F2A = mean(spkCt_F2A(idxSC,:));     se_SC_F2A = std(spkCt_F2A(idxSC,:))/sqrt(sum(idxSC));

figure()

subplot(1,2,1); title('Accurate to Fast'); hold on
% plot(spkCt_A2F(idxSEF,:)', 'k-')
% plot(spkCt_A2F(idxFEF,:)', 'b-')
% plot(spkCt_A2F(idxSC,:)', 'm-')
errorbar(mu_SEF_A2F, se_SEF_A2F, 'k', 'CapSize',0)
errorbar(mu_FEF_A2F, se_FEF_A2F, 'b', 'CapSize',0)
errorbar(mu_SC_A2F, se_SC_A2F, 'm', 'CapSize',0)
ylabel('Post-array spike count (z)'); ytickformat('%2.1f'); xticks([])

subplot(1,2,2); title('Fast to Accurate'); hold on
% plot(spkCt_F2A(idxSEF,:)', 'k-')
% plot(spkCt_F2A(idxFEF,:)', 'b-')
% plot(spkCt_F2A(idxSC,:)', 'm-')
errorbar(mu_SEF_F2A, se_SEF_F2A, 'k', 'CapSize',0)
errorbar(mu_FEF_F2A, se_FEF_F2A, 'b', 'CapSize',0)
errorbar(mu_SC_F2A, se_SC_F2A, 'm', 'CapSize',0)
ytickformat('%2.1f'); xticks([])

ppretty([3,1.2])

end % fxn : Fig2_SpkCt_After_X_Before()
