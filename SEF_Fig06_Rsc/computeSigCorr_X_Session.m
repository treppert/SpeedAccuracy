% computeSigCorr_X_Session.m
% This script computes the signal correlation for all pairs of
% task-relevant neurons for a given session. It plots the corresponding
% correlation matrix using imagesc().
% 

idx_Sess = ismember(unitData.SessionID, 11);
idx_Area = (unitData.Area == "SEF") | (unitData.Area == "SC");
idx_Fxn = ~(unitData.FxnType == "None");

unitTest = unitData( idx_Sess & idx_Area & idx_Fxn , : );
nUnit = size(unitTest,1);

nDir = 8;
iVR = 2; %index of visual response epoch
iPS = 3; %index of post-saccade epoch
scAcc.VR = NaN(nDir,nUnit); %Acc condition - VR epoch
scAcc.PS = scAcc.VR; %Acc condition - PS epoch
scFast = scAcc; %Fast condition

for uu = 1:nUnit

  kk = unitTest.SessionID(uu); %get session number
  nTrial = behavData.NumTrials(kk); %number of trials

  %% compute spike counts by condition and direction
  [scAcc_uu,scFast_uu] = computeSpkCt_X_Epoch(unitTest(uu,:) , behavData(kk,:));
  scAcc.VR(:,uu) = scAcc_uu(:,iVR);
  scAcc.PS(:,uu) = scAcc_uu(:,iPS);
  scFast.VR(:,uu) = scFast_uu(:,iVR);
  scFast.PS(:,uu) = scFast_uu(:,iPS);

end % for : unit (uu)

