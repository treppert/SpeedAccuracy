%plot_Raster_X_Trial_SAT.m

idx_Sess = ismember(unitData.SessionID, 1:16);
idx_Area = ismember(unitData.Area, {'SEF'});

unitTest = unitData( idx_Sess & idx_Area , : );
nUnit = size(unitTest,1);

tPlot = (-650 : 1050); %time from stimulus (ms)

for uu = 1:nUnit
  fprintf('%s \n', unitTest.ID{uu})
  kk = unitTest.SessionID(uu); %get session number
  nTrial = behavData.NumTrials(kk);

  %% Load spike times
  spikes = load_spikes_SAT(unitTest.Index(uu), 'task','SAT');

  %% Organization of spike times by trial
  %organize spikes as 1-D array for plotting
  spikesMat = cell2mat(transpose(spikes)) - 3500;
  jjSpike = NaN(1,length(spikesMat)); %corresponding trial numbers
  
  %get trial numbers corresponding to each spike
  iMat = 1; %index used to count through spikes_u_mat
  for jj = 1:nTrial
    idxStart_jj = iMat;
    idxEnd_jj = iMat + length(spikes{jj}) - 1;
    jjSpike(idxStart_jj : idxEnd_jj) = jj;
    iMat = iMat + length(spikes{jj});
  end % for : trials(jj)
  
  %remove spikes outside of time window of interest
  idxPlot = ((spikesMat >= tPlot(1)) & (spikesMat <= tPlot(end)));
  spikesMat = spikesMat(idxPlot);
  jjSpike = jjSpike(idxPlot);
  
  %parse trials by task condition
  trialAcc = find(behavData.Condition{kk} == 1);
  trialFast = find(behavData.Condition{kk} == 3);
  trialNeut = find(behavData.Condition{kk} == 4);
  
  %sort spikes by task condition
  idxAcc = ismember(jjSpike, trialAcc);
  idxFast = ismember(jjSpike, trialFast);
  idxNeut = ismember(jjSpike, trialNeut);
  jjSpikeAcc = jjSpike(idxAcc);     tSpikeMatAcc = spikesMat(idxAcc);
  jjSpikeFast = jjSpike(idxFast);   tSpikeMatFast = spikesMat(idxFast);
  jjSpikeNeut = jjSpike(idxNeut);   tSpikeMatNeut = spikesMat(idxNeut);
  
  %% Plotting
  PRINTDIR = 'C:\Users\Thomas Reppert\Dropbox\SAT-Local\Figs - Raster-X-Trial - SAT\SEF\';
  figure('visible','off'); hold on

  scatter(tSpikeMatNeut, jjSpikeNeut, 4, 'k', 'filled', 'MarkerFaceAlpha',0.4)
  scatter(tSpikeMatAcc,  jjSpikeAcc,  4, 'r', 'filled', 'MarkerFaceAlpha',0.5)
  scatter(tSpikeMatFast, jjSpikeFast, 4, [0 .7 0], 'filled', 'MarkerFaceAlpha',0.5)
  plot([0 0], [0 nTrial], 'k-', 'LineWidth',1.1)
  
  ylim([0 nTrial+1])
  ylabel('Trial')
  xlabel('Time from array (ms)')
  xlim([tPlot(1) tPlot(end)])
  title(unitTest.ID{uu})
  ppretty([8.5,12]); drawnow

  print(PRINTDIR + unitTest.ID(uu) + ".tif", '-dtiff'); close()

end % for : unit (uu)
