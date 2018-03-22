function [ ] = plot_sdf_error_SEF( spikes , ninfo , moves , binfo , bline_avg )
%plot_baseline_activity Summary of this function goes here
%   Detailed explanation goes here

TIME_ZERO = 3500;

TIME_SACC = (-500 : 800);
TIME_REW = (-800 : 500);
NUM_SAMP = length(TIME_SACC);

MIN_BLINE = 5; %sp/sec
NUM_CELLS = length(spikes);

sdf_ErrDir_Sacc = NaN(NUM_CELLS, NUM_SAMP);
sdf_ErrDir_Rew = NaN(NUM_CELLS, NUM_SAMP);
sdf_ErrTime_Sacc = NaN(NUM_CELLS, NUM_SAMP);
sdf_ErrTime_Rew = NaN(NUM_CELLS, NUM_SAMP);
sdf_Corr_Sacc = NaN(NUM_CELLS, NUM_SAMP);
sdf_Corr_Rew = NaN(NUM_CELLS, NUM_SAMP);

time_rew = determine_time_reward_SAT(binfo, moves);

%% Compute the SDF for each direction

for kk = 1:NUM_CELLS
  if (bline_avg(kk) < MIN_BLINE); continue; end
  if (ninfo(kk).errTime ~= -1); continue; end
  
  %get session number corresponding to behavioral data
  kk_moves = ismember({binfo.session}, ninfo(kk).sesh);
  
  sdf_kk = compute_spike_density_fxn(spikes(kk).SAT);
  
  %align SDF to saccade and reward
  sdf_sacc = align_signal_on_response(sdf_kk, moves(kk_moves).resptime);
  sdf_rew = align_signal_on_response(sdf_kk, moves(kk_moves).resptime + time_rew(kk_moves));
  
  %index by condition
  idx_fast = (binfo(kk_moves).condition == 3);
  idx_acc = (binfo(kk_moves).condition == 1);
  
  %index by error
  idx_Corr = ~(binfo(kk_moves).err_dir | binfo(kk_moves).err_time);
  idx_ErrDir = (idx_fast & binfo(kk_moves).err_dir & ~binfo(kk_moves).err_time);
  idx_ErrTime = (idx_acc & ~binfo(kk_moves).err_dir & binfo(kk_moves).err_time);
  
  sdf_Corr_Sacc(kk,:) = nanmean(sdf_sacc(idx_Corr,TIME_ZERO + TIME_SACC));
  sdf_Corr_Rew(kk,:) = nanmean(sdf_rew(idx_Corr,TIME_ZERO + TIME_REW));
  sdf_ErrDir_Sacc(kk,:) = nanmean(sdf_sacc(idx_ErrDir,TIME_ZERO + TIME_SACC));
  sdf_ErrDir_Rew(kk,:) = nanmean(sdf_rew(idx_ErrDir,TIME_ZERO + TIME_REW));
  sdf_ErrTime_Sacc(kk,:) = nanmean(sdf_sacc(idx_ErrTime,TIME_ZERO + TIME_SACC));
  sdf_ErrTime_Rew(kk,:) = nanmean(sdf_rew(idx_ErrTime,TIME_ZERO + TIME_REW));
  
end%for:cells(kk)

%normalization
sdf_Corr_Sacc = sdf_Corr_Sacc ./ bline_avg';
sdf_Corr_Rew = sdf_Corr_Rew ./ bline_avg';
sdf_ErrDir_Sacc = sdf_ErrDir_Sacc ./ bline_avg';
sdf_ErrDir_Rew = sdf_ErrDir_Rew ./ bline_avg';
sdf_ErrTime_Sacc = sdf_ErrTime_Sacc ./ bline_avg';
sdf_ErrTime_Rew = sdf_ErrTime_Rew ./ bline_avg';

%% Plotting - individual cells

% for kk = 1:NUM_CELLS
%   figure(); hold on
%   plot(TIME_SACC, sdf_Corr_Sacc(kk,:), 'k-', 'LineWidth',1.0)
%   plot(TIME_SACC, sdf_ErrDir_Sacc(kk,:), '-', 'Color',[0 .7 0], 'LineWidth',1.0)
%   plot(TIME_SACC, sdf_ErrTime_Sacc(kk,:), 'r-', 'LineWidth',1.0)
%   ppretty('image_size',[4,2])
% end

%% Plotting - average across cells

NUM_SEM = sum([ninfo.errTime] == -1);

figure(); hold on
plot(mean(time_rew)*ones(1,2), [1 2], 'k--')
shaded_error_bar(TIME_SACC, nanmean(sdf_Corr_Sacc), nanstd(sdf_Corr_Sacc)/sqrt(NUM_SEM), {'k-'})
shaded_error_bar(TIME_SACC, nanmean(sdf_ErrTime_Sacc), nanstd(sdf_ErrTime_Sacc)/sqrt(NUM_SEM), {'r-'})
% shaded_error_bar(TIME_SACC, nanmean(sdf_ErrDir_Sacc), nanstd(sdf_ErrDir_Sacc)/sqrt(NUM_SEM), {'-', 'Color',[0 .7 0]})
ppretty('image_size',[4.8,3])

end%function:plot_sdf_error_SEF()
