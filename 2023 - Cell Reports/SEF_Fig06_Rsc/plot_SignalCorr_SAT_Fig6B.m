% plot_SignalCorr_SAT_Fig6B.m
% This script produces plots for Figures 6 and S6 of the SAT manuscript.
% 
% Bar plots show the mean +/ SE noise correlation for Accurate Correct,
% Accurate Timing Error, Fast Correct, and Fast Choice Error trials.
% 
% We used a two-way ANOVA with factors Condition (Fast/Accurate) and Trial
% Outcome (Correct/Error) to summarize the data.
% 

GREEN = [0 .7 0];
RED = [1 0 0];

BARWIDTH = 0.6;
LINEWIDTH = 1.0;

hFig = figure("Visible","on"); hold on

%retrieve signal correlation values from pairData
sigAC = pairData.sigAC;
sigAE = pairData.sigAET;
sigFC = pairData.sigFC;
sigFE = pairData.sigFEC;

%compute mean +/- SE signal correlation across pairs
rsigAC = mean(sigAC,1);  seAC = std(sigAC,0,1) / sqrt(nPair);
rsigAE = mean(sigAE,1);  seAE = std(sigAE,0,1) / sqrt(nPair);
rsigFC = mean(sigFC,1);  seFC = std(sigFC,0,1) / sqrt(nPair);
rsigFE = mean(sigFE,1);  seFE = std(sigFE,0,1) / sqrt(nPair);

%plotting
bar(1, rsigAC, BARWIDTH, 'FaceColor',RED, 'EdgeColor','none')
bar(2, rsigAE, BARWIDTH, 'FaceColor',0.3*RED, 'EdgeColor','none')
errorbar(1:2, [rsigAC rsigAE], [seAC seAE], 'LineWidth',LINEWIDTH, 'Color','k', 'CapSize',0)

bar(3, rsigFC, BARWIDTH, 'FaceColor',GREEN, 'EdgeColor','none')
bar(4, rsigFE, BARWIDTH, 'FaceColor',0.3*GREEN, 'EdgeColor','none')
errorbar(3:4, [rsigFC rsigFE], [seFC seFE], 'LineWidth',LINEWIDTH, 'Color','k', 'CapSize',0)
yline(0, 'Color','k')

%formatting
xticks([]); xlim([0.3 4.7])
ytickformat('%3.2f')
title(XAREA + "-" + YAREA + "    Fxn-Fxn    n = " + num2str(nPair))

ppretty([2,2]); drawnow
set(gca, 'XColor','none') 


%% Stats - Two-way ANOVA with factors Condition and Trial Outcome
rNoise = [sigAC; sigAE; sigFC; sigFE];
Condition = [ones(2*nPair,1); 2*ones(2*nPair,1)];
Outcome = [ones(nPair,1); 2*ones(nPair,1); ones(nPair,1); 2*ones(nPair,1)];
[pval,tabstat] = anovan(rNoise,{Condition,Outcome}, 'display','off', 'model','interaction', ...
  'varnames',{'Condition','Outcome'});

clearvars -except ROOTDIR* behavData* unitData* pairData* nPair *AREA tabstat
