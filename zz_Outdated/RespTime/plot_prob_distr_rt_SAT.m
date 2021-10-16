function [  ] = plot_prob_distr_rt_SAT( moves , info )

idx_fast = ([info.condition] == 3);
idx_acc  = ([info.condition] == 1);

idx_corr = ~([info.Task_ErrChoice] | [info.Task_ErrHold]);
idx_err = [info.Task_ErrChoice];

resptime = double([moves.resptime]);

%% Correct trials
figure(); hold on
histogram(resptime(idx_acc & idx_corr), 'BinWidth',25, 'EdgeColor','none', 'FaceColor','r', 'Normalization','count')
histogram(resptime(idx_fast & idx_corr), 'BinWidth',25, 'EdgeColor','none', 'FaceColor',[0 .7 0], 'Normalization','count')
xlim([175 1000])
ppretty()

%% Error trials
figure(); hold on
histogram(resptime(idx_acc & idx_err), 'BinWidth',25, 'EdgeColor','none', 'FaceColor','r', 'Normalization','count')
histogram(resptime(idx_fast & idx_err), 'BinWidth',25, 'EdgeColor','none', 'FaceColor',[0 .7 0], 'Normalization','count')
set(gca,'Ydir','reverse')
set(gca, 'XAxisLocation','top')
xticklabels(cell(1,length(get(gca, 'xtick'))))
xlim([175 1000])

end%function:plot_prob_distr_rt_SAT()

