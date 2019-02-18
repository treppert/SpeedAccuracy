function [  ] = plotRasterStimSAT( binfo , moves , ninfo , spikes , varargin )
%plotRasterStimSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {'sort_RT', {'area=','SC'}, {'monkey=','D'}});

idx_area = ismember({ninfo.area}, args.area);
idx_monkey = ismember({ninfo.monkey}, args.monkey);

ninfo = ninfo(idx_area & idx_monkey);
spikes = spikes(idx_area & idx_monkey);

NUM_CELLS = length(ninfo);
IDX_PLOT = (-500 : 1000);

%% Spike rasters

for cc = 1:NUM_CELLS
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  idx_corr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idx_cond = (binfo(kk).condition == 1);
  
  resptime = double(moves(kk).resptime(idx_cond & idx_corr));
  num_trials = sum(idx_cond & idx_corr);
  
  %organize spikes as 1-D array for plotting
  tmp = spikes(cc).SAT(idx_cond & idx_corr);
  t_spikes = cell2mat(tmp) - 3500;
  trials = NaN(1,length(t_spikes));
  
  %get trial numbers corresponding to each spike
  idx = 1;
  for jj = 1:num_trials
    trials(idx:idx+length(tmp{jj})-1) = jj;
    idx = idx + length(tmp{jj});
  end%for:trials(jj)
  
  if (args.sort_RT) %if desired, sort trials by response time
    [resptime,idx_RT] = sort(resptime);
    
    trials_new = NaN(1,length(t_spikes));
    for jj = 1:num_trials
      trials_new(trials == jj) = idx_RT(jj);
    end
    
    trials = trials_new;
  end%if:sort-RT
  
  %remove spikes outside of timing window of interest
  idx_time = ((t_spikes >= IDX_PLOT(1)) & (t_spikes <= IDX_PLOT(end)));
  t_spikes = t_spikes(idx_time);
  trials = trials(idx_time);
  
  %% Plotting
  figure(); hold on
  plot(t_spikes, trials, 'k.', 'MarkerSize',4)
  plot([0 0], [0 num_trials], 'b-', 'LineWidth',1.5)
  plot(resptime, (1:num_trials), 'ro', 'MarkerSize',3)
  
  xlim([IDX_PLOT(1), IDX_PLOT(end)]);
  xticks(IDX_PLOT(1):100:IDX_PLOT(end));
  y_lim = get(gca, 'ylim');
  yticks(y_lim(1):50:y_lim(2))
  
  xlabel('Time re. stimulus (ms)')
  ylabel('Trial number')
  
  title([ninfo(cc).sess,'-',ninfo(cc).unit,' -- N_{trial} = ',num2str(num_trials)], 'FontSize',8)
  ppretty('image_size',[8,10])
  pause()
%   pause(0.5)
%   print_fig_SAT(ninfo(cc), gcf, '-dtiff')
%   pause(0.5)
%   close(gcf)
  
end%for:cells(cc)

end%util:plot_spike_raster_SAT()
