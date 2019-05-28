function [ ] = plotSDFChcErrXisiSATcc( TIME , sdfPlot , ninfo , nstats )
%plotSDFChcErrXisiSATcc Summary of this function goes here
%   TIME.PRIMARY - Time from primary saccade (ms)
%   TIME.SECONDARY - Time from secondary saccade (ms)
%   SDFcc - Struct with fields CorrRe1, ErrRe1, CorrRe2, ErrRe2
% 

%compute y-limits for vertical lines
tmp = [sdfPlot.AccCorrSH.RePrimary ; sdfPlot.AccCorrSH.ReSecondary ; sdfPlot.AccErrSH.RePrimary ; sdfPlot.AccErrSH.ReSecondary ; ...
  sdfPlot.FastCorrSH.RePrimary ; sdfPlot.FastCorrSH.ReSecondary ; sdfPlot.FastErrSH.RePrimary ; sdfPlot.FastErrSH.ReSecondary ; ...
  sdfPlot.AccCorrLO.RePrimary ; sdfPlot.AccCorrLO.ReSecondary ; sdfPlot.AccErrLO.RePrimary ; sdfPlot.AccErrLO.ReSecondary ; ...
  sdfPlot.FastCorrLO.RePrimary ; sdfPlot.FastCorrLO.ReSecondary ; sdfPlot.FastErrLO.RePrimary ; sdfPlot.FastErrLO.ReSecondary];

yLim = [min(tmp) max(tmp)];

figure()

%% Fast condition

%Time from primary saccade
subplot(2,2,1); hold on
plot([0 0], yLim, 'k:')

plot(TIME.PRIMARY-3500, sdfPlot.FastCorrSH.RePrimary, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdfPlot.FastErrSH.RePrimary, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdfPlot.FastCorrLO.RePrimary, '-', 'Color',[0 .4 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdfPlot.FastErrLO.RePrimary, ':', 'Color',[0 .4 0], 'LineWidth',1.0)

% plot(nstats.A_ChcErr_tErr_Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
% plot(nstats.A_ChcErr_tErrEnd_Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0)

xlim([TIME.PRIMARY(1) TIME.PRIMARY(end)]-3500); xticks((TIME.PRIMARY(1):50:TIME.PRIMARY(end))-3500)
ylabel('Activity (sp/sec)')
% title(['Magnitude = ', num2str(round(nstats.A_ChcErr_magErr_Fast)), ' sp/s'])
print_session_unit(gca , ninfo,[])


%Time from secondary saccade
subplot(2,2,2); hold on
plot([0 0], yLim, 'k:')

plot(TIME.SECONDARY-3500, sdfPlot.FastCorrSH.ReSecondary, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.SECONDARY-3500, sdfPlot.FastErrSH.ReSecondary, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.SECONDARY-3500, sdfPlot.FastCorrLO.ReSecondary, '-', 'Color',[0 .4 0], 'LineWidth',1.0)
plot(TIME.SECONDARY-3500, sdfPlot.FastErrLO.ReSecondary, ':', 'Color',[0 .4 0], 'LineWidth',1.0)

xlim([TIME.SECONDARY(1) TIME.SECONDARY(end)]-3500); xticks((TIME.SECONDARY(1):50:TIME.SECONDARY(end))-3500)
set(gca, 'YAxisLocation','right')


%% Accurate condition

%Time from primary saccade
subplot(2,2,3); hold on
plot([0 0], yLim, 'k:')

plot(TIME.PRIMARY-3500, sdfPlot.AccCorrSH.RePrimary, '-', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdfPlot.AccErrSH.RePrimary, ':', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdfPlot.AccCorrLO.RePrimary, '-', 'Color',[.5 0 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdfPlot.AccErrLO.RePrimary, ':', 'Color',[.5 0 0], 'LineWidth',1.0)

% plot(nstats.A_ChcErr_tErr_Acc*ones(1,2), yLim, ':', 'Color',[1 0 0], 'LineWidth',1.0)
% plot(nstats.A_ChcErr_tErrEnd_Acc*ones(1,2), yLim, ':', 'Color',[1 0 0], 'LineWidth',1.0)

xlim([TIME.PRIMARY(1) TIME.PRIMARY(end)]-3500); xticks((TIME.PRIMARY(1):50:TIME.PRIMARY(end))-3500)
ylabel('Activity (sp/sec)')
xlabel('Time from primary saccade (ms)')
% title(['Magnitude = ', num2str(round(nstats.A_ChcErr_magErr_Acc)), ' sp/s'])


%Time from secondary saccade
subplot(2,2,4); hold on
plot([0 0], yLim, 'k:')

plot(TIME.SECONDARY-3500, sdfPlot.AccCorrSH.ReSecondary, '-', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.SECONDARY-3500, sdfPlot.AccErrSH.ReSecondary, ':', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.SECONDARY-3500, sdfPlot.AccCorrLO.ReSecondary, '-', 'Color',[.5 0 0], 'LineWidth',1.0)
plot(TIME.SECONDARY-3500, sdfPlot.AccErrLO.ReSecondary, ':', 'Color',[.5 0 0], 'LineWidth',1.0)

xlim([TIME.SECONDARY(1) TIME.SECONDARY(end)]-3500); xticks((TIME.SECONDARY(1):50:TIME.SECONDARY(end))-3500)
xlabel('Time from secondary saccade (ms)')
set(gca, 'YAxisLocation','right')

ppretty([12,4.8])

end%util:plotSDFChcErrXisiSATcc()

