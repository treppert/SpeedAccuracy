function [  ] = plot_distr_errRT_SAT( moves , info )

idx_fast = ([info.condition] == 3);
idx_acc  = ([info.condition] == 1);

resptime = double([moves.resptime]);
deadline = double([info.tgt_dline]);

rt_fast = resptime(idx_fast) - deadline(idx_fast);
rt_acc  = resptime(idx_acc)  - deadline(idx_acc);

figure(); hold on
h_ax = gca;

histogram(rt_acc, 'BinWidth',50, 'EdgeColor','none', 'FaceColor','r', 'Normalization','probability')
histogram(rt_fast, 'BinWidth',50, 'EdgeColor','none', 'FaceColor',[0 .7 0], 'Normalization','probability')
line([0 0], [0 .25], 'color','k', 'linewidth',1.5)
xlim([-400 800]); xticks(-400:200:800)

%produce inset of deadline distribution
axes('Position',[.6 .6 .3 .3]); hold on
histogram(deadline(idx_acc), 'BinWidth',10, 'EdgeColor','none', 'FaceColor','r', 'Normalization','probability')
histogram(deadline(idx_fast), 'BinWidth',10, 'EdgeColor','none', 'FaceColor',[0 .7 0], 'Normalization','probability')
xlim([250 600])

ppretty()

% set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f')) %inset
% set(h_ax,'yticklabel',num2str(get(h_ax,'ytick')','%.2f')) %main histogram

end%function:plot_RT_distr_re_dline_SAT()

