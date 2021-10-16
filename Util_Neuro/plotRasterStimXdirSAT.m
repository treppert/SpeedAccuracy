function [  ] = plotRasterStimXdirSAT( behavData , moves , unitData , spikes , varargin )
%plotRasterStimXdirSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SC'}, {'monkey=','D'}});

idx_area = ismember(unitData.aArea, args.area);
idx_monkey = ismember(unitData.aMonkey, args.monkey);

unitData = unitData(idx_area & idx_monkey);
spikes = spikes(idx_area & idx_monkey);

NUM_CELLS = length(spikes);
SORT_X_RT = true;

T_PLOT  = 3500 + (-200 : 800);
IDX_DD_PLOT = [6, 3, 2, 1, 4, 7, 8, 9];

for uu = 1:NUM_CELLS
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  
  figure(); ppretty([12,8])
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData(uu,:), behavData.Task_NumTrials{kk});
  %index by condition
  idxCond = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  %index by trial outcome
  idxOutcome = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrHold{kk});
  
  yMax = 0;
  for dd = 1:8 %loop over directions and plot
    
    %index by direction
    idxDD = (moves(kk).octant == dd);
    
    spikesDD = spikes(uu).SAT(idxCond & idxOutcome & idxDD);
    nTrialDD = sum(idxCond & idxOutcome & idxDD);
    
    RT = moves(kk).resptime(idxCond & idxOutcome & idxDD);
    if (SORT_X_RT)
      [RT,idxRT] = sort(RT);
    else
      idxRT = (1:nTrialDD);
    end
    
    %collect spikes and corresponding trials
    [tSpike,trialSpike] = collectSpikeTimes(spikesDD(idxRT), T_PLOT);
    
    %% Plotting
    subplot(3,3,IDX_DD_PLOT(dd)); hold on
    
    plot(tSpike-3500, trialSpike, '.', 'Color',[1 .5 .5], 'MarkerSize',4)
    plot([0 0], [0 nTrialDD], 'k--', 'LineWidth',1.5)
    if (SORT_X_RT)
      plot(RT, (1:nTrialDD), 'o', 'Color',[.4 .4 .4], 'MarkerSize',3)
    end
    
    if (IDX_DD_PLOT(dd) == 4)
      ylabel('Trial')
      yTicks = get(gca, 'ytick');
      xticklabels([])
    elseif (IDX_DD_PLOT(dd) == 8)
      xlabel('Time from stimulus (ms)')
      xTicks = get(gca, 'xtick');
      yticklabels([])
    else
      xticklabels([])
      yticklabels([])
    end
    
    xlim([-200 800])
    yLim = get(gca, 'ylim');
    if (yLim(2) > yMax); yMax = yLim(2); end
    
    pause(0.1)
  end%for:direction(dd)
  
  %make axis ticks and limits consistent across plots
  for dd = 1:8
    subplot(3,3,IDX_DD_PLOT(dd))
    yticks(yTicks); xticks(xTicks); ylim([0 yMax])
  end
  
  subplot(3,3,5); xticks([]); yticks([]); print_session_unit(gca , unitData(uu,:), behavData(kk,:), 'horizontal')
  ppretty([12,8])
%   pause(0.1); print(['~/Dropbox/Speed Accuracy/SEF_SAT/Figs/0-Raster/',unitData.aArea{uu},'-',unitData.Task_Session(uu),'-',unitData.aID{uu},'-ACC.tif'], '-dtiff')
%   pause(0.1); close()
  pause()
  
end%for:cells(uu)

end%util:plotRasterStimSAT()

function [ tSpike , trialSpike ] = collectSpikeTimes( spikes , tPlot )

nTrial = length(spikes);

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
idx_time = ((tSpike >= tPlot(1)) & (tSpike <= tPlot(end)));
tSpike = tSpike(idx_time);
trialSpike = trialSpike(idx_time);

end%util:collectSpikeTimes()
