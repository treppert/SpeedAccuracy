% computeSigCorr_X_Session.m
% This script computes the signal correlation for all pairs of
% task-relevant neurons for a given session.
% 

idx_Sess = ismember(unitData.SessionID, 1:9);
idx_Area = ismember(unitData.Area, {'SEF','FEF','SC'});
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

  fprintf(unitTest.ID(uu) + "\n")
  kk = unitTest.SessionID(uu); %get session number
  nTrial = behavData.NumTrials(kk); %number of trials

  %% Compute spike counts by condition and direction
  [scAcc_uu,scFast_uu] = computeSpkCt_X_Epoch(unitTest(uu,:) , behavData(kk,:));
  scAcc.VR(:,uu) = scAcc_uu(1:nDir,iVR);
  scAcc.PS(:,uu) = scAcc_uu(1:nDir,iPS);
  scFast.VR(:,uu) = scFast_uu(1:nDir,iVR);
  scFast.PS(:,uu) = scFast_uu(1:nDir,iPS);

end % for : unit (uu)

%% Compute signal correlation across all units
rAcc.VR  = corr(scAcc.VR, "type","Pearson");
rAcc.PS  = corr(scAcc.PS, "type","Pearson");
rFast.VR = corr(scFast.VR, "type","Pearson");
rFast.PS = corr(scFast.PS, "type","Pearson");

clearvars -except behavData unitData pairData spkCorr ROOTDIR* *Acc *Fast
