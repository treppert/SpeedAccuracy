function [  ] = plot_Perr_vs_switch( info , monkey )
%plot_param_re_switch Summary of this function goes here
%   Detailed explanation goes here

ERROR = 'err_time';
MIN_NUM_TRIALS = 10;

TRIAL_PLOT = ( -4 : 3 );
NUM_TRIAL = length(TRIAL_PLOT);

NUM_SESSION = length(info);
Perr_A2F = cell(1,NUM_SESSION);
Perr_F2A = cell(1,NUM_SESSION);

trial_switch = identify_condition_switch(info, monkey);

%% Compute probability of error vs trial

for kk = 1:NUM_SESSION
  
  Perr_kk = double(info(kk).(ERROR));
  
  tt_A2F = trial_switch(kk).A2F;  num_A2F = length(tt_A2F);
  tt_F2A = trial_switch(kk).F2A;  num_F2A = length(tt_F2A);
  
  if ((num_A2F < MIN_NUM_TRIALS) || (num_F2A < MIN_NUM_TRIALS)); continue; end
  
  Perr_A2F{kk} = NaN(NUM_TRIAL,num_A2F);
  Perr_F2A{kk} = NaN(NUM_TRIAL,num_F2A);
  
  for tt = 1:NUM_TRIAL
    
    Perr_A2F{kk}(tt,:) = Perr_kk(tt_A2F + TRIAL_PLOT(tt));
    Perr_F2A{kk}(tt,:) = Perr_kk(tt_F2A + TRIAL_PLOT(tt));
    
  end%for:trials(tt)
  
end%for:sessions(kk)


%% Plotting

mu_A2F = NaN(NUM_TRIAL,NUM_SESSION);
mu_F2A = NaN(NUM_TRIAL,NUM_SESSION);

figure(); hold on

for kk = 1:NUM_SESSION
  if isempty(Perr_A2F{kk}); continue; end
  
  mu_A2F(:,kk) = nanmean(Perr_A2F{kk},2);
  mu_F2A(:,kk) = nanmean(Perr_F2A{kk},2);
  
%   plot(TRIAL_PLOT, mu_F2A(:,kk), '-', 'Color',.4*ones(1,3), 'LineWidth',1.0)
%   plot(TRIAL_PLOT+NUM_TRIAL, mu_A2F(:,kk), '-', 'Color',.4*ones(1,3), 'LineWidth',1.0)
  
end

%remove sessions with no data
kk_nan = isnan(mu_A2F(1,:));
mu_A2F(:,kk_nan) = [];
mu_F2A(:,kk_nan) = [];
NUM_SESSION = size(mu_A2F,2);

% plot(TRIAL_PLOT, mean(mu_F2A,2), 'k-', 'LineWidth',2.0)
% plot(TRIAL_PLOT+NUM_TRIAL, mean(mu_A2F,2), 'k-', 'LineWidth',2.0)
errorbar_no_caps(TRIAL_PLOT, mean(mu_F2A,2), 'err',std(mu_F2A,0,2)/sqrt(NUM_SESSION), 'color','k')
errorbar_no_caps(TRIAL_PLOT+NUM_TRIAL, mean(mu_A2F,2), 'err',std(mu_A2F,0,2)/sqrt(NUM_SESSION), 'color','k')

% plot(-0.5*ones(1,2), [0 .6], 'k--')
% plot( 3.5*ones(1,2), [0 .6], 'k--')

xlim([-5 12]); xticks(-5:12); xticklabels(cell(1,12))
ppretty()

end%function:plot_param_re_switch()

