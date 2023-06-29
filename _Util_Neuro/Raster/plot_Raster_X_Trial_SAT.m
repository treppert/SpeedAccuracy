%plot_Raster_X_Trial_SAT.m

idx_Sess = ismember(unitData.SessionID, 43:49);
idx_Area = ismember(unitData.Area, {'FEF'});

unitTest = unitData( idx_Sess , : );
nUnit = size(unitTest,1);

tPlot = (-600 : 1200); %time from stimulus (ms)

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
  trialNeut = find(behavData.Condition{kk} == 2);
  
  %sort spikes by task condition
  idxAcc = ismember(jjSpike, trialAcc);
  idxFast = ismember(jjSpike, trialFast);
  idxNeut = ismember(jjSpike, trialNeut);
  jjSpikeAcc = jjSpike(idxAcc);     tSpikeMatAcc = spikesMat(idxAcc);
  jjSpikeFast = jjSpike(idxFast);   tSpikeMatFast = spikesMat(idxFast);
  jjSpikeNeut = jjSpike(idxNeut);   tSpikeMatNeut = spikesMat(idxNeut);
  
  %% Plotting
  FACEALPHA = 0.3;
  PRINTDIR = 'C:\Users\thoma\Dropbox\SAT-Local\Figs - Raster-X-Trial - SAT\FEF\';
  figure('visible','off'); hold on

  scatter(tSpikeMatNeut, jjSpikeNeut, 4, 'k', 'filled', 'MarkerFaceAlpha',FACEALPHA)
  scatter(tSpikeMatAcc,  jjSpikeAcc,  4, 'r', 'filled', 'MarkerFaceAlpha',FACEALPHA)
  scatter(tSpikeMatFast, jjSpikeFast, 4, [0 .7 0], 'filled', 'MarkerFaceAlpha',FACEALPHA)
  plot([0 0], [0 nTrial], 'k-', 'LineWidth',1.1)
  
  ylim([0 nTrial+1])
  ylabel('Trial')
  xlabel('Time from array (ms)')
  xlim([tPlot(1) tPlot(end)])
  title(unitTest.ID{uu})
  ppretty([10,12]); drawnow

  print(PRINTDIR + unitTest.ID(uu) + ".tif", '-dtiff'); close()

end % for : unit (uu)

clearvars -except behavData* unitData pairData ROOTDIR*
