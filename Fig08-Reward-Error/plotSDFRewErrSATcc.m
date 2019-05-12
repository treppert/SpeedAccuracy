function [ ] = plotSDFRewErrSATcc( TIME , sdfPlot , ninfo , nstats )
%plotSDFRewErrSATcc Summary of this function goes here
% 

%compute y-limits for vertical lines
tmp = [sdfPlot.AccCorr.Reward ; sdfPlot.AccErr.Reward ; sdfPlot.FastCorr.Reward ; sdfPlot.FastErrNoClear.Reward ; ...
  sdfPlot.AccCorr.Response ; sdfPlot.AccErr.Response ; sdfPlot.FastCorr.Response ; sdfPlot.FastErrNoClear.Response ; ...
  sdfPlot.AccCorr.Stimulus ; sdfPlot.AccErr.Stimulus ; sdfPlot.FastCorr.Stimulus ; sdfPlot.FastErrNoClear.Stimulus];
yLim = [min(tmp) max(tmp)];

figure()

%% Fast condition

%Time-locked to array
subplot(2,3,1); hold on
plot([0 0], yLim, 'k:')

plot(TIME.STIMULUS-3500, sdfPlot.FastCorr.Stimulus, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.STIMULUS-3500, sdfPlot.FastErrNoClear.Stimulus, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.STIMULUS-3500, sdfPlot.FastErrClear.Stimulus, ':', 'Color','k', 'LineWidth',1.0)

xlim([TIME.STIMULUS(1) TIME.STIMULUS(end)]-3500); xticks((TIME.STIMULUS(1):100:TIME.STIMULUS(end))-3500)
ylabel('Activity (sp/sec)')
print_session_unit(gca , ninfo,[])

%Time-locked to response
subplot(2,3,2); hold on
plot([0 0], yLim, 'k:')

plot(TIME.RESPONSE-3500, sdfPlot.FastCorr.Response, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.RESPONSE-3500, sdfPlot.FastErrNoClear.Response, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.RESPONSE-3500, sdfPlot.FastErrClear.Response, ':', 'Color','k', 'LineWidth',1.0)

xlim([TIME.RESPONSE(1) TIME.RESPONSE(end)]-3500); xticks((TIME.RESPONSE(1):100:TIME.RESPONSE(end))-3500)

%Time-locked to reward
subplot(2,3,3); hold on
plot([0 0], yLim, 'k:')

plot(TIME.REWARD-3500, sdfPlot.FastCorr.Reward, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.REWARD-3500, sdfPlot.FastErrNoClear.Reward, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.REWARD-3500, sdfPlot.FastErrClear.Reward, ':', 'Color','k', 'LineWidth',1.0)

% plot(nstats.A_ChcErr_tErr_Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
% plot(nstats.A_ChcErr_tErrEnd_Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0)

xlim([TIME.REWARD(1) TIME.REWARD(end)]-3500); xticks((TIME.REWARD(1):100:TIME.REWARD(end))-3500)

%% Accurate condition

%Time-locked to array
subplot(2,3,4); hold on
plot([0 0], yLim, 'k:')

plot(TIME.STIMULUS-3500, sdfPlot.AccCorr.Stimulus, 'r-', 'LineWidth',1.0)
plot(TIME.STIMULUS-3500, sdfPlot.AccErr.Stimulus, 'r:', 'LineWidth',1.0)
% plot(TIME.STIMULUS-3500, sdfPlot.AccErrBetter.Stimulus, 'r:', 'LineWidth',1.0)
% plot(TIME.STIMULUS-3500, sdfPlot.AccErrWorse.Stimulus, ':', 'Color',[.4 0 0], 'LineWidth',1.0)

xlim([TIME.STIMULUS(1) TIME.STIMULUS(end)]-3500); xticks((TIME.STIMULUS(1):100:TIME.STIMULUS(end))-3500)
ylabel('Activity (sp/sec)')
xlabel('Time from array (ms)')

%Time-locked to response
subplot(2,3,5); hold on
plot([0 0], yLim, 'k:')

plot(TIME.RESPONSE-3500, sdfPlot.AccCorr.Response, 'r-', 'LineWidth',1.0)
plot(TIME.RESPONSE-3500, sdfPlot.AccErr.Response, 'r:', 'LineWidth',1.0)
% plot(TIME.RESPONSE-3500, sdfPlot.AccErrBetter.Response, 'r:', 'LineWidth',1.0)
% plot(TIME.RESPONSE-3500, sdfPlot.AccErrWorse.Response, ':', 'Color',[.4 0 0], 'LineWidth',1.0)

xlim([TIME.RESPONSE(1) TIME.RESPONSE(end)]-3500); xticks((TIME.RESPONSE(1):100:TIME.RESPONSE(end))-3500)
xlabel('Time from response (ms)')

%Time-locked to reward
subplot(2,3,6); hold on
plot([0 0], yLim, 'k:')

plot(TIME.REWARD-3500, sdfPlot.AccCorr.Reward, 'r-', 'LineWidth',1.0)
plot(TIME.REWARD-3500, sdfPlot.AccErr.Reward, 'r:', 'LineWidth',1.0)
% plot(TIME.REWARD-3500, sdfPlot.AccErrBetter.Reward, 'r:', 'LineWidth',1.0)
% plot(TIME.REWARD-3500, sdfPlot.AccErrWorse.Reward, ':', 'Color',[.4 0 0], 'LineWidth',1.0)

plot(nstats.A_Reward_tErrStart_Acc*ones(1,2), yLim, ':', 'Color',[1 0 0], 'LineWidth',1.25)
plot(nstats.A_Reward_tErrEnd_Acc*ones(1,2), yLim, ':', 'Color',[1 0 0], 'LineWidth',1.25)

xlim([TIME.REWARD(1) TIME.REWARD(end)]-3500); xticks((TIME.REWARD(1):100:TIME.REWARD(end))-3500)
xlabel('Time from reward (ms)')

ppretty([12,4])

end%util:plotSDFRewErrSATcc()

