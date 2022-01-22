function [  ] = plot_histogram_vigor( moves , info )
%plot_histogram_vigor Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(moves);

figure()

for kk = 1:NUM_SESSION
  
  idx_tr = ~isnan(moves(kk).displacement);
  
  idx_fast = (idx_tr & (info(kk).condition == 3)); num_fast = sum(idx_fast);
  idx_acc =  (idx_tr & (info(kk).condition == 1));  num_acc  = sum(idx_acc);
  
  subplot(3,3,kk); hold on
  plot(sort(moves(kk).vigor(idx_acc)), (1:num_acc)/num_acc, 'r-', 'LineWidth',1.25)
  plot(sort(moves(kk).vigor(idx_fast)), (1:num_fast)/num_fast, '-', 'Color',[0 .7 0], 'LineWidth',1.25)
  xlim([.6 1.4]); xticks(.6:.2:1.4); pause(0.5)
  
end%for:sessions(kk)

ppretty('image_size',[8,10])

end%function:plot_histogram_vigor()
