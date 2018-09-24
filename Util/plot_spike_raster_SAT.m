function [  ] = plot_spike_raster_SAT( binfo , ninfo , spikes )
%plot_spike_raster Summary of this function goes here
%   Detailed explanation goes here

NUM_CELL = length(ninfo);

IDX_PLOT = (-500 : 750);
IDX_STIM = 3500;

%% Spike rasters

for cc = 1:NUM_CELL
  
  kk = ismember({binfo.session}, ninfo(cc).sesh);
  
  %organize spikes as 1-D array for plotting
  tmp = spikes(cc).SAT;
  t_spikes = cell2mat(tmp) - IDX_STIM;
  trials = uint16(zeros(1,length(t_spikes)));
  
  %get trial numbers corresponding to each spike
  idx = 1;
  for jj = 1:binfo(kk).num_trials
    trials(idx:idx+length(tmp{jj})-1) = jj;
    idx = idx + length(tmp{jj});
  end%for:trials(jj)
  
  %remove spikes outside of timing window of interest
  idx_time = ((t_spikes >= IDX_PLOT(1)) & (t_spikes <= IDX_PLOT(end)));
  t_spikes = t_spikes(idx_time);
  trials = trials(idx_time);
  
  %save spikes by group (Accurate/Fast & Correct/Error)
%   sraster_acc(cc).corr = t_spikes(ismember(trials, find(idx_acc & idx_corr)));

  figure(); hold on
  plot(t_spikes, trials, 'k.', 'MarkerSize',4)
  xlim([IDX_PLOT(1), IDX_PLOT(end)]);
  title([ninfo(cc).sesh,'-',ninfo(cc).unit], 'FontSize',8)
  
  ppretty('image_size',[7,10])
  
end%for:cells(cc)

end%util:plot_spike_raster_SAT()
