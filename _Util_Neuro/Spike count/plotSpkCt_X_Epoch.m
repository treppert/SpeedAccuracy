% function [ ] = plotSpkCt_X_Epoch( unitTest )
%plotSpkCt_X_Epoch This function plots spike counts across the four main
%within-trial time windows (baseline, visual response, post-saccade, and
%post-reward), separately for Fast and Accurate conditions.
%   Detailed explanation goes here

PRINTDIR = 'C:\Users\thoma\Documents\Figs - SAT\';

idx_Monk = ismember(unitData.Monkey, {'D','E'});
idx_Area = ismember(unitData.Area, {'SEF'});
idx_Fxn = cellfun(@(x) strcmp(x,"V"), unitData.FxnType);

unitTest = unitData( idx_Monk & idx_Area & idx_Fxn , : );
nUnit = size(unitTest,1);

vecDir = deg2rad([0 45 90 135 180 225 270 315 360]');
nDir = 8;
nEpoch = 4;

for uu = 1:nUnit
  kk = unitTest.SessionIndex(uu); %get session number
  nTrial = behavData.NumTrials(kk); %number of trials

  %% Compute spike counts
  sc_uu = computeSpikeCount_SAT(unitTest(uu,:), behavData(kk,:));

  %% Index spike counts
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitTest.TrialRemoveSAT{uu}, nTrial);
  %index by condition
  idxAcc = ((behavData.Condition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Condition{kk} == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Correct{kk};

  %% Split spike counts by condition and direction
  scAcc = NaN(nDir+1,nEpoch);
  scFast = scAcc;
  for dd = 1:nDir
    idxDir = (behavData.Sacc_Octant{kk} == dd);
    scAcc(dd,:)  = mean(sc_uu(idxAcc & idxCorr & idxDir,:));
    scFast(dd,:) = mean(sc_uu(idxFast & idxCorr & idxDir,:));
  end % for : direction (dd)
  scAcc(nDir+1,:)  = scAcc(1,:); %close the circle for plotting
  scFast(nDir+1,:) = scFast(1,:);

  %% Plotting
  hFig = figure('visible','off');
  rLim = ceil(max([scFast scAcc],[],'all'));
  
  axFast = subplot(1,2,1, polaraxes);
  polarplot(vecDir,scFast, 'LineWidth',2.0);
  legend({'BL' 'VR' 'PS' 'PR'}, 'Location','southwest')
  title({[unitTest.ID{uu} '-' unitTest.Area{uu}] 'Fast'})
  thetaticks([])
  rlim([0 rLim])

  axAcc  = subplot(1,2,2, polaraxes);
  polarplot(vecDir,scAcc, 'LineWidth',2.0);
  title('Accurate')
  thetaticks([])
  rlim([0 rLim])
  
  ppretty([6,2]); pause(0.1)
  print([PRINTDIR, 'Polar-',unitTest.ID{uu},'-',unitTest.Area{uu},'.tif'], '-dtiff'); pause(0.1); close(hFig)
end % for : unit (uu)

clearvars -except behavData unitData pairData spkCorr ROOTDIR*

% end % fxn : plotSpkCt_X_Epoch()
