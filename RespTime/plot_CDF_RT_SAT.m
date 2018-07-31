function [  ] = plot_CDF_RT_SAT( moves , info , condition )
%plot_CDF_RT_SAT Summary of this function goes here
%   Detailed explanation goes here

if strcmp(condition, 'acc')
  idx_cond  = ([info.condition] == 1);
  color_plot = 'r';
elseif strcmp(condition, 'fast')
  idx_cond = ([info.condition] == 3);
  color_plot = [0 .7 0];
end

info = index_timing_errors_SAT(info, moves);

idx_errtime = [info.err_time] & ~[info.err_dir];
idx_errdir  = [info.err_dir] & ~[info.err_time];
idx_errboth = ([info.err_time] & [info.err_dir]);
idx_corr = ~([info.err_time] | [info.err_dir] | [info.err_hold] | [info.err_nosacc]);

RT = [moves.resptime];

%% Accurate

num_errtime = sum(idx_errtime & idx_cond);   ycdf_errtime = (1:num_errtime) / num_errtime;
num_errdir = sum(idx_errdir & idx_cond);     ycdf_errdir = (1:num_errdir) / num_errdir;
num_errboth = sum(idx_errboth & idx_cond);   ycdf_errboth = (1:num_errboth) / num_errboth;
num_corr = sum(idx_corr & idx_cond);         ycdf_corr = (1:num_corr) / num_corr;

fprintf('Number of trials with both error types = %d/%d\n', num_errboth, sum([info.num_trials]))

RT_errtime = sort(RT(idx_errtime & idx_cond));
RT_errdir = sort(RT(idx_errdir & idx_cond));
RT_errboth = sort(RT(idx_errboth & idx_cond));
RT_corr = sort(RT(idx_corr & idx_cond));

figure(); hold on

plot(RT_corr, ycdf_corr, '-', 'Color',color_plot)
plot(RT_errtime, ycdf_errtime, ':', 'LineWidth',2, 'Color',color_plot)
plot(RT_errdir, ycdf_errdir, '--', 'LineWidth',2, 'Color',color_plot)
plot(RT_errboth, ycdf_errboth, '-.', 'LineWidth',2, 'Color',color_plot)

ppretty()

end%fxn:plot_CDF_RT_SAT()

