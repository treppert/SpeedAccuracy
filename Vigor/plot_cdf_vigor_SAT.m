function [  ] = plot_cdf_vigor_SAT( moves , info )
%plot_cdf_vigor_SAT Summary of this function goes here
%   Detailed explanation goes here

idx_acc = ([info.condition] == 1);
idx_fast = ([info.condition] == 3);

idx_corr = ~([info.err_dir] | [info.err_time]);
idx_errdir = [info.err_dir];

vigor = [moves.vigor];

%remove NaNs
i_nan = isnan(vigor);
vigor(i_nan) = [];
idx_acc(i_nan) = [];
idx_fast(i_nan) = [];
idx_corr(i_nan) = [];
idx_errdir(i_nan) = [];

vig_corr_A = sort(vigor(idx_corr & idx_acc));
vig_corr_F = sort(vigor(idx_corr & idx_fast));
vig_errdir_A = sort(vigor(idx_errdir & idx_acc));
vig_errdir_F = sort(vigor(idx_errdir & idx_fast));

y_corr_A = (1:sum(idx_corr & idx_acc)) / sum(idx_corr & idx_acc);
y_corr_F = (1:sum(idx_corr & idx_fast)) / sum(idx_corr & idx_fast);
y_errdir_A = (1:sum(idx_errdir & idx_acc)) / sum(idx_errdir & idx_acc);
y_errdir_F = (1:sum(idx_errdir & idx_fast)) / sum(idx_errdir & idx_fast);

figure(); hold on
plot(vig_corr_A, y_corr_A, 'r-')
plot(vig_corr_F, y_corr_F, '-', 'Color',[0 .7 0])
plot(vig_errdir_A, y_errdir_A, 'r--', 'LineWidth',1.75)
plot(vig_errdir_F, y_errdir_F, '--', 'Color',[0 .7 0], 'LineWidth',1.75)
ppretty()

end%fxn:plot_cdf_vigor_SAT()

