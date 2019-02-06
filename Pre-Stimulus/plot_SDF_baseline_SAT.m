function [  ] = plot_SDF_baseline_SAT( ninfo , spikes , binfo )
%plot_avg_sdf_baseline Summary of this function goes here
%   Detailed explanation goes here

NUM_CELLS = length(spikes);
NORMALIZE = true;
MIN_GRADE = 0.5;

%indexes to plot re. stimulus appearance
TIME_BASE = (-600 : -1);

blineAcc = NaN(NUM_CELLS,length(TIME_BASE));
blineFast = NaN(NUM_CELLS,length(TIME_BASE));
blineMean = NaN(1,NUM_CELLS); %for normalization

%exclude cells based on grade of visual responsiveness
gradeVis = [ninfo.visGrade];

for cc = 1:NUM_CELLS
  if (gradeVis(cc) < MIN_GRADE); continue; end
%   if (gradeVis(cc) ~= 0); continue; end
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  %index by isolation quality
  idx_iso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  
  %index by condition
  idxFast = ((binfo(kk).condition == 3) & ~idx_iso);
  idxAcc = ((binfo(kk).condition == 1) & ~idx_iso);
  
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  
  sdf_stim = compute_spike_density_fxn(spikes(cc).SAT);

  blineAcc(cc,:) = mean(sdf_stim(idxAcc & idxCorr,TIME_BASE + 3500));
  blineFast(cc,:) = mean(sdf_stim(idxFast & idxCorr,TIME_BASE + 3500));
  
  %record mean baseline across Acc and Fast for normalization
  blineMean(cc) = nanmean([blineAcc(cc,:), blineFast(cc,:)]);
  
end%for:cells(kk)

if (NORMALIZE)
  blineAcc = blineAcc ./ blineMean';
  blineFast = blineFast ./ blineMean';
end

%% Plotting
NUM_SEM = sum(gradeVis >= MIN_GRADE);

figure(); hold on
shaded_error_bar(TIME_BASE, nanmean(blineFast), nanstd(blineFast)/sqrt(NUM_SEM), {'-', 'Color',[0 .7 0]})
shaded_error_bar(TIME_BASE, nanmean(blineAcc), nanstd(blineAcc)/sqrt(NUM_SEM), {'r-'})
xlim([TIME_BASE(1)-10, TIME_BASE(end)+10]);
ppretty('image_size',[6.4,4])
% print('~/Dropbox/ZZtmp/blineVis-Eu.eps', '-depsc2')

pause(0.25)

figure(); hold on
shaded_error_bar(TIME_BASE, nanmean(blineFast-blineAcc), nanstd(blineFast-blineAcc)/sqrt(NUM_SEM), 'k-')
xlim([TIME_BASE(1)-10, TIME_BASE(end)+10]);
ppretty('image_size',[6.4,4])
% print('~/Dropbox/ZZtmp/blineDiffVis-Eu.eps', '-depsc2')


end%util:plot_SDF_baseline_SAT()

