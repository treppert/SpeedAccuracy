function [ ] = plotSDFChcErrSATcc( T_1 , T_2 , SDFcc , ninfo , nstats )
%plotSDFChcErrSATcc Summary of this function goes here
%   T_1 - Time from primary saccade (ms)
%   T_2 - Time from secondary saccade (ms)
%   SDFcc - Struct with fields CorrRe1, ErrRe1, CorrRe2, ErrRe2
% 

figure()

tmp = [SDFcc.CorrRe1 SDFcc.CorrRe2 SDFcc.ErrRe1 SDFcc.ErrRe2];
yLim = [min(tmp) max(tmp)];

%% Time from primary saccade
subplot(1,2,1); hold on
plot([0 0], yLim, 'k:')

plot(T_1-3500, SDFcc.CorrRe1, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(T_1-3500, SDFcc.ErrRe1, ':', 'Color',[0 .7 0], 'LineWidth',1.0)

plot(nstats.tChcErrFast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)

% plot(RT.Acc*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
% plot(RT.Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)

xlim([T_1(1) T_1(end)]-3500)
xlabel('Time from primary saccade (ms)')
ylabel('Activity (sp/sec)')

title(['Eff. = ',num2str(ninfo.taskType)], 'FontSize',8)
print_session_unit(gca , ninfo,[])

%% Time from secondary saccade
subplot(1,2,2); hold on
plot([0 0], yLim, 'k--')

% plot(T_2-3500, SDFcc.CorrRe2, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(T_2-3500, SDFcc.ErrRe2, ':', 'Color',[0 .7 0], 'LineWidth',1.0)

% plot(-RT.Acc*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
% plot(-RT.Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)

xlim([T_2(1) T_2(end)]-3500)
xlabel('Time from secondary saccade (ms)')
set(gca, 'YAxisLocation','right')

ppretty([8,3])

end%util:plotSDFChcErrSATcc()

