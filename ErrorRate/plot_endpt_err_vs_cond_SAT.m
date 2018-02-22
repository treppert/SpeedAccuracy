function [ varargout ] = plot_endpt_err_vs_cond_SAT( info , moves )
%plot_endpt_err_vs_cond_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(info);

err = new_struct({'acc','fast'}, 'dim',[1,NUM_SESSION]);
tgt_oct = new_struct({'acc','fast'}, 'dim',[1,NUM_SESSION]);

moves = determine_errors_FEF(moves, info);

for kk = 1:NUM_SESSION
  
  idx_acc = (info(kk).condition == 1);
  idx_fast = (info(kk).condition == 3);
  
  idx_corr = ~(moves(kk).err_direction | moves(kk).err_timing);
  
%   err(kk).acc = moves(kk).err(idx_acc & idx_corr);
  err(kk).acc = nanstd(moves(kk).err(idx_acc & idx_corr));
  tgt_oct(kk).acc = single(info(kk).tgt_octant(idx_acc & idx_corr));
  
%   err(kk).fast = moves(kk).err(idx_fast & idx_corr);
  err(kk).fast = nanstd(moves(kk).err(idx_fast & idx_corr));
  tgt_oct(kk).fast = single(info(kk).tgt_octant(idx_fast & idx_corr));
  
end%for:sessions(kk)

if (nargout > 0)
  
  varargout{1} = [err.acc]';
  varargout{2} = [err.fast]';
  
else
  
  %% Plotting -- VS direction
  % figure(); hold on
  % scatter([tgt_oct.acc]-0.15, [err.acc], 'MarkerFaceColor','r', 'MarkerFaceAlpha',0.5, 'MarkerEdgeColor','none')
  % scatter([tgt_oct.fast]+0.15, [err.fast], 'MarkerFaceColor',[0 .7 0], 'MarkerFaceAlpha',0.5, 'MarkerEdgeColor','none')
  % xlim([0 9]); xticks(1:8); ylim([0 4.5])
  % ppretty('image_size',[2,3])
  
  %% Plotting -- All saccades
  figure(); hold on
  histogram([err.fast], 'BinWidth',0.2, 'FaceColor',[0 .7 0])
  histogram([err.acc], 'BinWidth',0.2, 'FaceColor','r')
  xlim([0 5])
  ppretty('image_size',[3.2,2])
  
end

end%function:plot_endpt_err_vs_cond_SAT()

