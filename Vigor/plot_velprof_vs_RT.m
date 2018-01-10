function [  ] = plot_velprof_vs_RT( moves , info )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

DISP_LIM = [5.5,6.5];

APPEND = 20;
ALLOT = size(moves(1).r, 1);
NUM_SESSION = length(moves);

velprof_early = NaN(ALLOT,NUM_SESSION);
velprof_late = NaN(ALLOT,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  idx_fast = (info(kk).condition == 3);
  
  lim_RT_fast = quantile(moves(kk).resptime(idx_fast), [.25 .75]);
  
  idx_early = (idx_fast & (moves(kk).resptime < lim_RT_fast(1)));
  idx_late = (idx_fast & (moves(kk).resptime > lim_RT_fast(2)));
  
  idx_disp = ( (moves(kk).displacement > DISP_LIM(1)) & (moves(kk).displacement < DISP_LIM(2)) );
  
  velprof_early(:,kk) = nanmean(moves(kk).vel(:,(idx_early & idx_disp)), 2);
  velprof_late(:,kk) = nanmean(moves(kk).vel(:,(idx_late & idx_disp)), 2);
  
end%for:sessions(kk)

figure(); hold on

shaded_error_bar((1:ALLOT)-APPEND, nanmean(velprof_early,2), nanstd(velprof_early,0,2)/sqrt(NUM_SESSION), {'Color',[0 .3 0]}, false)
shaded_error_bar((1:ALLOT)-APPEND, nanmean(velprof_late,2), nanstd(velprof_late,0,2)/sqrt(NUM_SESSION), {'Color',[0 .7 0]})

xlim([-10 50]); xticks(-10:10:50)
yticks(0:100:800)
ppretty('image_size',[1.5,3])

end%function:plot_velprof_vs_RT()

