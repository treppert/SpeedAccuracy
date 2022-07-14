function [ ] = Fig6X_SpkCorr_X_Trial( spkCorr )
%Fig6X_SpkCorr_X_Trial Summary of this function goes here
%   Detailed explanation goes here

BLUE = [0 0 1];

figure(); hold on
errorbar(TRIAL_PLOT, mean(RT_F2A), std(RT_F2A)/sqrt(NUM_SESS), 'Color','k', 'CapSize',0)
errorbar(TRIAL_PLOT+NUM_TRIAL, mean(RT_A2F), std(RT_A2F)/sqrt(NUM_SESS), 'Color','k', 'CapSize',0)
xlim(XLIM); xticks(-5:12); xticklabels(XLABEL)
ylabel('Response time (ms)')

ppretty([1.6,1.2])
set(gca, 'XMinorTick','off', 'XTickLabelRotation',45, 'YColor',BLUE)

end % fxn : Fig6X_SpkCorr_X_Trial()

