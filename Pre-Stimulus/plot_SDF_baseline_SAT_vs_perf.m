function [  ] = plot_SDF_baseline_SAT_vs_perf( ninfo , spikes , binfo , moves )
%plot_SDF_baseline_SAT_vs_perf Summary of this function goes here
%   Detailed explanation goes here

NUM_CELLS = length(spikes);
NORMALIZE = true;
MIN_GRADE = 0.5;

%compute mean error rate of each session (to split based on performance)
errRate = plot_Perr_vs_RT_vs_cond(moves, binfo);
% MAX_ER_FAST_GOOD = 0.20; %Da
MAX_ER_FAST_GOOD = 0.30; %Eu

%indexes to plot re. stimulus appearance
TIME_BASE = (-600 : -1);

blineGoodAcc = NaN(NUM_CELLS,length(TIME_BASE));
blineGoodFast = NaN(NUM_CELLS,length(TIME_BASE));
blineBadAcc = NaN(NUM_CELLS,length(TIME_BASE));
blineBadFast = NaN(NUM_CELLS,length(TIME_BASE));
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
  
  sdf_cc = compute_spike_density_fxn(spikes(cc).SAT);
  
  if (errRate.fast(kk) >= MAX_ER_FAST_GOOD) %"bad" performance session
    blineBadAcc(cc,:) = mean(sdf_cc(idxAcc & idxCorr,TIME_BASE + 3500));
    blineBadFast(cc,:) = mean(sdf_cc(idxFast & idxCorr,TIME_BASE + 3500));
    blineMean(cc) = nanmean([blineBadAcc(cc,:), blineBadFast(cc,:)]);
  else %"good" performance session
    blineGoodAcc(cc,:) = mean(sdf_cc(idxAcc & idxCorr,TIME_BASE + 3500));
    blineGoodFast(cc,:) = mean(sdf_cc(idxFast & idxCorr,TIME_BASE + 3500));
    blineMean(cc) = nanmean([blineGoodAcc(cc,:), blineGoodFast(cc,:)]);
  end
  
end%for:cells(kk)

if (NORMALIZE)
  blineGoodAcc = blineGoodAcc ./ blineMean';
  blineGoodFast = blineGoodFast ./ blineMean';
  blineBadAcc = blineBadAcc ./ blineMean';
  blineBadFast = blineBadFast ./ blineMean';
end

%% Plotting
NUM_SEM_GOOD = sum(~isnan(blineGoodAcc(:,1)));
NUM_SEM_BAD = sum(~isnan(blineBadAcc(:,1)));

figure(); hold on
shaded_error_bar(TIME_BASE, nanmean(blineGoodAcc), nanstd(blineGoodAcc)/sqrt(NUM_SEM_GOOD), {'r-', 'LineWidth',1.25})
shaded_error_bar(TIME_BASE, nanmean(blineGoodFast), nanstd(blineGoodFast)/sqrt(NUM_SEM_GOOD), {'-', 'LineWidth',1.25, 'Color',[0 .7 0]})
xlim([TIME_BASE(1)-10, TIME_BASE(end)+10]);
ytickformat('%3.2f')
ppretty()

pause(0.25)

figure(); hold on
shaded_error_bar(TIME_BASE, nanmean(blineBadAcc), nanstd(blineBadAcc)/sqrt(NUM_SEM_BAD), {'r-', 'LineWidth',1.0})
shaded_error_bar(TIME_BASE, nanmean(blineBadFast), nanstd(blineBadFast)/sqrt(NUM_SEM_BAD), {'-', 'LineWidth',1.0, 'Color',[0 .7 0]})
xlim([TIME_BASE(1)-10, TIME_BASE(end)+10]);
ytickformat('%3.2f')
ppretty()

pause(0.25)

blineGoodDiff = blineGoodFast - blineGoodAcc;
blineBadDiff = blineBadFast - blineBadAcc;

figure(); hold on
shaded_error_bar(TIME_BASE, nanmean(blineGoodDiff), nanstd(blineGoodDiff)/sqrt(NUM_SEM_GOOD), {'k-', 'LineWidth',1.5})
shaded_error_bar(TIME_BASE, nanmean(blineBadDiff), nanstd(blineBadDiff)/sqrt(NUM_SEM_BAD), {'k-'})
plot([TIME_BASE(1) TIME_BASE(end)], [0 0], 'k--')
xlim([TIME_BASE(1)-10, TIME_BASE(end)+10]);
ytickformat('%3.2f')
ppretty()

end%util:plot_SDF_baseline_SAT_vs_perf()

