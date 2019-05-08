function [ ] = plotSDFChcErrSATcc( TIME , sdfPlot , ninfo , nstats )
%plotSDFChcErrSATcc Summary of this function goes here
%   TIME.PRIMARY - Time from primary saccade (ms)
%   TIME.SECONDARY - Time from secondary saccade (ms)
%   SDFcc - Struct with fields CorrRe1, ErrRe1, CorrRe2, ErrRe2
% 

%compute y-limits for vertical lines
tmp = [sdfPlot.AccCorr.RePrimary ; sdfPlot.AccCorr.ReSecondary ; sdfPlot.AccErr.RePrimary ; sdfPlot.AccErr.ReSecondary ; ...
  sdfPlot.FastCorr.RePrimary ; sdfPlot.FastCorr.ReSecondary ; sdfPlot.FastErr.RePrimary ; sdfPlot.FastErr.ReSecondary];
yLim = [min(tmp) max(tmp)];

figure()

%% Fast condition

%Time from primary saccade
subplot(2,2,1); hold on
plot([0 0], yLim, 'k:')

plot(TIME.PRIMARY-3500, sdfPlot.FastCorr.RePrimary, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdfPlot.FastErr.RePrimary, ':', 'Color',[0 .7 0], 'LineWidth',1.0)

plot(nstats.A_ChcErr_tErr_Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(nstats.A_ChcErr_tErrEnd_Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0)

grid on
xlim([TIME.PRIMARY(1) TIME.PRIMARY(end)]-3500); xticks((TIME.PRIMARY(1):50:TIME.PRIMARY(end))-3500)
ylabel('Activity (sp/sec)')
print_session_unit(gca , ninfo,[])
title(['Magnitude = ', num2str(round(nstats.A_ChcErr_magErr_Fast)), ' sp/s'])


%Time from secondary saccade
subplot(2,2,2); hold on
plot([0 0], yLim, 'k:')

plot(TIME.SECONDARY-3500, sdfPlot.FastCorr.ReSecondary, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.SECONDARY-3500, sdfPlot.FastErr.ReSecondary, ':', 'Color',[0 .7 0], 'LineWidth',1.0)

xlim([TIME.SECONDARY(1) TIME.SECONDARY(end)]-3500); xticks((TIME.SECONDARY(1):50:TIME.SECONDARY(end))-3500)
set(gca, 'YAxisLocation','right')


%% Accurate condition

%Time from primary saccade
subplot(2,2,3); hold on
plot([0 0], yLim, 'k:')

plot(TIME.PRIMARY-3500, sdfPlot.AccCorr.RePrimary, '-', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdfPlot.AccErr.RePrimary, ':', 'Color',[1 0 0], 'LineWidth',1.0)

plot(nstats.A_ChcErr_tErr_Acc*ones(1,2), yLim, ':', 'Color',[1 0 0], 'LineWidth',1.0)
plot(nstats.A_ChcErr_tErrEnd_Acc*ones(1,2), yLim, ':', 'Color',[1 0 0], 'LineWidth',1.0)

grid on
xlim([TIME.PRIMARY(1) TIME.PRIMARY(end)]-3500); xticks((TIME.PRIMARY(1):50:TIME.PRIMARY(end))-3500)
ylabel('Activity (sp/sec)')
xlabel('Time from primary saccade (ms)')
title(['Magnitude = ', num2str(round(nstats.A_ChcErr_magErr_Acc)), ' sp/s'])


%Time from secondary saccade
subplot(2,2,4); hold on
plot([0 0], yLim, 'k:')

plot(TIME.SECONDARY-3500, sdfPlot.AccCorr.ReSecondary, '-', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.SECONDARY-3500, sdfPlot.AccErr.ReSecondary, ':', 'Color',[1 0 0], 'LineWidth',1.0)

xlim([TIME.SECONDARY(1) TIME.SECONDARY(end)]-3500); xticks((TIME.SECONDARY(1):50:TIME.SECONDARY(end))-3500)
xlabel('Time from secondary saccade (ms)')
set(gca, 'YAxisLocation','right')


ppretty([12,4.8])

end%util:plotSDFChcErrSATcc()

