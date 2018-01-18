function [ latency ] = calc_vislatency_SAT( ninfo , spikes )
%calc_vislatency_SAT Summary of this function goes here
%   Detailed explanation goes here

DEBUG = false;

NUM_CELLS = length(ninfo);
MIN_GRADE = 2; %minimum grade for visual response

MIN_RISE = 10; %minimum increase from baseline activity (sp/sec)
MIN_HOLD = 10; %minimum consecutive timepoints above criterion

TIME_STIM = 3500;
TIME_CHECK = ( 1 : 200 ); %timepoints re. stimulus appearance

latency = NaN(1,NUM_CELLS);

for kk = 1:NUM_CELLS
  if (ninfo(kk).vis < MIN_GRADE); continue; end
  
  visresp = compute_spike_density_fxn( spikes(kk).SAT );
  visresp = mean(visresp(:,TIME_STIM + TIME_CHECK));
  
  bline = mean(visresp(1:40));
  
  %find points that are above threshold
  time_sup = find(visresp > ( bline + MIN_RISE ));
  
  %make correction for cells with low firing rate
  if isempty(time_sup)
    time_sup = find(visresp > ( bline + 3 ));
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
  latency(kk) = find(visresp(1:estimated_lat) < (bline+2), 1, 'last');
  
  %make correction for cells with slow ramping
  if (latency(kk) > 100)
    latency(kk) = find(visresp(1:latency(kk)) < (bline), 1, 'last');
  end
  
  if (DEBUG)
    figure(); hold on
    plot(visresp, 'k-');
    plot(latency(kk), visresp(latency(kk)), 'r*')
  end
  
end%for:cells(kk)

end%util:calc_vislatency_SAT()

  
