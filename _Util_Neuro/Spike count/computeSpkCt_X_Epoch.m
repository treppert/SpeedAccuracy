function [ scAcc , scFast ] = computeSpkCt_X_Epoch( unitTest , behavData )
%computeSpkCt_X_Epoch This function computes spike counts across the four main
%within-trial time windows (baseline, visual response, post-saccade, and
%post-reward), separately for Fast and Accurate conditions.
%   Detailed explanation goes here

nDir = 8;
nEpoch = 4;
nTrial = behavData.NumTrials; %number of trials

%% Compute spike counts
sc_uu = computeSpikeCount_SAT(unitTest, behavData);

%% Index spike counts
%index by isolation quality
idxIso = removeTrials_Isolation(unitTest.TrialRemoveSAT{1}, nTrial);
%index by condition
idxAcc = ((behavData.Condition{1} == 1) & ~idxIso);
idxFast = ((behavData.Condition{1} == 3) & ~idxIso);
%index by trial outcome
idxCorr = behavData.Correct{1};

%% Split spike counts by condition and direction
scAcc = NaN(nDir+1,nEpoch);
scFast = scAcc;
for dd = 1:nDir
  idxDir = (behavData.Sacc_Octant{1} == dd);
  scAcc(dd,:)  = mean(sc_uu(idxAcc & idxCorr & idxDir,:));
  scFast(dd,:) = mean(sc_uu(idxFast & idxCorr & idxDir,:));
end % for : direction (dd)
scAcc(nDir+1,:)  = scAcc(1,:); %close the circle for plotting
scFast(nDir+1,:) = scFast(1,:);

end % fxn : computeSpkCt_X_Epoch()
