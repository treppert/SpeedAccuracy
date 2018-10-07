function [  ] = plot_SDF_baseline_SAT( ninfo , spikes , binfo , moves )
%plot_avg_sdf_baseline Summary of this function goes here
%   Detailed explanation goes here

NORMALIZE = true;
MIN_GRADE_VIS = 2; %scale out of 5
MIN_AVG_BLINE_A = 2; %sp/sec

%indexes to plot re. fixation
TIME_FIX = (1 : 700);
IDX_FIX = TIME_FIX + 3500;

%indexes to plot re. stimulus appearance
TIME_BASE = (-700 : -1);
IDX_BASE = TIME_BASE + 3500;

NUM_SAMP = length(TIME_BASE);
LIM_FIXTIME = -2000;

NUM_CELLS = length(spikes);

%initialize output re. fixation and stimulus
bline_Acc_Fix = NaN(NUM_CELLS,NUM_SAMP);
bline_Acc_Stim = NaN(NUM_CELLS,NUM_SAMP);
bline_Fast_Fix = NaN(NUM_CELLS,NUM_SAMP);
bline_Fast_Stim = NaN(NUM_CELLS,NUM_SAMP);
bline_avg = NaN(1,NUM_CELLS); %for normalization

%ensure correct indexing of timing errors
binfo = index_timing_errors_SAT(binfo, moves);

%exclude cells based on grade of visual responsiveness
grade_Vis = [ninfo.vis];

for cc = 1:NUM_CELLS
  if (grade_Vis(cc) < MIN_GRADE_VIS); continue; end
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  TRIAL_POOR_ISOLATION = false(1,binfo(kk).num_trials);
  
  %remove trials with poor unit isolation
  if (ninfo(cc).iRem1)
    TRIAL_POOR_ISOLATION(ninfo(cc).iRem1 : ninfo(cc).iRem2) = true;
  end
  
  fixtime = binfo(kk).fixtime;
  fixtime(fixtime < LIM_FIXTIME) = NaN;
  
  sdf_stim = compute_spike_density_fxn(spikes(cc).SAT);

  sdf_fix = align_signal_on_response(sdf_stim, fixtime);
  sdf_fix(isnan(fixtime),:) = NaN;
  
  %index by condition
  idx_Acc =  ((binfo(kk).condition == 1) & ~TRIAL_POOR_ISOLATION);
  idx_Fast = ((binfo(kk).condition == 3) & ~TRIAL_POOR_ISOLATION);
  
  %index by trial outcome
  idx_corr = ~(binfo(kk).err_time | binfo(kk).err_dir | binfo(kk).err_hold);
  
  bline_Acc_Fix(cc,:) = nanmean(sdf_fix(idx_Acc & idx_corr,IDX_FIX));
  bline_Acc_Stim(cc,:) = mean(sdf_stim(idx_Acc & idx_corr,IDX_BASE));
  bline_Fast_Fix(cc,:) = nanmean(sdf_fix(idx_Fast & idx_corr,IDX_FIX));
  bline_Fast_Stim(cc,:) = mean(sdf_stim(idx_Fast & idx_corr,IDX_BASE));
  
  %record average baseline across Acc and Fast for normalization
  bline_avg(cc) = mean([bline_Acc_Stim(cc,:), bline_Fast_Stim(cc,:)]);
  
end%for:cells(kk)

bline_avg(bline_avg < MIN_AVG_BLINE_A) = NaN;

if (NORMALIZE)
  bline_Acc_Fix = bline_Acc_Fix ./ bline_avg';
  bline_Acc_Stim = bline_Acc_Stim ./ bline_avg';
  bline_Fast_Fix = bline_Fast_Fix ./ bline_avg';
  bline_Fast_Stim = bline_Fast_Stim ./ bline_avg';
end%if:NORMALIZE

figure(); hold on
% subplot(1,2,1); hold on
% shaded_error_bar(TIME_FIX, nanmean(bline_Fast_Fix), nanstd(bline_Fast_Fix)/sqrt(NUM_CELLS), {'Color',[0 .7 0]})
% shaded_error_bar(TIME_FIX, nanmean(bline_Acc_Fix), nanstd(bline_Acc_Fix)/sqrt(NUM_CELLS), {'Color','r'})
% xlim([TIME_FIX(1)-10, TIME_FIX(end)+10]);

% subplot(1,2,2); hold on
% yticks([]); yyaxis right; set(gca, 'ycolor', 'k')
shaded_error_bar(TIME_BASE, nanmean(bline_Fast_Stim), nanstd(bline_Fast_Stim)/sqrt(NUM_CELLS), {'-', 'Color',[0 .7 0]})
shaded_error_bar(TIME_BASE, nanmean(bline_Acc_Stim), nanstd(bline_Acc_Stim)/sqrt(NUM_CELLS), {'r-'})
xlim([TIME_BASE(1)-10, TIME_BASE(end)+10]);

ppretty('image_size',[6.4,4])

end%util:plot_avg_sdf_baseline()

