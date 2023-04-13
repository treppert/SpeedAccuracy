% function [ ] = plot_NoiseCorr_SAT( )
%plot_NoiseCorr_SAT This function plots the noise correlation for a single
%pairs of neurons from the SAT data set. Correlations are computed
%separately for each target direction and split by task condition (Fast vs
%Accurate).
%   Detailed explanation goes here

PRINTDIR = "C:\Users\thoma\Documents\Figs - SAT\";
GREEN = [0 0.7 0];

idx_Sess = ismember(pairData.SessionID, 2:13);
idx_Monk = ismember(pairData.Monkey, {'D','E'});
idx_YArea = ismember(pairData.Y_Area, {'SC','FEF'});
idx_XFxn  = ~ismember(pairData.X_FxnType, 'None');
idx_YFxn  = ~ismember(pairData.Y_FxnType, 'None');

pairTest = pairData( idx_Sess & idx_Monk & idx_YArea & idx_YFxn & idx_XFxn , : );
nPair = size(pairTest,1);

vecDir = [0 45 90 135 180 225 270 315 360]';
nDir = 8;
nEpoch = 4;

rAcc_ = NaN(nPair,nEpoch);
rFast_ = rAcc_;

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

  %account for neurons with no baseline activity
  min_ValidDir = 2;
  nNaN_Acc = sum(isnan(rAcc_pp),1);
  nNaN_Fast = sum(isnan(rFast_pp),1);
  rAcc_pp(:,  nNaN_Acc>min_ValidDir) = NaN;
  rFast_pp(:, nNaN_Fast>min_ValidDir) = NaN;

  %% Compute mean noise correlation across directions
  rAcc_mean  = mean(rAcc_pp,1, "omitnan");
  rFast_mean = mean(rFast_pp,1, "omitnan");
  rAcc_(pp,:)  = rAcc_mean;
  rFast_(pp,:) = rFast_mean;

  %% Plot noise correlation by direction and epoch
  % hFig = figure('Visible','off');
  % yLim = [-1 +1];
  % 
  % %complete the circle for plotting
  % rAcc_pp(nDir+1,:)  = rAcc_pp(1,:);
  % rFast_pp(nDir+1,:) = rFast_pp(1,:);
  % 
  % subplot(1,2,1); hold on %Fast condition
  % plot(vecDir,rFast_pp, 'LineWidth',1.5)
  % legend({'BL' 'VR' 'PS' 'PR'}, 'Location','best')
  % ylim(yLim); xticks(vecDir(1:2:end)); xlim([-5 365])
  % ytickformat('%2.1f')
  % xlabel('Target direction')
  % ylabel('Noise correlation')
  % text(170,0.9, 'Fast')
  % title(pairID)
  % 
  % subplot(1,2,2); hold on %Accurate condition
  % plot(vecDir,rAcc_pp, 'LineWidth',1.5)
  % ylim(yLim); xticks(vecDir(1:2:end)); xlim([-5 365])
  % ytickformat('%2.1f')
  % xlabel('Target direction')
  % text(170,0.9, 'Accurate')
  % 
  % ppretty([6,1.8]); drawnow
  % print(PRINTDIR + "NoiseCorr-" + pairID + ".tif", '-dtiff'); close(hFig)
  
  %% Plot mean noise correlation across directions
  % hFig = figure("Visible","off"); hold on
  % yLim = [-.4 +.4];
  % 
  % yline(0, '--')
  % plot(rFast_mean, '.-', "Color",GREEN, "LineWidth",1.5, "MarkerSize",20)
  % plot(rAcc_mean, '.-', "Color",'r', "LineWidth",1.5, "MarkerSize",20)
  % xticks(1:4); xticklabels({'BL','VR','PS','PR'}); xlim([0.5 4.5])
  % ylim(yLim); ytickformat('%2.1f')
  % ylabel('Noise correlation')
  % title(pairID)
  % 
  % ppretty([3,1.8]); drawnow
  % print(PRINTDIR + "NoiseCorr-" + pairID + ".tif", '-dtiff'); close(hFig)
  
end % for : pair (pp)

%% Plot mean noise correlation across all pairs
rAcc_mu = mean((rAcc_),1, "omitnan"); %mean across pairs
rFast_mu = mean((rFast_),1, "omitnan");

figure(); hold on
yline(0, '--')
plot(rFast_mu, '.-', "Color",GREEN, "LineWidth",1.5, "MarkerSize",20)
plot(rAcc_mu, '.-', "Color",'r', "LineWidth",1.5, "MarkerSize",20)
xticks(1:4); xticklabels({'BL','VR','PS','PR'}); xlim([0.5 4.5])
ytickformat('%3.2f')
ylabel('Noise correlation')
ppretty([3,1.8]); drawnow

% end % fxn : plot_NoiseCorr_SAT()

clearvars -except behavData unitData pairData spkCorr ROOTDIR* rAcc_ rFast_ GREEN
