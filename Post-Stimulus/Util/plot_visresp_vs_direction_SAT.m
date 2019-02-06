function [ ] = plot_visresp_vs_direction_SAT( spikes , ninfo , binfo )
%plot_visresp_vs_direction_SAT Summary of this function goes here
%   Detailed explanation goes here

LOC_DD_PLOT = [6, 3, 2, 1, 4, 7, 8, 9]; %indexes for plotting by direction

TIME_PLOT = (-100 : 500);
NUM_SAMP = length(TIME_PLOT);

NUM_CELLS = length(spikes);
NUM_DIR = 8;

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  
  %index by condition
  idxFast = ((binfo(kk).condition == 3) & ~idxIso);
  idxAcc = ((binfo(kk).condition == 1) & ~idxIso);
  
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  
  %% Compute the SDF for each direction
  sdfFast = NaN(NUM_DIR,NUM_SAMP);
  sdfAcc = NaN(NUM_DIR,NUM_SAMP);
  
  %loop over singleton locations and index by location
  for dd = 1:NUM_DIR
    idx_dd = (binfo(kk).tgt_octant == dd);
    
    sdfFast_dd = compute_spike_density_fxn(spikes(cc).SAT(idxFast & idxCorr & idx_dd));
    sdfAcc_dd = compute_spike_density_fxn(spikes(cc).SAT(idxAcc & idxCorr & idx_dd));
    
    sdfFast(dd,:) = nanmean(sdfFast_dd(:,3500+TIME_PLOT));
    sdfAcc(dd,:) = nanmean(sdfAcc_dd(:,3500+TIME_PLOT));
    
  end%for:direction(dd)
  
  %% Plotting
  
  figure()
  ylim_cc = NaN(NUM_DIR,2);
  
  
  for dd = 1:NUM_DIR
    subplot(3,3,LOC_DD_PLOT(dd)); hold on
    plot(TIME_PLOT, sdfFast(dd,:), '-', 'color',[0 .7 0], 'linewidth',1.25);
    plot(TIME_PLOT, sdfAcc(dd,:), 'r-', 'linewidth',1.25);
    
    %axis labels
    if (LOC_DD_PLOT(dd) == 4)
      ylabel('Activity (sp/sec)')
    elseif (LOC_DD_PLOT(dd) == 8)
      xlabel('Time from stimulus (ms)')
    end
    
    xlim([TIME_PLOT(1) TIME_PLOT(end)]); xticks(TIME_PLOT(1):100:TIME_PLOT(end)); pause(.05)
    ylim_cc(dd,:) = get(gca, 'ylim');
  end%for:direction(dd)
  
  %set y-axes and plot zero-line
  ylim_cc = [min(ylim_cc(:,1)), max(ylim_cc(:,2))];
  for dd = 1:NUM_DIR
    subplot(3,3,LOC_DD_PLOT(dd))
    plot([0 0], ylim_cc, 'k-')
  end
  
  subplot(3,3,5); xticks([]); yticks([]); print_session_unit(gca , ninfo(cc), binfo(kk), 'horizontal')
  
  ppretty('image_size',[10,8])
  pause(0.25)
  print(['~/Dropbox/ZZtmp/', ninfo(cc).sess,'-',ninfo(cc).unit,'.tif'], '-dtiff'); pause(0.25)
  pause(0.25); close()
  
end%for:cell(cc)

end%function:plot_visresp_vs_direction_SAT()
