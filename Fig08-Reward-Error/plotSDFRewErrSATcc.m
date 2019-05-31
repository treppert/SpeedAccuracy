function [ ] = plotSDFRewErrSATcc( TIME , sdfPlot , ninfo , nstats )
%plotSDFRewErrSATcc Summary of this function goes here
% 

%compute y-limits for vertical lines
tmp = [sdfPlot.AccCorr.Reward ; sdfPlot.AccErr.Reward ; sdfPlot.FastCorr.Reward ; sdfPlot.FastErr.Reward ; ...
  sdfPlot.AccCorr.Response ; sdfPlot.AccErr.Response ; sdfPlot.FastCorr.Response ; sdfPlot.FastErr.Response ; ...
  sdfPlot.AccCorr.Stimulus ; sdfPlot.AccErr.Stimulus ; sdfPlot.FastCorr.Stimulus ; sdfPlot.FastErr.Stimulus];
yLim = [min(tmp) max(tmp)];

figure()

%% Fast condition

% %Time-locked to array
% subplot(2,3,1); hold on
% plot([0 0], yLim, 'k:')
% 
% plot(TIME.STIMULUS-3500, sdfPlot.FastCorr.Stimulus, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
% plot(TIME.STIMULUS-3500, sdfPlot.FastErr.Stimulus, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
% 
% xlim([TIME.STIMULUS(1) TIME.STIMULUS(end)]-3500); xticks((TIME.STIMULUS(1):100:TIME.STIMULUS(end))-3500)
% ylabel('Activity (sp/sec)')
% print_session_unit(gca , ninfo,[])
% 
% %Time-locked to response
% subplot(2,3,2); hold on
% plot([0 0], yLim, 'k:')
% 
% plot(TIME.RESPONSE-3500, sdfPlot.FastCorr.Response, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
% plot(TIME.RESPONSE-3500, sdfPlot.FastErr.Response, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
% 
% xlim([TIME.RESPONSE(1) TIME.RESPONSE(end)]-3500); xticks((TIME.RESPONSE(1):100:TIME.RESPONSE(end))-3500)

%Time-locked to reward
% subplot(2,3,3); hold on
subplot(2,1,1); hold on
plot([0 0], yLim, 'k:')

plot(TIME.REWARD-3500, sdfPlot.FastCorr.Reward, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.REWARD-3500, sdfPlot.FastErr.Reward, ':', 'Color',[0 .7 0], 'LineWidth',1.0)

plot(nstats.A_Reward_tErrStart_Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.25)
plot(nstats.A_Reward_tErrEnd_Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.25)

xlim([TIME.REWARD(1) TIME.REWARD(end)]-3500); xticks((TIME.REWARD(1):50:TIME.REWARD(end))-3500)
print_session_unit(gca , ninfo,[])

%% Accurate condition

% %Time-locked to array
% subplot(2,3,4); hold on
% plot([0 0], yLim, 'k:')
% 
% plot(TIME.STIMULUS-3500, sdfPlot.AccCorr.Stimulus, 'r-', 'LineWidth',1.0)
% plot(TIME.STIMULUS-3500, sdfPlot.AccErr.Stimulus, 'r:', 'LineWidth',1.0)
% 
% xlim([TIME.STIMULUS(1) TIME.STIMULUS(end)]-3500); xticks((TIME.STIMULUS(1):100:TIME.STIMULUS(end))-3500)
% ylabel('Activity (sp/sec)')
% xlabel('Time from array (ms)')
% 
% %Time-locked to response
% subplot(2,3,5); hold on
% plot([0 0], yLim, 'k:')
% 
% plot(TIME.RESPONSE-3500, sdfPlot.AccCorr.Response, 'r-', 'LineWidth',1.0)
% plot(TIME.RESPONSE-3500, sdfPlot.AccErr.Response, 'r:', 'LineWidth',1.0)
% 
% xlim([TIME.RESPONSE(1) TIME.RESPONSE(end)]-3500); xticks((TIME.RESPONSE(1):100:TIME.RESPONSE(end))-3500)
% xlabel('Time from response (ms)')

%Time-locked to reward
% subplot(2,3,6); hold on
subplot(2,1,2); hold on
plot([0 0], yLim, 'k:')

plot(TIME.REWARD-3500, sdfPlot.AccCorr.Reward, 'r-', 'LineWidth',1.0)
plot(TIME.REWARD-3500, sdfPlot.AccErr.Reward, 'r:', 'LineWidth',1.0)

plot(nstats.A_Reward_tErrStart_Acc*ones(1,2), yLim, 'r:', 'LineWidth',1.25)
plot(nstats.A_Reward_tErrEnd_Acc*ones(1,2), yLim, 'r:', 'LineWidth',1.25)

xlim([TIME.REWARD(1) TIME.REWARD(end)]-3500); xticks((TIME.REWARD(1):50:TIME.REWARD(end))-3500)
xlabel('Time from reward (ms)')

ppretty([4.8,3])

end%util:plotSDFRewErrSATcc()

