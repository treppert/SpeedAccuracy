function [ ] = plotBlineXAreaSAT( ninfo , nstats )
%plotBlineXAreaSAT Summary of this function goes here
%   Detailed explanation goes here

idxEff = ismember([ninfo.taskType], [2]);
idxSEF = (ismember({ninfo.area}, 'SEF') & ismember({ninfo.visType}, {'sustained'}) & idxEff);
idxFEF = (ismember({ninfo.area}, 'FEF') & ([ninfo.visGrade] >= 0.5) & idxEff);
idxSC = (ismember({ninfo.area}, 'SC') & ([ninfo.visGrade] >= 0.5) & idxEff);

blineDiffSEF = [nstats(idxSEF).blineFastMEAN] - [nstats(idxSEF).blineAccMEAN];
blineDiffFEF = [nstats(idxFEF).blineFastMEAN] - [nstats(idxFEF).blineAccMEAN];
blineDiffSC = [nstats(idxSC).blineFastMEAN] - [nstats(idxSC).blineAccMEAN];

figure(); hold on

hSEF = cdfplot(blineDiffSEF);
hFEF = cdfplot(blineDiffFEF);
% hSC = cdfplot(blineDiffSC);

plot([0 0], [.05 .95], 'k:')

legend([hSEF,hFEF], {'SEF','FEF'})
ylabel('Cumulative probability')
xlabel('Discharge rate diff. (sp/s)')
title([])
ytickformat('%2.1f')
grid off

ppretty([5,5])

end%fxn:plotBlineXAreaSAT()

