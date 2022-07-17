function [ tSpike , trialSpike , RT_S ] = collect_SpikeTimes( spikes , tLim , tRef , RT_S )
% This function is used to prepare spike times for raster plotting.
%   tRef - Reference time point (time of array, response, or reward)
%   RT_S - Time of second saccade
% 

RT_S = RT_S - tRef;
nTrial = length(tRef);

%plot spike times relative to time of primary saccade
for jj = 1:nTrial; spikes{jj} = spikes{jj} - tRef(jj); end

%sort by time of second saccade
[RT_S, idx_RTS] = sort(RT_S);
spikes = spikes(idx_RTS);

%organize spikes as 1-D array for plotting
tSpike = cell2mat(spikes');
trialSpike = NaN(1,length(tSpike));

%get trial numbers corresponding to each spike
idx = 1;
for jj = 1:nTrial
  trialSpike(idx:idx+length(spikes{jj})-1) = jj;
  idx = idx + length(spikes{jj});
end%for:trials(jj)

%remove spikes outside of time window of interest
idx_time = ((tSpike >= tLim(1)) & (tSpike <= tLim(2)));
tSpike = tSpike(idx_time);
trialSpike = trialSpike(idx_time);

end % util : collectSpikeTimes()
