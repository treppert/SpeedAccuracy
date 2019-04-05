function [ ] = plotVisRespSATcc(T_STIM, T_RESP, visResp, sdfMove, ninfo, nstats)
%plotVisRespSATcc Summary of this function goes here
%   Detailed explanation goes here

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
% plot(RT.Acc*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
% plot(RT.Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
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

ppretty([8,3])

end%util:plotVisRespSATcc()

