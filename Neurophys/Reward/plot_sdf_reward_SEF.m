function [ ] = plot_sdf_reward_SEF( spikes , ninfo , moves , binfo , Adiff )
%plot_baseline_activity Summary of this function goes here
%   Detailed explanation goes here

binfo = index_timing_errors_SAT(binfo, moves);

PLOT_INDIV_CELLS = false;

TIME_REW = 3500 + (-400 : 400);
NUM_SAMP = length(TIME_REW);
TIME_PLOT = TIME_REW - 3500;

NUM_CELLS = length(spikes);

A_Corr = NaN(NUM_CELLS, NUM_SAMP);
A_Err = NaN(NUM_CELLS, NUM_SAMP);

maxA = NaN(NUM_CELLS,1); %divisor for normalization

%compute expected/actual time of reward for each session
[~,time_rew] = determine_time_reward_SAT(binfo, moves);

% CC_PLOT = find(Adiff.sacc > .05 & Adiff.rew > .05);
% CC_PLOT = find(Adiff.sacc > .05 & abs(Adiff.rew) < .05);
CC_PLOT = find(abs(Adiff.sacc) < .05 & Adiff.rew > .05);
NUM_CC_PLOT = length(CC_PLOT);

%% Compute the SDFs split by condition and trial outcome

for cc = 1:NUM_CELLS
  if ~ismember(cc, CC_PLOT); continue; end
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  TRIAL_POOR_ISOLATION = false(1,binfo(kk).num_trials);
  
  sdf_kk = compute_spike_density_fxn(spikes(cc).SAT);
  sdf_kk = align_signal_on_response(sdf_kk, double(moves(kk).resptime) + time_rew{kk});
  
  %remove trials with poor unit isolation
  if (ninfo(cc).iRem1)
    TRIAL_POOR_ISOLATION(ninfo(cc).iRem1 : ninfo(cc).iRem2) = true;
  end
  
  %index by condition
  idx_cond = ((binfo(kk).condition == 1) & ~TRIAL_POOR_ISOLATION);
  
  %index by trial outcome
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idx_err = (~binfo(kk).err_dir & binfo(kk).err_time);
  
  %compute SDF
  A_Corr(cc,:) = nanmean(sdf_kk(idx_cond & idx_corr,TIME_REW));
  A_Err(cc,:) = nanmean(sdf_kk(idx_cond & idx_err,TIME_REW));
  
  %compute normalization factor
  maxA(cc) = max(nanmean(sdf_kk(idx_cond,TIME_REW)));
  
end%for:cells(kk)


%% Plotting - individual cells
if (PLOT_INDIV_CELLS)
for cc = 1:NUM_CELLS
  
  linmin = min([A_Corr(cc,:),A_Err(cc,:)]);
  linmax = max([A_Corr(cc,:),A_Err(cc,:)]);
  
  figure(); hold on
  plot([0 0], [linmin linmax], 'k--')
  plot(TIME_PLOT, A_Corr(cc,:), 'r-', 'LineWidth',1.0)
  plot(TIME_PLOT, A_Err(cc,:), 'r:', 'LineWidth',1.0)
  print_session_unit(gca, ninfo(cc), 'horizontal')
  ppretty('image_size',[4.8,3])
  
  pause(0.25)
  
end%for:cells(cc)
end

%% Plotting - across-cell average
A_Diff = (A_Err - A_Corr) ./ maxA; %normalization

% figure(); hold on
% shaded_error_bar(TIME_PLOT, nanmean(A_Corr), nanstd(A_Corr)/sqrt(NUM_SEM), {'r-'}, false)
% shaded_error_bar(TIME_PLOT, nanmean(A_Err), nanstd(A_Err)/sqrt(NUM_SEM), {'r:'}, false)
% ppretty('image_size',[4.8,3])

figure(); hold on
shaded_error_bar(TIME_PLOT, nanmean(A_Diff), nanstd(A_Diff)/sqrt(NUM_CC_PLOT), {'r-'}, false)
ppretty('image_size',[5,4])

end%function:plot_sdf_error_SEF()
