function [ ] = plot_sdf_reward_SEF( spikes , ninfo , moves , binfo )
%plot_baseline_activity Summary of this function goes here
%   Detailed explanation goes here

NORMALIZE = true;

TIME_ZERO = 3500;
TIME_REW = (-400 : 800);
NUM_SAMP = length(TIME_REW);

NUM_CELLS = length(spikes);

sdfAcc_Corr = NaN(NUM_CELLS, NUM_SAMP);
sdfFast_Corr = NaN(NUM_CELLS, NUM_SAMP);
sdfAcc_ErrTime = NaN(NUM_CELLS, NUM_SAMP);
sdfFast_ErrTime = NaN(NUM_CELLS, NUM_SAMP);

maxActivity = NaN(NUM_CELLS,1); %divisor for normalization

%compute expected/actual time of reward for each session
[~,time_rew] = determine_time_reward_SAT(binfo, moves);

%% Compute the SDF

for cc = 1:NUM_CELLS
  if (ninfo(cc).rewAcc <= 0); continue; end
  
  kk = ismember({binfo.session}, ninfo(cc).sesh);
  
  idx_fast = (binfo(kk).condition == 3);
  idx_acc = (binfo(kk).condition == 1);
  
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time);
  idx_errtime = (~binfo(kk).err_dir & binfo(kk).err_time);
  
  sdf = compute_spike_density_fxn(spikes(cc).SAT);
  sdf = align_signal_on_response(sdf, moves(kk).resptime + time_rew{kk});
  
  maxActivity(cc) = max(nanmean(sdf(:,TIME_ZERO + TIME_REW)));
  
  idxAcc_Corr = (idx_acc & idx_corr);
  idxFast_Corr = (idx_fast & idx_corr);
  idxAcc_ErrTime = (idx_acc & idx_errtime);
  idxFast_ErrTime = (idx_fast & idx_errtime);
  
  sdfAcc_Corr(cc,:) = nanmean(sdf(idxAcc_Corr,TIME_ZERO + TIME_REW));
  sdfFast_Corr(cc,:) = nanmean(sdf(idxFast_Corr,TIME_ZERO + TIME_REW));
  sdfAcc_ErrTime(cc,:) = nanmean(sdf(idxAcc_ErrTime,TIME_ZERO + TIME_REW));
  sdfFast_ErrTime(cc,:) = nanmean(sdf(idxFast_ErrTime,TIME_ZERO + TIME_REW));
  
end%for:cells(kk)

if (NORMALIZE)
  sdfAcc_Corr = sdfAcc_Corr ./ maxActivity;
  sdfAcc_ErrTime = sdfAcc_ErrTime ./ maxActivity;
end

%% Plotting - individual cells
if (false)
for cc = NUM_CELLS:-1:1
  if (ninfo(cc).rewAcc <= 0); continue; end
  
  linmin = min([sdfAcc_Corr(cc,:),sdfAcc_ErrTime(cc,:)]);
  linmax = max([sdfAcc_Corr(cc,:),sdfAcc_ErrTime(cc,:)]);
  
  figure(); hold on
  plot([0 0], [linmin linmax], 'k--')
%   plot([TIME_REW(1) TIME_REW(end)], bline(cc)*ones(1,2), 'k-')
  plot(TIME_REW, sdfAcc_Corr(cc,:), 'r-', 'LineWidth',1.0)
  plot(TIME_REW, sdfAcc_ErrTime(cc,:), 'r:', 'LineWidth',1.0)
  print_session_unit(gca, ninfo(cc), 'horizontal')
%   xlim([-625 825]); xticks(-600:100:800)
  ppretty('image_size',[4,2])
  
  pause(0.25)
end
end

%% Plotting - across-cell average
NUM_SEM = sum([ninfo.rewAcc] > 0);
sdf_Diff = sdfAcc_ErrTime-sdfAcc_Corr;

figure(); hold on
% plot(TIME_REW, sdf_Diff, 'k-')
shaded_error_bar(TIME_REW, nanmean(sdf_Diff), nanstd(sdf_Diff)/sqrt(NUM_SEM), {'k-'}, false)
ppretty('image_size',[4.8,3])

% figure(); hold on
% % plot(TIME_REW, sdf_Diff, 'k-', 'LineWidth',1.0)
% shaded_error_bar(TIME_REW, nanmean(sdf_Diff), nanstd(sdf_Diff)/sqrt(NUM_SEM), {'k-'}, false)
% xlim([-625 825]); xticks(-600:100:800)
% ppretty('image_size',[4,2])

end%function:plot_sdf_error_SEF()
