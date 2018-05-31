function [  ] = plot_cdf_vigor_SAT( moves , info )
%plot_cdf_vigor_SAT Summary of this function goes here
%   Detailed explanation goes here

idx_acc = ([info.condition] == 1);
idx_fast = ([info.condition] == 3);

vigor = [moves.vigor];

%remove NaNs
i_nan = isnan(vigor);
vigor(i_nan) = [];
idx_acc(i_nan) = [];
idx_fast(i_nan) = [];

vig_acc = sort(vigor(idx_acc));
vig_fast = sort(vigor(idx_fast));

y_acc = (1:sum(idx_acc)) / sum(idx_acc);
y_fast = (1:sum(idx_fast)) / sum(idx_fast);

figure(); hold on
plot(vig_acc, y_acc, 'r-', 'LineWidth',1.25)
plot(vig_fast, y_fast, '-', 'Color',[0 .7 0], 'LineWidth',1.25)
ppretty()

end%fxn:plot_cdf_vigor_SAT()

