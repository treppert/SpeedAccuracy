function [  ] = plot_endpt_err_vs_oct_SAT( info , moves )
%plot_hist_endpt_err_SAT Summary of this function goes here
%   Detailed explanation goes here

TGT_ECCEN = 8;
NUM_SESSION = length(info);

x_err = new_struct({'acc','fast','all'}, 'dim',[1,NUM_SESSION]);
y_err = new_struct({'acc','fast','all'}, 'dim',[1,NUM_SESSION]);
tgt_oct = new_struct({'acc','fast','all'}, 'dim',[1,NUM_SESSION]);

moves = determine_errors_FEF(moves, info);

for kk = 1:NUM_SESSION
  
  idx_acc = (info(kk).condition == 1);
  idx_fast = (info(kk).condition == 3);
  
  idx_corr = ~(moves(kk).err_direction | moves(kk).err_timing);
  
  x_err(kk).acc = moves(kk).err_x(idx_acc & idx_corr);
  y_err(kk).acc = moves(kk).err_y(idx_acc & idx_corr);
  tgt_oct(kk).acc = single(info(kk).tgt_octant(idx_acc & idx_corr));
  
  x_err(kk).fast = moves(kk).err_x(idx_fast & idx_corr);
  y_err(kk).fast = moves(kk).err_y(idx_fast & idx_corr);
  tgt_oct(kk).fast = single(info(kk).tgt_octant(idx_fast & idx_corr));
  
  x_err(kk).all = moves(kk).err_x((idx_acc | idx_fast) & idx_corr);
  y_err(kk).all = moves(kk).err_y((idx_acc | idx_fast) & idx_corr);
  tgt_oct(kk).all = single(info(kk).tgt_octant((idx_acc | idx_fast) & idx_corr));
  
end%for:sessions(kk)

r_acc = sqrt([x_err.acc].^2 + [y_err.acc].^2);
th_acc = atan2([y_err.acc], [x_err.acc]);

r_fast = sqrt([x_err.fast].^2 + [y_err.fast].^2);
th_fast = atan2([y_err.fast], [x_err.fast]);

% figure(); polaraxes(); hold on
% polarscatter(th_fast, r_fast, 'Filled', 'MarkerFaceColor',[0 .7 0], 'MarkerFaceAlpha',0.3)
% polarscatter(th_acc, r_acc, 'Filled', 'MarkerFaceColor','r', 'MarkerFaceAlpha',0.2)
% ppretty('image_size',[3,3])

figure(); hold on
scatter([tgt_oct.acc]-0.15, [x_err.acc], 'MarkerFaceColor','r', 'MarkerFaceAlpha',0.5, 'MarkerEdgeColor','none')
scatter([tgt_oct.fast]+0.15, [x_err.fast], 'MarkerFaceColor',[0 .7 0], 'MarkerFaceAlpha',0.5, 'MarkerEdgeColor','none')
% scatter(toct_all, xerr_all, 'MarkerFaceColor','k', 'MarkerFaceAlpha',0.5, 'MarkerEdgeColor','none')
xlim([0 9]); xticks(1:8); ylim([-4 4])
ppretty('image_size',[2,3])


figure(); hold on
scatter([tgt_oct.acc]-0.15, [y_err.acc], 'MarkerFaceColor','r', 'MarkerFaceAlpha',0.5, 'MarkerEdgeColor','none')
scatter([tgt_oct.fast]+0.15, [y_err.fast], 'MarkerFaceColor',[0 .7 0], 'MarkerFaceAlpha',0.5, 'MarkerEdgeColor','none')
% scatter(toct_all, yerr_all, 'MarkerFaceColor','k', 'MarkerFaceAlpha',0.5, 'MarkerEdgeColor','none')
xlim([0 9]); xticks(1:8); ylim([-4 4])
ppretty('image_size',[2,3])


end%function:plot_hist_endpt_err_SAT()


