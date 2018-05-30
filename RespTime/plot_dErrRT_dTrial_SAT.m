function [  ] = plot_dErrRT_dTrial_SAT( moves , info , monkey )
%plot_dErrRT_dTrial_SAT Summary of this function goes here
%   Detailed explanation goes here

MIN_NUM_TRIAL = 8; %min of each transition per session

NUM_SESSION = length(moves);
TRIAL_SWITCH = identify_condition_switch(info, monkey);

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
  
  
 %% Fast to Accurate
  if (NUM_F2A >= MIN_NUM_TRIAL)
    
    for jj = 1:NUM_PLOT
      idx_jj = TRIAL_SWITCH(kk).F2A + TRIAL_PLOT(jj);
      errRT_F2A{kk}(:,jj) = moves(kk).resptime(idx_jj) - info(kk).tgt_dline(idx_jj);
    end%for:trial_idx(jj)
    
    errRT_F2A_(kk,:) = nanmean(errRT_F2A{kk});
    
  end
  
  %% Accurate to Fast
  if (NUM_A2F >= MIN_NUM_TRIAL)
    
    for jj = 1:NUM_PLOT
      idx_jj = TRIAL_SWITCH(kk).A2F + TRIAL_PLOT(jj);
      errRT_A2F{kk}(:,jj) = moves(kk).resptime(idx_jj) - info(kk).tgt_dline(idx_jj);
    end%for:trial_idx(jj)
    
    errRT_A2F_(kk,:) = nanmean(errRT_A2F{kk});
    
  end
  
end%for:sessions(kk)

NUM_SEM_A2F = sum(~isnan(errRT_A2F_),1);
NUM_SEM_F2A = sum(~isnan(errRT_F2A_),1);

figure(); hold on
% plot(TRIAL_PLOT, errRT_F2A_, '.-', 'Color',[1 .5 .5], 'LineWidth',1.0)
errorbar_no_caps(TRIAL_PLOT, nanmean(errRT_F2A_), 'err',nanstd(errRT_F2A_)./sqrt(NUM_SEM_F2A), 'color','r', 'linewidth',2.0)
ppretty()

pause(0.25)

figure(); hold on
% plot(TRIAL_PLOT, errRT_A2F_, '.-', 'Color',[.4 .7 .4], 'LineWidth',1.0)
errorbar_no_caps(TRIAL_PLOT, nanmean(errRT_A2F_), 'err',nanstd(errRT_A2F_)./sqrt(NUM_SEM_A2F), 'color',[0 .7 0], 'linewidth',2.0)
ppretty()

end%function:plot_dErrRT_dTrial_SAT()

