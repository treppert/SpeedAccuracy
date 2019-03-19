function [ ] = plotVisRespSATcc(T_STIM, T_RESP, visResp, sdfMove, RT, ninfo)
%plotVisRespSATcc Summary of this function goes here
%   Detailed explanation goes here

figure()

tmp = [visResp.Acc ; visResp.Fast ; sdfMove.Acc ; sdfMove.Fast];
yLim = [min(tmp) max(tmp)];

%visual response
subplot(1,2,1); hold on
plot([0 0], yLim, 'k--')
plot(T_STIM-3500, visResp.Acc, 'r-', 'LineWidth',0.5)
plot(T_STIM-3500, visResp.Fast, '-', 'Color',[0 .7 0], 'LineWidth',0.5)
plot(ninfo.latVRAcc*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
plot(ninfo.latVRFast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
plot(RT.Acc*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
plot(RT.Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
xlim([T_STIM(1) T_STIM(end)]-3500)
print_session_unit(gca , ninfo,[], 'horizontal')

%activity from primary response
subplot(1,2,2); hold on
plot([0 0], yLim, 'k--')
plot(T_RESP.Acc-3500, sdfMove.Acc, 'r-', 'LineWidth',0.5)
plot(T_RESP.Fast-3500, sdfMove.Fast, '-', 'Color',[0 .7 0], 'LineWidth',0.5)
plot(-RT.Acc*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
plot(-RT.Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
xlim([T_RESP.Acc(1) T_RESP.Acc(end)]-3500)
set(gca, 'YAxisLocation','right')

ppretty([8,3])

end%util:plotVisRespSATcc()

