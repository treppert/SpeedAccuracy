function [  ] = plot_Raster_X_Trial( unitData , behavData )
%plot_RasterXTrial_SAT() Summary of this function goes here
%   Detailed explanation goes here

DIRPRINT = 'C:\Users\thoma\Dropbox\SAT_Figs\Raster_X_Trial\';
NUM_UNITS = size(unitData, 1);
TIME_PLOT = (-1000 : 2000); %time from stimulus (ms)

%% Spike rasters

for u = 2:NUM_UNITS
  k = unitData.SessionIndex(u);
  nTrial = behavData.Task_NumTrials(k);
  spikes_u = load_spikes_SAT(unitData.Index(u));

  %% Organization of spike times by trial
  %organize spikes as 1-D array for plotting
  spikes_u_mat = cell2mat(transpose(spikes_u)) - 3500;
  jjSpike = NaN(1,length(spikes_u_mat)); %corresponding trial numbers
  
  %get trial numbers corresponding to each spike
  i_mat = 1; %index used to count through spikes_u_mat
  for jj = 1:nTrial
    idxStart_jj = i_mat;
    idxEnd_jj = i_mat + length(spikes_u{jj}) - 1;
    jjSpike(idxStart_jj : idxEnd_jj) = jj;
    i_mat = i_mat + length(spikes_u{jj});
  end % for : trials(jj)
  
  %remove spikes outside of time window of interest
  idxPlot = ((spikes_u_mat >= TIME_PLOT(1)) & (spikes_u_mat <= TIME_PLOT(end)));
  spikes_u_mat = spikes_u_mat(idxPlot);
  jjSpike = jjSpike(idxPlot);
  
  %parse trials by task condition
  trialAcc = find(behavData.Task_SATCondition{k} == 1);
  trialFast = find(behavData.Task_SATCondition{k} == 3);
  trialNeut = find(behavData.Task_SATCondition{k} == 4);
  
  %sort spikes by task condition
  idxAcc = ismember(jjSpike, trialAcc);
  idxFast = ismember(jjSpike, trialFast);
  idxNeut = ismember(jjSpike, trialNeut);
  jjSpikeAcc = jjSpike(idxAcc);     tSpikeMatAcc = spikes_u_mat(idxAcc);
  jjSpikeFast = jjSpike(idxFast);   tSpikeMatFast = spikes_u_mat(idxFast);
  jjSpikeNeut = jjSpike(idxNeut);   tSpikeMatNeut = spikes_u_mat(idxNeut);
  
  %% Plotting
  figure(); hold on
%   plot(tSpikeMat, jjSpike, 'k.', 'MarkerSize',4)
  plot(tSpikeMatNeut, jjSpikeNeut, '.', 'Color','k', 'MarkerSize',4)
  plot(tSpikeMatAcc, jjSpikeAcc, '.', 'Color',[.6 0 0], 'MarkerSize',4)
  plot(tSpikeMatFast, jjSpikeFast, '.', 'Color',[0 .6 0], 'MarkerSize',4)
  plot([0 0], [0 nTrial], 'k-', 'LineWidth',2.0)
  
  ylim([0 nTrial+1])
  ylabel('Trial')
  xlabel('Time from array (ms)')
  xlim([-600 1000])
  title(unitData.ID{u})
  ppretty([8.5,12])
  
  drawnow
  print([DIRPRINT, unitData.ID{u}, '-', unitData.Area{u}, '.tif'], '-dtiff')
  close()

end%for:units(u)

end % util :: plot_Raster_X_Trial()
