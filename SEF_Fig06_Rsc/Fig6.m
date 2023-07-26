% Fig6.m -- Figure 6 header file

%% Specify trials with poor isolation from each recording session
% %cell array -- trial with poor isolation quality (Unit-Data-SAT.xlsx)
% trialRemove = cell(16,1); %16 recording sessions
% for kk = 1:16; trialRemove{kk} = [1 1]; end
% trialRemove{5} = [495 800];
% trialRemove{7} = [1 330];
% trialRemove{11} = [1029 1200];%SEF [150 275];%C
% trialRemove{12} = [1 150];%SEF     [525 625];%SC
% trialRemove{13} = [1776 1849];
% trialRemove{16} = [1 100];

%% Signal correlation
% computeSigCorr_X_Session %sig corr values for export to Excel
% plot_SignalCorr_SAT %scatter plots for individual pairs of neurons

%% Noise correlation
% computeNoiseCorr_X_FxnClass
% computeNoiseCorr_X_Session %noise corr values for export to Excel
% plot_NoiseCorr_X_Direction %plot noise corr vs direction vs epoch


%% Post-processing
nPair = size(pairData,1);
rAC = mean(pairData.rAC,1);     seAC = std(pairData.rAC,0,1) / sqrt(nPair);
rFC = mean(pairData.rFC,1);     seFC = std(pairData.rFC,0,1) / sqrt(nPair);
rAET = mean(pairData.rAET,1);   seAET = std(pairData.rAET,0,1) / sqrt(nPair);
rFEC = mean(pairData.rFEC,1);   seFEC = std(pairData.rFEC,0,1) / sqrt(nPair);


%% Plotting
PRINTDIR = 'C:\Users\thoma\Dropbox\SAT-Local\Figures\';

colorArea = colororder; %colors for time epochs [BL VR PS PR]
colorArea = colorArea(1:4,:);

EPOCH = {'BL' 'VR' 'PS' 'PR'}; %time intervals of interest
nEpoch = 4;

hFig = figure("Visible","on"); hold on
GREEN = [0 .7 0];
BARWIDTH = 0.6;
xTickAcc = 1:4;
xTickFast = 6:9;
XOFFSET = 0.06;
TICKFORMAT = "%3.2f";

bar(xTickAcc-XOFFSET,  rAC, BARWIDTH, 'FaceColor','r',   'EdgeColor','none')
bar(xTickFast-XOFFSET, rFC, BARWIDTH, 'FaceColor',GREEN, 'EdgeColor','none')

LINEWIDTH = 1.4;
errorbar(xTickFast-XOFFSET, rFC,  seFC,  'Linestyle','-',  'LineWidth',LINEWIDTH, 'Color','k', 'CapSize',0)
errorbar(xTickFast+XOFFSET, rFEC, seFEC, 'Linestyle','--',  'LineWidth',LINEWIDTH, 'Color','k', 'CapSize',0)
errorbar(xTickAcc-XOFFSET,  rAC,  seAC,  'Linestyle','-',  'LineWidth',LINEWIDTH,  'Color','k', 'CapSize',0)
errorbar(xTickAcc+XOFFSET,  rAET, seAET, 'Linestyle',':',  'LineWidth',LINEWIDTH, 'Color','k', 'CapSize',0)

% legend({'','','Correct','Choice error','','Timing error'}, 'Location','northwest')

xticks([xTickAcc xTickFast])
xticklabels([EPOCH EPOCH])
ylabel('Noise correlation')
ytickformat('%3.2f')

ppretty([6,2]); drawnow

% print(PRINTDIR + unitTest.ID(uu) + ".tif", '-dtiff'); close(hFig)

clearvars -except ROOTDIR* behavData* unitData* pairData*