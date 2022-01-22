function [  ] = plot_saccade_raster_SAT( gaze_kk , info_kk , moves_kk , varargin )
%plot_saccade_raster_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {'align_on_resp'});

IDX_PLOT = 3500 + (-100 : 600);
NUM_SAMP = length(IDX_PLOT);

NUM_TRIAL = 40;
TRIAL_PLOT = (1:NUM_TRIAL); %trials per group
OFFSET = 400; %deg/sec

info_kk = index_timing_errors_SAT(info_kk, moves_kk);

%% Indexing and data preparation

idx_cond = (info_kk.condition == 3);
% idx_cond = (info_kk.condition == 1);

idx_corr = ~(info_kk.Task_ErrChoice | info_kk.Task_ErrTime | info_kk.Task_ErrHold | info_kk.Task_ErrNoSacc);
idx_err = (info_kk.Task_ErrChoice & ~info_kk.Task_ErrTime);
% idx_errtime = (~info_kk.Task_ErrChoice & info_kk.Task_ErrTime);

if (args.align_on_resp)
  resptime = double(moves_kk.resptime);
  
  trial_corr = find(idx_cond & idx_corr);
  num_corr = length(trial_corr);
  rast_corr = NaN(NUM_SAMP,num_corr);
  for jj = 1:num_corr
    rast_corr(:,jj) = gaze_kk.v(IDX_PLOT + resptime(trial_corr(jj)), trial_corr(jj));
  end
  
  trial_err = find(idx_cond & idx_err);
  num_err = length(trial_err);
  rast_err = NaN(NUM_SAMP,num_err);
  for jj = 1:num_err
    rast_err(:,jj) = gaze_kk.v(IDX_PLOT + resptime(trial_err(jj)), trial_err(jj));
  end
  
else %align on stimulus
  rast_corr = gaze_kk.v(IDX_PLOT,(idx_cond & idx_corr));
  rast_err = gaze_kk.v(IDX_PLOT,(idx_cond & idx_err));
end

%record associated trial numbers for cross-reference
tr_corr = find(idx_cond & idx_corr);
tr_errdir = find(idx_cond & idx_err);

%sample trials without replacement
iplot_corr = randsample(length(tr_corr), NUM_TRIAL);
iplot_err = randsample(length(tr_errdir), NUM_TRIAL);

%only keep data from sampled trials
rast_corr = rast_corr(:,iplot_corr);
rast_err = rast_err(:,iplot_err);


%% Plotting
Y_LIM = (TRIAL_PLOT(1)-1)*OFFSET + [-100, OFFSET*length(TRIAL_PLOT)+100];
X_LIM = [(IDX_PLOT(1)-3500-50), (IDX_PLOT(end)-3500+50)];

%displace the saccade rasters on the y-axis
for jj = 1:NUM_TRIAL
  rast_corr(:,jj) = rast_corr(:,jj) + OFFSET*(jj-1);
  rast_err(:,jj) = rast_err(:,jj) + OFFSET*(jj-1);
end%for:trials(jj)


figure()

subplot(1,2,1); hold on
plot(IDX_PLOT - 3500, rast_corr, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
yticks([]); ylim(Y_LIM); xlim(X_LIM)
title('Fast -- Correct', 'FontSize',8)

pause(0.25)

subplot(1,2,2); hold on
plot(IDX_PLOT - 3500, rast_err, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
yticks([]); ylim(Y_LIM); xlim(X_LIM)
title('Fast -- Mis-directed', 'FontSize',8)

ppretty('image_size',[8,4])

end%util:plot_saccade_raster_SAT()
