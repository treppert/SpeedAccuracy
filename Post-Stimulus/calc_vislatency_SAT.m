function [ latVR ] = calc_vislatency_SAT( ninfo , spikes , binfo )
%calc_vislatency_SAT Summary of this function goes here
%   Detailed explanation goes here

DEBUG = false;

NUM_CELLS = length(ninfo);
MIN_GRADE = 3; %minimum grade for visual response

MIN_RISE = 10; %minimum increase from baseline activity (sp/sec)
MIN_HOLD = 10; %minimum consecutive timepoints above criterion

TIME_STIM = 3500;
TIME_CHECK = ( 1 : 200 ); %timepoints re. stimulus appearance

latVR = NaN(1,NUM_CELLS);

for cc = 1:NUM_CELLS
  if (ninfo(cc).vis < MIN_GRADE); continue; end
  
  %get session number corresponding to behavioral data
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  %index by isolation quality
  idx_iso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  
  %index by trial outcome
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  
  VRcc = compute_spike_density_fxn(spikes(cc).SAT(idx_corr & ~idx_iso));
  VRcc = mean(VRcc(:,TIME_STIM + TIME_CHECK));
  
  bline = mean(VRcc(1:40));
  
  %find points that are above threshold
  time_sup = find(VRcc > ( bline + MIN_RISE ));
  
  %make correction for cells with low firing rate
  if isempty(time_sup)
    time_sup = find(VRcc > ( bline + 3 ));
  end
  
  num_sup = length(time_sup);
  dt_sup = diff(time_sup);
  
  %use the minimum hold period to identify temporary estimate of latency
  estimated_lat = NaN;
  for ii = 1 : (num_sup - MIN_HOLD)
    idx_ii = (ii : ii + MIN_HOLD - 1);
    
    if (sum(dt_sup(idx_ii)) == MIN_HOLD)
      estimated_lat = time_sup(ii);
      break
    end
    
  end%for:timepoint(ii)
  
  if isnan(estimated_lat)
    continue
  end
  
  %get best estimate of latency by walking back to baseline
  latVR(cc) = find(VRcc(1:estimated_lat) < (bline+2), 1, 'last');
  
  %make correction for cells with slow ramping
  if (latVR(cc) > 100)
    latVR(cc) = find(VRcc(1:latVR(cc)) < (bline), 1, 'last');
  end
  
  if (DEBUG)
    figure(101); hold off
    plot(VRcc, 'k-'); hold on
    plot(latVR(cc), VRcc(latVR(cc)), 'r*')
    print_session_unit(gca , ninfo(cc), 'horizontal')
    pause(1.0)
  end
  
end%for:cells(kk)

end%util:calc_vislatency_SAT()

  
