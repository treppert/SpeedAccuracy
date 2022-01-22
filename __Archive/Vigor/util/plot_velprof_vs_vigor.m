function [  ] = plot_velprof_vs_vigor( moves )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

DISP_LIM = [6.0,7.0];

APPEND = 20;
ALLOT = size(moves(1).r, 1);
NUM_SESSION = length(moves);

velprof_high = NaN(ALLOT,NUM_SESSION);
velprof_low = NaN(ALLOT,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  idx_low = (moves(kk).vigor < 0.9);
  idx_high = (moves(kk).vigor > 1.1);
  
  idx_disp = ( (moves(kk).disp > DISP_LIM(1)) & (moves(kk).disp < DISP_LIM(2)) );
  
  velprof_high(:,kk) = mean(moves(kk).vel(:,(idx_high & idx_disp)), 2);
  velprof_low(:,kk) = mean(moves(kk).vel(:,(idx_low & idx_disp)), 2);
  
end%for:sessions(kk)

figure(); hold on

shaded_error_bar((1:ALLOT)-APPEND, nanmean(velprof_high,2), 3*nanstd(velprof_high,0,2)/sqrt(NUM_SESSION), {'Color','k'})
shaded_error_bar((1:ALLOT)-APPEND, nanmean(velprof_low,2), 3*nanstd(velprof_low,0,2)/sqrt(NUM_SESSION), {'Color',.4*ones(1,3)})

xlim([-10 50]); xticks(-10:10:50)
yticks(0:100:800)
ppretty('image_size',[2,4])

end%function:plot_velprof_vs_vigor()

