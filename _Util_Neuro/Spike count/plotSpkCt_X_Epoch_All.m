% function [ varargout ] = plotSpkCt_X_Epoch_All( unitTest , behavData )
%plotSpkCt_X_Epoch_All This function plots spike counts across the four main
%within-trial time windows (baseline, visual response, post-saccade, and
%post-reward), separately for Fast and Accurate conditions.
%   Plots are generated for all neurons of a particular class from a single
%   session, for combined viewing.
% 

idx_Sess = (unitData.SessionID == 11);
idx_Area = (unitData.Area == "SEF") | (unitData.Area == "SC");
idx_Fxn = ~(unitData.FxnType == "None");
unitTest = unitData( idx_Sess & idx_Area & idx_Fxn , : );
nUnit = size(unitTest,1);

hFig = figure('visible','on');
hPlot = cell(nUnit,2); %[Fast|Acc]
hAx = hPlot; %[Fast|Acc]

vecDir = deg2rad([0 45 90 135 180 225 270 315 360]');
nDir = 8;
nEpoch = 4;

for uu = 1:nUnit
  kk = unitTest.SessionID(uu); %get session number
  nTrial = behavData.NumTrials(kk); %number of trials

  %% compute spike counts by condition and direction
  [scAcc,scFast] = computeSpkCt_X_Epoch(unitTest(uu,:) , behavData(kk,:));

  %% Plotting
  rLim = ceil(max([scFast scAcc],[],'all'));
  iplotFast = 2*(uu-1) + 1;
  iplotAcc  = 2*(uu-1) + 2;
  
  hAx{uu,1} = subplot(nUnit,2,iplotFast, polaraxes);
  hPlot{uu,1} = polarplot(vecDir,scFast, 'LineWidth',2.0);
  if (uu == 1)
    legend({'BL' 'VR' 'PS' 'PR'}, 'Location','southwest')
    text(deg2rad(270), 1.1*rLim, 'Fast')
  end
  title(unitTest.ID(uu))
  thetaticks([])
  rlim([0 rLim])

  hAx{uu,2} = subplot(nUnit,2,iplotAcc, polaraxes);
  hPlot{uu,2} = polarplot(vecDir,scAcc, 'LineWidth',2.0);
  if (uu == 1)
    text(deg2rad(270), 1.1*rLim, 'Accurate')
  end
  thetaticks([])
  rlim([0 rLim])
  
end % for : unit (uu)

ppretty([6,3*nUnit]); drawnow

% end % fxn : plotSpkCt_X_Epoch()
clearvars -except behavData unitData pairData spkCorr ROOTDIR*
