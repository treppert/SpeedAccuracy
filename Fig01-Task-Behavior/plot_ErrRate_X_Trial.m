function [  ] = plot_ErrRate_X_Trial( binfo , varargin )
%plot_ErrRate_X_Trial Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

[binfo, ~, ~] = utilIsolateMonkeyBehavior(binfo, cell(1,length(binfo)), cell(1,length(binfo)), args.monkey);
NUM_SESSION = length(binfo);

MIN_NUM_TRIALS = 8;

TRIAL_PLOT = ( -4 : 3 );
NUM_TRIAL = length(TRIAL_PLOT);

pErrA2F{1} = NaN(NUM_SESSION,NUM_TRIAL); pErrA2F{2} = pErrA2F{1}; 
pErrF2A{1} = NaN(NUM_SESSION,NUM_TRIAL); pErrF2A{2} = pErrF2A{1};

trialSwitch = identify_condition_switch(binfo);

%% Compute probability of error vs trial

for kk = 1:NUM_SESSION
  
  jjErr = find(binfo(kk).err_time);
  
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
    pErrA2F{tt}(kk,jj) = length(intersect(jjErr,jjA2F + TRIAL_PLOT(jj))) / numA2F;
    pErrF2A{tt}(kk,jj) = length(intersect(jjErr,jjF2A + TRIAL_PLOT(jj))) / numF2A;
  end%for:trials(jj)
  
end%for:sessions(kk)

%remove extra NaNs based on task (T/L or L/T)
idxTT1 = ([binfo.taskType] == 1);
idxTT2 = ([binfo.taskType] == 2);
pErrA2F{1}(idxTT2,:) = []; pErrF2A{1}(idxTT2,:) = [];
pErrA2F{2}(idxTT1,:) = []; pErrF2A{2}(idxTT1,:) = [];

%% Statistics -- One-way ANOVA with factor Trial Number (combine across more and less efficient)
DV_ErrRate = [ [pErrF2A{1}(:,5:8) pErrA2F{1}(:,1:4)] ; [pErrF2A{2}(:,5:8) pErrA2F{2}(:,1:4)] ];
DV_ErrRate = reshape(DV_ErrRate', NUM_SESSION*NUM_TRIAL,1);
F_Trial = (1 : 8); F_Trial = repmat(F_Trial, 1,NUM_SESSION)';
anovan(DV_ErrRate, {F_Trial});

%save for ANOVA in R
save('C:\Users\Thomas Reppert\Dropbox\SAT\Stats\ErrRateXTrial.mat', 'F_Trial','DV_ErrRate')
return
%% Plotting

%remove sessions with insufficient number of "switch" trials
NUM_SEM = NaN(1,2);
for tt = 1:2
  idxNaN = isnan(pErrA2F{tt}(:,1));
  pErrA2F{tt}(idxNaN,:) = [];
  pErrF2A{tt}(idxNaN,:) = [];
  NUM_SEM(tt) = size(pErrA2F{tt}, 1);
end

figure(); hold on

% errorbar_no_caps(TRIAL_PLOT, mean(pErrF2A), 'err',std(pErrF2A)/sqrt(NUM_SEM), 'color','k')
% errorbar_no_caps(TRIAL_PLOT+NUM_TRIAL, mean(pErrA2F), 'err',std(pErrA2F)/sqrt(NUM_SEM), 'color','k')

errorbar(TRIAL_PLOT+0.1, mean(pErrF2A{1}), std(pErrF2A{1})/sqrt(NUM_SEM(1)), 'Color','k', 'LineWidth',0.75, 'CapSize',0)
errorbar(TRIAL_PLOT+NUM_TRIAL+0.1, mean(pErrA2F{1}), std(pErrA2F{1})/sqrt(NUM_SEM(1)), 'Color','k', 'LineWidth',0.75, 'CapSize',0)
errorbar(TRIAL_PLOT-0.1, mean(pErrF2A{2}), std(pErrF2A{2})/sqrt(NUM_SEM(2)), 'Color','k', 'LineWidth',1.75, 'CapSize',0)
errorbar(TRIAL_PLOT+NUM_TRIAL-0.1, mean(pErrA2F{2}), std(pErrA2F{2})/sqrt(NUM_SEM(2)), 'Color','k', 'LineWidth',1.75, 'CapSize',0)

xlim([-5 12]); xticks(-5:12); xticklabels(cell(1,12))
ppretty([6.4,4])

end%function:plot_ErrRate_X_Trial()

