function [  ] = plot_SDF_baseline_SAT( binfo , ninfo , spikes , bline_avg )
%plot_avg_sdf_baseline Summary of this function goes here
%   Detailed explanation goes here

TIME_ZERO = 3500;
TIME_BASE = (-500 : -1);
TIME_FIX = (1 : 500);
NUM_SAMP = length(TIME_BASE);
LIM_FIXTIME = -2000;

MIN_GRADE = 3;
MIN_BLINE = 5; %sp/sec
NUM_CELLS = length(spikes);
NUM_SEM = sum(([ninfo.vis] >= MIN_GRADE));% & (bline_avg >= MIN_BLINE));

%initialize output re. fixation and stimulus
bline_Acc_Fix = NaN(NUM_CELLS,NUM_SAMP);
bline_Acc_Stim = NaN(NUM_CELLS,NUM_SAMP);
bline_Fast_Fix = NaN(NUM_CELLS,NUM_SAMP);
bline_Fast_Stim = NaN(NUM_CELLS,NUM_SAMP);

for kk = 1:NUM_CELLS
  if (ninfo(kk).vis < MIN_GRADE); continue; end
%   if (bline_avg(kk) < MIN_BLINE); continue; end
  
  kk_moves = ismember({binfo.session}, ninfo(kk).sesh);
  
  fixtime = binfo(kk_moves).fixtime;
  fixtime(fixtime < LIM_FIXTIME) = NaN;
  
  sdf_stim = compute_spike_density_fxn(spikes(kk).SAT);

  sdf_fix = align_signal_on_response(sdf_stim, fixtime);
  sdf_fix(isnan(fixtime),:) = NaN;
  
  idx_Acc = (binfo(kk_moves).condition == 1);
  idx_Fast = (binfo(kk_moves).condition == 3);
  
  bline_Acc_Fix(kk,:) = nanmean(sdf_fix(idx_Acc,TIME_ZERO + TIME_FIX));
  bline_Acc_Stim(kk,:) = mean(sdf_stim(idx_Acc,TIME_ZERO + TIME_BASE));
  bline_Fast_Fix(kk,:) = nanmean(sdf_fix(idx_Fast,TIME_ZERO + TIME_FIX));
  bline_Fast_Stim(kk,:) = mean(sdf_stim(idx_Fast,TIME_ZERO + TIME_BASE));
  
end%for:cells(kk)

%normalization
% bline_Acc_Fix = bline_Acc_Fix ./ bline_avg';
% bline_Acc_Stim = bline_Acc_Stim ./ bline_avg';
% bline_Fast_Fix = bline_Fast_Fix ./ bline_avg';
% bline_Fast_Stim = bline_Fast_Stim ./ bline_avg';

figure()
subplot(1,2,1); hold on
shaded_error_bar(TIME_FIX, nanmean(bline_Fast_Fix), nanstd(bline_Fast_Fix)/sqrt(NUM_SEM), {'Color',[0 .7 0]})
shaded_error_bar(TIME_FIX, nanmean(bline_Acc_Fix), nanstd(bline_Acc_Fix)/sqrt(NUM_SEM), {'Color','r'})
xlim([TIME_FIX(1)-10, TIME_FIX(end)+10]);

subplot(1,2,2); hold on
yticks([]); yyaxis right; set(gca, 'ycolor', 'k')
shaded_error_bar(TIME_BASE, nanmean(bline_Fast_Stim), nanstd(bline_Fast_Stim)/sqrt(NUM_SEM), {'-', 'Color',[0 .7 0]})
shaded_error_bar(TIME_BASE, nanmean(bline_Acc_Stim), nanstd(bline_Acc_Stim)/sqrt(NUM_SEM), {'r-'})
xlim([TIME_BASE(1)-10, TIME_BASE(end)+10]);

ppretty('image_size',[6.4,2])

end%util:plot_avg_sdf_baseline()

