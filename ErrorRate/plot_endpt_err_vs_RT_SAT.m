function [  ] = plot_endpt_err_vs_RT_SAT( info , moves )
%plot_endpt_err_vs_RT_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(info);

MIN_PER_BIN = 10;
MIN_NUM_SESSION = 3;

%set up the RT bins to average data
BIN_LIM = 200 : 50 : 800;
NUM_BIN = length(BIN_LIM) - 1;
RT_PLOT  = BIN_LIM(1:NUM_BIN) + diff(BIN_LIM)/2;

err_acc = NaN(NUM_SESSION,NUM_BIN);
err_fast = NaN(NUM_SESSION,NUM_BIN);

moves = determine_errors_FEF(moves, info);

for kk = 1:NUM_SESSION
  
  idx_corr = ~(moves(kk).err_direction | moves(kk).err_timing);
  
  idx_acc = ((info(kk).condition == 1) & idx_corr);
  idx_fast = ((info(kk).condition == 3) & idx_corr);
  
  for jj = 1:NUM_BIN
    
    idx_jj = ((moves(kk).resptime > BIN_LIM(jj)) & (moves(kk).resptime < BIN_LIM(jj+1)));
    
    if (sum(idx_acc & idx_jj) >= MIN_PER_BIN)
      err_acc(kk,jj) = nanmean(moves(kk).err(idx_acc & idx_jj));
    end
    
    if (sum(idx_fast & idx_jj) >= MIN_PER_BIN)
      err_fast(kk,jj) = nanmean(moves(kk).err(idx_fast & idx_jj));
    end
    
  end%for:RT_bins(jj)
  
end%for:sessions(kk)


%% Plotting

num_sem_acc = sum(~isnan(err_acc),1);
num_sem_fast = sum(~isnan(err_fast),1);

err_acc(:,num_sem_acc < MIN_NUM_SESSION) = NaN;
err_fast(:,num_sem_fast < MIN_NUM_SESSION) = NaN;

figure(); hold on
% plot(RT_PLOT, err_fast, 'LineWidth',1.25, 'Color',[0 .7 0])
% plot(RT_PLOT, err_acc, 'LineWidth',1.25, 'Color','r')
errorbar_no_caps(RT_PLOT, nanmean(err_fast), 'err',nanstd(err_fast)./sqrt(num_sem_fast), 'color',[0 .7 0])
errorbar_no_caps(RT_PLOT, nanmean(err_acc), 'err',nanstd(err_acc)./sqrt(num_sem_acc), 'color','r')
ppretty()

end%function:plot_endpt_err_vs_RT_SAT()

