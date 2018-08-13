function [  ] = plot_CDF_RT_SAT_2( moves , info )
%plot_CDF_RT_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(moves);

QUANTILE = (.1 : .1 : .9);
NUM_QUANTILE = length(QUANTILE);

info = index_timing_errors_SAT(info, moves);

RT_corr_A = NaN(NUM_SESSION, NUM_QUANTILE);
RT_errdir_A = NaN(NUM_SESSION, NUM_QUANTILE);
RT_corr_F = NaN(NUM_SESSION, NUM_QUANTILE);
RT_errdir_F = NaN(NUM_SESSION, NUM_QUANTILE);

%also store RT values combined across all sessions (for Wilcoxon rank-sum)
RT_combined = struct('acc_corr',[], 'acc_errdir',[], 'fast_corr',[], 'fast_errdir',[]);

dline_A = NaN(1,NUM_SESSION);
dline_F = NaN(1,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  idx_acc = (info(kk).condition == 1);
  idx_fast = (info(kk).condition == 3);
  
  idx_errdir = info(kk).err_dir;
  idx_corr = ~(info(kk).err_dir | info(kk).err_hold | info(kk).err_nosacc);
  
  RT = moves(kk).resptime;
  
  RT_corr_A(kk,:) = quantile(RT(idx_corr & idx_acc), QUANTILE);
  RT_errdir_A(kk,:) = quantile(RT(idx_errdir & idx_acc), QUANTILE);
  RT_corr_F(kk,:) = quantile(RT(idx_corr & idx_fast), QUANTILE);
  RT_errdir_F(kk,:) = quantile(RT(idx_errdir & idx_fast), QUANTILE);
  
  RT_combined.acc_corr = cat(2, RT_combined.acc_corr, RT(idx_corr & idx_acc));
  RT_combined.acc_errdir = cat(2, RT_combined.acc_errdir, RT(idx_errdir & idx_acc));
  RT_combined.fast_corr = cat(2, RT_combined.fast_corr, RT(idx_corr & idx_fast));
  RT_combined.fast_errdir = cat(2, RT_combined.fast_errdir, RT(idx_errdir & idx_fast));
  
  dline_A(kk) = nanmean(info(kk).tgt_dline(idx_acc));
  dline_F(kk) = nanmean(info(kk).tgt_dline(idx_fast));
  
end

fprintf('Deadline: ACC %g +- %g || FAST %g +- %g\n', mean(dline_A), std(dline_A)/sqrt(NUM_SESSION), ...
  mean(dline_F), std(dline_F)/sqrt(NUM_SESSION))

%% Stats
[pval,~,wstat] = ranksum(RT_combined.acc_corr, RT_combined.acc_errdir, 'tail','both');
fprintf('ACC: Z = %g  p = %g\n', wstat.zval, pval)
[pval,~,wstat] = ranksum(RT_combined.fast_corr, RT_combined.fast_errdir, 'tail','both');
fprintf('FAST: Z = %g  p = %g\n', wstat.zval, pval)

%% Plotting

figure(); hold on

errorbar_no_caps(0.55, mean(dline_A), 'err',std(dline_A)/sqrt(NUM_SESSION), 'color',[1 .5 .5])
errorbar_no_caps(0.45, mean(dline_F), 'err',std(dline_F)/sqrt(NUM_SESSION), 'color',[.4 .7 .4])

errorbar_no_caps(QUANTILE, mean(RT_corr_A), 'err',std(RT_corr_A)/sqrt(NUM_SESSION), 'color','r')
errorbar_no_caps(QUANTILE, mean(RT_errdir_A), 'err',std(RT_errdir_A)/sqrt(NUM_SESSION), 'color','r', 'linewidth',2.0)
errorbar_no_caps(QUANTILE, mean(RT_corr_F), 'err',std(RT_corr_F)/sqrt(NUM_SESSION), 'color',[0 .7 0])
errorbar_no_caps(QUANTILE, mean(RT_errdir_F), 'err',std(RT_errdir_F)/sqrt(NUM_SESSION), 'color',[0 .7 0], 'linewidth',2.0)

ppretty('image_size',[3,4.8])

end%fxn:plot_CDF_RT_SAT()

