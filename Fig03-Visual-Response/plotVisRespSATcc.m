function [ ] = plotVisRespSATcc(T_STIM, visResp, ninfo, nstats, varargin)
%plotVisRespSATcc Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'tVec=',[]}});

figure(); hold on

tmp = [visResp.AccTin ; visResp.FastTin];
yLim = [min(tmp) max(tmp)];

subplot(2,1,1); hold on %Fast condition
plot([0 0], yLim, 'k--')
plot(T_STIM-3500, visResp.FastTin, '-', 'Color',[0 .7 0], 'LineWidth',0.75)
plot(T_STIM-3500, visResp.FastDin, '--', 'Color',[0 .7 0], 'LineWidth',0.5)
plot(nstats.VRlatFast*ones(1,2), yLim, 'k:', 'LineWidth',0.5)
plot(nstats.VRTSTFast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
% plot([T_STIM(1) T_STIM(end)]-3500, nstats.blineFastMEAN*ones(1,2), ':', 'Color',[0 .7 0], 'LineWidth',0.5)
title(['mag(A) = ',num2str(nstats.VRmagAcc)], 'FontSize',8)
print_session_unit(gca , ninfo,[])

subplot(2,1,2); hold on %Accurate condition
plot([0 0], yLim, 'k--')
plot(T_STIM-3500, visResp.AccTin, 'r-', 'LineWidth',0.75)
plot(T_STIM-3500, visResp.AccDin, 'r--', 'LineWidth',0.5)
plot(nstats.VRlatAcc*ones(1,2), yLim, 'k:', 'LineWidth',0.5)
plot(nstats.VRTSTAcc*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
% plot([T_STIM(1) T_STIM(end)]-3500, nstats.blineAccMEAN*ones(1,2), 'r:', 'LineWidth',0.5)
title(['mag(A) = ',num2str(nstats.VRmagFast)], 'FontSize',8)
xlabel('Time from array (ms)')
ylabel('Activity (sp/sec)')

ppretty([6,4])

% if ~isempty(args.tVec) %plot vector of timestamps of target selection
%   plot(args.tVec.Acc, yLim(1)+diff(yLim)*.1, '.', 'MarkerSize',10, 'Color',[.5 0 0])
%   plot(args.tVec.Fast, yLim(1)+diff(yLim)*.05, '.', 'MarkerSize',10, 'Color',[0 .4 0])
% end


end%util:plotVisRespSATcc()

