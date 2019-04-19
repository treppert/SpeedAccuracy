function [  ] = plotRTXtrial( binfo , moves , varargin )
%plotRTXtrial Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

[binfo, moves, ~] = utilIsolateMonkeyBehavior(binfo, moves, cell(1,length(binfo)), args.monkey);
NUM_SESSION = length(binfo);

MIN_NUM_TRIALS = 8;

TRIAL_PLOT = ( -4 : 3 );
NUM_TRIAL = length(TRIAL_PLOT);

rtA2F{1} = NaN(NUM_SESSION,NUM_TRIAL); rtA2F{2} = rtA2F{1};
rtF2A{1} = NaN(NUM_SESSION,NUM_TRIAL); rtF2A{2} = rtF2A{1};

trialSwitch = identify_condition_switch(binfo);

%% Compute RT vs trial

for kk = 1:NUM_SESSION
  
  jjA2F = trialSwitch(kk).A2F;
  %if (Q or S), then add A2N trials to fill out A2F (!)
  if sum(ismember(args.monkey, {'Q','S'}))
    jjA2F = sort([jjA2F trialSwitch(kk).A2N]);
  end
  numA2F = length(jjA2F);
  
  jjF2A = trialSwitch(kk).F2A;  numF2A = length(jjF2A);
  
  if ((numA2F < MIN_NUM_TRIALS) || (numF2A < MIN_NUM_TRIALS))
    fprintf('Session %d -- Less than %d trials\n', kk, MIN_NUM_TRIALS)
    continue
  end
  
  %index by task (T/L or L/T)
  tt = binfo(kk).taskType;
  
  for jj = 1:NUM_TRIAL
    
    rtA2F{tt}(kk,jj) = mean(moves(kk).resptime(jjA2F + TRIAL_PLOT(jj)));
    rtF2A{tt}(kk,jj) = mean(moves(kk).resptime(jjF2A + TRIAL_PLOT(jj)));
    
  end%for:trials(jj)
  
end%for:sessions(kk)

%remove extra NaNs based on task (T/L or L/T)
idxTT1 = ([binfo.taskType] == 1);
idxTT2 = ([binfo.taskType] == 2);
rtA2F{1}(idxTT2,:) = []; rtF2A{1}(idxTT2,:) = [];
rtA2F{2}(idxTT1,:) = []; rtF2A{2}(idxTT1,:) = [];

%% Plotting

%remove sessions with insufficient number of switch trials
NUM_SEM = NaN(1,2);
for tt = 1:2
  idxNaN = isnan(rtA2F{tt}(:,1));
  rtA2F{tt}(idxNaN,:) = [];
  rtF2A{tt}(idxNaN,:) = [];
  NUM_SEM(tt) = size(rtA2F{tt}, 1);
end

figure(); hold on

errorbar(TRIAL_PLOT+0.1, mean(rtF2A{1}), std(rtF2A{1})/sqrt(NUM_SEM(1)), 'Color','k', 'LineWidth',0.75, 'CapSize',0)
errorbar(TRIAL_PLOT+NUM_TRIAL+0.1, mean(rtA2F{1}), std(rtA2F{1})/sqrt(NUM_SEM(1)), 'Color','k', 'LineWidth',0.75, 'CapSize',0)
errorbar(TRIAL_PLOT-0.1, mean(rtF2A{2}), std(rtF2A{2})/sqrt(NUM_SEM(2)), 'Color','k', 'LineWidth',1.25, 'CapSize',0)
errorbar(TRIAL_PLOT+NUM_TRIAL-0.1, mean(rtA2F{2}), std(rtA2F{2})/sqrt(NUM_SEM(2)), 'Color','k', 'LineWidth',1.25, 'CapSize',0)

xlim([-5 12]); xticks(-4:11); xticklabels(cell(1,12))
ppretty([6.4,4])

end%function:plotRTXtrial()

