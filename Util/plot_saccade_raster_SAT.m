function [  ] = plot_saccade_raster_SAT( gaze_kk , info_kk , moves_kk )
%plot_saccade_raster_SAT Summary of this function goes here
%   Detailed explanation goes here

IDX_PLOT = (-900 : 100);
IDX_STIM = 3500;

NUM_TRIAL = 40;
TRIAL_PLOT = (1:NUM_TRIAL); %trials per group
OFFSET = 400; %deg/sec

info_kk = index_timing_errors_SAT(info_kk, moves_kk);


%% Indexing and data preparation

idx_A = (info_kk.condition == 1);
idx_F = (info_kk.condition == 3);

idx_corr = ~(info_kk.err_dir | info_kk.err_time | info_kk.err_hold | info_kk.err_nosacc);
idx_errdir = (info_kk.err_dir & ~info_kk.err_time);
idx_errtime = (~info_kk.err_dir & info_kk.err_time);

rast_corr_A = gaze_kk.v(IDX_STIM+IDX_PLOT,(idx_A & idx_corr));
rast_errtime_A = gaze_kk.v(IDX_STIM+IDX_PLOT,(idx_A & idx_errtime));

rast_corr_F = gaze_kk.v(IDX_STIM+IDX_PLOT,(idx_F & idx_corr));
rast_errdir_F = gaze_kk.v(IDX_STIM+IDX_PLOT,(idx_F & idx_errdir));

%record associated trial numbers for cross-reference
tr_corr_A = find(idx_A & idx_corr);
tr_errtime_A = find(idx_A & idx_errtime);

tr_corr_F = find(idx_F & idx_corr);
tr_errdir_F = find(idx_F & idx_errdir);

%sample trials without replacement
iplot_corr_A = randsample(length(tr_corr_A), NUM_TRIAL);
iplot_corr_F = randsample(length(tr_corr_F), NUM_TRIAL);
iplot_errdir_F = randsample(length(tr_errdir_F), NUM_TRIAL);
iplot_errtime_A = randsample(length(tr_errtime_A), NUM_TRIAL);

%only keep data from sampled trials
rast_corr_A = rast_corr_A(:,iplot_corr_A);
rast_corr_F = rast_corr_F(:,iplot_corr_F);
rast_errdir_F = rast_errdir_F(:,iplot_errdir_F);
rast_errtime_A = rast_errtime_A(:,iplot_errtime_A);


%% Plotting
Y_LIM = (TRIAL_PLOT(1)-1)*OFFSET + [-100, OFFSET*length(TRIAL_PLOT)+100];
X_LIM = [(IDX_PLOT(1)-50), (IDX_PLOT(end)+50)];

%displace the saccade rasters on the y-axis
for jj = 1:NUM_TRIAL
  rast_corr_A(:,jj) = rast_corr_A(:,jj) + OFFSET*(jj-1);
  rast_corr_F(:,jj) = rast_corr_F(:,jj) + OFFSET*(jj-1);
  rast_errtime_A(:,jj) = rast_errtime_A(:,jj) + OFFSET*(jj-1);
  rast_errdir_F(:,jj) = rast_errdir_F(:,jj) + OFFSET*(jj-1);
end%for:trials(jj)


figure()

subplot(1,4,1); hold on
plot(IDX_PLOT, rast_corr_A, 'r-', 'LineWidth',1.0)
yticks([]); ylim(Y_LIM); xlim(X_LIM)
title('Acc -- Correct', 'FontSize',8)

pause(0.25)

subplot(1,4,2); hold on
plot(IDX_PLOT, rast_errtime_A, 'r-', 'LineWidth',1.0)
yticks([]); ylim(Y_LIM); xlim(X_LIM)
title('Acc -- Mis-timed', 'FontSize',8)

pause(0.25)

subplot(1,4,3); hold on
plot(IDX_PLOT, rast_corr_F, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
yticks([]); ylim(Y_LIM); xlim(X_LIM)
title('Fast -- Correct', 'FontSize',8)

pause(0.25)

subplot(1,4,4); hold on
plot(IDX_PLOT, rast_errdir_F, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
yticks([]); ylim(Y_LIM); xlim(X_LIM)
title('Fast -- Mis-directed', 'FontSize',8)

ppretty('image_size',[14,8])

end%util:plot_saccade_raster_SAT()
