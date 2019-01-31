function [  ] = plot_probTE_vs_switch( info , monkey )
%plot_probTE_vs_switch Summary of this function goes here
%   Detailed explanation goes here

MIN_NUM_TRIALS = 10;
NUM_SESSION = length(info);

TRIAL_PLOT = ( -4 : 3 );
NUM_TRIAL = length(TRIAL_PLOT);

pErrA2F = NaN(NUM_SESSION,NUM_TRIAL);
pErrF2A = NaN(NUM_SESSION,NUM_TRIAL);

trial_switch = identify_condition_switch(info, monkey);

%% Compute probability of error vs trial

for kk = 1:NUM_SESSION
  
  jjErrTime = find(info(kk).err_time);
  
  jjA2F = trial_switch(kk).A2F;  numA2F = length(jjA2F);
  jjF2A = trial_switch(kk).F2A;  numF2A = length(jjF2A);
  
  if ((numA2F < MIN_NUM_TRIALS) || (numF2A < MIN_NUM_TRIALS))
    fprintf('Session %d -- Less than %d trials\n', kk, MIN_NUM_TRIALS)
    continue
  end
  
  for jj = 1:NUM_TRIAL
    
    pErrA2F(kk,jj) = length(intersect(jjErrTime,jjA2F + TRIAL_PLOT(jj))) / numA2F;
    pErrF2A(kk,jj) = length(intersect(jjErrTime,jjF2A + TRIAL_PLOT(jj))) / numF2A;
    
  end%for:trials(jj)
  
end%for:sessions(kk)

%% Plotting

%remove sessions with insufficient number of "switch" trials
idxNaN = isnan(pErrA2F(:,1));
pErrA2F(idxNaN,:) = [];
pErrF2A(idxNaN,:) = [];
[NUM_SEM,~] = size(pErrA2F);

figure(); hold on

errorbar_no_caps(TRIAL_PLOT, mean(pErrF2A), 'err',std(pErrF2A)/sqrt(NUM_SEM), 'color','k')
errorbar_no_caps(TRIAL_PLOT+NUM_TRIAL, mean(pErrA2F), 'err',std(pErrA2F)/sqrt(NUM_SEM), 'color','k')

xlim([-5 12]); xticks(-5:12); xticklabels(cell(1,12))
ppretty()

end%function:plot_probTE_vs_switch()

