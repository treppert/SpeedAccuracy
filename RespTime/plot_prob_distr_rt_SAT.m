function [  ] = plot_prob_distr_rt_SAT( moves , info , varargin )

args = getopt(varargin, {'subplot'});

idx_fast = ([info.condition] == 3);
idx_acc  = ([info.condition] == 1);

resptime = double([moves.resptime]);

rt_fast = resptime(idx_fast);
rt_acc  = resptime(idx_acc);

if (args.subplot)
  set(gca,'Ydir','reverse')
  set(gca, 'XAxisLocation','top')
  xticklabels(cell(1,length(get(gca, 'xtick'))))
  xlim([175 800])
else
  figure(); hold on
  xlim([175 1000])
end

histogram(rt_acc, 'BinWidth',25, 'EdgeColor','none', 'FaceColor','r', 'Normalization','probability')
histogram(rt_fast, 'BinWidth',25, 'EdgeColor','none', 'FaceColor',[0 .7 0], 'Normalization','probability')

if (~args.subplot)
  ppretty()
end
% set(gca,'yticklabel',num2str(get(gca,'ytick')','%.2f'))

end%function:plot_prob_distr_rt_SAT()

