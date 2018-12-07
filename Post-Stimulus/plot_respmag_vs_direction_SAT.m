function [ ] = plot_respmag_vs_direction_SAT( ninfo , spikes , latVR , binfo )
%plot_respmag_vs_direction_SAT Summary of this function goes here
%   Inputs are outputs from []

CONDITION = 'fast';
MIN_VIS = 3; %minimum grade for visual response
NUM_CELLS = length(ninfo);

TIME_ASSESS = 3500 + (1 : 100); %time for avg resp magnitude (re. latency)

magVR = NaN(NUM_CELLS,8);

%% Compute visual response magnitude vs direction

for cc = 1:NUM_CELLS
  if (ninfo(cc).vis < MIN_VIS); continue; end
  
  %get session number corresponding to behavioral data
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  %index by isolation quality
  idx_iso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  
  %index by condition
  if strcmp(CONDITION, 'fast')
    idx_cond = ((binfo(kk).condition == 3) & ~idx_iso);
  elseif strcmp(CONDITION, 'acc')
    idx_cond = ((binfo(kk).condition == 1) & ~idx_iso);
  end
  
  %index by trial outcome
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  
  %each response magnitude independently for each direction
  for dd = 1:8
    
    idx_dd = ismember(binfo(kk).tgt_octant, dd);
    
    sdf_dd = compute_spike_density_fxn(spikes(cc).SAT(idx_cond & idx_corr & idx_dd));
    sdf_dd = nanmean(sdf_dd(:, latVR(cc) + TIME_ASSESS));
    
    magVR(cc,dd) = mean(sdf_dd);
    
  end%for:direction(dd)
  
end%for:cells(cc)

%% Compute the resultant vector
THETA_VR = (0 : pi/4 : 7*pi/4);

resVR = NaN(1,NUM_CELLS); %magnitude of resultant vector
thVR = NaN(1,NUM_CELLS); %angle of resultant vector

for cc = 1:NUM_CELLS
  if (ninfo(cc).vis < MIN_VIS); continue; end
  
  xVRcc = sum(magVR(cc,:) .* cos(THETA_VR));
  yVRcc = sum(magVR(cc,:) .* sin(THETA_VR));
  
  resVR(cc) = sqrt(xVRcc*xVRcc + yVRcc*yVRcc);
  thVR(cc) = atan2(yVRcc,xVRcc);
  
end%for:cells(cc)


%% Plotting
magVR = cat(2, magVR, magVR(:,1)); %complete the circle for plotting
THETA_PLOT = (0 : pi/4 : 2*pi);

for cc = 1:NUM_CELLS
  if (ninfo(cc).vis < MIN_VIS); continue; end
  
  figure(); polaraxes(); hold on

  if strcmp(CONDITION, 'fast')
    polarplot(THETA_PLOT, magVR(cc,:), '-', 'Color',[0 .7 0], 'LineWidth',1.0)
    polarplot(thVR(cc)*ones(1,2), [0 resVR(cc)], '-', 'Color',[0 .4 0], 'LineWidth',1.5)
  else
    polarplot(THETA_PLOT, magVR(cc,:), 'r-', 'LineWidth',1.0)
    polarplot(thVR(cc)*ones(1,2), [0 resVR(cc)], 'r-', 'LineWidth',1.5)
  end
  
  thetaticks(rad2deg(THETA_PLOT))
  title([ninfo(cc).sess,'-',ninfo(cc).unit], 'FontSize',8)
  ppretty('image_size',[5,5])
  
  pause(0.1)
end%for:cells(cc)

end%function:plot_respmag_vs_direction_SAT()
