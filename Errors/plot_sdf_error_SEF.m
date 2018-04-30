function [ ] = plot_sdf_error_SEF( spikes , ninfo , moves , binfo )
%plot_baseline_activity Summary of this function goes here
%   Detailed explanation goes here

TIME_ZERO = 3500;

TIME_STIM = (-500 : 500);
TIME_SACC = (-500 : 500);
TIME_REW = (-200 : 800);
NUM_SAMP = length(TIME_SACC);

MIN_GRADE = 3;
NUM_CELLS = length(spikes);

sdf_CorrAcc_Stim = NaN(NUM_CELLS, NUM_SAMP);
sdf_ErrTime_Stim = NaN(NUM_CELLS, NUM_SAMP);

sdf_CorrFast_Sacc = NaN(NUM_CELLS, NUM_SAMP);
sdf_CorrAcc_Sacc = NaN(NUM_CELLS, NUM_SAMP);
sdf_ErrDir_Sacc = NaN(NUM_CELLS, NUM_SAMP);
sdf_ErrTime_Sacc = NaN(NUM_CELLS, NUM_SAMP);

sdf_CorrAcc_Rew = NaN(NUM_CELLS, NUM_SAMP);
sdf_ErrTime_Rew = NaN(NUM_CELLS, NUM_SAMP);

RT_CorrFast = NaN(1,NUM_CELLS);
RT_CorrAcc = NaN(1,NUM_CELLS);
RT_ErrDir = NaN(1,NUM_CELLS);
RT_ErrTime = NaN(1,NUM_CELLS);

time_rew = determine_time_reward_SAT(binfo, moves);

%% Compute the SDF

for kk = 1:5%NUM_CELLS
%   if (ninfo(kk).vis < MIN_GRADE); continue; end
%   if (ninfo(kk).errTime ~= -1); continue; end
  
  %get session number corresponding to behavioral data
  kk_moves = ismember({binfo.session}, ninfo(kk).sesh);
  
  sdf_kk = compute_spike_density_fxn(spikes(kk).SAT);
  RT_kk = moves(kk_moves).resptime;
  
  %align SDF to saccade and reward
  sdf_sacc = align_signal_on_response(sdf_kk, RT_kk);
  sdf_rew = align_signal_on_response(sdf_kk, RT_kk + time_rew(kk_moves));
  
  %index by condition
  idx_fast = (binfo(kk_moves).condition == 3);
  idx_acc = (binfo(kk_moves).condition == 1);
  
  %index by error
  idx_corr = ~(binfo(kk_moves).err_dir | binfo(kk_moves).err_time);
  idx_CorrFast = (idx_fast & idx_corr);
  idx_CorrAcc = (idx_acc & idx_corr);
  idx_ErrDir = (idx_fast & binfo(kk_moves).err_dir & ~binfo(kk_moves).err_time);
  idx_ErrTime = (idx_acc & ~binfo(kk_moves).err_dir & binfo(kk_moves).err_time);
  
  %calculate median RT per group
  RT_CorrFast(kk) = median(RT_kk(idx_CorrFast));
  RT_CorrAcc(kk) = median(RT_kk(idx_CorrAcc));
  RT_ErrDir(kk) = median(RT_kk(idx_ErrDir));
  RT_ErrTime(kk) = median(RT_kk(idx_ErrTime));
  
  
  sdf_CorrAcc_Stim(kk,:) = mean(sdf_kk(idx_CorrAcc,TIME_ZERO + TIME_STIM));
  sdf_ErrTime_Stim(kk,:) = mean(sdf_kk(idx_ErrTime,TIME_ZERO + TIME_STIM));
  
  sdf_CorrFast_Sacc(kk,:) = mean(sdf_sacc(idx_CorrFast,TIME_ZERO + TIME_SACC));
  sdf_CorrAcc_Sacc(kk,:) = mean(sdf_sacc(idx_CorrAcc,TIME_ZERO + TIME_SACC));
  sdf_ErrDir_Sacc(kk,:) = mean(sdf_sacc(idx_ErrDir,TIME_ZERO + TIME_SACC));
  sdf_ErrTime_Sacc(kk,:) = mean(sdf_sacc(idx_ErrTime,TIME_ZERO + TIME_SACC));
  
  sdf_CorrAcc_Rew(kk,:) = nanmean(sdf_rew(idx_CorrAcc,TIME_ZERO + TIME_REW));
  sdf_ErrTime_Rew(kk,:) = mean(sdf_rew(idx_ErrTime,TIME_ZERO + TIME_REW));
  
end%for:cells(kk)

% %normalization
% sdf_CorrFast_Sacc = sdf_CorrFast_Sacc ./ bline_avg';
% sdf_ErrDir_Sacc = sdf_ErrDir_Sacc ./ bline_avg';
% sdf_ErrTime_Sacc = sdf_ErrTime_Sacc ./ bline_avg';

%% Plotting - individual cells

for kk = 1:NUM_CELLS
%   if (ninfo(kk).vis < MIN_GRADE); continue; end
  linmin = min([sdf_CorrFast_Sacc(kk,:),sdf_CorrAcc_Sacc(kk,:)]);
  linmax = max([sdf_ErrDir_Sacc(kk,:),sdf_ErrTime_Sacc(kk,:)]);
  
  figure()
  
%   subplot(1,3,1); hold on
%   plot([0 0], [linmin linmax], 'k--')
%   plot(RT_CorrAcc(kk)*ones(1,2), [linmin linmax], 'r-')
%   plot(RT_ErrTime(kk)*ones(1,2), [linmin linmax], 'r-.')
%   plot(TIME_STIM, sdf_CorrAcc_Stim(kk,:), 'r-', 'LineWidth',1.0)
%   plot(TIME_STIM, sdf_ErrTime_Stim(kk,:), 'r:', 'LineWidth',1.0)
%   xlim([-525 525]); xticks(-500:100:500)
%   print_session_unit(gca, ninfo(kk))
%   
%   y_lim = get(gca, 'ylim');
%   
%   pause(0.25)
%   
%   subplot(1,3,2); hold on
%   hold on
%   plot([0 0], [linmin linmax], 'k--')
%   plot(-RT_CorrAcc(kk)*ones(1,2), [linmin linmax], 'r-')
%   plot(-RT_ErrTime(kk)*ones(1,2), [linmin linmax], 'r-.')
%   plot(TIME_SACC, sdf_CorrAcc_Sacc(kk,:), 'r-', 'LineWidth',1.0)
%   plot(TIME_SACC, sdf_ErrTime_Sacc(kk,:), 'r:', 'LineWidth',1.0)
%   xlim([-525 525]); xticks(-500:100:500); %yticks([])
%   
%   tmp = get(gca, 'ylim'); %make y-axes consistent
%   if (tmp(1) < y_lim(1)); y_lim(1) = tmp(1); end
%   if (tmp(2) > y_lim(2)); y_lim(2) = tmp(2); end
%   
%   pause(0.25)
  
%   subplot(1,3,3); hold on
%   hold on
%   plot([0 0], [linmin linmax], 'k--')
%   plot(TIME_REW, sdf_CorrAcc_Rew(kk,:), 'r-', 'LineWidth',1.0)
%   plot(TIME_REW, sdf_ErrTime_Rew(kk,:), 'r:', 'LineWidth',1.0)
%   print_session_unit(gca, ninfo(kk))
%   ppretty('image_size',[4,2])
%   xlim([-525 525]); xticks(-500:100:500); %yticks([])
  
%   tmp = get(gca, 'ylim'); %make y-axes consistent
%   if (tmp(1) < y_lim(1)); y_lim(1) = tmp(1); end
%   if (tmp(2) > y_lim(2)); y_lim(2) = tmp(2); end
  
%   pause(0.25)
  
%   subplot(1,3,1); ylim(y_lim)
%   subplot(1,3,2); ylim(y_lim)
%   subplot(1,3,3); ylim(y_lim)
  
  %ppretty('image_size',[14,2])
%   pause(0.25); print(['~/Dropbox/tmp/', ninfo(kk).sesh,'-',ninfo(kk).unit,'.tif'], '-dtiff'); pause(0.25)
end

return
%% Plotting - average across cells

NUM_SEM = sum([ninfo.errTime] == -1);

figure(); hold on
plot(mean(time_rew)*ones(1,2), [1 2], 'k--')
shaded_error_bar(TIME_SACC, nanmean(sdf_Corr_Sacc), nanstd(sdf_Corr_Sacc)/sqrt(NUM_SEM), {'k-'})
shaded_error_bar(TIME_SACC, nanmean(sdf_ErrTime_Sacc), nanstd(sdf_ErrTime_Sacc)/sqrt(NUM_SEM), {'r-'})
% shaded_error_bar(TIME_SACC, nanmean(sdf_ErrDir_Sacc), nanstd(sdf_ErrDir_Sacc)/sqrt(NUM_SEM), {'-', 'Color',[0 .7 0]})
ppretty('image_size',[4.8,3])

end%function:plot_sdf_error_SEF()
