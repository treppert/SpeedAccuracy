function [ ] = plot_sdf_reward_SEF( spikes , ninfo , moves , binfo )
%plot_baseline_activity Summary of this function goes here
%   Detailed explanation goes here

TIME_ZERO = 3500;

TIME_REW = (-400 : 800);
NUM_SAMP = length(TIME_REW);

NUM_CELLS = length(spikes);

sdfAcc_Corr = NaN(NUM_CELLS, NUM_SAMP);
sdfFast_Corr = NaN(NUM_CELLS, NUM_SAMP);
sdfAcc_ErrTime = NaN(NUM_CELLS, NUM_SAMP);
sdfFast_ErrTime = NaN(NUM_CELLS, NUM_SAMP);

time_rew = determine_time_reward_SAT(binfo, moves);

%% Compute the SDF

for cc = 1:NUM_CELLS
  
  kk = ismember({binfo.session}, ninfo(cc).sesh);
  
  sdf_kk = compute_spike_density_fxn(spikes(cc).SAT);
  sdf_rew = align_signal_on_response(sdf_kk, moves(kk).resptime + time_rew(kk));
  
  idx_fast = (binfo(kk).condition == 3);
  idx_acc = (binfo(kk).condition == 1);
  
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time);
  idx_errtime = (~binfo(kk).err_dir & binfo(kk).err_time);
  
  idxAcc_Corr = (idx_acc & idx_corr);
  idxFast_Corr = (idx_fast & idx_corr);
  idxAcc_ErrTime = (idx_acc & idx_errtime);
  idxFast_ErrTime = (idx_fast & idx_errtime);
  
  sdfAcc_Corr(cc,:) = nanmean(sdf_rew(idxAcc_Corr,TIME_ZERO + TIME_REW));
  sdfFast_Corr(cc,:) = nanmean(sdf_rew(idxFast_Corr,TIME_ZERO + TIME_REW));
  sdfAcc_ErrTime(cc,:) = nanmean(sdf_rew(idxAcc_ErrTime,TIME_ZERO + TIME_REW));
  sdfFast_ErrTime(cc,:) = nanmean(sdf_rew(idxFast_ErrTime,TIME_ZERO + TIME_REW));
  
end%for:cells(kk)

%% Plotting - individual cells

for cc = 1:NUM_CELLS
  
  linmin = min([sdfAcc_Corr(cc,:),sdfFast_Corr(cc,:)]);
  linmax = max([sdfAcc_ErrTime(cc,:),sdfFast_ErrTime(cc,:)]);
  
  figure(); hold on
  plot([0 0], [linmin linmax], 'k--')
  plot(TIME_REW, sdfAcc_Corr(cc,:), 'r-', 'LineWidth',1.0)
  plot(TIME_REW, sdfFast_Corr(cc,:), '-', 'Color',[0 .7 0], 'LineWidth',1.0)
  plot(TIME_REW, sdfAcc_ErrTime(cc,:), 'r:', 'LineWidth',1.0)
  plot(TIME_REW, sdfFast_ErrTime(cc,:), ':', 'Color',[0 .7 0], 'LineWidth',1.0)
  print_session_unit(gca, ninfo(cc))
  ppretty('image_size',[5,2])
  xlim([-425 825]); xticks(-400:100:800)
  
  print(['~/Dropbox/tmp/sdf-reward-Eu/', ninfo(cc).sesh,'-',ninfo(cc).unit,'.tif'], '-dtiff')
  pause(0.25)
  
end

end%function:plot_sdf_error_SEF()
