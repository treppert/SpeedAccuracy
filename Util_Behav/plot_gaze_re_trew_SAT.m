function [  ] = plot_gaze_re_trew_SAT( gaze_kk , moves_kk , info_kk )
%plot_gaze_re_trew_SAT Summary of this function goes here
%   Detailed explanation goes here

T_STIM = 3500;
T_PLOT = -400 : 600;
NUM_TRIAL = info_kk.num_trials;

idx_acc = (info_kk.condition == 1);

idx_corr = ~(info_kk.Task_ErrChoice | info_kk.Task_ErrTime);
idx_errtime = (~info_kk.Task_ErrChoice & info_kk.Task_ErrTime);

[~,t_rew] = determine_time_reward_SAT(info_kk, moves_kk);
t_rew = t_rew{1};

for jj = 1:NUM_TRIAL
  
  if (idx_acc(jj) && (moves_kk.resptime(jj) < 1000) && ~isnan(t_rew(jj))) %if ACC condition
    
    i_plot = T_STIM + moves_kk.resptime(jj) + T_PLOT + t_rew(jj);
    
    if (idx_corr(jj)) %if correct trial
      
      figure(); hold on
      plot(T_PLOT, gaze_kk.x(i_plot,jj), 'k-')
      plot(T_PLOT, gaze_kk.y(i_plot,jj), 'b-')
      xlim([T_PLOT(1), T_PLOT(end)])
      tmp = 0;
      
    elseif (idx_errtime(jj)) %if timing error
      
      figure(); hold on
      plot(T_PLOT, gaze_kk.x(i_plot,jj), 'k-')
      plot(T_PLOT, gaze_kk.y(i_plot,jj), 'b-')
      xlim([T_PLOT(1), T_PLOT(end)])
      tmp = 1;
      
    end
    
  end%if:ACC
  
end%for:trials(jj)

end%fxn:plot_gaze_re_trew_SAT()

