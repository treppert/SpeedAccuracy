function [ raster_acc , raster_fast ] = plot_saccade_raster( gaze , info )
%plot_saccade_raster Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(gaze);
NUM_SAMPLES = 6001;

IDX_PLOT = (1 : 1000);
IDX_STIM = 3500;
OFFSET = 500; %deg/sec

raster_acc = new_struct({'corr','errdir','errtime'}, 'dim',[1,NUM_SESSION]);
raster_fast = new_struct({'corr','errdir','errtime'}, 'dim',[1,NUM_SESSION]);

for kk = 1:NUM_SESSION
  
  idx_fast = (info(kk).condition == 3);
  idx_acc = (info(kk).condition == 1);
  
  idx_corr = ~(info(kk).err_dir | info(kk).err_time);
  idx_errdir = (info(kk).err_dir & ~info(kk).err_time);
  idx_errtime = (info(kk).err_time & ~info(kk).err_dir);
  
  raster_acc(kk).corr = gaze(kk).v(IDX_STIM+IDX_PLOT,(idx_acc & idx_corr));
  raster_acc(kk).errdir = gaze(kk).v(IDX_STIM+IDX_PLOT,(idx_acc & idx_errdir));
  raster_acc(kk).errtime = gaze(kk).v(IDX_STIM+IDX_PLOT,(idx_acc & idx_errtime));
  
  raster_acc(kk) = compute_offset_raster(raster_acc(kk), OFFSET);
  
  raster_fast(kk).corr = gaze(kk).v(IDX_STIM+IDX_PLOT,(idx_fast & idx_corr));
  raster_fast(kk).errdir = gaze(kk).v(IDX_STIM+IDX_PLOT,(idx_fast & idx_errdir));
  raster_fast(kk).errtime = gaze(kk).v(IDX_STIM+IDX_PLOT,(idx_fast & idx_errtime));
  
  raster_fast(kk) = compute_offset_raster(raster_fast(kk), OFFSET);
  
end%for:sessions(kk)

SESSION_PLOT = 5;

dline_acc = nanmean(info(SESSION_PLOT).tgt_dline(info(SESSION_PLOT).condition == 1));
dline_fast = nanmean(info(SESSION_PLOT).tgt_dline(info(SESSION_PLOT).condition == 3));

TRIAL_PLOT = (21:30);
Y_LIM = TRIAL_PLOT(1)*OFFSET + [-10, OFFSET*length(TRIAL_PLOT)+10];

figure()

subplot(2,3,1); hold on
plot(IDX_PLOT, raster_acc(SESSION_PLOT).corr(:,TRIAL_PLOT), 'r-', 'LineWidth',1.25)
y_lim = get(gca, 'ylim'); ylim(Y_LIM); yticks([])
plot(dline_acc*ones(1,2), [y_lim(1)+50, y_lim(2)-50], 'k:', 'LineWidth',1.5)

pause(0.25)

subplot(2,3,4); hold on
plot(IDX_PLOT, raster_fast(SESSION_PLOT).corr(:,TRIAL_PLOT), '-', 'Color',[0 .7 0], 'LineWidth',1.25)
y_lim = get(gca, 'ylim'); ylim(Y_LIM); yticks([])
plot(dline_fast*ones(1,2), [y_lim(1)+50, y_lim(2)-50], 'k:', 'LineWidth',1.5)

pause(0.25)

subplot(2,3,2); hold on
plot(IDX_PLOT, raster_acc(SESSION_PLOT).errtime(:,TRIAL_PLOT), 'r:', 'LineWidth',1.5)
y_lim = get(gca, 'ylim'); ylim(Y_LIM); yticks([])
plot(dline_acc*ones(1,2), [y_lim(1)+50, y_lim(2)-50], 'k:', 'LineWidth',1.5)

pause(0.25)

subplot(2,3,5); hold on
plot(IDX_PLOT, raster_fast(SESSION_PLOT).errtime(:,TRIAL_PLOT), ':', 'Color',[0 .7 0], 'LineWidth',1.5)
y_lim = get(gca, 'ylim'); ylim(Y_LIM); yticks([])
plot(dline_fast*ones(1,2), [y_lim(1)+50, y_lim(2)-50], 'k:', 'LineWidth',1.5)

pause(0.25)

subplot(2,3,3); hold on
plot(IDX_PLOT, raster_acc(SESSION_PLOT).errdir(:,TRIAL_PLOT), 'r:', 'LineWidth',1.5)
y_lim = get(gca, 'ylim'); ylim(Y_LIM); yticks([])
plot(dline_acc*ones(1,2), [y_lim(1)+50, y_lim(2)-50], 'k:', 'LineWidth',1.5)

pause(0.25)

subplot(2,3,6); hold on
plot(IDX_PLOT, raster_fast(SESSION_PLOT).errdir(:,TRIAL_PLOT), ':', 'Color',[0 .7 0], 'LineWidth',1.5)
y_lim = get(gca, 'ylim'); ylim(Y_LIM); yticks([])
plot(dline_fast*ones(1,2), [y_lim(1)+50, y_lim(2)-50], 'k:', 'LineWidth',1.5)

% ppretty('image_size',[9,8])

end%util:plot_saccade_raster()


function [ raster ] = compute_offset_raster( raster , offset )

fields = fieldnames(raster);
NUM_FIELDS = length(fields);

for ff = 1:NUM_FIELDS
  
  [~,NUM_TRIAL] = size(raster.(fields{ff}));
  
  for jj = 1:NUM_TRIAL
    
    raster.(fields{ff})(:,jj) = raster.(fields{ff})(:,jj) + offset*(jj-1);
    
  end%for:trials(jj)
  
end%for:fields(ff)

end%util:compute_offset_raster