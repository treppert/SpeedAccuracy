function [ ] = plot_visresp_vs_direction_MG( spikes , ninfo , binfo )
%plot_visresp_vs_direction_MG Summary of this function goes here
%   Detailed explanation goes here

LOC_DD_PLOT = [6, 3, 2, 1, 4, 7, 8, 9]; %indexes for plotting by direction

TIME_PLOT = (-100 : 500);
NUM_SAMP = length(TIME_PLOT);

NUM_DIR = 8;
NUM_CELLS = length(spikes);

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_hold | binfo(kk).err_nosacc);
  
  %% Compute the SDF for each direction
  sdf_cc = NaN(NUM_DIR,NUM_SAMP);
    
  %loop over singleton locations and index by location
  for dd = 1:NUM_DIR
    
    idx_dd = ismember(binfo(kk).tgt_octant, dd);
    sdf_dd = compute_spike_density_fxn(spikes(cc).MG(idxCorr & idx_dd));
    sdf_cc(dd,:) = nanmean(sdf_dd(:,3500+TIME_PLOT));
    
  end%for:direction(dd)
  
  %% Plotting
  
  figure()
  Y_LIM = NaN(NUM_DIR,2);
  
  for dd = 1:NUM_DIR
    subplot(3,3,LOC_DD_PLOT(dd)); hold on
    plot(TIME_PLOT, sdf_cc(dd,:), 'k-');
    
    %axis labels
    if (LOC_DD_PLOT(dd) == 4)
      ylabel('Activity (sp/sec)')
    elseif (LOC_DD_PLOT(dd) == 8)
      xlabel('Time from stimulus (ms)')
    end
    
    xlim([TIME_PLOT(1) TIME_PLOT(end)]); xticks(TIME_PLOT(1):100:TIME_PLOT(end)); pause(.05)
    Y_LIM(dd,:) = get(gca, 'ylim');
  end%for:direction(dd)
  
  %set y-axes and plot zero-line
  Y_LIM = [min(Y_LIM(:,1)), max(Y_LIM(:,2))];
  for dd = 1:NUM_DIR
    subplot(3,3,LOC_DD_PLOT(dd))
    plot([0 0], Y_LIM, 'k-')
  end
  
  subplot(3,3,5); xticks([]); yticks([]); print_session_unit(gca , ninfo(cc), binfo(kk), 'horizontal')
  
  ppretty('image_size',[10,8])
  pause(0.25)
  print(['~/Dropbox/ZZtmp/', ninfo(cc).sess,'-',ninfo(cc).unit,'.tif'], '-dtiff'); pause(0.25)
  pause(0.25); close()
  
end%for:cells(cc)

end%function:plot_visresp_vs_direction_MG()
