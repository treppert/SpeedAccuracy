function [ ] = plot_visresp_vs_direction_SAT( spikes , ninfo , binfo )
%plot_visresp_vs_direction_SAT Summary of this function goes here
%   Detailed explanation goes here

MIN_VIS = 3; %minimum grade for VIS cells

LOC_DD_PLOT = [6, 3, 2, 1, 4, 7, 8, 9]; %indexes for plotting by direction

TIME_ARRAY = 3500;
TIME_PLOT = (-200 : 300);
NUM_SAMP = length(TIME_PLOT);

NUM_DIR = 8;
NUM_CELLS = length(spikes);

for cc = 1:NUM_CELLS
  
  if (ninfo(cc).vis < MIN_VIS); continue; end
  
  %% Compute the SDF for each direction
  
  %neuron-specific initialization
  sdf_Acc  = NaN(NUM_DIR,NUM_SAMP);
  sdf_Fast = NaN(NUM_DIR,NUM_SAMP);
    
  %get session number corresponding to behavioral data
  kk = ismember({binfo.session}, ninfo(cc).sesh);
  
  %index by trial outcome
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  
  %index by condition -- only trials with correct outcome
  idx_fast = (binfo(kk).condition == 3) & idx_corr;
  idx_acc = (binfo(kk).condition == 1) & idx_corr;
  
  for dd = 1:NUM_DIR
    idx_dd = ismember(binfo(kk).tgt_octant, dd);
    
    sdf_acc = compute_spike_density_fxn(spikes(cc).SAT(idx_acc & idx_dd));
    sdf_fast = compute_spike_density_fxn(spikes(cc).SAT(idx_fast & idx_dd));
    
    sdf_Acc(dd,:)  = nanmean(sdf_acc(:,TIME_ARRAY+TIME_PLOT))';
    sdf_Fast(dd,:) = nanmean(sdf_fast(:,TIME_ARRAY+TIME_PLOT))';
    
  end%for:directions(dd)
  
  %% Plotting
  
  figure()
  
  Y_LIM = NaN(NUM_DIR,2);
  for dd = 1:NUM_DIR
    subplot(3,3,LOC_DD_PLOT(dd)); hold on
    plot(TIME_PLOT, sdf_Acc(dd,:), 'r-', 'linewidth',1.25);
    plot(TIME_PLOT, sdf_Fast(dd,:), '-', 'color',[0 .7 0], 'linewidth',1.25);
    
    %axis labels
    if ismember(LOC_DD_PLOT(dd), [1,4,7])
      ylabel('Activity (sp/sec)')
    end
    if ismember(LOC_DD_PLOT(dd), [7,8,9])
      xlabel('Time re. stimulus (ms)')
    end
    
    xlim([TIME_PLOT(1) TIME_PLOT(end)]); xticks(TIME_PLOT(1):100:TIME_PLOT(end)); pause(.05)
    Y_LIM(dd,:) = get(gca, 'ylim');
  end
  
  %set y-axes and plot zero-line
  Y_LIM = [min(Y_LIM(:,1)), max(Y_LIM(:,2))];
  for dd = 1:NUM_DIR
    subplot(3,3,LOC_DD_PLOT(dd)); ylim(Y_LIM)
    plot([0 0], Y_LIM, 'k-')
  end
  
  ppretty('image_size',[10,8])
  pause(0.25); print(['~/Dropbox/tmp/', ninfo(cc).sesh,'-',ninfo(cc).unit,'.tif'], '-dtiff'); pause(0.25)
  
end%for:cells(cc)

end%function:plot_visresp_vs_direction_SAT()
