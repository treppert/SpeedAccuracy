function [  ] = plotRTXtrial( binfo , moves )
%plotRTXtrial Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(binfo);
MIN_NUM_TRIALS = 8;

TRIAL_PLOT = ( -4 : 3 );
NUM_TRIAL = length(TRIAL_PLOT);

rtA2F = NaN(NUM_SESSION,NUM_TRIAL);
rtF2A = NaN(NUM_SESSION,NUM_TRIAL);

trialSwitch = identify_condition_switch(binfo);

%% Compute RT vs trial

for kk = 1:NUM_SESSION
  
  trialA2F = trialSwitch(kk).A2F;  num_A2F = length(trialA2F);
  trialF2A = trialSwitch(kk).F2A;  num_F2A = length(trialF2A);
  
  if ((num_A2F < MIN_NUM_TRIALS) || (num_F2A < MIN_NUM_TRIALS))
    fprintf('Session %d -- Less than %d trials\n', kk, MIN_NUM_TRIALS)
    continue
  end
  
  for jj = 1:NUM_TRIAL
    
    rtA2F(kk,jj) = mean(moves(kk).resptime(trialA2F + TRIAL_PLOT(jj)));
    rtF2A(kk,jj) = mean(moves(kk).resptime(trialF2A + TRIAL_PLOT(jj)));
    
  end%for:trials(jj)
  
end%for:sessions(kk)

%% Plotting

%remove sessions with insufficient number of switch trials
idxNaN = isnan(rtA2F(:,1));
rtA2F(idxNaN,:) = [];
rtF2A(idxNaN,:) = [];
[NUM_SEM,~] = size(rtA2F);

figure(); hold on

errorbar_no_caps(TRIAL_PLOT, mean(rtF2A), 'err',std(rtF2A)/sqrt(NUM_SEM), 'color','k')
errorbar_no_caps(TRIAL_PLOT+NUM_TRIAL, mean(rtA2F), 'err',std(rtA2F)/sqrt(NUM_SEM), 'color','k')

xlim([-5 12]); xticks(-5:12); xticklabels(cell(1,12))
ppretty([6.4,4])

end%function:plotRTXtrial()

