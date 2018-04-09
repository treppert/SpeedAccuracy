function [  ] = plot_spike_raster( binfo , ninfo , spikes )
%plot_spike_raster Summary of this function goes here
%   Detailed explanation goes here

NUM_CELL = length(ninfo);

IDX_PLOT = (1 : 1000);
IDX_STIM = 3500;

TRIAL_PLOT = (201:300);

for cc = 1:NUM_CELL
  
  kk = ismember({binfo.session}, ninfo(cc).sesh);
  NUM_TRIAL = binfo(kk).num_trials;
  
  %organize spikes as 1-D array for plotting
  tmp = spikes(cc).SAT;
  t_spikes = cell2mat(tmp) - IDX_STIM;
  trials = uint16(zeros(1,length(t_spikes)));
  
  %get trial numbers corresponding to each spike
  idx = 1;
  for jj = 1:NUM_TRIAL
    trials(idx:idx+length(tmp{jj})-1) = jj;
    idx = idx + length(tmp{jj});
  end%for:trials(jj)
  
  idx_time = ((t_spikes >= IDX_PLOT(1)) & (t_spikes <= IDX_PLOT(end)));
  idx_trial = ((trials >= TRIAL_PLOT(1)) & (trials <= TRIAL_PLOT(end)));
  
  figure(); hold on
  plot(t_spikes(idx_trial & idx_time), trials(idx_trial & idx_time), 'k.', 'MarkerSize',3)
  
end%for:cells(kk)

end%util:plot_spike_raster

