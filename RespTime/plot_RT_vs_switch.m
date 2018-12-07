function [  ] = plot_RT_vs_switch( info , moves , monkey )
%plot_param_re_switch Summary of this function goes here
%   Detailed explanation goes here

MIN_NUM_TRIALS = 10;
NUM_SESSION = length(info);

TRIAL_PLOT = ( -4 : 3 );
NUM_TRIAL = length(TRIAL_PLOT);

rtA2F = NaN(NUM_SESSION,NUM_TRIAL);
rtF2A = NaN(NUM_SESSION,NUM_TRIAL);

trial_switch = identify_condition_switch(info, monkey);

%% Compute RT vs trial

for kk = 1:NUM_SESSION
  
  jjA2F = trial_switch(kk).A2F;  num_A2F = length(jjA2F);
  jjF2A = trial_switch(kk).F2A;  num_F2A = length(jjF2A);
  
  if ((num_A2F < MIN_NUM_TRIALS) || (num_F2A < MIN_NUM_TRIALS))
    fprintf('Session %d -- Less than %d trials\n', kk, MIN_NUM_TRIALS)
    continue
  end
  
  for jj = 1:NUM_TRIAL
    
    rtA2F(kk,jj) = mean(moves(kk).resptime(jjA2F + TRIAL_PLOT(jj)));
    rtF2A(kk,jj) = mean(moves(kk).resptime(jjF2A + TRIAL_PLOT(jj)));
    
  end%for:trials(jj)
  
end%for:sessions(kk)

%% Plotting

%remove sessions with insufficient number of "switch" trials
idxNaN = isnan(rtA2F(:,1));
rtA2F(idxNaN,:) = [];
rtF2A(idxNaN,:) = [];
[NUM_SEM,~] = size(rtA2F);

figure(); hold on

errorbar_no_caps(TRIAL_PLOT, mean(rtF2A), 'err',std(rtF2A)/sqrt(NUM_SEM), 'color','k')
errorbar_no_caps(TRIAL_PLOT+NUM_TRIAL, mean(rtA2F), 'err',std(rtA2F)/sqrt(NUM_SEM), 'color','k')

xlim([-5 12]); xticks(-5:12); xticklabels(cell(1,12))
ppretty()

end%function:plot_param_re_switch()

