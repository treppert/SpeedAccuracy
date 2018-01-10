function [  ] = plot_param_re_switch( info , moves )
%plot_param_re_switch Summary of this function goes here
%   Detailed explanation goes here

NUM_SESS = length(info);

TT_PLOT = [-3, -2, -1, 0, 1, 2, 3, 4];
NUM_TT = length(TT_PLOT);

info = identify_condition_switch(info);
info = determine_errors_SAT(info);

parm_A2F = cell(1,NUM_SESS);
parm_F2A = cell(1,NUM_SESS);

for kk = 1:NUM_SESS
  
%   parm = double(info(kk).err_time);
  parm = moves(kk).duration;
%   parm(info(kk).err_dir) = NaN;
  
  tt_A2F = info(kk).acc_to_fast;  num_A2F = length(tt_A2F);
  tt_F2A = info(kk).fast_to_acc;  num_F2A = length(tt_F2A);
  
  parm_A2F{kk} = NaN(NUM_TT,num_A2F);
  parm_F2A{kk} = NaN(NUM_TT,num_F2A);
  
  for tt = 1:NUM_TT
    
    parm_A2F{kk}(tt,:) = parm(tt_A2F + TT_PLOT(tt));
    parm_F2A{kk}(tt,:) = parm(tt_F2A + TT_PLOT(tt));
    
  end%for:trials(tt)
  
end%for:sessions(kk)

%% Plotting

mu_A2F = NaN(NUM_TT,NUM_SESS);
mu_F2A = NaN(NUM_TT,NUM_SESS);

figure()
hold on

for kk = 1:NUM_SESS
  
%   subplot(3,3,kk); hold on
  
%   plot(TT_PLOT, parm_A2F{kk}, 'ko', 'MarkerSize',3)
%   plot(TT_PLOT+NUM_TT+1, parm_F2A{kk}, 'ko', 'MarkerSize',3)
  
  mu_A2F(:,kk) = nanmean(parm_A2F{kk},2);
  mu_F2A(:,kk) = nanmean(parm_F2A{kk},2);
  
  plot(TT_PLOT, mu_A2F(:,kk), '-', 'Color',.4*ones(1,3), 'LineWidth',1.0)
  plot(TT_PLOT+NUM_TT+1, mu_F2A(:,kk), '-', 'Color',.4*ones(1,3), 'LineWidth',1.0)
  
  xlim([-3.1 13.1]); xticks([(-3:4),(6:13)])
%   xticklabels({'','-3','','-1','','','','','','-3','','-1','','','',''})
%   ylim([0 1200])
  
end%for:sessions(kk)

plot(TT_PLOT, mean(mu_A2F,2), 'k-', 'LineWidth',2.0)
plot(TT_PLOT+NUM_TT+1, mean(mu_F2A,2), 'k-', 'LineWidth',2.0)

% ppretty('image_size',[6,6])
ppretty()

end%function:plot_param_re_switch()

