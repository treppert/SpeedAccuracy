function [  ] = plot_cdf_vigor_SAT( moves , info , varargin )
%plot_cdf_vigor_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {'plot_velprof'});

info = index_timing_errors_SAT(info, moves);

idx_acc = ([info.condition] == 1);
idx_fast = ([info.condition] == 3);

idx_corr = ~([info.Task_ErrChoice] | [info.Task_ErrTime] | [info.Task_ErrHold]);
idx_errdir = ([info.Task_ErrChoice] & ~[info.Task_ErrTime]);

vigor = [moves.vigor];
velprof = [moves.vel];
peakvel = [moves.peakvel];

%remove NaNs
idx_nan = isnan(vigor);
vigor(idx_nan) = [];
idx_acc(idx_nan) = [];
idx_fast(idx_nan) = [];
idx_corr(idx_nan) = [];
idx_errdir(idx_nan) = [];

vig_corr_A = sort(vigor(idx_corr & idx_acc));
vig_corr_F = sort(vigor(idx_corr & idx_fast));
vig_errdir_A = sort(vigor(idx_errdir & idx_acc));
vig_errdir_F = sort(vigor(idx_errdir & idx_fast));

y_corr_A = (1:sum(idx_corr & idx_acc)) / sum(idx_corr & idx_acc);
y_corr_F = (1:sum(idx_corr & idx_fast)) / sum(idx_corr & idx_fast);
y_errdir_A = (1:sum(idx_errdir & idx_acc)) / sum(idx_errdir & idx_acc);
y_errdir_F = (1:sum(idx_errdir & idx_fast)) / sum(idx_errdir & idx_fast);

figure(); hold on
plot(vig_corr_A, y_corr_A, 'r-')
plot(vig_corr_F, y_corr_F, '-', 'Color',[0 .7 0])
plot(vig_errdir_A, y_errdir_A, 'r--', 'LineWidth',1.75)
plot(vig_errdir_F, y_errdir_F, '--', 'Color',[0 .7 0], 'LineWidth',1.75)
ppretty()

if (args.plot_velprof)
  LIM_CDF_PLOT = [0.495,0.505];
  ALLOT = 150;  APPEND = 20;
  
  pause(0.25)
  
  idx_plot_F = ((y_corr_F > LIM_CDF_PLOT(1)) & (y_corr_F < LIM_CDF_PLOT(2)));
  idx_plot_A = ((y_corr_A > LIM_CDF_PLOT(1)) & (y_corr_A < LIM_CDF_PLOT(2)));
  
  velprof_F = nanmean(velprof(:,idx_plot_F),2);
  velprof_A = nanmean(velprof(:,idx_plot_A),2);
  
  figure(); hold on
%   plot((1:ALLOT)-APPEND, velprof(:,idx_plot_F), 'LineWidth',0.5, 'Color',[.4 .7 .4])
%   plot((1:ALLOT)-APPEND, velprof(:,idx_plot_A), 'LineWidth',0.5, 'Color',[1 .5 .5])
  plot((1:ALLOT)-APPEND, velprof_F, 'LineWidth',1.25, 'Color',[0 .7 0])
  plot((1:ALLOT)-APPEND, velprof_A, 'LineWidth',1.25, 'Color','r')
  xlim([-10 50])
  ppretty()
  
  pause(0.25)
  
  peakvel_F = nanmean(peakvel(idx_plot_F));
  peakvel_A = nanmean(peakvel(idx_plot_A));
  
  figure(); hold on
  bar([1,2], [peakvel_F peakvel_A], 'FaceColor',[.5 .5 .5], 'BarWidth',0.4)
  ppretty('image_size',[2,4])
  
end%if:plot_vel_profile

end%fxn:plot_cdf_vigor_SAT()

