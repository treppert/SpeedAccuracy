% plot_NoiseCorr_X_FxnClass.m
% Visualize noise correlations vs functional classification of neurons in SEF, FEF, and SC.
% 

GREEN = [0 .7 0];
BARWIDTH = 0.6;
LINEWIDTH = 1.4;

%% Control analysis - Correlation vs mean firing rate
% rAC = pairData.rAC(:,1); %baseline epoch
% rFC = pairData.rFC(:,1);
% scAC = NaN(nPair,2); %[uX,uY]
% scFC = scAC;
% 
% for pp = 1:nPair
%   uX = pairData.XUnit(pp);
%   uY = pairData.YUnit(pp);
%   kk = pairData.SID(pp);
% 
%   [scX_Acc,scX_Fast] = computeSpikeCount_Search(unitData(uX,:), behavData(kk,:), 'Outcome','Correct');
%   [scY_Acc,scY_Fast] = computeSpikeCount_Search(unitData(uY,:), behavData(kk,:), 'Outcome','Correct');
%   scAC(pp,:) = [mean(scX_Acc(:,1))  , mean(scY_Acc(:,1)) ];
%   scFC(pp,:) = [mean(scX_Fast(:,1)) , mean(scY_Fast(:,1))];
% 
% end
% 
% cMap = parula;
% rBinLim = linspace(-.8, +.8, 257);
% nColorBin = 256; %standard colormap
% 
% cPlotAcc = NaN(nPair,3);
% cPlotFast = cPlotAcc;
% for pp = 1:nPair
%   idxAcc  = find(rAC(pp) > rBinLim, 1, "last");
%   idxFast = find(rFC(pp) > rBinLim, 1, "last");
% 
%   cPlotAcc(pp,:)  = cMap(idxAcc,:);
%   cPlotFast(pp,:) = cMap(idxFast,:);
% end
% 
% hFig = figure("Visible","on");
% MARKERSIZE = 40;
% FACEALPHA = 0.6;
% 
% subplot(1,3,1); hold on; title('Accurate')
% scatter(scAC(:,1), scAC(:,2), MARKERSIZE, cPlotAcc, 'filled', ...
%   'MarkerFaceAlpha',FACEALPHA)
% xlabel(['BL spike count ', XAREA])
% ylabel(['BL spike count ', YAREA])
% 
% subplot(1,3,2); hold on; title('Fast')
% scatter(scFC(:,1), scFC(:,2), MARKERSIZE, cPlotFast, 'filled', ...
%   'MarkerFaceAlpha',FACEALPHA)
% xlabel(['BL spike count ', XAREA])
% 
% subplot(1,3,3); hold on
% colormap(cMap); colorbar; clim([-.8 +.8])
% 
% ppretty([8,1.8]); drawnow
% subplot(1,3,3); set(gca, 'XColor','none'); set(gca, 'YColor','none')

clearvars -except ROOTDIR* behavData* unitData* pairData* rNoise
