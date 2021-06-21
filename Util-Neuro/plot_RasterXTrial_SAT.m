function [  ] = plot_RasterXTrial_SAT( uInfo , spikes , bInfo )
%plot_RasterXTrial_SAT() Summary of this function goes here
%   Detailed explanation goes here

AREA = {'FEF'};
MONKEY = {'Q'};

idxArea = ismember(uInfo.area, AREA);
idxMonkey = ismember(uInfo.monkey, MONKEY);
idxKeep = [157,252]; %idxArea & idxMonkey;

uInfo = uInfo(idxKeep, :);
spikes = spikes(idxKeep);

NUM_UNITS = size(uInfo, 1);
TIME_PLOT = (-1000 : 2000); %time from stimulus

%% Spike rasters

for uu = 1:NUM_UNITS
  %unit-specific initialization
  unitID = [uInfo.Properties.RowNames{uu}, '-', uInfo.area{uu}];
  numTrials = length(spikes{uu});
  
  %% Organization of spike times by trial
  %organize spikes as 1-D array for plotting
  tSpikeCell = spikes{uu};
  tSpikeMat = cell2mat(tSpikeCell) - 3500;
  jjSpike = NaN(1,length(tSpikeMat));
  
  %get trial numbers corresponding to each spike
  idxMat = 1; %index used to count through tSpikeMat
  for jj = 1:numTrials
    idxStart_jj = idxMat;
    idxEnd_jj = idxMat + length(tSpikeCell{jj}) - 1;
    jjSpike(idxStart_jj : idxEnd_jj) = jj;
    idxMat = idxMat + length(tSpikeCell{jj});
  end % for : trials(jj)
  
  %remove spikes outside of time window of interest
  idxPlot = ((tSpikeMat >= TIME_PLOT(1)) & (tSpikeMat <= TIME_PLOT(end)));
  tSpikeMat = tSpikeMat(idxPlot);
  jjSpike = jjSpike(idxPlot);
  
  %parse trials by task condition
  kk = ismember(bInfo.session, uInfo.sess{uu});
  trialAcc = find(bInfo.condition{kk} == 1);
  trialFast = find(bInfo.condition{kk} == 3);
  
  %sort spikes by task condition
  idxAcc = ismember(jjSpike, trialAcc);
  idxFast = ismember(jjSpike, trialFast);
  jjSpikeAcc = jjSpike(idxAcc);     tSpikeMatAcc = tSpikeMat(idxAcc);
  jjSpikeFast = jjSpike(idxFast);   tSpikeMatFast = tSpikeMat(idxFast);
  
  %% Plotting
  figure(); hold on
%   plot(tSpikeMat, jjSpike, 'k.', 'MarkerSize',4)
  plot(tSpikeMatAcc, jjSpikeAcc, 'r.', 'MarkerSize',4)
  plot(tSpikeMatFast, jjSpikeFast, '.', 'Color',[0 .7 0], 'MarkerSize',4)
  plot([0 0], [0 numTrials], 'k-', 'LineWidth',2.0)
  
  ylim([0 numTrials+1])
%   ylabel('Trial number')
%   xlabel('Time from array (ms)')
  xlim([-600 1000])
  title(unitID)
  ppretty([7,6]); pause(0.5)
  
end%for:units(uu)

end % util :: plot_RasterXTrial_SAT()

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
  
