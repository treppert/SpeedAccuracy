function [  ] = plot_avg_sdf_baseline( spikes , ninfo , binfo )
%plot_avg_sdf_baseline Summary of this function goes here
%   Detailed explanation goes here

NUM_CELLS = length(spikes);

LIM_FIXTIME = -2000; %fixtime beyond which we label NaNs

TYPE_PLOT = {'V','VM'};

IDX_RE_STIM = (-700 : 200); %relative to stimulus appearance
IDX_RE_FIX  = -fliplr(IDX_RE_STIM); %relative to fixation
NUM_SAMP = length(IDX_RE_STIM);

IDX_STIM = 3500;
IDX_NORM = (-500 : -100);

%initialize output re. fixation and stimulus
base_stim_acc = NaN(NUM_CELLS,NUM_SAMP);
base_stim_fast = base_stim_acc;
base_fix_acc = base_stim_acc;
base_fix_fast = base_stim_acc;

norm_factor = NaN(NUM_CELLS,1);

for kk = 1:NUM_CELLS
  if ~ismember(ninfo(kk).type, TYPE_PLOT); continue; end
%   if (kk == 8); continue; end %no fixation time for this SC cell
  
  kk_moves = ismember({binfo.session}, ninfo(kk).session);
  
  fixtime = binfo(kk_moves).fixtime;
  fixtime(fixtime < LIM_FIXTIME) = NaN;
  
  sdf_stim = compute_spike_density_fxn(spikes(kk).SAT);
  sdf_fix = align_signal_on_response(sdf_stim, fixtime);
  
%   sdf_stim(isnan(fixtime),:) = NaN;
  sdf_fix(isnan(fixtime),:) = NaN;
  
  idx_acc = (binfo(kk_moves).condition == 1);
  idx_fast = (binfo(kk_moves).condition == 3);
  
  norm_factor(kk) = nanmean(nanmean(sdf_stim((idx_acc|idx_fast),IDX_STIM+IDX_NORM)));
  
  %% SDF re. stimulus appearance
  
  base_stim_acc(kk,:) = nanmean(sdf_stim(idx_acc,IDX_STIM+IDX_RE_STIM));
  base_stim_fast(kk,:) = nanmean(sdf_stim(idx_fast,IDX_STIM+IDX_RE_STIM));
  
  %% SDF re. fixation
  
  base_fix_acc(kk,:) = nanmean(sdf_fix(idx_acc,IDX_STIM+IDX_RE_FIX));
  base_fix_fast(kk,:) = nanmean(sdf_fix(idx_fast,IDX_STIM+IDX_RE_FIX));
  
end%for:cells(kk)

NUM_CELLS = sum(ismember({ninfo.type}, TYPE_PLOT));

%perform normalization
base_fix_fast = base_fix_fast ./ norm_factor;
base_fix_acc = base_fix_acc ./ norm_factor;
base_stim_fast = base_stim_fast ./ norm_factor;
base_stim_acc = base_stim_acc ./ norm_factor;

figure()
subplot(1,2,1); hold on
shaded_error_bar(IDX_RE_FIX, nanmean(base_fix_fast), nanstd(base_fix_fast)/sqrt(NUM_CELLS), {'Color',[0 .7 0]})
shaded_error_bar(IDX_RE_FIX, nanmean(base_fix_acc), nanstd(base_fix_acc)/sqrt(NUM_CELLS), {'Color','r'})
xlim([IDX_RE_FIX(1)-10, IDX_RE_FIX(end)+10]); %xticks(IDX_RE_FIX(1) : 250 : IDX_RE_FIX(end))

subplot(1,2,2); hold on
yticks([]); yyaxis right; set(gca, 'ycolor', 'k')
shaded_error_bar(IDX_RE_STIM, nanmean(base_stim_fast), nanstd(base_stim_fast)/sqrt(NUM_CELLS), {'-', 'Color',[0 .7 0]})
shaded_error_bar(IDX_RE_STIM, nanmean(base_stim_acc), nanstd(base_stim_acc)/sqrt(NUM_CELLS), {'r-'})
xlim([IDX_RE_STIM(1)-10, IDX_RE_STIM(end)+10]); %xticks(IDX_RE_STIM(1) : 250 : IDX_RE_STIM(end))

ppretty('image_size',[6.4,2])

end%util:plot_avg_sdf_baseline()


%   base_all = [ base_stim_acc(kk,:) base_stim_fast(kk,:) base_fix_acc(kk,:) base_fix_fast(kk,:) ];
%   figure()
%   subplot(1,2,1); hold on
%   plot(IDX_RE_FIX, base_fix_fast(kk,:), 'LineWidth',1.25, 'Color',[0 .7 0])
%   plot(IDX_RE_FIX, base_fix_acc(kk,:), 'r', 'LineWidth',1.25)
%   ylim([min(base_all) max(base_all)])
%   print_session_unit(gca, ninfo(kk), 'type','horizontal')
%   subplot(1,2,2); hold on
%   yticks([]); yyaxis right; set(gca, 'ycolor', 'k')
%   plot(IDX_RE_STIM, base_stim_fast(kk,:), 'LineWidth',1.25, 'Color',[0 .7 0])
%   plot(IDX_RE_STIM, base_stim_acc(kk,:), 'r-', 'LineWidth',1.25)
%   ylim([min(base_all) max(base_all)])
%   ppretty('image_size',[6.4,2]); pause(1.0)
%   print(['~/Dropbox/tmp/',ninfo(kk).session,'-',ninfo(kk).unit,'.tif'], '-dtiff'); pause(1.5)
  
