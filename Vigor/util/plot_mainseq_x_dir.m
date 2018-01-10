function [  ] = plot_mainseq_x_dir( moves , info )
%plot_mainseq_x_dir Summary of this function goes here
%   Detailed explanation goes here

NUM_DIR = 8;

%% Split main sequence data by direction

disp = cell(1,NUM_DIR);
peakvel = cell(1,NUM_DIR);

for jj = 1:NUM_DIR
  
  idx_dir = (moves.octant == jj);
  
  disp{jj} = moves.disp(idx_dir);
  peakvel{jj} = moves.peakvel(idx_dir);
  
end%for:directions(jj)

%% Plotting

figure()

idx_plot = [6, 3, 2, 1, 4, 7, 8, 9];

for jj = 1:NUM_DIR
  
  subplot(3,3,idx_plot(jj)); hold on; xlim([3 12]); xticks(3:3:12); ylim([100 900])
  
  plot(disp{jj}, peakvel{jj}, 'ko', 'MarkerSize',3)
  
  if ~ismember(idx_plot(jj), [7,8,9])
    xticklabels([])
  end
  
  if ~ismember(idx_plot(jj), [1,4,7])
    yticklabels([])
  end
  
  if (jj == NUM_DIR)
    title([num2str(info.session_num), '-', info.session], 'fontsize',8, 'position',[9,100])
  end
  
end%for:directions(kk)

ppretty('image_size',[8,6])

pause(.25)

%create colormap for polar plot
pv_lim = linspace(200, 900, 8);
num_pvbin = length(pv_lim) - 1;
shading = linspace(0.9, 0, num_pvbin);

figure(); polaraxes(); hold on

for ii = 1:num_pvbin
  
  idx_bin = ((moves.peakvel > pv_lim(ii)) & (moves.peakvel < pv_lim(ii+1)));
  polarplot(moves.th_fin(idx_bin), moves.disp(idx_bin), 'o', 'MarkerSize',3, ...
    'Color',shading(ii)*ones(1,3))
  
end

rlim([0 12]); rticks(0:3:12); thetaticks(0:45:315)
title([num2str(info.session_num), '-', info.session], 'fontsize',8, 'position',[270,11])
ppretty('image_size',[2,2])

end%function:plot_mainseq_x_dir()
