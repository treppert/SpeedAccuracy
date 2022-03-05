% function [  ] = plot_Raster_X_Dir_RF_ErrChoice( behavData , unitData , spikesSAT )
%plot_Raster_X_Dir_RF_ErrChoice Summary of this function goes here
%   Detailed explanation goes here

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'E'});
idxFunction = (unitData.Grade_Err == +1);
idxKeep = (idxArea & idxMonkey & idxFunction);

NUM_UNIT = sum(idxKeep);
unitDataTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

tPlot  = 3500 + (-350 : 500);
xLimPlot = [-350 , 500];

for uu = NUM_UNIT:NUM_UNIT
  fprintf('%s \n', unitDataTest.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitDataTest.Task_Session(uu));
  RTP_kk = behavData.Sacc_RT{kk}; %primary saccade RT
  RTS_kk = behavData.Sacc2_RT{kk}; %second saccade RT
  RTS_kk(RTS_kk == 0) = NaN;
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitDataTest.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  idxErr = (behavData.Task_ErrChoice{kk} & ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  
  %index by saccade octant re. response field (RF)
  Octant_Sacc1 = behavData.Sacc_Octant{kk};
  RF = unitDataTest.RF{uu};
  
  if ismember(9,RF) %average over all possible directions
    idxRF = true(behavData.Task_NumTrials(kk),1);
  else %average only trials with saccade into RF
    idxRF = ismember(Octant_Sacc1, RF);
  end
  
  %index by condition and trial outcome
  idxAE = ((behavData.Task_SATCondition{kk} == 1) & idxErr & idxRF & ~idxIso);
  trialAC = find((behavData.Task_SATCondition{kk} == 1) & idxCorr & idxRF & ~idxIso);
  trialFE = find((behavData.Task_SATCondition{kk} == 3) & idxErr & idxRF & ~idxIso);
  trialFC = find((behavData.Task_SATCondition{kk} == 3) & idxCorr & idxRF & ~idxIso);
  
  [tSpike_AE, trial_AE, RTS_AE] = collect_SpikeTimes(spikesTest{uu}(idxAE), tPlot([1,end]), ...
    RTP_kk(idxAE), RTS_kk(idxAE));
  
  %limit trial counts by number of Accurate choice errors
  nTrial = length(RTS_AE);
  trialAC = datasample(trialAC, nTrial, 'Replace',false);
  trialFE = datasample(trialFE, nTrial, 'Replace',false);
  trialFC = datasample(trialFC, nTrial, 'Replace',false);
  
  [tSpike_AC, trial_AC, RTS_AC] = collect_SpikeTimes(spikesTest{uu}(trialAC), tPlot([1,end]), ...
    RTP_kk(trialAC), RTS_kk(trialAC));
  
  [tSpike_FE, trial_FE, RTS_FE] = collect_SpikeTimes(spikesTest{uu}(trialFE), tPlot([1,end]), ...
    RTP_kk(trialFE), RTS_kk(trialFE));
  
  [tSpike_FC, trial_FC, RTS_FC] = collect_SpikeTimes(spikesTest{uu}(trialFC), tPlot([1,end]), ...
    RTP_kk(trialFC), RTS_kk(trialFC));
  
  %% Plotting
  figure()
  
  subplot(2,2,1); hold on %Fast error
  scatter(tSpike_FE-3500, trial_FE, 3, [.4 .8 .6], 'filled')
  plot([0 0], [0 nTrial], 'k:', 'LineWidth',1.2)
  scatter(RTS_FE, (1:nTrial), 20, [.4 .4 .4])
  xlim(xLimPlot); xticks([])
  ylabel('Trial')
  
  subplot(2,2,2); hold on %Accurate error
  scatter(tSpike_AE-3500, trial_AE, 3, [1 .6 .6], 'filled')
  plot([0 0], [0 nTrial], 'k:', 'LineWidth',1.2)
  scatter(RTS_AE, (1:nTrial), 20, [.4 .4 .4])
  xlim(xLimPlot); xticks([]); yticks([])
  
  subplot(2,2,3); hold on %Fast correct
  scatter(tSpike_FC-3500, trial_FC, 3, [.4 .4 .4], 'filled')
  plot([0 0], [0 nTrial], 'k:', 'LineWidth',1.2)
  xlim(xLimPlot)
  xlabel('Time from primary saccade (ms)')
  ylabel('Trial')
  
  subplot(2,2,4); hold on %Accurate correct
  scatter(tSpike_AC-3500, trial_AC, 3, [.4 .4 .4], 'filled')
  plot([0 0], [0 nTrial], 'k:', 'LineWidth',1.2)
  xlim(xLimPlot); yticks([])
  xlabel('Time from primary saccade (ms)')
  
  ppretty([6,3])
  
end % for : unit(uu)

clearvars -except behavData unitData spikesSAT
% end % fxn : plot_Raster_X_Dir_RF_ErrChoice()

function [ tSpike , trialSpike , RT_S ] = collect_SpikeTimes( spikes , tLim , RT_P , RT_S )

RT_S = RT_S - RT_P;
nTrial = length(RT_P);

%plot spike times relative to time of primary saccade
for jj = 1:nTrial; spikes{jj} = spikes{jj} - RT_P(jj); end

%sort by time of second saccade
[RT_S, idx_RTS] = sort(RT_S);
spikes = spikes(idx_RTS);

%organize spikes as 1-D array for plotting
tSpike = cell2mat(spikes);
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

end%util:collectSpikeTimes()
