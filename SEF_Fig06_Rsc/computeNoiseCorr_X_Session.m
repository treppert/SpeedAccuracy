% computeNoiseCorr_X_Session.m
% This script computes the noise correlation for all pairs of
% task-relevant neurons for a given session.
% 

SESSION = 3;

%cell array -- trial with poor isolation quality (Unit-Data-SAT.xlsx)
trialRemove = cell(16,1);
trialRemove{5} = [495 800];
trialRemove{7} = [1 330];
trialRemove{11} = [150 275];
trialRemove{12} = [525 625];
trialRemove{13} = [1776 1849];
trialRemove{16} = [1 100];

idx_Sess = ismember(unitData.SessionID, SESSION);
idx_Area = ismember(unitData.Area, {'SEF','FEF','SC'});
idx_Fxn = ~(unitData.FxnType == "None");

unitTest = unitData( idx_Sess & idx_Area & idx_Fxn , : );
nUnit = size(unitTest,1);

nDir = 8;
iVR = 2; %index of visual response epoch
iPS = 3; %index of post-saccade epoch
iPR = 4; %post-reward epoch

scAcc.VR = cell(nDir,1); %spike count - Acc - VR epoch
scAcc.PS = scAcc.VR;     %Acc - PS epoch
scAcc.PR = scAcc.VR;     %Acc - PR epoch
scFast = scAcc; %spike count - Fast

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
    scAcc.PS{dd} = cat(2,  scAcc.PS{dd},  scst.Acc{dd}(:,iPS));
    scAcc.PR{dd} = cat(2,  scAcc.PR{dd},  scst.Acc{dd}(:,iPR));
    scFast.VR{dd} = cat(2, scFast.VR{dd}, scst.Fast{dd}(:,iVR));
    scFast.PS{dd} = cat(2, scFast.PS{dd}, scst.Fast{dd}(:,iPS));
    scFast.PR{dd} = cat(2, scFast.PR{dd}, scst.Fast{dd}(:,iPR));
  end

end % for : unit (uu)

%% Subtract off the direction-specific mean activation (i.e., the signal)
% scAccMAT(:,:,iVR) = cell2mat( cellfun( @(x) x - mean(x,1) , scAcc.VR , "UniformOutput",false ) );
% scAccMAT(:,:,iPS) = cell2mat( cellfun( @(x) x - mean(x,1) , scAcc.PS , "UniformOutput",false ) );
% scFastMAT(:,:,iVR) = cell2mat( cellfun( @(x) x - mean(x,1) , scFast.VR , "UniformOutput",false ) );
% scFastMAT(:,:,iPS) = cell2mat( cellfun( @(x) x - mean(x,1) , scFast.PS , "UniformOutput",false ) );

%% Compute noise correlation across all units recorded simultaneously
% Accurate condition - split on direction, condition, and epoch
tmp = cell2mat( cellfun(@(x) corr(x, "type","Pearson"), scAcc.VR, "UniformOutput",false) );
rAcc.VR = reshape(tmp', nUnit,nUnit,nDir);
tmp = cell2mat( cellfun(@(x) corr(x, "type","Pearson"), scAcc.PS, "UniformOutput",false) );
rAcc.PS = reshape(tmp', nUnit,nUnit,nDir);
tmp = cell2mat( cellfun(@(x) corr(x, "type","Pearson"), scAcc.PR, "UniformOutput",false) );
rAcc.PR = reshape(tmp', nUnit,nUnit,nDir);
% Fast condition
tmp = cell2mat( cellfun(@(x) corr(x, "type","Pearson"), scFast.VR, "UniformOutput",false) );
rFast.VR = reshape(tmp', nUnit,nUnit,nDir);
tmp = cell2mat( cellfun(@(x) corr(x, "type","Pearson"), scFast.PS, "UniformOutput",false) );
rFast.PS = reshape(tmp', nUnit,nUnit,nDir);
tmp = cell2mat( cellfun(@(x) corr(x, "type","Pearson"), scFast.PR, "UniformOutput",false) );
rFast.PR = reshape(tmp', nUnit,nUnit,nDir);

%% Mean noise correlation across all directions
% rmuAcc.PS  = mean(rAcc.PS,3, "omitnan");
% rmuFast.PS = mean(rFast.PS,3, "omitnan");

%% Plotting - Individual pairs
PRINTDIR = "C:\Users\thoma\Documents\Figs - SAT\";
idx_Sess = (pairData.SessionID == SESSION);
pairTest = pairData(idx_Sess,:);
nPair = size(pairTest,1);

idxPlot = [16 7 4 1 10 19 22 25 13]; %indexes for visual response epoch
MARGIN = [0.08,0.02]; %margin between subplots
GREEN = [0.0 0.7 0.0];

EPOCH = {'VR','PS','PR'};

for pp = 1:nPair
  idxX = (unitTest.Index == pairTest.X_Index(pp)); %SEF
  idxY = (unitTest.Index == pairTest.Y_Index(pp)); %FEF/SC

  hFig = figure("Visible","off");
  
  for dd = 1:nDir

    for ep = 1:3

      subplot_tight(3,9, idxPlot(dd)+ep-1, MARGIN);
      scatter(scFast.(EPOCH{ep}){dd}(:,idxX),scFast.(EPOCH{ep}){dd}(:,idxY), 20,GREEN, 'filled', 'MarkerFaceAlpha',0.5)
      hold on
      scatter(scAcc.(EPOCH{ep}){dd}(:,idxX), scAcc.(EPOCH{ep}){dd}(:,idxY),  20,'r',   'filled', 'MarkerFaceAlpha',0.5)

      xLim = get(gca, 'xlim'); xDiff = diff(xLim);
      yLim = get(gca, 'ylim'); yDiff = diff(yLim);
      text(xLim(1),yLim(2),     "r = " + num2str(rAcc.(EPOCH{ep})(idxX,idxY,dd),3),"Color","r")
      text(xLim(1),0.92*yLim(2),"r = " + num2str(rFast.(EPOCH{ep})(idxX,idxY,dd),3),"Color",GREEN)
      
      if (dd==3 && ep==2)
        title(unitTest.ID(idxX) + "  --  " + unitTest.ID(idxY))
      elseif (dd==7 && ep==1)
        title("Visual response")
      elseif (dd==7 && ep==2)
        title("Post-saccade")
      elseif (dd==7 && ep==3)
        title("Post-reward")
      elseif (dd==6 && ep==1)
        xlabel("Spike count " + string(unitTest.Area(idxX)))
        ylabel("Spike count " + string(unitTest.Area(idxY)))
      end

    end % for : epoch (ep)

  end % for : dir (dd)

  ppretty([12,4]); drawnow
  print(PRINTDIR + "NoiseCorr-X-Dir  --  " + unitTest.ID(idxX) + "  --  " + unitTest.ID(idxY) + ".tif", '-dtiff'); close(hFig)

end % for : pair (pp)



%% Plotting - Across neurons
if (false)
PRINTDIR = "C:\Users\thoma\Documents\Figs - SAT\";
hFig = figure("Visible","on");
idxDir = [6 3 2 1 4 7 8 9];
for dd = 1:nDir
  subplot(3,3,idxDir(dd))
  imagesc(rAcc.PS(:,:,dd), [-1 +1])
  xticks([]); yticks([])
end
subplot(3,3,5)
imagesc(rmuAcc.PS, [-1 +1])
colorbar
xticks(1:nUnit); xticklabels(unitTest.Area)
yticks(1:nUnit); yticklabels(unitTest.Area)
subplot(3,3,2); title(unitTest.Session(1))
xlabel("Noise correlation")

print(PRINTDIR + "NoiseCorr-X-Dir-" + unitTest.Session(1) + ".tif", '-dtiff'); close(hFig)
end % if (plot)

clearvars -except behavData unitData pairData spkCorr ROOTDIR* *Acc *Fast 