% computeNoiseCorr_X_Session.m
% This script computes the noise correlation for all pairs of
% task-relevant neurons for a given session.
% 

%index behavioral data
sessTest = find(ismember(behavData.Monkey, 'S'));
behavTest = behavData(sessTest,:);
nSess = numel(sessTest);

%index unit data
idx_Area = ismember(unitData.Area, 'FEF');
idx_Fxn  = ismember(unitData.VR, 1);

epoch = {'BL','VR','PS','PR'};
nEpoch = 4;
nDir = 8;

%initialize noise correlation output
scNoise = new_struct({'Acc','Fast'}, 'dim',[nSess,1]);
rNoise  = new_struct({'Acc','Fast'}, 'dim',[nSess,1]);
rNoise(1).Acc = struct('BL',[], 'VR',[], 'PS',[], 'PR',[]);
rNoise(1).Fast = rNoise(1).Acc;
rmuNoise = rNoise;

for kk = 1:nSess
  idx_Sess = ismember(unitData.SessionID, sessTest(kk));
  unitTest = unitData( idx_Sess & idx_Area & idx_Fxn , : );
  nUnit = size(unitTest,1);
  
  %Save indexing information on session and units
  rNoise(kk).Session = sessTest(kk);
  rNoise(kk).Unit = unitTest.Unit;
  rNoise(kk).VRF = unitTest.VRF;

  %Initialize spike counts
  for ep = 1:nEpoch
    scNoise(kk).Acc.(epoch{ep})  = cell(nDir,1); 
    scNoise(kk).Fast.(epoch{ep}) = cell(nDir,1);
  end
  
  for uu = 1:nUnit
    %Compute single-trial spike counts by condition, direction, and epoch
    [~,~,scst] = computeSpikeCount_SAT(unitTest(uu,:), behavTest(kk,:), 'Correct');
    
    %Organize spike counts for correlation across neurons
    for dd = 1:nDir
      for ep = 1:nEpoch
        scNoise(kk).Acc.(epoch{ep}){dd}  = cat(2, scNoise(kk).Acc.(epoch{ep}){dd},  scst.Acc{dd}(:,ep));
        scNoise(kk).Fast.(epoch{ep}){dd} = cat(2, scNoise(kk).Fast.(epoch{ep}){dd}, scst.Fast{dd}(:,ep));
      end
    end
  end % for : unit (uu)
  
  %% Subtract direction-specific mean activation (i.e., the signal)
  for ep = 1:nEpoch
    scNoise(kk).Acc.(epoch{ep})  = cellfun( @(x) x - mean(x,1) , scNoise(kk).Acc.(epoch{ep}) ,  "UniformOutput",false );
    scNoise(kk).Fast.(epoch{ep}) = cellfun( @(x) x - mean(x,1) , scNoise(kk).Fast.(epoch{ep}) , "UniformOutput",false );
  end
  
  %% Compute noise correlation vs saccade direction
  for ep = 1:nEpoch
    rAccMAT.(epoch{ep})  = cell2mat( cellfun(@(x) corr(x, "type","Pearson"), scNoise(kk).Acc.(epoch{ep}),  "UniformOutput",false) );
    rFastMAT.(epoch{ep}) = cell2mat( cellfun(@(x) corr(x, "type","Pearson"), scNoise(kk).Fast.(epoch{ep}), "UniformOutput",false) );
    rNoise(kk).Acc.(epoch{ep})  = reshape(rAccMAT.(epoch{ep})',  nUnit,nUnit,nDir);
    rNoise(kk).Fast.(epoch{ep}) = reshape(rFastMAT.(epoch{ep})', nUnit,nUnit,nDir);
  end
  
  %% Compute mean noise correlation across all directions
  for ep = 1:nEpoch
    rmuNoise(kk).Acc.(epoch{ep})  = mean(rNoise(kk).Acc.(epoch{ep}), 3, "omitnan");
    rmuNoise(kk).Fast.(epoch{ep}) = mean(rNoise(kk).Fast.(epoch{ep}), 3, "omitnan");
  end
  
end % for : session (kk)

clearvars -except ROOTDIR* behavData unitData pairData *Noise* *Signal*
