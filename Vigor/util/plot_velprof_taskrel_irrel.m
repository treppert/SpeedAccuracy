function [  ] = plot_velprof_taskrel_irrel( moves_tr , moves_all )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

DISP_LIM = [5.5,6.5];

APPEND = 20;
ALLOT = size(moves_tr(1).r, 1);
NUM_SESSION = length(moves_tr);

velprof_tr = NaN(ALLOT,NUM_SESSION);
velprof_ntr = NaN(ALLOT,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  disp_all = moves_all(kk).displacement;
  peakvel_all = moves_all(kk).peakvel;
  vel_all = moves_all(kk).vel;
  
  disp_tr = moves_tr(kk).displacement;
  peakvel_tr = moves_tr(kk).peakvel;
  vel_tr = moves_tr(kk).vel;
  
  %% Separate task-relevant and -irrelevant saccades
  
  idx_tr = ( ismember(disp_all, disp_tr) & ismember(peakvel_all, peakvel_tr) );
  
  disp_ntr = disp_all(~idx_tr);
  vel_ntr = vel_all(:,~idx_tr);
  
  %% Index by saccade displacement
  
  idx_disp_tr = ( (disp_tr > DISP_LIM(1)) & (disp_tr < DISP_LIM(2)) );
  idx_disp_ntr = ( (disp_ntr > DISP_LIM(1)) & (disp_ntr < DISP_LIM(2)) );
  
  vel_tr = vel_tr(:,idx_disp_tr);
  vel_ntr = vel_ntr(:,idx_disp_ntr);
  
  %% Collect mean velocity profiles for task-relevant and -irrelevant saccades
  
  velprof_tr(:,kk) = nanmean(vel_tr, 2);
  velprof_ntr(:,kk) = nanmean(vel_ntr, 2);
  
end%for:sessions(kk)

figure(); hold on

shaded_error_bar((1:ALLOT)-APPEND, nanmean(velprof_tr,2), nanstd(velprof_tr,0,2)/sqrt(NUM_SESSION), {'Color','k'}, false)
shaded_error_bar((1:ALLOT)-APPEND, nanmean(velprof_ntr,2), nanstd(velprof_ntr,0,2)/sqrt(NUM_SESSION), {'Color',.5*ones(1,3)})

xlim([-10 50]); xticks(-10:10:50)
yticks(0:100:800)
ppretty('image_size',[1.5,3])

end%function:plot_velprof_vs_RT()

