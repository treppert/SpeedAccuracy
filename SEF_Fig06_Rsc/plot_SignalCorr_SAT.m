% function [ ] = plot_SignalCorr_SAT( )
%plot_SignalCorr_SAT This function plots the relationship between
%signal-related activation of two neurons for the SAT data set. It provides
%a look at the change in activation across all 8 directions separately for
%each neuron, and a combined look at the paired activation for each
%direction.
%   Detailed explanation goes here

PRINTDIR = "C:\Users\Thomas Reppert\Dropbox\SAT-Local\Figs - Signal Correlation\";

idx_Sess = ismember(pairData.SessionID, [2,3,4,8,9]);
idx_Monk = ismember(pairData.Monkey, {'D','E'});
idx_YArea = ismember(pairData.Y_Area, 'SC');
idx_XFxn  = ~ismember(pairData.X_FxnType, 'None');
idx_YFxn  = ~ismember(pairData.Y_FxnType, 'None');

pairTest = pairData( idx_Sess & idx_Monk & idx_YArea & idx_YFxn & idx_XFxn , : );
nPair = 1;%size(pairTest,1);
nDir = 8;

for pp = 1:nPair
  iX = pairTest.X_Index(pp); %(X=SEF)
  iY = pairTest.Y_Index(pp); %(Y=FEF/SC)
  X_Area = string(pairTest.X_Area(pp));
  Y_Area = string(pairTest.Y_Area(pp));
  pairID = unitData.ID(iY) + "-" + unitData.ID(iX);
  kk = pairTest.SessionID(pp); %get session number

  %% Compute spike counts by trial epoch
  [scAccX,scFastX] = computeSpkCt_X_Epoch(unitData(iX,:), behavData(kk,:), 'Correct');
  [scAccY,scFastY] = computeSpkCt_X_Epoch(unitData(iY,:), behavData(kk,:), 'Correct');
  scAccX = scAccX(1:nDir,:);  scFastX = scFastX(1:nDir,:);
  scAccY = scAccY(1:nDir,:);  scFastY = scFastY(1:nDir,:);
  
  %% Compute signal correlation between X and Y
  [rAcc, pAcc]  = corr(scAccX,  scAccY,  "type","Pearson"); rAcc  = diag(rAcc);
  [rFast,pFast] = corr(scFastX, scFastY, "type","Pearson"); rFast = diag(rFast);

  %% Get range of spike counts across epochs for each neuron
  rangeX = [min([scAccX scFastX],[],'all') max([scAccX scFastX],[],'all')];
  rangeY  = [min([scAccY scFastY],[],'all') max([scAccY scFastY],[],'all')];

  %% Figure - Scatter plots (signal correlation)
  GREEN = [0 0.7 0];
  hFig = figure('Visible','on');

  for ep = 1:4
    hplotCorr = subplot(1,4,ep); hold on
    scatter(scFastX(:,ep),scFastY(:,ep), 20,GREEN, 'filled', 'MarkerFaceAlpha',0.5)
    scatter(scAccX(:,ep), scAccY(:,ep),  20,'r',   'filled', 'MarkerFaceAlpha',0.5)
    xlim(rangeX)
    ylim(rangeY)
    text(rangeX(1),rangeY(2),     "r = " + num2str(rAcc(ep),3),"Color","r")
    text(rangeX(1),0.95*rangeY(2),"r = " + num2str(rFast(ep),3),"Color",GREEN)
    
    if (ep == 1)
      title('Baseline')
      xlabel(unitData.ID(iX))
      ylabel(unitData.ID(iY))
    elseif (ep == 2)
      title('Visual response'); xticks([]); yticks([])
    elseif (ep == 3)
      title('Post-saccade'); xticks([]); yticks([])
    elseif (ep == 4)
      title('Post-reward'); xticks([]); yticks([])
    end
  end % for : epoch (ep)
  
  ppretty([10,1.8]); drawnow
  % print(PRINTDIR + "SignalCorr-" + pairID + ".tif", '-dtiff'); close(hFig)

end % for : pair (pp)

% end % fxn : plot_SignalCorr_SAT()

clearvars -except behavData unitData pairData spkCorr ROOTDIR*
