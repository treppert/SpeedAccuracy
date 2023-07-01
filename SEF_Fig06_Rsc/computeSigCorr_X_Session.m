% computeSigCorr_X_Session.m
% This script computes the signal correlation for all pairs of
% task-relevant neurons for a given session.
% 

%index behavioral data
sessTest = find(ismember(behavData.Monkey, 'S'));
behavTest = behavData(sessTest,:);
nSess = numel(sessTest);

%index physiology data
idx_Area = ismember(unitData.Area, 'FEF');
idx_Hemi = ismember(unitData.Hemi, {'L','R'});
idx_Fxn  = ismember(unitData.VR, 1);

iVR = 2; %visual response epoch
iPS = 3; %post-saccade epoch
nDir = 8;

rSignal = new_struct({'Acc','Fast'}, 'dim',[1,nSess]);

for kk = 1:nSess
  idx_Sess = ismember(unitData.SessionID, sessTest(kk));
  unitTest = unitData( idx_Sess & idx_Area & idx_Hemi , : );
  nUnit = size(unitTest,1);

  if (nUnit == 0); continue; end
  
  sc_Acc = NaN(nDir,nUnit); %spike count - Acc condition
  sc_Fast = sc_Acc; %spike count - Fast condition
  
  for uu = 1:nUnit
    %% Compute spike counts by condition and direction
    [scAcc_uu,scFast_uu] = computeSpikeCount_SAT(unitTest(uu,:), behavTest(kk,:), 'Correct');

    %use appropriate time epoch(s) to estimate signal correlation
    if (unitTest.Area(uu) == "SEF")
      iEpoch = [iVR,iPS];
    else %FEF/SC
      iEpoch = iVR;
    end %switch (unit area)

    sc_Acc(:,uu)  = mean(scAcc_uu(1:nDir,iEpoch),  2);
    sc_Fast(:,uu) = mean(scFast_uu(1:nDir,iEpoch), 2);
  
  end % for : unit (uu)
  
  %account for directions with no data
  dnanAcc  = isnan(sc_Acc(:,1));    sc_Acc(dnanAcc,:) = [];
  dnanFast = isnan(sc_Fast(:,1));   sc_Fast(dnanFast,:) = [];

  %% Compute signal correlation across units for this session
  rSignal(kk).Acc  = corr(sc_Acc,  "type","Pearson");
  rSignal(kk).Fast = corr(sc_Fast, "type","Pearson");

end % for : session (kk)

clearvars -except ROOTDIR* behavData* unitData pairData rNoise* rSignal*
