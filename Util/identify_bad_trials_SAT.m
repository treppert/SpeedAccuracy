function [ bad_trials ] = identify_bad_trials_SAT( xx , yy )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

DEBUG = false;

LIM_SD_SIG = 0.002; %deg

HALF_WIN = 20; %half-window length of filter
SAMP_CHECK = (3501:5000); %samples to check for missing data

NUM_SAMP = length(SAMP_CHECK);
NUM_TRIALS = size(xx, 1);

%remove samples with larger eccentricity
xx(abs(xx) > 2.0) = NaN;
yy(abs(yy) > 2.0) = NaN;

sd_xx = NaN(NUM_TRIALS,NUM_SAMP);
sd_yy = sd_xx;

for tt = 1:NUM_TRIALS
  
  sig_x = xx(tt,:);
  sig_y = yy(tt,:);
  
  for jj = 1:NUM_SAMP
    
    idx_jj = (SAMP_CHECK(jj)-HALF_WIN : SAMP_CHECK(jj)+HALF_WIN);
    
    sd_xx(tt,jj) = std(sig_x(idx_jj));
    sd_yy(tt,jj) = std(sig_y(idx_jj));
    
  end%for:samples(jj)
  
  if (DEBUG)
    
    figure(); hold on
    plot(sig_x(SAMP_CHECK), 'k-')
    plot(sig_y(SAMP_CHECK), 'b-')
    
    yyaxis right; ylim([0 0.01])
    plot(sd_xx(tt,:), 'k:')
    plot(sd_yy(tt,:), 'b:')
    pause()
    
  end%debug?
  
end%for:trials(tt)

%% Identify trials with missing gaze data

xx_bad = sum(sd_xx<LIM_SD_SIG, 2);
yy_bad = sum(sd_yy<LIM_SD_SIG, 2);

bad_trials = find(xx_bad | yy_bad);

fprintf('** %d of %d trials with missing data\n', length(bad_trials), NUM_TRIALS)

end%function:identify_bad_trials_SAT()

