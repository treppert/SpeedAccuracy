function [  ] = plot_Perr_vs_switch( info )
%plot_param_re_switch Summary of this function goes here
%   Detailed explanation goes here

ERROR = 'err_time';

TRIAL_PLOT = ( -2 : 1 );
NUM_TRIAL = length(TRIAL_PLOT);

NUM_SESSION = length(info);
Perr_A2F = cell(1,NUM_SESSION);
Perr_F2A = cell(1,NUM_SESSION);

trial_switch = identify_condition_switch(info);

%% Compute probability of error vs trial

for kk = 1:NUM_SESSION
  
  Perr_kk = double(info(kk).(ERROR));
  
  tt_A2F = trial_switch(kk).A2F;  num_A2F = length(tt_A2F);
  tt_F2A = trial_switch(kk).F2A;  num_F2A = length(tt_F2A);
  
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
  
  mu_A2F(:,kk) = nanmean(Perr_A2F{kk},2);
  mu_F2A(:,kk) = nanmean(Perr_F2A{kk},2);
  
%   plot(TRIAL_PLOT, mu_A2F(:,kk), '-', 'Color',.4*ones(1,3), 'LineWidth',1.0)
%   plot(TRIAL_PLOT+NUM_TRIAL, mu_F2A(:,kk), '-', 'Color',.4*ones(1,3), 'LineWidth',1.0)
  
end

% plot(TRIAL_PLOT, mean(mu_A2F,2), 'k-', 'LineWidth',2.0)
% plot(TRIAL_PLOT+NUM_TRIAL, mean(mu_F2A,2), 'k-', 'LineWidth',2.0)
errorbar_no_caps(TRIAL_PLOT, mean(mu_A2F,2), 'err',std(mu_A2F,0,2)/sqrt(NUM_SESSION), 'color','k')
errorbar_no_caps(TRIAL_PLOT+NUM_TRIAL, mean(mu_F2A,2), 'err',std(mu_F2A,0,2)/sqrt(NUM_SESSION), 'color','k')

% plot(-0.5*ones(1,2), [0 .6], 'k--')
% plot( 3.5*ones(1,2), [0 .6], 'k--')

xlim([TRIAL_PLOT(1)-0.2 , TRIAL_PLOT(end)+4.2])
xticks(TRIAL_PLOT(1) : TRIAL_PLOT(end)+4)
xticklabels({'-2','-1','0','+1','-2','-1','0','+1'})
ppretty()

end%function:plot_param_re_switch()

