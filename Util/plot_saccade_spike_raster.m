function [  ] = plot_saccade_spike_raster( gaze , binfo , ninfo , spikes )
%plot_spike_raster Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(gaze);
NUM_CELL = length(ninfo);

IDX_PLOT = (1 : 1500);
IDX_STIM = 3500;

NUMTRIAL_PLOT = 50;
TRIAL_PLOT = (1:50); %trials per group
OFFSET = 400; %deg/sec

%% Saccade rasters

braster_acc = new_struct({'corr','errdir','errtime'}, 'dim',[1,NUM_SESSION]);
braster_fast = new_struct({'corr','errdir','errtime'}, 'dim',[1,NUM_SESSION]);

btrial_acc = braster_acc; %trial numbers associated with all saccade rasters
btrial_fast = braster_fast;

dline_acc = NaN(1,NUM_SESSION); %response deadline for plotting
dline_fast = NaN(1,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  idx_fast = (binfo(kk).condition == 3);
  idx_acc = (binfo(kk).condition == 1);
  
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time);
  idx_errdir = (binfo(kk).err_dir & ~binfo(kk).err_time);
  idx_errtime = (binfo(kk).err_time & ~binfo(kk).err_dir);
  
  braster_acc(kk).corr = gaze(kk).v(IDX_STIM+IDX_PLOT,(idx_acc & idx_corr));
  braster_acc(kk).errdir = gaze(kk).v(IDX_STIM+IDX_PLOT,(idx_acc & idx_errdir));
  braster_acc(kk).errtime = gaze(kk).v(IDX_STIM+IDX_PLOT,(idx_acc & idx_errtime));
  
  braster_acc(kk) = compute_offset_raster(braster_acc(kk), OFFSET);
  
  braster_fast(kk).corr = gaze(kk).v(IDX_STIM+IDX_PLOT,(idx_fast & idx_corr));
  braster_fast(kk).errdir = gaze(kk).v(IDX_STIM+IDX_PLOT,(idx_fast & idx_errdir));
  braster_fast(kk).errtime = gaze(kk).v(IDX_STIM+IDX_PLOT,(idx_fast & idx_errtime));
  
  braster_fast(kk) = compute_offset_raster(braster_fast(kk), OFFSET);
  
  %record associated trial numbers for cross-reference
  btrial_acc(kk).corr = find(idx_acc & idx_corr);
  btrial_acc(kk).errdir = find(idx_acc & idx_errdir);
  btrial_acc(kk).errtime = find(idx_acc & idx_errtime);
  btrial_fast(kk).corr = find(idx_fast & idx_corr);
  btrial_fast(kk).errdir = find(idx_fast & idx_errdir);
  btrial_fast(kk).errtime = find(idx_fast & idx_errtime);
  
  %record mean response deadline
  dline_acc(kk) = nanmean(binfo(kk).tgt_dline(idx_acc));
  dline_fast(kk) = nanmean(binfo(kk).tgt_dline(idx_fast));
  
end%for:sessions(kk)

%% Spike rasters

sraster_acc = new_struct({'corr','errdir','errtime'}, 'dim',[1,NUM_CELL]);
sraster_fast = new_struct({'corr','errdir','errtime'}, 'dim',[1,NUM_CELL]);

yval_acc = sraster_acc;
yval_fast = sraster_fast;

for cc = 1:NUM_CELL
  
  kk = ismember({binfo.session}, ninfo(cc).sesh);
  
  idx_fast = (binfo(kk).condition == 3);
  idx_acc = (binfo(kk).condition == 1);
  
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time);
  idx_errdir = (binfo(kk).err_dir & ~binfo(kk).err_time);
  idx_errtime = (binfo(kk).err_time & ~binfo(kk).err_dir);
  
  %organize spikes as 1-D array for plotting
  tmp = spikes(cc).SAT;
  t_spikes = cell2mat(tmp) - IDX_STIM;
  trials = uint16(zeros(1,length(t_spikes)));
  
  %get trial numbers corresponding to each spike
  idx = 1;
  for jj = 1:binfo(kk).num_trials
    trials(idx:idx+length(tmp{jj})-1) = jj;
    idx = idx + length(tmp{jj});
  end%for:trials(jj)
  
  %remove spikes outside of timing window of interest
  idx_time = ((t_spikes >= IDX_PLOT(1)) & (t_spikes <= IDX_PLOT(end)));
  t_spikes = t_spikes(idx_time);
  trials = trials(idx_time);
  
  %save spikes by group (Accurate/Fast & Correct/Error)
  sraster_acc(cc).corr = t_spikes(ismember(trials, find(idx_acc & idx_corr)));
  sraster_acc(cc).errdir = t_spikes(ismember(trials, find(idx_acc & idx_errdir)));
  sraster_acc(cc).errtime = t_spikes(ismember(trials, find(idx_acc & idx_errtime)));

  sraster_fast(cc).corr = t_spikes(ismember(trials, find(idx_fast & idx_corr)));
  sraster_fast(cc).errdir = t_spikes(ismember(trials, find(idx_fast & idx_errdir)));
  sraster_fast(cc).errtime = t_spikes(ismember(trials, find(idx_fast & idx_errtime)));
  
  %record associated trial numbers for cross-reference
  strial_acc.corr = trials(ismember(trials, find(idx_acc & idx_corr)));
  strial_acc.errdir = trials(ismember(trials, find(idx_acc & idx_errdir)));
  strial_acc.errtime = trials(ismember(trials, find(idx_acc & idx_errtime)));
  
  strial_fast.corr = trials(ismember(trials, find(idx_fast & idx_corr)));
  strial_fast.errdir = trials(ismember(trials, find(idx_fast & idx_errdir)));
  strial_fast.errtime = trials(ismember(trials, find(idx_fast & idx_errtime)));
  
  %convert trial numbers to y-values for plotting
  yval_acc(cc) = compute_yval_sraster(strial_acc, TRIAL_PLOT, OFFSET);
  yval_fast(cc) = compute_yval_sraster(strial_fast, TRIAL_PLOT, OFFSET);
  
end%for:cells(cc)


%% Plotting
Y_LIM = (TRIAL_PLOT(1)-1)*OFFSET + [-100, OFFSET*length(TRIAL_PLOT)+100];

for cc = 1:NUM_CELL
  
  kk = ismember({binfo.session}, ninfo(cc).sesh);
  
  figure()
  
%   subplot(1,6,1); hold on
% %   plot(IDX_PLOT, braster_fast(kk).corr(:,TRIAL_PLOT), '-', 'Color',[0 .7 0], 'LineWidth',1.25)
%   plot(IDX_PLOT, braster_fast(kk).corr(:,:), '-', 'Color',[0 .7 0], 'LineWidth',1.25)
%   plot(sraster_fast(cc).corr, yval_fast(cc).corr, 'k.', 'MarkerSize',3)
%   yticks([]); y_lim = get(gca, 'ylim'); %ylim(Y_LIM)
%   plot(dline_fast(kk)*ones(1,2), [y_lim(1)+50, y_lim(2)-50], 'k:', 'LineWidth',1.5)
%   title('Fast -- Correct', 'FontSize',8)
%   
%   pause(0.25)
%   
%   subplot(1,6,2); hold on
% %   plot(IDX_PLOT, braster_fast(kk).errdir(:,TRIAL_PLOT), '-', 'Color',[0 .7 0], 'LineWidth',1.25)
%   plot(IDX_PLOT, braster_fast(kk).errdir(:,:), '-', 'Color',[0 .7 0], 'LineWidth',1.25)
%   plot(sraster_fast(cc).errdir, yval_fast(cc).errdir, 'k.', 'MarkerSize',3)
%   yticks([]); y_lim = get(gca, 'ylim'); %ylim(Y_LIM)
%   plot(dline_fast(kk)*ones(1,2), [y_lim(1)+50, y_lim(2)-50], 'k:', 'LineWidth',1.5)
%   title('Fast -- Mis-directed', 'FontSize',8)
%   
%   pause(0.25)
%   
%   subplot(1,6,3); hold on
% %   plot(IDX_PLOT, braster_fast(kk).errdir(:,TRIAL_PLOT), '-', 'Color',[0 .7 0], 'LineWidth',1.25)
%   plot(IDX_PLOT, braster_fast(kk).errtime(:,:), '-', 'Color',[0 .7 0], 'LineWidth',1.25)
%   plot(sraster_fast(cc).errtime, yval_fast(cc).errtime, 'k.', 'MarkerSize',3)
%   yticks([]); y_lim = get(gca, 'ylim'); %ylim(Y_LIM)
%   plot(dline_fast(kk)*ones(1,2), [y_lim(1)+50, y_lim(2)-50], 'k:', 'LineWidth',1.5)
%   title('Fast -- Mis-timed', 'FontSize',8)
%   
%   pause(0.25)
  
  subplot(1,2,1); hold on
%   subplot(1,6,4); hold on
%   plot(IDX_PLOT, braster_acc(kk).corr(:,TRIAL_PLOT), 'r-', 'LineWidth',1.25)
  plot(IDX_PLOT, braster_acc(kk).corr(:,:), 'r-', 'LineWidth',1.25)
  plot(sraster_acc(cc).corr, yval_acc(cc).corr, 'k.', 'MarkerSize',3)
  yticks([]); y_lim = get(gca, 'ylim'); %ylim(Y_LIM)
  plot(dline_acc(kk)*ones(1,2), [y_lim(1)+50, y_lim(2)-50], 'k:', 'LineWidth',1.5)
  title('Acc -- Correct', 'FontSize',8)
%   
%   pause(0.25)
%   
%   subplot(1,6,5); hold on
% %   plot(IDX_PLOT, braster_acc(kk).errdir(:,TRIAL_PLOT), 'r-', 'LineWidth',1.25)
%   plot(IDX_PLOT, braster_acc(kk).errdir(:,:), 'r-', 'LineWidth',1.25)
%   plot(sraster_acc(cc).errdir, yval_acc(cc).errdir, 'k.', 'MarkerSize',3)
%   yticks([]); y_lim = get(gca, 'ylim'); %ylim(Y_LIM)
%   plot(dline_acc(kk)*ones(1,2), [y_lim(1)+50, y_lim(2)-50], 'k:', 'LineWidth',1.5)
%   title('Acc -- Mis-directed', 'FontSize',8)
  
  pause(0.25)
  
  subplot(1,2,2); hold on
%   subplot(1,6,6); hold on
%   plot(IDX_PLOT, braster_acc(kk).errdir(:,TRIAL_PLOT), 'r-', 'LineWidth',1.25)
  plot(IDX_PLOT, braster_acc(kk).errtime(:,:), 'r-', 'LineWidth',1.25)
  plot(sraster_acc(cc).errtime, yval_acc(cc).errtime, 'k.', 'MarkerSize',3)
  yticks([]); y_lim = get(gca, 'ylim'); %ylim(Y_LIM)
  plot(dline_acc(kk)*ones(1,2), [y_lim(1)+50, y_lim(2)-50], 'k:', 'LineWidth',1.5)
  title('Acc -- Mis-timed', 'FontSize',8)
  
  pause(0.25)
end%for:cells(cc)



end%util:plot_saccade_spike_raster

function [ yval ] = compute_yval_sraster( trials , trial_plot , offset )

fields = fieldnames(trials);
NUM_FIELDS = length(fields);

for ff = 1:NUM_FIELDS
  
  yval.(fields{ff}) = NaN(1,length(trials.(fields{ff})));
  
  uniq_trials = unique(trials.(fields{ff}));
  NUM_TRIAL = length(uniq_trials);
%   NUM_TRIAL = length(trial_plot); %specify trials for plotting
  
  for jj = 1:NUM_TRIAL
    
%     idx_jj = (trials.(fields{ff}) == uniq_trials(trial_plot(jj)));
%     yval.(fields{ff})(idx_jj) = offset*(trial_plot(jj)-1);
    idx_jj = (trials.(fields{ff}) == uniq_trials(jj));
    yval.(fields{ff})(idx_jj) = offset*(jj-1);
    
  end%for:trials(jj)
  
end%for:fields(ff)

end%util:transform_trials_sraster()

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