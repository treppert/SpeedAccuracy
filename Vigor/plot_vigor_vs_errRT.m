function [  ] = plot_vigor_vs_errRT( moves , info )
%plot_vigor_vs_errRT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(moves);

vig_acc_corr = NaN(1,NUM_SESSION);
vig_acc_err = NaN(1,NUM_SESSION);

vig_fast_corr = NaN(1,NUM_SESSION);
vig_fast_err = NaN(1,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  idx_acc = (info(kk).condition == 1);
  idx_fast = (info(kk).condition == 3);
  idx_err = info(kk).err_time;
  
  vig_acc_corr(kk) = nanmean(moves(kk).vigor(~idx_err & idx_acc));
  vig_acc_err(kk) = nanmean(moves(kk).vigor(idx_err & idx_acc));
  
  vig_fast_corr(kk) = nanmean(moves(kk).vigor(~idx_err & idx_fast));
  vig_fast_err(kk) =  nanmean(moves(kk).vigor(idx_err & idx_fast));
  
end%for:session(kk)

Y_ACC = [nanmean(vig_acc_corr) nanmean(vig_acc_err)];
Y_FAST = [nanmean(vig_fast_corr) nanmean(vig_fast_err)];

SD_ACC = [nanstd(vig_acc_corr) nanstd(vig_acc_err)] / sqrt(NUM_SESSION);
SD_FAST = [nanstd(vig_fast_corr) nanstd(vig_fast_err)] / sqrt(NUM_SESSION);

figure(); hold on
barwitherr([SD_ACC SD_FAST], [Y_ACC Y_FAST])
ylim([.97 1.02]); ppretty('image_size',[2,4])

end%fxn:plot_vigor_vs_errRT()

