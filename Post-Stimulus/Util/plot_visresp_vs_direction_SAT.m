function [ ] = plot_visresp_vs_direction_SAT( spikes , ninfo , binfo , moves , varargin )
%plot_visresp_vs_direction_SAT Summary of this function goes here
%   Detailed explanation goes here

MIN_VIS = 3; %minimum grade for VIS cells

LOC_DD_PLOT = [6, 3, 2, 1, 4, 7, 8, 9]; %indexes for plotting by direction

TIME_PLOT = (-100 : 300);
NUM_SAMP = length(TIME_PLOT);

NUM_DIR = 8;
NUM_CELLS = length(spikes);

if (nargin > 3) %if provided, plot time of initiation of visual response
  t_VR = varargin{1};
end

for cc = 1:NUM_CELLS
  if (ninfo(cc).vis < MIN_VIS); continue; end
  
  %get session number corresponding to behavioral data
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  %index by isolation quality
  idx_iso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  
  %index by condition
  idx_cond = ((binfo(kk).condition == 3) & ~idx_iso);
  
  %index by trial outcome
%   idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idx_corr = (binfo(kk).err_dir & ~binfo(kk).err_time); %choice error trials
  
  %% Compute the SDF for each direction
  
  %neuron-specific initialization
  sdf_cc = NaN(NUM_DIR,NUM_SAMP);
    
  for dd = 1:NUM_DIR
    
%     idx_dd = (idx_cond & idx_corr & (binfo(kk).tgt_octant == dd)); %correct trials
    idx_dd = (idx_cond & idx_corr & (moves(kk).octant == dd)); %choice error trials
    
    sdf_dd = compute_spike_density_fxn(spikes(cc).SAT(idx_dd));
    sdf_cc(dd,:) = nanmean(sdf_dd(:,3500+TIME_PLOT));
    
  end%for:directions(dd)
  
  %% Plotting
  Y_LIM = NaN(NUM_DIR,2);
  
  figure()
  
  for dd = 1:NUM_DIR
    subplot(3,3,LOC_DD_PLOT(dd)); hold on
    plot(TIME_PLOT, sdf_cc(dd,:), '-', 'color',[0 .7 0], 'linewidth',1.25);
    
    %axis labels
    if (LOC_DD_PLOT(dd) == 4)
      ylabel('Activity (sp/sec)')
    elseif (LOC_DD_PLOT(dd) == 8)
      xlabel('Time from stimulus (ms)')
    end
    
    xlim([TIME_PLOT(1) TIME_PLOT(end)]); xticks(TIME_PLOT(1):100:TIME_PLOT(end)); pause(.05)
    Y_LIM(dd,:) = get(gca, 'ylim');
  end
  
  %set y-axes and plot zero-line
  Y_LIM = [min(Y_LIM(:,1)), max(Y_LIM(:,2))];
  for dd = 1:NUM_DIR
    subplot(3,3,LOC_DD_PLOT(dd))
    plot([0 0], Y_LIM, 'k-')
    if (nargin > 3) %plot region used to calculate VR magnitude
      plot([t_VR(cc) t_VR(cc)], Y_LIM, 'k:')
      plot([t_VR(cc) t_VR(cc)]+100, Y_LIM, 'k:')
    end
  end
  
  subplot(3,3,5); xticks([]); yticks([]); print_session_unit(gca , ninfo(cc), 'horizontal')
  
  ppretty('image_size',[10,8])
  pause()
%   print(['~/Dropbox/tmp/', ninfo(cc).sess,'-',ninfo(cc).unit,'.tif'], '-dtiff'); pause(0.25)
  
end%for:cells(cc)

end%function:plot_visresp_vs_direction_SAT()
