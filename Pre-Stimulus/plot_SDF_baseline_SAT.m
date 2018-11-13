function [  ] = plot_SDF_baseline_SAT( ninfo , spikes , binfo , moves )
%plot_avg_sdf_baseline Summary of this function goes here
%   Detailed explanation goes here

NORMALIZE = true;
MIN_GRADE_VIS = 3; %scale out of 5
NUM_CELLS = length(spikes);

%indexes to plot re. stimulus appearance
TIME_BASE = (-700 : -1);
IDX_BASE = TIME_BASE + 3500;

NUM_SAMP = length(TIME_BASE);

binfo = index_timing_errors_SAT(binfo, moves);

bline_acc = NaN(NUM_CELLS,NUM_SAMP);
bline_fast = NaN(NUM_CELLS,NUM_SAMP);
bline_avg = NaN(1,NUM_CELLS); %for normalization

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
  
  sdf_stim = compute_spike_density_fxn(spikes(cc).SAT);

  %index by condition
  idx_Acc =  ((binfo(kk).condition == 1) & ~TRIAL_POOR_ISOLATION);
  idx_Fast = ((binfo(kk).condition == 3) & ~TRIAL_POOR_ISOLATION);
  
  %index by trial outcome
  idx_corr = ~(binfo(kk).err_time | binfo(kk).err_dir | binfo(kk).err_hold);
  
  bline_acc(cc,:) = mean(sdf_stim(idx_Acc & idx_corr,IDX_BASE));
  bline_fast(cc,:) = mean(sdf_stim(idx_Fast & idx_corr,IDX_BASE));
  
  %record average baseline across Acc and Fast for normalization
  bline_avg(cc) = nanmean([bline_acc(cc,:), bline_fast(cc,:)]);
  
end%for:cells(kk)

if (NORMALIZE)
  bline_acc = bline_acc ./ bline_avg';
  bline_fast = bline_fast ./ bline_avg';
end

figure(); hold on
shaded_error_bar(TIME_BASE, nanmean(bline_fast), nanstd(bline_fast)/sqrt(NUM_CELLS), {'-', 'Color',[0 .7 0]})
shaded_error_bar(TIME_BASE, nanmean(bline_acc), nanstd(bline_acc)/sqrt(NUM_CELLS), {'r-'})
xlim([TIME_BASE(1)-10, TIME_BASE(end)+10]);
ppretty('image_size',[6.4,4])

end%util:plot_SDF_baseline_SAT()

