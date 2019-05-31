function [ ] = plotVisRespSATcc(T_STIM, T_RESP, visResp, sdfMove, ninfo, nstats, varargin)
%plotVisRespSATcc Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'tVec=',[]}});

figure()

tmp = [visResp.AccTin ; visResp.FastTin ; sdfMove.AccTin ; sdfMove.FastTin];
yLim = [min(tmp) max(tmp)];

%visual response
subplot(1,2,1); hold on
plot([0 0], yLim, 'k--')

plot(T_STIM-3500, visResp.AccTin, 'r-', 'LineWidth',0.75)
plot(T_STIM-3500, visResp.AccDin, 'r--', 'LineWidth',0.5)
plot(T_STIM-3500, visResp.FastTin, '-', 'Color',[0 .7 0], 'LineWidth',0.75)
plot(T_STIM-3500, visResp.FastDin, '--', 'Color',[0 .7 0], 'LineWidth',0.5)

plot(nstats.VRlatAcc*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
plot(nstats.VRlatFast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
plot(nstats.VRTSTAcc*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
plot(nstats.VRTSTFast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
plot([T_STIM(1) T_STIM(end)]-3500, nstats.blineAccMEAN*ones(1,2), 'r:', 'LineWidth',0.5)
plot([T_STIM(1) T_STIM(end)]-3500, nstats.blineFastMEAN*ones(1,2), ':', 'Color',[0 .7 0], 'LineWidth',0.5)

if ~isempty(args.tVec) %plot vector of timestamps of target selection
  plot(args.tVec.Acc, yLim(1)+diff(yLim)*.1, '.', 'MarkerSize',10, 'Color',[.5 0 0])
  plot(args.tVec.Fast, yLim(1)+diff(yLim)*.05, '.', 'MarkerSize',10, 'Color',[0 .4 0])
end

% plot(RT.Acc*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
% plot(RT.Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)

title(['magAcc = ',num2str(nstats.VRmagAcc), '  magFast = ',num2str(nstats.VRmagFast), ...
  '  Eff. = ',num2str(ninfo.taskType)], 'FontSize',8)
xlim([T_STIM(1) T_STIM(end)]-3500)
xlabel('Time from array (ms)')
ylabel('Activity (sp/sec)')
print_session_unit(gca , ninfo,[])

%activity from primary response
IDX_FAST = (151 : length(T_RESP));
subplot(1,2,2); hold on
plot([0 0], yLim, 'k--')
plot(T_RESP-3500, sdfMove.AccTin, 'r-', 'LineWidth',0.75)
plot(T_RESP-3500, sdfMove.AccDin, 'r--', 'LineWidth',0.5)
plot(T_RESP(IDX_FAST)-3500, sdfMove.FastTin(IDX_FAST), '-', 'Color',[0 .7 0], 'LineWidth',0.75)
plot(T_RESP(IDX_FAST)-3500, sdfMove.FastDin(IDX_FAST), '--', 'Color',[0 .7 0], 'LineWidth',0.5)
% plot(-RT.Acc*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
% plot(-RT.Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
xlim([T_RESP(1) T_RESP(end)]-3500)
xlabel('Time from response (ms)')
set(gca, 'YAxisLocation','right')

ppretty([10,2.5])

end%util:plotVisRespSATcc()

