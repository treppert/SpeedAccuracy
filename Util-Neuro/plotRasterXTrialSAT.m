function [  ] = plotRasterXTrialSAT( binfo , moves , ninfo , spikes , varargin )
%plotRasterXTrialSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=',{'SEF'}}, {'monkey=',{'D','E','Q','S'}}});
ROOT_DIR = 'C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\SEF_SAT\Figs\0-Raster\SAT\';

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

ninfo = ninfo(idxArea & idxMonkey);
spikes = spikes(idxArea & idxMonkey);

NUM_CELLS = length(ninfo);
TIME_PLOT = (-1000 : 2000); %time from stimulus

%% Spike rasters

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
%   RTkk = double(moves(kk).resptime);
  
  %organize spikes as 1-D array for plotting
  tSpikeCell = spikes(cc).SAT;
%   tSpikeCell = spikes(cc).MG;
  tSpikeMat = cell2mat(tSpikeCell) - 3500;
  trialSpike = NaN(1,length(tSpikeMat));
  
  %get trial numbers corresponding to each spike
  idx = 1;
  for jj = 1:length(tSpikeCell)
    trialSpike(idx:idx+length(tSpikeCell{jj})-1) = jj;
    idx = idx + length(tSpikeCell{jj});
  end%for:trials(jj)
  
  %remove spikes outside of timing window of interest
  idxPlot = ((tSpikeMat >= TIME_PLOT(1)) & (tSpikeMat <= TIME_PLOT(end)));
  tSpikeMat = tSpikeMat(idxPlot);
  trialSpike = trialSpike(idxPlot);
  
  %% Plotting
  figure(); hold on
  plot(trialSpike, tSpikeMat, 'k.', 'MarkerSize',4)
  plot([0 binfo(kk).num_trials], [0 0], 'b-', 'LineWidth',1.5)
  
  xlabel('Trial number')
  ylabel('Time from array (ms)')
  ylim([TIME_PLOT(1), TIME_PLOT(end)]);
  xLim = get(gca, 'xlim'); xticks(xLim(1):50:xLim(end));
  
  title([ninfo(cc).sess,'-',ninfo(cc).unit]); ppretty([16,8])
  print([ROOT_DIR, ninfo(cc).sess,'-',ninfo(cc).unit,'.tif'], '-dtiff')
  pause(0.25); close(); pause(0.25)
  
end%for:cells(cc)

end%util:plotRasterXTrialSAT()


%   if (args.sort_RT) %if desired, sort trials by response time
%     [RTkk,idx_RT] = sort(RTkk);
%     
%     trials_new = NaN(1,length(t_spikes));
%     for jj = 1:NUM_TRIAL
%       trials_new(trials == jj) = idx_RT(jj);
%     end
%     
%     trials = trials_new;
%   end%if:sort-RT
  
