function [ ] = plotSDFChcErrXendptSATcc( TIME , sdfPlot , ninfo , nstats )
%plotSDFChcErrXendptSATcc Summary of this function goes here
%   TIME.Primary - Time from primary saccade (ms)
%   TIME.Secondary - Time from secondary saccade (ms)
%   SDFcc - Struct with fields CorrRe1, ErrRe1, CorrRe2, ErrRe2
% 

%compute y-limits for vertical lines
tmp = [sdfPlot.AccCorr.Primary ; sdfPlot.AccCorr.Secondary ; sdfPlot.AccErrT.Primary ; sdfPlot.AccErrT.Secondary ; ...
  sdfPlot.FastCorr.Primary ; sdfPlot.FastCorr.Secondary ; sdfPlot.FastErrT.Primary ; sdfPlot.FastErrT.Secondary];
yLim = [min(tmp) max(tmp)];

figure()

%% Fast condition

%Time from primary saccade
subplot(2,2,1); hold on
plot([0 0], yLim, 'k:')

plot(TIME.Primary-3500, sdfPlot.FastCorr.Primary, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.Primary-3500, sdfPlot.FastErrT.Primary, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.Primary-3500, sdfPlot.FastErrD.Primary, ':', 'Color',[0 .3 0], 'LineWidth',1.0)

plot(nstats.A_ChcErr_tErr_Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(nstats.A_ChcErr_tErrEnd_Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0)

xlim([TIME.Primary(1) TIME.Primary(end)]-3500)
ylabel('Activity (sp/sec)')
print_session_unit(gca , ninfo,[])


%Time from secondary saccade
subplot(2,2,2); hold on
plot([0 0], yLim, 'k:')

plot(TIME.Secondary-3500, sdfPlot.FastCorr.Secondary, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.Secondary-3500, sdfPlot.FastErrT.Secondary, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.Secondary-3500, sdfPlot.FastErrD.Secondary, ':', 'Color',[0 .3 0], 'LineWidth',1.0)

xlim([TIME.Secondary(1) TIME.Secondary(end)]-3500)
set(gca, 'YAxisLocation','right')


%% Accurate condition

%Time from primary saccade
subplot(2,2,3); hold on
plot([0 0], yLim, 'k:')

plot(TIME.Primary-3500, sdfPlot.AccCorr.Primary, '-', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.Primary-3500, sdfPlot.AccErrT.Primary, ':', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.Primary-3500, sdfPlot.AccErrD.Primary, ':', 'Color',[.4 0 0], 'LineWidth',1.0)

plot(nstats.A_ChcErr_tErr_Acc*ones(1,2), yLim, ':', 'Color',[1 0 0], 'LineWidth',1.0)
plot(nstats.A_ChcErr_tErrEnd_Acc*ones(1,2), yLim, ':', 'Color',[1 0 0], 'LineWidth',1.0)

xlim([TIME.Primary(1) TIME.Primary(end)]-3500)
ylabel('Activity (sp/sec)')
xlabel('Time from primary saccade (ms)')


%Time from secondary saccade
subplot(2,2,4); hold on
plot([0 0], yLim, 'k:')

plot(TIME.Secondary-3500, sdfPlot.AccCorr.Secondary, '-', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.Secondary-3500, sdfPlot.AccErrT.Secondary, ':', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.Secondary-3500, sdfPlot.AccErrD.Secondary, ':', 'Color',[.4 0 0], 'LineWidth',1.0)

xlim([TIME.Secondary(1) TIME.Secondary(end)]-3500)
xlabel('Time from secondary saccade (ms)')
set(gca, 'YAxisLocation','right')

ppretty([10,4])

end%util:plotSDFChcErrXendptSATcc()

