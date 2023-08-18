% plot_NoiseCorr_X_FxnClass.m
% Visualize noise correlations vs functional classification of neurons in SEF, FEF, and SC.
% 

GREEN = [0 .7 0];
BARWIDTH = 0.6;
LINEWIDTH = 1.4;

%% Plotting - Mean correlation
% %average across epochs
% rAC = mean(pairData.rAC,2);
% rFC = mean(pairData.rFC,2);
% rAE = mean(pairData.rAET,2, "omitnan");
% rFE = mean(pairData.rFEC,2, "omitnan");
% 
% %average across pairs
% rACmu = mean(rAC,1);  seAC = std(rAC,0,1) / sqrt(nPair);
% rAEmu = mean(rAE,1);  seAE = std(rAE,0,1) / sqrt(nPair);
% rFCmu = mean(rFC,1);  seFC = std(rFC,0,1) / sqrt(nPair);
% rFEmu = mean(rFE,1);  seFE = std(rFE,0,1) / sqrt(nPair);
% 
% %stats
% % rNoise = mean([rAC rFC rAE rFE], 2);
% rNoise = [rAC; rAE; rFC; rFE];
% Condition = [ones(2*nPair,1); 2*ones(2*nPair,1)];
% Outcome = [ones(nPair,1); 2*ones(nPair,1); ones(nPair,1); 2*ones(nPair,1)];
% pNoise = anovan(rNoise,{Condition,Outcome}, 'display','on', 'model','interaction', ...
%   'varnames',{'Condition','Outcome'});
% 
% %plotting only correct trials
% % hFig = figure("Visible","on"); hold on
% % bar(1, rACmu, BARWIDTH, 'FaceColor','r',   'EdgeColor','none', 'FaceAlpha',0.5)
% % bar(2, rFCmu, BARWIDTH, 'FaceColor',GREEN, 'EdgeColor','none', 'FaceAlpha',0.5)
% % errorbar([1 2], [rACmu rFCmu], [seAC seFC], 'LineWidth',LINEWIDTH, 'Color','k', 'CapSize',0)
% 
% %plotting correct and error trials
% hFig = figure("Visible","on"); hold on
% bar(1:2, [rACmu rAEmu], BARWIDTH, 'FaceColor','r', 'EdgeColor','none', 'FaceAlpha',0.5)
% errorbar(1:2, [rACmu rAEmu], [seAC seAE], 'LineWidth',LINEWIDTH, 'Color','k', 'CapSize',0)
% bar(3:4, [rFCmu rFEmu], BARWIDTH, 'FaceColor',GREEN, 'EdgeColor','none', 'FaceAlpha',0.5)
% errorbar(3:4, [rFCmu rFEmu], [seFC seFE], 'LineWidth',LINEWIDTH, 'Color','k', 'CapSize',0)
% 
% xticks(1:4); xticklabels([]); xlim([0.3 4.7])
% ytickformat('%3.2f'); %ylabel('Noise correlation');
% fprintf(MONKEY + "   " + XAREA + "-" + YAREA + "   FXN-FXN   n = " + num2str(nPair) + "\n")
% 
% ppretty([2.6,2]); drawnow
% set(gca, 'XMinorTick','off')

%% Plotting - Correlation x epoch
% EPOCH = {'BL' 'VR' 'PS' 'PR'}; %time intervals of interest
% 
% rAC = mean(pairData.rAC,1);     seAC = std(pairData.rAC,0,1) / sqrt(nPair);
% rFC = mean(pairData.rFC,1);     seFC = std(pairData.rFC,0,1) / sqrt(nPair);
% rAET = mean(pairData.rAET,1);   seAET = std(pairData.rAET,0,1) / sqrt(nPair);
% rFEC = mean(pairData.rFEC,1);   seFEC = std(pairData.rFEC,0,1) / sqrt(nPair);
% 
% hFig = figure("Visible","on"); hold on
% xTickAcc = 1:4;
% xTickFast = 6:9;
% xOffset = 0.05;
% 
% bar(xTickAcc-xOffset,  rAC, BARWIDTH, 'FaceColor','r',   'EdgeColor','none', 'FaceAlpha',0.5)
% bar(xTickFast-xOffset, rFC, BARWIDTH, 'FaceColor',GREEN, 'EdgeColor','none', 'FaceAlpha',0.5)
% 
% errorbar(xTickFast-xOffset, rFC,  seFC,  'Linestyle','-',  'LineWidth',LINEWIDTH, 'Color','k', 'CapSize',0)
% errorbar(xTickFast+xOffset, rFEC, seFEC, 'Linestyle','--',  'LineWidth',LINEWIDTH, 'Color','k', 'CapSize',0)
% errorbar(xTickAcc-xOffset,  rAC,  seAC,  'Linestyle','-',  'LineWidth',LINEWIDTH,  'Color','k', 'CapSize',0)
% errorbar(xTickAcc+xOffset,  rAET, seAET, 'Linestyle',':',  'LineWidth',LINEWIDTH, 'Color','k', 'CapSize',0)
% legend({'','','Correct','Choice error','','Timing error'}, 'Location','northwest')
% 
% xticks([xTickAcc xTickFast]); xticklabels([])
% ytickformat('%3.2f'); %ylabel('Noise correlation');
% fprintf(MONKEY + "   " + XAREA + "-" + YAREA + "   FXN-FXN   n = " + num2str(nPair) + "\n")
% 
% ppretty([6,2]); drawnow; yline(0)
% set(gca, 'XMinorTick','off')
% 
% % print(PRINTDIR + unitTest.ID(uu) + ".tif", '-dtiff'); close(hFig)

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
