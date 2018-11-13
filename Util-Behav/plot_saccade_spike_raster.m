function [  ] = plot_saccade_spike_raster( gaze , binfo , moves , ninfo , spikes )
%plot_spike_raster Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(gaze);
NUM_CELL = length(ninfo);

IDX_PLOT = (1 : 2000);
IDX_STIM = 3500;

NUM_TRIAL_PLOT = 40;
TRIAL_PLOT = (1:NUM_TRIAL_PLOT); %trials per group
OFFSET = 400; %deg/sec

%% Saccade rasters

braster_acc = new_struct({'corr','errdir','errtime'}, 'dim',[1,NUM_SESSION]);
braster_fast = new_struct({'corr','errdir','errtime'}, 'dim',[1,NUM_SESSION]);

btrial_acc = braster_acc; %trial numbers associated with all saccade rasters
btrial_fast = braster_fast;

RT_acc = braster_acc;
RT_fast = braster_fast;

tRew_acc = cell(1,NUM_SESSION); %time of reward delivered (only correct trials)
tRew_fast = cell(1,NUM_SESSION);
tRew_err = NaN(1,NUM_SESSION);

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
  
  braster_fast(kk).corr = gaze(kk).v(IDX_STIM+IDX_PLOT,(idx_fast & idx_corr));
  braster_fast(kk).errdir = gaze(kk).v(IDX_STIM+IDX_PLOT,(idx_fast & idx_errdir));
  braster_fast(kk).errtime = gaze(kk).v(IDX_STIM+IDX_PLOT,(idx_fast & idx_errtime));
  
  %record associated trial numbers for cross-reference
  btrial_acc(kk).corr = find(idx_acc & idx_corr);
  btrial_acc(kk).errdir = find(idx_acc & idx_errdir);
  btrial_acc(kk).errtime = find(idx_acc & idx_errtime);
  btrial_fast(kk).corr = find(idx_fast & idx_corr);
  btrial_fast(kk).errdir = find(idx_fast & idx_errdir);
  btrial_fast(kk).errtime = find(idx_fast & idx_errtime);
  
  %record associated response times for plotting
  RT_acc(kk).corr = moves(kk).resptime(idx_acc & idx_corr);
  RT_acc(kk).errdir = moves(kk).resptime(idx_acc & idx_errdir);
  RT_acc(kk).errtime = moves(kk).resptime(idx_acc & idx_errtime);
  RT_fast(kk).corr = moves(kk).resptime(idx_fast & idx_corr);
  RT_fast(kk).errdir = moves(kk).resptime(idx_fast & idx_errdir);
  RT_fast(kk).errtime = moves(kk).resptime(idx_fast & idx_errtime);
  
  %record associated times of reward for plotting
  tRew_kk = binfo(kk).rewtime - binfo(kk).resptime;
  tRew_kk(tRew_kk < 600 | tRew_kk > 850) = NaN;
  tRew_acc{kk} = RT_acc(kk).corr + tRew_kk(idx_acc & idx_corr);
  tRew_fast{kk} = RT_fast(kk).corr + tRew_kk(idx_fast & idx_corr);
  
  %calculate time of expectation of reward for error trials
  tRew_err(kk) = nanmean(tRew_kk(idx_acc | idx_fast));
  
  %record mean response deadline
  dline_acc(kk) = nanmean(binfo(kk).tgt_dline(idx_acc));
  dline_fast(kk) = nanmean(binfo(kk).tgt_dline(idx_fast));
  
end%for:sessions(kk)

%% Spike rasters
if (0)
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
%   yval_fast(cc) = compute_yval_sraster(strial_fast, TRIAL_PLOT, OFFSET);
  
end%for:cells(cc)

end

%% Plotting
Y_LIM = (TRIAL_PLOT(1)-1)*OFFSET + [-100, OFFSET*length(TRIAL_PLOT)+100];
YVAL_RT = (0 : OFFSET : (NUM_TRIAL_PLOT-1)*OFFSET);

for cc = 1:NUM_CELL
  
  kk = 3;
%   kk = ismember({binfo.session}, ninfo(cc).sesh);
  
  %sample without replacement NUM_TRIAL_PLOT times
  iplot_acc_corr = randsample(length(btrial_acc(kk).corr), NUM_TRIAL_PLOT);
  iplot_fast_corr = randsample(length(btrial_fast(kk).corr), NUM_TRIAL_PLOT);
  iplot_fast_errdir = randsample(length(btrial_fast(kk).errdir), NUM_TRIAL_PLOT);
  iplot_acc_errtime = randsample(length(btrial_acc(kk).errtime), NUM_TRIAL_PLOT);
  
  %only keep data from sampled trials
  braster_acc(kk).corr = braster_acc(kk).corr(:,iplot_acc_corr);
  braster_fast(kk).corr = braster_fast(kk).corr(:,iplot_fast_corr);
  braster_fast(kk).errdir = braster_fast(kk).errdir(:,iplot_fast_errdir);
  braster_acc(kk).errtime = braster_acc(kk).errtime(:,iplot_acc_errtime);
  
  RT_acc_corr = RT_acc(kk).corr(iplot_acc_corr);
  RT_fast_corr = RT_fast(kk).corr(iplot_fast_corr);
  RT_fast_errdir = RT_fast(kk).errdir(iplot_fast_errdir);
  RT_acc_errtime = RT_acc(kk).errtime(iplot_acc_errtime);
  
  tRew_acc{kk} = tRew_acc{kk}(iplot_acc_corr);
  tRew_fast{kk} = tRew_fast{kk}(iplot_fast_corr);
  
  %deal with low number of trials -- Fast timing errors
  numtrial_fast_errtime = length(btrial_fast(kk).errtime);
  if (numtrial_fast_errtime < NUM_TRIAL_PLOT)
    iplot_fast_errtime = randsample(length(btrial_fast(kk).errtime), numtrial_fast_errtime);
    yval_RT_fast_errtime = (0 : OFFSET : (numtrial_fast_errtime-1)*OFFSET);
  else
    iplot_fast_errtime = randsample(length(btrial_fast(kk).errtime), NUM_TRIAL_PLOT);
    yval_RT_fast_errtime = YVAL_RT;
  end
  braster_fast(kk).errtime = braster_fast(kk).errtime(:,iplot_fast_errtime);
  RT_fast_errtime = RT_fast(kk).errtime(iplot_fast_errtime);
  
  %deal with low number of trials -- Acc direction errors
  numtrial_acc_errdir = length(btrial_acc(kk).errdir);
  if (numtrial_acc_errdir < NUM_TRIAL_PLOT)
    iplot_acc_errdir = randsample(length(btrial_acc(kk).errdir), numtrial_acc_errdir);
    yval_RT_acc_errdir = (0 : OFFSET : (numtrial_acc_errdir-1)*OFFSET);
  else
    iplot_acc_errdir = randsample(length(btrial_acc(kk).errdir), NUM_TRIAL_PLOT);
    yval_RT_acc_errdir = YVAL_RT;
  end
  braster_acc(kk).errdir = braster_acc(kk).errdir(:,iplot_acc_errdir);
  RT_acc_errdir = RT_acc(kk).errdir(iplot_acc_errdir);
  
  %order trials within each group by RT
  [RT_acc_corr,iRT_acc_corr] = sort(RT_acc_corr);
  [RT_fast_corr,iRT_fast_corr] = sort(RT_fast_corr);
  [RT_acc_errtime,iRT_acc_errtime] = sort(RT_acc_errtime);
  [RT_fast_errtime,iRT_fast_errtime] = sort(RT_fast_errtime);
  [RT_acc_errdir,iRT_acc_errdir] = sort(RT_acc_errdir);
  [RT_fast_errdir,iRT_fast_errdir] = sort(RT_fast_errdir);
  
  tRew_acc{kk} = tRew_acc{kk}(iRT_acc_corr);
  tRew_fast{kk} = tRew_fast{kk}(iRT_fast_corr);
  
  braster_acc(kk).corr = braster_acc(kk).corr(:,iRT_acc_corr);
  braster_fast(kk).corr = braster_fast(kk).corr(:,iRT_fast_corr);
  braster_acc(kk).errtime = braster_acc(kk).errtime(:,iRT_acc_errtime);
  braster_fast(kk).errtime = braster_fast(kk).errtime(:,iRT_fast_errtime);
  braster_acc(kk).errdir = braster_acc(kk).errdir(:,iRT_acc_errdir);
  braster_fast(kk).errdir = braster_fast(kk).errdir(:,iRT_fast_errdir);
  
  %displace the saccade rasters on the y-axis for plotting
  braster_acc(kk) = compute_yval_braster(braster_acc(kk), OFFSET);
  braster_fast(kk) = compute_yval_braster(braster_fast(kk), OFFSET);
  
  %% Plotting
  
  figure()
  
  subplot(1,4,1); hold on
  plot(IDX_PLOT, braster_acc(kk).corr, 'r-', 'LineWidth',1.0)
  plot(RT_acc_corr, YVAL_RT, 'ko', 'MarkerSize',3)
  plot(tRew_acc{kk}, YVAL_RT, 'bo', 'MarkerSize',3)
%   plot(sraster_acc(cc).corr, yval_acc(cc).corr+OFFSET/2, 'k.', 'MarkerSize',4)
  yticks([]); y_lim = get(gca, 'ylim'); ylim(Y_LIM)
  plot(dline_acc(kk)*ones(1,2), [y_lim(1)+50, y_lim(2)-50], 'k:', 'LineWidth',1.5)
  title('Acc -- Correct', 'FontSize',8)
  
  pause(0.25)
  
  subplot(1,4,2); hold on
  plot(IDX_PLOT, braster_acc(kk).errtime, 'r-', 'LineWidth',1.0)
  plot(RT_acc_errtime, YVAL_RT, 'ko', 'MarkerSize',3)
  plot(RT_acc_errtime + tRew_err(kk), YVAL_RT, 'ko', 'MarkerSize',3)
  yticks([]); y_lim = get(gca, 'ylim'); ylim(Y_LIM)
  plot(dline_acc(kk)*ones(1,2), [y_lim(1)+50, y_lim(2)-50], 'k:', 'LineWidth',1.5)
  title('Acc -- Mis-timed', 'FontSize',8)
  
  pause(0.25)
  
%   subplot(1,6,3); hold on
%   plot(IDX_PLOT, braster_acc(kk).errdir, 'r-', 'LineWidth',1.0)
%   plot(RT_acc_errdir, yval_RT_acc_errdir, 'ko', 'MarkerSize',3)
%   yticks([]); y_lim = get(gca, 'ylim'); ylim(Y_LIM)
%   plot(dline_acc(kk)*ones(1,2), [y_lim(1)+50, y_lim(2)-50], 'k:', 'LineWidth',1.5)
%   title('Acc -- Mis-directed', 'FontSize',8)
%   
%   pause(0.25)
  
  subplot(1,4,3); hold on
  plot(IDX_PLOT, braster_fast(kk).corr, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
  plot(RT_fast_corr, YVAL_RT, 'ko', 'MarkerSize',3)
  plot(tRew_fast{kk}, YVAL_RT, 'bo', 'MarkerSize',3)
  yticks([]); y_lim = get(gca, 'ylim'); ylim(Y_LIM)
  plot(dline_fast(kk)*ones(1,2), [y_lim(1)+50, y_lim(2)-50], 'k:', 'LineWidth',1.5)
  title('Fast -- Correct', 'FontSize',8)
  
  pause(0.25)
  
  subplot(1,4,4); hold on
  plot(IDX_PLOT, braster_fast(kk).errtime, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
  plot(RT_fast_errtime, yval_RT_fast_errtime, 'ko', 'MarkerSize',3)
  plot(RT_fast_errtime + tRew_err(kk), yval_RT_fast_errtime, 'ko', 'MarkerSize',3)
  yticks([]); y_lim = get(gca, 'ylim'); ylim(Y_LIM)
  plot(dline_fast(kk)*ones(1,2), [y_lim(1)+50, y_lim(2)-50], 'k:', 'LineWidth',1.5)
  title('Fast -- Mis-timed', 'FontSize',8)
  
  pause(0.25)
  
%   subplot(1,6,6); hold on
%   plot(IDX_PLOT, braster_fast(kk).errdir, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
%   plot(RT_fast_errdir, yval_RT, 'ko', 'MarkerSize',3)
%   yticks([]); y_lim = get(gca, 'ylim'); ylim(Y_LIM)
%   plot(dline_fast(kk)*ones(1,2), [y_lim(1)+50, y_lim(2)-50], 'k:', 'LineWidth',1.5)
%   title('Fast -- Mis-directed', 'FontSize',8)
%   
%   pause(0.25)
  
end%for:cells(cc)

ppretty('image_size',[14,8])

end%util:plot_saccade_spike_raster

function [ yval ] = compute_yval_sraster( trials , trial_plot , offset )

fields = fieldnames(trials);
NUM_FIELDS = length(fields);

for ff = 1:NUM_FIELDS
  
  yval.(fields{ff}) = NaN(1,length(trials.(fields{ff})));
  
  uniq_trials = unique(trials.(fields{ff}));
  NUM_TRIAL = length(trial_plot); %specify trials for plotting
  
  for jj = 1:NUM_TRIAL
    
    idx_jj = (trials.(fields{ff}) == uniq_trials(trial_plot(jj)));
    yval.(fields{ff})(idx_jj) = offset*(trial_plot(jj)-1);
    
  end%for:trials(jj)
  
end%for:fields(ff)

end%util:compute_yval_sraster()

function [ raster ] = compute_yval_braster( raster , offset )

fields = fieldnames(raster);
NUM_FIELDS = length(fields);

for ff = 1:NUM_FIELDS
  
  [~,NUM_TRIAL] = size(raster.(fields{ff}));
  
  for jj = 1:NUM_TRIAL
    
    raster.(fields{ff})(:,jj) = raster.(fields{ff})(:,jj) + offset*(jj-1);
    
  end%for:trials(jj)
  
end%for:fields(ff)

end%util:compute_yval_braster


