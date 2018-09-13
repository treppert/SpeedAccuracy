function [  ] = plot_avg_sdf_baseline_indiv( spikes , ninfo , binfo )
%plot_avg_sdf_baseline Summary of this function goes here
%   Detailed explanation goes here

NUM_CELLS = length(spikes);

TYPE_PLOT = {'M'};

IDX_PLOT = (-600 : 0); %relative to stimulus appearance
NUM_SAMP = length(IDX_PLOT);

%initialize output re. fixation and stimulus
base_acc = NaN(NUM_CELLS,NUM_SAMP);
base_fast = base_acc;

figure()
idx_plot = 0;

for kk = 1:NUM_CELLS
  if ~ismember(ninfo(kk).type, TYPE_PLOT); continue; end
  idx_plot = idx_plot + 1;
  
  sdf_kk = compute_spike_density_fxn(spikes(kk).SAT);
  
  kk_moves = ismember({binfo.session}, ninfo(kk).session);
  idx_acc = (binfo(kk_moves).condition == 1);
  idx_fast = (binfo(kk_moves).condition == 3);
  
  base_acc(kk,:) = nanmean(sdf_kk(idx_acc, 3500+IDX_PLOT));
  base_fast(kk,:) = nanmean(sdf_kk(idx_fast, 3500+IDX_PLOT));
  
  base_all = [ base_acc(kk,:) base_fast(kk,:) ];
  
  subplot(4,4,idx_plot); hold on
  plot(IDX_PLOT, base_fast(kk,:), 'LineWidth',1.25, 'Color',[0 .7 0])
  plot(IDX_PLOT, base_acc(kk,:), 'r-', 'LineWidth',1.25)
  
  title([ninfo(kk).session,'-',ninfo(kk).type], 'fontsize',8)
  ylim([min(base_all) max(base_all)])
  pause(.1)
  
end%for:cells(kk)

ppretty('image_size',[14,11])

end%util:plot_avg_sdf_baseline()

