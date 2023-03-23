% function [ varargout ] = plotSpkCt_X_Epoch_All( unitTest , behavData )
%plotSpkCt_X_Epoch_All This function plots spike counts across the four main
%within-trial time windows (baseline, visual response, post-saccade, and
%post-reward), separately for Fast and Accurate conditions.
%   Plots are generated for all neurons of a particular class from a single
%   session, for combined viewing.
% 

idx_Sess = (unitData.SessionIndex == 13);
idx_Area = (unitData.Area == 'SEF') | (unitData.Area == 'SC');
idx_Fxn = (unitData.isVis | unitData.isCErr | unitData.isTErr);
unitTest = unitData( idx_Sess & idx_Area & idx_Fxn , : );
nUnit = size(unitTest,1);

hFig = figure('visible','on');
pplot = cell(nUnit,2); %[Fast|Acc]
ax = pplot; %[Fast|Acc]

vecDir = deg2rad([0 45 90 135 180 225 270 315 360]');
nDir = 8;
nEpoch = 4;

colorFast = repmat([0 1 0], nEpoch,1); colorFast = [.8 .6 .4 0]' .* colorFast;
colorAcc  = repmat([1 0 0], nEpoch,1); colorAcc  = [.9 .6 .4 0]' .* colorAcc;

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
  rLim = ceil(max([scFast scAcc],[],'all'));
  iplotFast = 2*(uu-1) + 1;
  iplotAcc  = 2*(uu-1) + 2;
  
  ax{uu,1} = subplot(nUnit,2,iplotFast, polaraxes);
  pplot{uu,1} = polarplot(vecDir,scFast, 'LineWidth',2.0);
  % colororder(ax{uu,1},colorFast)
  if (uu == 1)
    legend({'BL' 'VR' 'PS' 'PR'}, 'Location','southwest')
    text(deg2rad(260), rLim, 'Fast')
  end
  title(unitTest.ID(uu))
  thetaticks([])
  rlim([0 rLim])

  ax{uu,2} = subplot(nUnit,2,iplotAcc, polaraxes);
  pplot{uu,2} = polarplot(vecDir,scAcc, 'LineWidth',2.0);
  % colororder(ax{uu,2},colorAcc)
  if (uu == 1)
    text(deg2rad(260), rLim, 'Accurate')
  end
  thetaticks([])
  rlim([0 rLim])
  
end % for : unit (uu)

ppretty([6,3*nUnit]); drawnow

% end % fxn : plotSpkCt_X_Epoch()
clearvars -except behavData unitData pairData spkCorr ROOTDIR*
