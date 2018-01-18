function [ avg_bline , varargout ] = calc_avg_baseline_SAT( spikes )
%calc_avg_baseline_SAT Summary of this function goes here
%   Detailed explanation goes here

TIME_STIM = 3500;
TIME_BASE = ( -500 : -1 );

NUM_CELLS = length(spikes);

avg_bline = NaN(1,NUM_CELLS);
sd_bline = NaN(1,NUM_CELLS);

for kk = 1:NUM_CELLS
  
  sdf_bline = compute_spike_density_fxn( spikes(kk).SAT );
  sdf_bline = mean(sdf_bline(:,TIME_STIM + TIME_BASE));
  
  avg_bline(kk) = mean(sdf_bline,2);
  sd_bline(kk) = std(sdf_bline,0,2);
  
end%for:cells(kk)

if (nargout > 1)
  varargout{1} = sd_bline;
end

end%util:calc_avg_baseline_SAT()

