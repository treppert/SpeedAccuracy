% computeSigCorr_X_Session.m
% This script computes the signal correlation for all pairs of
% task-relevant neurons for a given session.
% 

idx_Area = ismember(unitData.Area, {'SEF','FEF','SC'});
idx_Fxn = ~(unitData.FxnType == "None");

nSess = 16;
nDir = 8;
iVR = 2; %index of visual response epoch
iPS = 3; %index of post-saccade epoch

rSignal = new_struct({'Acc','Fast'}, 'dim',[1,nSess]);

for kk = 1:nSess
  idx_Sess = ismember(unitData.SessionID, kk);
  unitTest = unitData( idx_Sess & idx_Area & idx_Fxn , : );
  nUnit = size(unitTest,1);
  
  nTrial_kk = behavData.NumTrials(kk);
  iIso_kk = removeTrials_Isolation(trialRemove{kk}, nTrial_kk); %poor isolation
  
  scAcc_kk.VR = NaN(nDir,nUnit); %Acc condition - VR epoch
  scAcc_kk.PS = scAcc_kk.VR; %Acc condition - PS epoch
  scFast_kk = scAcc_kk; %Fast condition
  
  for uu = 1:nUnit
    %% Compute spike counts by condition and direction
    [scAcc_uu,scFast_uu] = computeSpkCt_X_Epoch(unitTest(uu,:), behavData(kk,:), 'Correct', iIso_kk);
    scAcc_kk.VR(:,uu) = scAcc_uu(1:nDir,iVR);
    scAcc_kk.PS(:,uu) = scAcc_uu(1:nDir,iPS);
    scFast_kk.VR(:,uu) = scFast_uu(1:nDir,iVR);
    scFast_kk.PS(:,uu) = scFast_uu(1:nDir,iPS);
  
  end % for : unit (uu)
  
  %% Compute signal correlation across units for this session
  rSignal(kk).Acc.VR  = corr(scAcc_kk.VR, "type","Pearson");
  rSignal(kk).Acc.PS  = corr(scAcc_kk.PS, "type","Pearson");
  rSignal(kk).Fast.VR = corr(scFast_kk.VR, "type","Pearson");
  rSignal(kk).Fast.PS = corr(scFast_kk.PS, "type","Pearson");

end % for : session (kk)

clearvars -except behavData unitData pairData spkCorr ROOTDIR* rNoise* rSignal*
