function [ ] = plot_sdf_reward_SEF( spikes , ninfo , moves , binfo , bline )
%plot_baseline_activity Summary of this function goes here
%   Detailed explanation goes here

MIN_BLINE = 4;
TIME_ZERO = 3500;

TIME_REW = (-600 : 800);
NUM_SAMP = length(TIME_REW);

NUM_CELLS = length(spikes);
MAX_T_REW = 1000;

sdfAcc_Corr = NaN(NUM_CELLS, NUM_SAMP);
sdfFast_Corr = NaN(NUM_CELLS, NUM_SAMP);
sdfAcc_ErrTime = NaN(NUM_CELLS, NUM_SAMP);
sdfFast_ErrTime = NaN(NUM_CELLS, NUM_SAMP);

%compute expected time of reward for each session
time_rew = determine_time_reward_SAT(binfo, moves);

%% Compute the SDF

for cc = 1:NUM_CELLS
  if ((ninfo(cc).rewAcc <= 0) || (bline(cc) < MIN_BLINE)); continue; end
  
  sdf = compute_spike_density_fxn(spikes(cc).SAT);
  kk = ismember({binfo.session}, ninfo(cc).sesh);
  
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time);
  idx_errtime = (~binfo(kk).err_dir & binfo(kk).err_time);
  
  %compute times of reward (correct) and expected reward (error)
%   t_rew_kk = moves(kk).resptime + time_rew(kk);
  t_rew_kk = NaN(1,binfo(kk).num_trials); %t[rew] re. response
  t_rew_kk(idx_errtime) = time_rew(kk);
  t_rew_kk(idx_corr) = binfo(kk).rewtime(idx_corr) - moves(kk).resptime(idx_corr);
  t_rew_kk(t_rew_kk > MAX_T_REW) = NaN;
  
  sdf = align_signal_on_response(sdf, moves(kk).resptime + t_rew_kk);
  
  idx_fast = (binfo(kk).condition == 3);
  idx_acc = (binfo(kk).condition == 1);
  
  idxAcc_Corr = (idx_acc & idx_corr);
  idxFast_Corr = (idx_fast & idx_corr);
  idxAcc_ErrTime = (idx_acc & idx_errtime);
  idxFast_ErrTime = (idx_fast & idx_errtime);
  
  sdfAcc_Corr(cc,:) = nanmean(sdf(idxAcc_Corr,TIME_ZERO + TIME_REW));
  sdfFast_Corr(cc,:) = nanmean(sdf(idxFast_Corr,TIME_ZERO + TIME_REW));
  sdfAcc_ErrTime(cc,:) = nanmean(sdf(idxAcc_ErrTime,TIME_ZERO + TIME_REW));
  sdfFast_ErrTime(cc,:) = nanmean(sdf(idxFast_ErrTime,TIME_ZERO + TIME_REW));
  
end%for:cells(kk)

%% Plotting - individual cells
if (0)
for cc = 1:NUM_CELLS
  if ((ninfo(cc).rewAcc <= 0) || (bline(cc) < MIN_BLINE)); continue; end
  
  linmin = min([sdfAcc_Corr(cc,:),sdfAcc_ErrTime(cc,:)]);
  linmax = max([sdfAcc_Corr(cc,:),sdfAcc_ErrTime(cc,:)]);
  
  figure(); hold on
%   plot([0 0], [linmin linmax], 'k--')
  plot(TIME_REW, sdfAcc_Corr(cc,:), 'r-', 'LineWidth',1.0)
  plot(TIME_REW, sdfAcc_ErrTime(cc,:), 'r:', 'LineWidth',1.0)
  print_session_unit(gca, ninfo(cc), 'horizontal')
  xlim([-625 825]); xticks(-600:100:800)
  ppretty('image_size',[4,2])
  
%   print(['~/Dropbox/tmp/sdf-reward-Da-Fast/', ninfo(cc).sesh,'-',ninfo(cc).unit,'.tif'], '-dtiff')
  pause(1.00)
end
end
%% Plotting - across-cell average

NUM_SEM = sum(([ninfo.rewAcc] > 0) & (bline >= MIN_BLINE));

% sdfAcc_Corr = sdfAcc_Corr ./ transpose(bline);
% sdfAcc_ErrTime = sdfAcc_ErrTime ./ transpose(bline);
sdfAcc_Diff = sdfAcc_ErrTime - sdfAcc_Corr;

figure(); hold on
% plot(TIME_REW, sdfAcc_Corr, 'r-')
% plot(TIME_REW, sdfAcc_ErrTime, 'r:')
shaded_error_bar(TIME_REW, nanmean(sdfAcc_Corr), nanstd(sdfAcc_Corr)/sqrt(NUM_SEM), {'g-'}, false)
shaded_error_bar(TIME_REW, nanmean(sdfAcc_ErrTime), nanstd(sdfAcc_ErrTime)/sqrt(NUM_SEM), {'g:'}, false)
xlim([-625 825]); xticks(-600:100:800)
ppretty('image_size',[6.4,4])

pause(0.5)

figure(); hold on
% plot(TIME_REW, sdfAcc_Diff, 'k-', 'LineWidth',1.0)
shaded_error_bar(TIME_REW, nanmean(sdfAcc_Diff), nanstd(sdfAcc_Diff)/sqrt(NUM_SEM), {'k-'}, false)
xlim([-625 825]); xticks(-600:100:800)
ppretty('image_size',[6.4,4])

end%function:plot_sdf_error_SEF()
