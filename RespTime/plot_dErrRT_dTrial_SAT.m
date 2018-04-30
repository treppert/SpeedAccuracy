function [  ] = plot_dErrRT_dTrial_SAT( moves , info )
%plot_dErrRT_dTrial_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(moves);
TRIAL_SWITCH = identify_condition_switch(info, {});

TRIAL_PLOT = (0 : 4);
NUM_PLOT = length(TRIAL_PLOT);

errRT_F2A = cell(1,NUM_SESSION);
errRT_F2A_ = NaN(NUM_SESSION, NUM_PLOT); %avg across sessions

errRT_A2F = cell(1,NUM_SESSION);
errRT_A2F_ = NaN(NUM_SESSION, NUM_PLOT); %avg across sessions

for kk = 1:NUM_SESSION
  
  NUM_F2A = length(TRIAL_SWITCH(kk).F2A);
  errRT_F2A{kk} = NaN(NUM_F2A,NUM_PLOT);
  
  NUM_A2F = length(TRIAL_SWITCH(kk).A2F);
  errRT_A2F{kk} = NaN(NUM_A2F,NUM_PLOT);
  
  for jj = 1:NUM_PLOT
    
    idx_jj = TRIAL_SWITCH(kk).F2A + TRIAL_PLOT(jj);
    errRT_F2A{kk}(:,jj) = moves(kk).resptime(idx_jj) - info(kk).tgt_dline(idx_jj);
    
    idx_jj = TRIAL_SWITCH(kk).A2F + TRIAL_PLOT(jj);
    errRT_A2F{kk}(:,jj) = moves(kk).resptime(idx_jj) - info(kk).tgt_dline(idx_jj);
    
  end%for:trial_idx(jj)
  
  errRT_F2A_(kk,:) = nanmean(errRT_F2A{kk});
  errRT_A2F_(kk,:) = nanmean(errRT_A2F{kk});
  
end%for:sessions(kk)

figure(); hold on
plot(TRIAL_PLOT, errRT_F2A_, '-', 'Color',[1 .5 .5], 'LineWidth',1.0)
errorbar_no_caps(TRIAL_PLOT, mean(errRT_F2A_), 'err',std(errRT_F2A_)/sqrt(NUM_SESSION), 'color','r', 'linewidth',2.0)
ppretty()

pause(0.5)

figure(); hold on
plot(TRIAL_PLOT, errRT_A2F_, '-', 'Color',[.4 .7 .4], 'LineWidth',1.0)
errorbar_no_caps(TRIAL_PLOT, mean(errRT_A2F_), 'err',std(errRT_A2F_)/sqrt(NUM_SESSION), 'color',[0 .7 0], 'linewidth',2.0)
ppretty()

end%function:plot_dErrRT_dTrial_SAT()

