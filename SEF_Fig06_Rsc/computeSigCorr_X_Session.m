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
  
  sc_Acc = NaN(nDir,nUnit); %spike count - Acc condition
  sc_Fast = sc_Acc; %spike count - Fast condition
  
  for uu = 1:nUnit
    %% Compute spike counts by condition and direction
    [scAcc_uu,scFast_uu] = computeSpikeCount_SAT(unitTest(uu,:), behavData(kk,:), 'Correct', iIso_kk);

    %use appropriate time epoch(s) to estimate signal correlation
    if (unitTest.Area(uu) == "SEF")
      iEpoch = [iVR,iPS];
    else %FEF/SC
      switch unitTest.FxnType(uu)
        case "V"
          iEpoch = iVR;
        case "VM"
          iEpoch = [iVR,iPS];
        case "M"
          iEpoch = iPS;
      end % switch (unit fxn type)
    end %switch (unit area)

    sc_Acc(:,uu)  = mean(scAcc_uu(1:nDir,iEpoch), 2);
    sc_Fast(:,uu) = mean(scFast_uu(1:nDir,iEpoch), 2);
  
  end % for : unit (uu)
  
  %% Compute signal correlation across units for this session
  rSignal(kk).Acc  = corr(sc_Acc,  "type","Pearson");
  rSignal(kk).Fast = corr(sc_Fast, "type","Pearson");

end % for : session (kk)

clearvars -except behavData unitData pairData ROOTDIR* rNoise* rSignal*
