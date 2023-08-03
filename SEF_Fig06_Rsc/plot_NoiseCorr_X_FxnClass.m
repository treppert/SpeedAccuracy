% function [  ] = plot_NoiseCorr_X_FxnClass( pairData )
%plot_NoiseCorr_X_FxnClass Visualize noise correlations vs functional
%classification of neurons in SEF, FEF, and SC.
%   Detailed explanation goes here
% 

MONKEY = 'Da';
XAREA = 'SEF';
YAREA = 'SC';

%% Post-processing of pairwise correlations
pairData = pairDataALL.(MONKEY);

%index pair data
idxXArea = ismember(pairData.XArea, XAREA);
idxYArea = ismember(pairData.YArea, YAREA);
idxXFxn  = ismember(pairData.X_VR, +1);
idxYFxn  = ismember(pairData.Y_VR, +1);

% pairData = pairData(idxXArea & idxYArea & idxXFxn & idxYFxn, :);
pairData = pairData(idxXArea & idxYArea, :);
nPair = size(pairData,1);


%% Plotting - Mean correlation
% PRINTDIR = 'C:\Users\thoma\Dropbox\SAT-Local\Figures\';
GREEN = [0 .7 0];
BARWIDTH = 0.6;
LINEWIDTH = 1.4;

%average across epochs
rAC = mean(pairData.rAC,2);
rFC = mean(pairData.rFC,2, "omitnan");
rAE = mean(pairData.rAET,2, "omitnan");
rFE = mean(pairData.rFEC,2, "omitnan");

rACmu = mean(rAC,1);  seAC = std(rAC,0,1) / sqrt(nPair);
rAEmu = mean(rAE,1);  seAE = std(rAE,0,1) / sqrt(nPair);
rFCmu = mean(rFC,1);  seFC = std(rFC,0,1) / sqrt(nPair);
rFEmu = mean(rFE,1);  seFE = std(rFE,0,1) / sqrt(nPair);

%stats
rNoise = [rAC; rAE; rFC; rFE];
Condition = [ones(2*nPair,1); 2*ones(2*nPair,1)];
Outcome = [ones(nPair,1); 2*ones(nPair,1); ones(nPair,1); 2*ones(nPair,1)];
pNoise = anovan(rNoise,{Condition,Outcome}, 'display','on', 'model','interaction', ...
  'varnames',{'Condition','Outcome'});

hFig = figure("Visible","on"); hold on

bar(1:2, [rACmu rAEmu], BARWIDTH, 'FaceColor','r', 'EdgeColor','none', 'FaceAlpha',0.5)
errorbar(1:2, [rACmu rAEmu], [seAC seAE], 'LineWidth',LINEWIDTH, 'Color','k', 'CapSize',0)

bar(3:4, [rFCmu rFEmu], BARWIDTH, 'FaceColor',GREEN, 'EdgeColor','none', 'FaceAlpha',0.5)
errorbar(3:4, [rFCmu rFEmu], [seFC seFE], 'LineWidth',LINEWIDTH, 'Color','k', 'CapSize',0)

% YLINE = .06;
% plot(1:2, [YLINE YLINE], 'k-', 'LineWidth',LINEWIDTH)
% plot(3:4, [YLINE YLINE], 'k-', 'LineWidth',LINEWIDTH)

xticks(1:4); xticklabels([]); xlim([0.3 4.7])
ytickformat('%3.2f'); %ylabel('Noise correlation');
fprintf(MONKEY + "   " + XAREA + "-" + YAREA + "   FXN-FXN   n = " + num2str(nPair) + "\n")

ppretty([2.6,2]); drawnow
set(gca, 'XMinorTick','off')

% print(PRINTDIR + unitTest.ID(uu) + ".tif", '-dtiff'); close(hFig)
% clearvars -except ROOTDIR* behavData* unitData* pairData*

return

%% Plotting - Correlation x epoch
EPOCH = {'BL' 'VR' 'PS' 'PR'}; %time intervals of interest

rAC = mean(pairData.rAC,1);     seAC = std(pairData.rAC,0,1) / sqrt(nPair);
rFC = mean(pairData.rFC,1);     seFC = std(pairData.rFC,0,1) / sqrt(nPair);
rAET = mean(pairData.rAET,1);   seAET = std(pairData.rAET,0,1) / sqrt(nPair);
rFEC = mean(pairData.rFEC,1);   seFEC = std(pairData.rFEC,0,1) / sqrt(nPair);

hFig = figure("Visible","on"); hold on
xTickAcc = 1:4;
xTickFast = 6:9;
xOffset = 0.05;

bar(xTickAcc-xOffset,  rAC, BARWIDTH, 'FaceColor','r',   'EdgeColor','none', 'FaceAlpha',0.5)
bar(xTickFast-xOffset, rFC, BARWIDTH, 'FaceColor',GREEN, 'EdgeColor','none', 'FaceAlpha',0.5)

errorbar(xTickFast-xOffset, rFC,  seFC,  'Linestyle','-',  'LineWidth',LINEWIDTH, 'Color','k', 'CapSize',0)
errorbar(xTickFast+xOffset, rFEC, seFEC, 'Linestyle','--',  'LineWidth',LINEWIDTH, 'Color','k', 'CapSize',0)
errorbar(xTickAcc-xOffset,  rAC,  seAC,  'Linestyle','-',  'LineWidth',LINEWIDTH,  'Color','k', 'CapSize',0)
errorbar(xTickAcc+xOffset,  rAET, seAET, 'Linestyle',':',  'LineWidth',LINEWIDTH, 'Color','k', 'CapSize',0)
% legend({'','','Correct','Choice error','','Timing error'}, 'Location','northwest')

xticks([xTickAcc xTickFast]);  xticklabels([EPOCH EPOCH])
ylabel('Noise correlation');   ytickformat('%3.2f')
title(MONKEY + " - SEF-SEF - PS-PS - n = " + num2str(nPair))

ppretty([6,2]); drawnow
set(gca, 'XMinorTick','off')

% print(PRINTDIR + unitTest.ID(uu) + ".tif", '-dtiff'); close(hFig)
clearvars -except ROOTDIR* behavData* unitData* pairData*

% end % fxn : plot_NoiseCorr_X_FxnClass()
