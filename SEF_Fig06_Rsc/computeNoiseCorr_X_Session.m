% computeNoiseCorr_X_Session.m
% This script computes the noise correlation for all pairs of
% task-relevant neurons for a given session.
% 
% TODO - Subtract off mean spike count for each direction to compute noise
% correlation across all directions for each pair ****
% 

%cell array -- trial with poor isolation quality (Unit-Data-SAT.xlsx)
trialRemove = cell(16,1);
trialRemove{5} = [495 800];
trialRemove{7} = [1 330];
trialRemove{11} = [150 275];
trialRemove{12} = [525 625];
trialRemove{13} = [1776 1849];
trialRemove{16} = [1 100];

idx_Sess = ismember(unitData.SessionID, 12);
idx_Area = ismember(unitData.Area, {'SEF','FEF','SC'});
idx_Fxn = ~(unitData.FxnType == "None");

unitTest = unitData( idx_Sess & idx_Area & idx_Fxn , : );
nUnit = size(unitTest,1);

nDir = 8;
iVR = 2; %index of visual response epoch
iPS = 3; %index of post-saccade epoch

scAcc.VR = cell(nDir,1); %spike count - Acc - VR epoch
scAcc.PS = scAcc.VR;     %Acc - PS epoch
scFast = scAcc; %spike count - Fast

rAcc  = scAcc; %noise correlation
rFast = scFast;

for uu = 1:nUnit
  fprintf(unitTest.ID(uu) + "\n")
  kk = unitTest.SessionID(uu); %get session number
  nTrial_kk = behavData.NumTrials(kk);
  iIso_kk = removeTrials_Isolation(trialRemove{kk}, nTrial_kk); %poor isolation
  
  %% Compute single-trial spike counts by condition, direction, and epoch
  [~,~,scst] = computeSpkCt_X_Epoch(unitTest(uu,:), behavData(kk,:), iIso_kk);
  
  %% Organize spike counts for correlation computation across neurons
  for dd = 1:nDir
    scAcc.VR{dd} = cat(2,  scAcc.VR{dd},  scst.Acc{dd}(:,iVR));
    scAcc.PS{dd} = cat(2,  scAcc.PS{dd},  scst.Acc{dd}(:,iVR));
    scFast.VR{dd} = cat(2, scFast.VR{dd}, scst.Fast{dd}(:,iVR));
    scFast.PS{dd} = cat(2, scFast.PS{dd}, scst.Fast{dd}(:,iVR));
  end

end % for : unit (uu)

%% Compute noise correlation across all units
tmp = cell2mat( cellfun(@(x) corr(x, "type","Pearson"), scAcc.PS, "UniformOutput",false) ); %Accurate
rAcc.PS = reshape(tmp', nUnit,nUnit,nDir);
tmp = cell2mat( cellfun(@(x) corr(x, "type","Pearson"), scFast.PS, "UniformOutput",false) ); %Fast
rFast.PS = reshape(tmp', nUnit,nUnit,nDir);

%% Mean noise correlation across all directions
rmuAcc.PS  = mean(rAcc.PS,3, "omitnan");
rmuFast.PS = mean(rFast.PS,3, "omitnan");

%% Plotting
hFig = figure("Visible","on");
idxDD = [6 3 2 1 4 7 8 9];
for dd = 1:nDir
  subplot(3,3,idxDD(dd))
  imagesc(rAcc.PS(:,:,dd), [-1 +1])
end
subplot(3,3,5)
imagesc(rmuAcc.PS, [-1 +1])

clearvars -except behavData unitData pairData spkCorr ROOTDIR* *Acc *Fast 
