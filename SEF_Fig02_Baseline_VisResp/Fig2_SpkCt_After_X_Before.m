function [ ] = Fig2_SpkCt_After_X_Before( behavData , unitData )
%Fig2_SpkCt_After_X_Before Summary of this function goes here
%   Detailed explanation goes here

TLIM_BL = [-600 50] + 3500;
TLIM_VR = [50 400] + 3500;

tmp = identify_condition_switch(behavData);
jjA2F = tmp.A2F; %trials with switch Acc to Fast
jjF2A = tmp.F2A; %trials with switch Fast to Acc

NUM_UNIT = size(unitData,1);

%initialize spike count
spkCt_A2F = NaN(NUM_UNIT,2); %before|after
spkCt_F2A = spkCt_A2F;

for uu = 1:NUM_UNIT
  kk = ismember(behavData.Task_Session, unitData.Session(uu));
  
  %compute spike count for all trials
  spikes_uu = load_spikes_SAT(unitData.Index(uu));
  tmpBL = cellfun(@(x) sum((x > TLIM_BL(1)) & (x < TLIM_BL(2))), spikes_uu);
  tmpVR = cellfun(@(x) sum((x > TLIM_VR(1)) & (x < TLIM_VR(2))), spikes_uu);
%   spkCt_uu = tmpBL + tmpVR;
  spkCt_uu = tmpVR;

  %index by isolation quality
  idxIso = removeTrials_Isolation(unitData.TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  
  %compute z-scored spike count
%   spkCt_uu(~idxIso) = zscore(spkCt_uu(~idxIso));
  
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

  spkCt_A2F(uu,:) = [mean(spkCt_uu(jjA2F_pre)) , mean(spkCt_uu(jjA2F_post))];
  spkCt_F2A(uu,:) = [mean(spkCt_uu(jjF2A_pre)) , mean(spkCt_uu(jjF2A_post))];

end % for: unit(uu)

%% Plotting
%index plotting by area
idxSEF = ismember(unitData.Area, {'SEF'});
idxFEF = ismember(unitData.Area, {'FEF'});
idxSC  = ismember(unitData.Area, {'SC'});

LINE_LIM = [0 100];
GRAY = 0.4*ones(1,3);
XLABEL = 'Spike count: Trial -1';
YLABEL = 'Spike count: Trial +1';


figure() %Scatterplot -- Before vs after

subplot(1,2,1); title('Accurate to Fast'); hold on
scatter(spkCt_A2F(idxSEF,1), spkCt_A2F(idxSEF,2), 10, 'k', 'filled', 'd')
scatter(spkCt_A2F(idxFEF,1), spkCt_A2F(idxFEF,2), 10, 'b', 'filled', 'd')
scatter(spkCt_A2F(idxSC,1), spkCt_A2F(idxSC,2), 10, 'm', 'filled', 'd')
line(LINE_LIM, LINE_LIM, 'LineStyle','--', 'Color',GRAY)
xlabel(XLABEL); ylabel(YLABEL)

subplot(1,2,2); title('Fast to Accurate'); hold on %F2A
scatter(spkCt_F2A(idxSEF,1), spkCt_F2A(idxSEF,2), 10, 'k', 'filled', 'd')
scatter(spkCt_F2A(idxFEF,1), spkCt_F2A(idxFEF,2), 10, 'b', 'filled', 'd')
scatter(spkCt_F2A(idxSC,1), spkCt_F2A(idxSC,2), 10, 'm', 'filled', 'd')
line(LINE_LIM, LINE_LIM, 'LineStyle','--', 'Color',GRAY)
xlabel(XLABEL)

ppretty([4,1.2])


figure() %Histogram -- Difference
BIN_EDGES_A2F = linspace(-10, 20, 7);
BIN_EDGES_F2A = linspace(-20, 10, 7);

subplot(1,2,1); title('Accurate to Fast'); hold on
histogram(diff(spkCt_A2F(idxSEF,:),1,2), 'normalization','count', 'FaceColor','k', 'BinEdges',BIN_EDGES_A2F)
histogram(diff(spkCt_A2F(idxFEF,:),1,2), 'normalization','count', 'FaceColor','b', 'BinEdges',BIN_EDGES_A2F)
histogram(diff(spkCt_A2F(idxSC,:),1,2), 'normalization','count', 'FaceColor','m', 'BinEdges',BIN_EDGES_A2F)
xlabel('Spike count change')
ylabel('Number of neurons')

subplot(1,2,2); title('Fast to Accurate'); hold on
histogram(diff(spkCt_F2A(idxSEF,:),1,2), 'normalization','count', 'FaceColor','k', 'BinEdges',BIN_EDGES_F2A)
histogram(diff(spkCt_F2A(idxFEF,:),1,2), 'normalization','count', 'FaceColor','b', 'BinEdges',BIN_EDGES_F2A)
histogram(diff(spkCt_F2A(idxSC,:),1,2), 'normalization','count', 'FaceColor','m', 'BinEdges',BIN_EDGES_F2A)
xlabel('Spike count change')

ppretty([4,1.2])

end % fxn : Fig2_SpkCt_After_X_Before()

