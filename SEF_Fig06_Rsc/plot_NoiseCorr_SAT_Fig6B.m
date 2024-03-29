% plot_NoiseCorr_SAT_Fig6B.m
% This script produces plots for Figures 6 and S6 of the SAT manuscript.
% 
% Bar plots show the mean +/ SE noise correlation for Accurate Correct,
% Accurate Timing Error, Fast Correct, and Fast Choice Error trials.
% 
% Line plots show the change in noise correlation within-trial across the
% four main epochs (Baseline, Visual response, Post-saccade, Post-reward).
% 
% We used a two-way ANOVA with factors Condition (Fast/Accurate) and Trial
% Outcome (Correct/Error) to summarize the data.
% 

GREEN = [0 .7 0];
RED = [1 0 0];

EPOCH = {'BL' 'VR' 'PS' 'PR'}; %time intervals of interest
LINEWIDTH = 1.0;
BARWIDTH = 0.6;

hFig = figure("Visible","on");

%% Plotting - Correlation x epoch
subplot(1,3, [1 2]); hold on

%compute mean +/- SE correlation across pairs
rAC = mean(pairData.rAC,1);     seAC = std(pairData.rAC,0,1) / sqrt(nPair);
rFC = mean(pairData.rFC,1);     seFC = std(pairData.rFC,0,1) / sqrt(nPair);
rAET = mean(pairData.rAET,1);   seAET = std(pairData.rAET,0,1) / sqrt(nPair);
rFEC = mean(pairData.rFEC,1);   seFEC = std(pairData.rFEC,0,1) / sqrt(nPair);

%determine x-tick locations
xTickAcc = 1:4;
xTickFast = 5:8;
xOffset = 0.05;
xAC = xTickAcc - xOffset;   xAE = xTickAcc + xOffset;
xFC = xTickFast - xOffset;  xFE = xTickFast + xOffset;

%plotting
errorbar(xFC, rFC,  seFC,  'LineWidth',LINEWIDTH, 'Color',GREEN, 'CapSize',0)
errorbar(xFE, rFEC, seFEC, 'LineWidth',LINEWIDTH, 'Color',0.3*GREEN, 'CapSize',0)
errorbar(xAC,  rAC,  seAC,  'LineWidth',LINEWIDTH,  'Color',RED, 'CapSize',0)
errorbar(xAE,  rAET, seAET, 'LineWidth',LINEWIDTH, 'Color',0.3*RED, 'CapSize',0)
yline(0, 'Color','k')

%formatting
xlim([0.5 8.5]); xticks([])
yLim = get(gca, 'YLim'); ytickformat('%3.2f')
title(XAREA + "-" + YAREA + "    Fxn-Fxn    n = " + num2str(nPair))

%% Plotting - Mean correlation
subplot(1,3,3); hold on

%compute mean within-trial correlation (across epochs)
rAC = mean(pairData.rAC,2);
rFC = mean(pairData.rFC,2);
rAE = mean(pairData.rAET,2, "omitnan");
rFE = mean(pairData.rFEC,2, "omitnan");

%compute mean +/- SE correlation across pairs
rACmu = mean(rAC,1);  seAC = std(rAC,0,1) / sqrt(nPair);
rAEmu = mean(rAE,1);  seAE = std(rAE,0,1) / sqrt(nPair);
rFCmu = mean(rFC,1);  seFC = std(rFC,0,1) / sqrt(nPair);
rFEmu = mean(rFE,1);  seFE = std(rFE,0,1) / sqrt(nPair);

%plotting
bar(1, rACmu, BARWIDTH, 'FaceColor',RED, 'EdgeColor','none')
bar(2, rAEmu, BARWIDTH, 'FaceColor',0.3*RED, 'EdgeColor','none')
errorbar(1:2, [rACmu rAEmu], [seAC seAE], 'LineWidth',LINEWIDTH, 'Color','k', 'CapSize',0)

bar(3, rFCmu, BARWIDTH, 'FaceColor',GREEN, 'EdgeColor','none')
bar(4, rFEmu, BARWIDTH, 'FaceColor',0.3*GREEN, 'EdgeColor','none')
errorbar(3:4, [rFCmu rFEmu], [seFC seFE], 'LineWidth',LINEWIDTH, 'Color','k', 'CapSize',0)
yline(0, 'Color','k')

%formatting
xticks([]); xlim([0.3 4.7])
ylim(yLim)

ppretty([6,2]); drawnow
subplot(1,3,[1 2]); set(gca, 'XColor','none') 
subplot(1,3,3); set(gca, 'YColor','none'); set(gca, 'XColor','none')

%% Stats - Two-way ANOVA with factors Condition and Trial Outcome
rNoise = [rAC; rAE; rFC; rFE];
Condition = [ones(2*nPair,1); 2*ones(2*nPair,1)];
Outcome = [ones(nPair,1); 2*ones(nPair,1); ones(nPair,1); 2*ones(nPair,1)];
[pval,tabstat] = anovan(rNoise,{Condition,Outcome}, 'display','off', 'model','interaction', ...
  'varnames',{'Condition','Outcome'});

%% Stats - Three-way ANOVA with factors Condition, Trial Outcome, and Epoch
rAC_1 = pairData.rAC(:,1); rAE_1 = pairData.rAET(:,1); %Accurate condition
rAC_2 = pairData.rAC(:,2); rAE_2 = pairData.rAET(:,2);
rAC_3 = pairData.rAC(:,3); rAE_3 = pairData.rAET(:,3);
rAC_4 = pairData.rAC(:,4); rAE_4 = pairData.rAET(:,4);

rFC_1 = pairData.rFC(:,1); rFE_1 = pairData.rFEC(:,1); %Fast condition
rFC_2 = pairData.rFC(:,2); rFE_2 = pairData.rFEC(:,2);
rFC_3 = pairData.rFC(:,3); rFE_3 = pairData.rFEC(:,3);
rFC_4 = pairData.rFC(:,4); rFE_4 = pairData.rFEC(:,4);

rNoise = [rAC_1; rAC_2; rAC_3; rAC_4; rAE_1; rAE_2; rAE_3; rAE_4; ...
          rFC_1; rFC_2; rFC_3; rFC_4; rFE_1; rFE_2; rFE_3; rFE_4];
Condition = [ones(8*nPair,1); 2*ones(8*nPair,1)];
Outcome = [ones(4*nPair,1); 2*ones(4*nPair,1); ones(4*nPair,1); 2*ones(4*nPair,1)];
Epoch = [ones(nPair,1); 2*ones(nPair,1); 3*ones(nPair,1); 4*ones(nPair,1)];
Epoch = [Epoch; Epoch; Epoch; Epoch];
[pval_3,tabstat_3] = anovan(rNoise,{Condition,Outcome,Epoch}, 'display','off', 'model','interaction', ...
  'varnames',{'Condition','Outcome','Epoch'});

%% Clear variables
clearvars -except ROOTDIR* behavData* unitData* pairData* nPair *AREA tabstat* pval* rAC rAE
