% function [ ] = plot_NoiseCorr_SAT( )
%plot_NoiseCorr_SAT This function plots the noise correlation for a single
%pairs of neurons from the SAT data set. Correlations are computed
%separately for each target direction and split by task condition (Fast vs
%Accurate).
%   Detailed explanation goes here

PRINTDIR = "C:\Users\Thomas Reppert\Dropbox\SAT-Local\Figs - Noise Correlation\";

idx_Sess = ismember(pairData.SessionID, 11:13);
idx_Monk = ismember(pairData.Monkey, {'D','E'});
idx_YArea = ismember(pairData.Y_Area, 'SC');
idx_XFxn  = ~ismember(pairData.X_FxnType, 'None');
idx_YFxn  = ~ismember(pairData.Y_FxnType, 'None');

pairTest = pairData( idx_Sess & idx_Monk & idx_YArea & idx_YFxn & idx_XFxn , : );
nPair = size(pairTest,1);

vecDir = [0 45 90 135 180 225 270 315 360]';
nDir = 8;
nEpoch = 4;

rAcc = NaN(nPair,nDir,nEpoch);
rFast = rAcc;

for pp = 1:nPair
  iX = pairTest.X_Index(pp); %(X=SEF)
  iY = pairTest.Y_Index(pp); %(Y=FEF/SC)
  pairID = unitData.ID(iY) + "-" + unitData.ID(iX);
  kk = pairTest.SessionID(pp); %get session number

  %get trials with poor isolation for either neuron
  iIso_X = removeTrials_Isolation(unitData.TrialRemoveSAT{iX}, behavData.NumTrials(kk));
  iIso_Y = removeTrials_Isolation(unitData.TrialRemoveSAT{iY}, behavData.NumTrials(kk));
  iIso = (iIso_X | iIso_Y);

  %% Compute single-trial spike counts by target direction and trial epoch
  [~,~,scX] = computeSpkCt_X_Epoch(unitData(iX,:), behavData(kk,:), iIso);
  [~,~,scY] = computeSpkCt_X_Epoch(unitData(iY,:), behavData(kk,:), iIso);
  
  %% Compute noise correlation by direction and epoch
  rmatAcc  = cellfun(@(x1,x2) corr(x1,x2,"type","Pearson"), scX.Acc,scY.Acc, "UniformOutput",false);
  rmatFast = cellfun(@(x1,x2) corr(x1,x2,"type","Pearson"), scX.Fast,scY.Fast, "UniformOutput",false);
  rAcc_pp  = cell2mat( cellfun(@(x) diag(x)', rmatAcc, "UniformOutput",false) ); %nDir X nEpoch
  rFast_pp = cell2mat( cellfun(@(x) diag(x)', rmatFast, "UniformOutput",false) ); %nDir X nEpoch
  rAcc(pp,:,:)  = rAcc_pp;
  rFast(pp,:,:) = rFast_pp;

  %% Plotting
  GREEN = [0 0.7 0];
  hFig = figure('Visible','off');
  yLim = [-1 +1]; %ceil(max([rFast_pp rAcc_pp],[],'all'));

  %complete the circle for plotting
  rAcc_pp(nDir+1,:)  = rAcc_pp(1,:);
  rFast_pp(nDir+1,:) = rFast_pp(1,:);

  subplot(1,2,1); hold on %Fast condition
  plot(vecDir,rFast_pp, 'LineWidth',1.5)
  legend({'BL' 'VR' 'PS' 'PR'}, 'Location','best')
  ylim(yLim); xticks(vecDir(1:2:end)); xlim([-5 365])
  ytickformat('%2.1f')
  xlabel('Target direction')
  ylabel('Noise correlation')
  text(170,0.9, 'Fast')
  title(pairID)

  subplot(1,2,2); hold on %Accurate condition
  plot(vecDir,rAcc_pp, 'LineWidth',1.5)
  ylim(yLim); xticks(vecDir(1:2:end)); xlim([-5 365])
  ytickformat('%2.1f')
  xlabel('Target direction')
  text(170,0.9, 'Accurate')

  ppretty([6,1.8]); drawnow
  print(PRINTDIR + "NoiseCorr-" + pairID + ".tif", '-dtiff'); close(hFig)

end % for : pair (pp)

% end % fxn : plot_NoiseCorr_SAT()

clearvars -except behavData unitData pairData spkCorr ROOTDIR*
