%plot_RasterXTrial_MG.m

idx_Sess = ismember(unitData.SessionID, 34:49);
idx_Area = ismember(unitData.Area, {'FEF'});

unitTest = unitData( idx_Sess & idx_Area , : );
nUnit = size(unitTest,1);

tPlot = (-600 : 1200); %time from stimulus (ms)

for uu = 1:nUnit
  fprintf('%s \n', unitTest.ID{uu})
  kk = unitTest.SessionID(uu); %get session number
  nTrial = behavDataMG.NumTrials(kk);

  %% Load spike times
  spikes = load_spikes_SAT(unitTest.Index(uu), 'task','MG');

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
  
  %% Plotting
  PRINTDIR = 'C:\Users\thoma\Dropbox\SAT-Local\Figs - Raster-X-Trial - MG\FEF\';
  figure('visible','off'); hold on

  scatter(spikesMat, jjSpike, 4, 'k', 'filled', 'MarkerFaceAlpha',0.3)
  plot([0 0], [0 nTrial], 'k-', 'LineWidth',1.1)
  
  ylim([0 nTrial+1])
  ylabel('Trial')
  xlabel('Time from array (ms)')
  xlim([tPlot(1) tPlot(end)])
  title(unitTest.ID{uu})
  ppretty([10,12]); drawnow

  print(PRINTDIR + unitTest.ID(uu) + ".tif", '-dtiff'); close()

end%for:units(u)
