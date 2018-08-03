function [  ] = plot_errorrate_vs_RT_vs_cond( moves , info )
%plot_errorrate_vs_RT_vs_cond Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(moves);

ER_A = NaN(1,NUM_SESSION);
ER_F = NaN(1,NUM_SESSION);

RT_A = NaN(1,NUM_SESSION);
RT_F = NaN(1,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  idx_acc = (info(kk).condition == 1);
  idx_fast = (info(kk).condition == 3);
  
  RT_A(kk) = nanmean(moves(kk).resptime(idx_acc));
  RT_F(kk) = nanmean(moves(kk).resptime(idx_fast));
  
  ER_A(kk) = sum(info(kk).err_dir(idx_acc)) / sum(idx_acc);
  ER_F(kk) = sum(info(kk).err_dir(idx_fast)) / sum(idx_fast);
  
end%for:session(kk)

X_PLOT = [mean(RT_F) mean(RT_A)];
XERR_PLOT = [std(RT_F) std(RT_A)] / sqrt(NUM_SESSION);

Y_PLOT = [mean(ER_F) mean(ER_A)];
YERR_PLOT = [std(ER_F) std(ER_A)] / sqrt(NUM_SESSION);

figure(); hold on
errorbarxy(X_PLOT, Y_PLOT, XERR_PLOT, YERR_PLOT, {'k-','k','k'})
ppretty('image_size',[3.2,2])

end%fxn:plot_errorrate_vs_RT_vs_cond()

