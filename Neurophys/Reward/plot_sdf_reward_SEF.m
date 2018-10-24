function [ ] = plot_sdf_reward_SEF( spikes , ninfo , moves , binfo )
%plot_baseline_activity Summary of this function goes here
%   Detailed explanation goes here

PLOT_INDIV_CELLS = true;
NORMALIZE = true;

TIME_REW = 3500 + (-400 : 800);
NUM_SAMP = length(TIME_REW);

NUM_CELLS = 3;%length(spikes);

A_Corr = NaN(NUM_CELLS, NUM_SAMP);
A_Err = NaN(NUM_CELLS, NUM_SAMP);

maxA = NaN(NUM_CELLS,1); %divisor for normalization

%compute expected/actual time of reward for each session
[~,time_rew] = determine_time_reward_SAT(binfo, moves);

%% Compute the SDFs split by condition and trial outcome

for cc = 1:NUM_CELLS
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  TRIAL_POOR_ISOLATION = false(1,binfo(kk).num_trials);
  
  sdf_kk = compute_spike_density_fxn(spikes(cc).SAT);
  sdf_kk = align_signal_on_response(sdf_kk, double(moves(kk).resptime) + time_rew{kk});
  
  %remove trials with poor unit isolation
  if (ninfo(cc).iRem1)
    TRIAL_POOR_ISOLATION(ninfo(cc).iRem1 : ninfo(cc).iRem2) = true;
  end
  
  %index by condition
  idx_cond = ((binfo(kk).condition == 3) & ~TRIAL_POOR_ISOLATION);
  
  %index by trial outcome
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idx_err = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  A_Corr(cc,:) = nanmean(sdf_kk(idx_cond & idx_corr,TIME_REW));
  A_Err(cc,:) = nanmean(sdf_kk(idx_cond & idx_err,TIME_REW));
  
  maxA(cc) = max(nanmean(sdf_kk(:,TIME_REW)));
  
end%for:cells(kk)


%% Plotting - individual cells
if (PLOT_INDIV_CELLS)
TIME_PLOT = TIME_REW - 3500;
for cc = 1:NUM_CELLS
  
  linmin = min([A_Corr(cc,:),A_Err(cc,:)]);
  linmax = max([A_Corr(cc,:),A_Err(cc,:)]);
  
  figure(); hold on
  plot([0 0], [linmin linmax], 'k--')
  plot(TIME_PLOT, A_Corr(cc,:), 'g-', 'LineWidth',1.0)
  plot(TIME_PLOT, A_Err(cc,:), 'g:', 'LineWidth',1.0)
  print_session_unit(gca, ninfo(cc), 'horizontal')
  ppretty('image_size',[4.8,3])
  
  pause(0.25)
  
end%for:cells(cc)
end


%% Plotting - across-cell average
if (NORMALIZE)
  A_Corr = A_Corr ./ maxA;
  A_Err = A_Err ./ maxA;
end

% NUM_SEM = sum([ninfo.rewAcc] > 0);
% sdf_Diff = sdfAcc_ErrTime-sdfAcc_Corr;
% 
% figure(); hold on
% % plot(TIME_REW, sdf_Diff, 'k-')
% shaded_error_bar(TIME_PLOT, nanmean(sdfAcc_Corr), nanstd(sdfAcc_Corr)/sqrt(NUM_SEM), {'r-'}, false)
% shaded_error_bar(TIME_PLOT, nanmean(sdfAcc_ErrTime), nanstd(sdfAcc_ErrTime)/sqrt(NUM_SEM), {'r:'}, false)
% ppretty('image_size',[4.8,3])
% 
% pause(0.25)
% 
% figure(); hold on
% % plot(TIME_PLOT, sdf_Diff, 'k-')
% shaded_error_bar(TIME_PLOT, nanmean(sdf_Diff), nanstd(sdf_Diff)/sqrt(NUM_SEM), {'k-'}, false)
% ppretty('image_size',[4.8,3])

end%function:plot_sdf_error_SEF()
