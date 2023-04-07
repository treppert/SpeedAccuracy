% function [ ] = plot_NoiseCorr_SAT( )
%plot_NoiseCorr_SAT This function plots the noise correlation for a single
%pairs of neurons from the SAT data set. Correlations are computed
%separately for each target direction and split by task condition (Fast vs
%Accurate).
%   Detailed explanation goes here

PRINTDIR = "C:\Users\Thomas Reppert\Dropbox\SAT-Local\Figs - Noise Correlation\";

idx_Sess = ismember(pairData.SessionID, [2,3,4,8,9]);
idx_Monk = ismember(pairData.Monkey, {'D','E'});
idx_YArea = ismember(pairData.Y_Area, 'SC');
idx_XFxn  = ~ismember(pairData.X_FxnType, 'None');
idx_YFxn  = ~ismember(pairData.Y_FxnType, 'None');

pairTest = pairData( idx_Sess & idx_Monk & idx_YArea & idx_YFxn & idx_XFxn , : );
nPair = 1;%size(pairTest,1);
nDir = 8;
nEpoch = 4;

rAcc = NaN(nPair,nDir,nEpoch);
rFast = rAcc;

for pp = 1:nPair
  iX = pairTest.X_Index(pp); %(X=SEF)
  iY = pairTest.Y_Index(pp); %(Y=FEF/SC)
  X_Area = string(pairTest.X_Area(pp));
  Y_Area = string(pairTest.Y_Area(pp));
  pairID = unitData.ID(iY) + "-" + unitData.ID(iX);
  kk = pairTest.SessionID(pp); %get session number

  %% Compute single-trial spike counts by target direction and trial epoch
  [~,~,scX] = computeSpkCt_X_Epoch(unitData(iX,:), behavData(kk,:));
  [~,~,scY] = computeSpkCt_X_Epoch(unitData(iY,:), behavData(kk,:));
  
  %% Compute signal correlation between X and Y
  rmatAcc  = cellfun(@(x1,x2) corr(x1,x2,"type","Pearson"), scX.Acc,scY.Acc, "UniformOutput",false);
  rmatFast = cellfun(@(x1,x2) corr(x1,x2,"type","Pearson"), scX.Fast,scY.Fast, "UniformOutput",false);
  rAcc(pp,:,:)  = cell2mat( cellfun(@(x) diag(x)', rmatAcc, "UniformOutput",false) );
  rFast(pp,:,:) = cell2mat( cellfun(@(x) diag(x)', rmatFast, "UniformOutput",false) );

  %% Plotting
  GREEN = [0 0.7 0];
  hFig = figure('Visible','on');

  
  ppretty([10,1.8]); drawnow
  % print(PRINTDIR + "SignalCorr-" + pairID + ".tif", '-dtiff'); close(hFig)

end % for : pair (pp)

% end % fxn : plot_SignalCorr_SAT()

clearvars -except behavData unitData pairData spkCorr ROOTDIR*
