function [  ] = plotRasterChoiceErrXdirSAT( binfo , moves , movesPP , ninfo , spikes , varargin )
%plotRasterChoiceErrXdirSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SC'}, {'monkey=','D'}});

idx_area = ismember({ninfo.area}, args.area);
idx_monkey = ismember({ninfo.monkey}, args.monkey);

ninfo = ninfo(idx_area & idx_monkey);
spikes = spikes(idx_area & idx_monkey);

NUM_CELLS = length(spikes);
T_PLOT  = 3500 + (-400 : 800);

IDX_DD_PLOT = [6, 3, 2, 1, 4, 7, 8, 9];

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  figure(); ppretty('image_size',[12,8])
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxCond = ((binfo(kk).condition == 3) & ~idxIso);
  %index by trial outcome
  idxErr = (binfo(kk).err_dir);
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_hold);
  
  yMax = 0;
  for dd = 1:8 %loop over directions and plot
    idxDir = (moves(kk).octant == dd);
    
    spikesErr = spikes(cc).SAT(idxCond & idxErr & idxDir);
    nTrialErr = sum(idxCond & idxErr & idxDir);
    spikesCorr = spikes(cc).SAT(idxCond & idxCorr & idxDir);
    nTrialCorr = sum(idxCond & idxCorr & idxDir);
    
    %plot spike times relative to time of primary saccade
    RTerr = double(moves(kk).resptime(idxCond & idxErr & idxDir));
    for jj = 1:nTrialErr
      spikesErr{jj} = spikesErr{jj} - RTerr(jj);
    end
    RTcorr = double(moves(kk).resptime(idxCond & idxCorr & idxDir));
    for jj = 1:nTrialCorr
      spikesCorr{jj} = spikesCorr{jj} - RTcorr(jj);
    end
    
    %sort error trials by ISI between primary response and PP saccade
    ISIerr = double(movesPP(kk).resptime(idxCond & idxErr & idxDir)) - RTerr;
    ISIerr(ISIerr < 0) = 9999; %movesPP.RT==0 -> No post-primary saccade
    [ISIerr,idxISIerr] = sort(ISIerr);
    
    %sort correct trials by RT
    [RTcorr,idxRTcorr] = sort(RTcorr);
    
    %collect spikes and corresponding trials
    [tSpikeErr,trialSpikeErr] = collectSpikeTimes(spikesErr(idxISIerr), T_PLOT);
    [tSpikeCorr,trialSpikeCorr] = collectSpikeTimes(spikesCorr(idxRTcorr), T_PLOT);
    
    %shift error trials up on the plot
    trialSpikeErr = trialSpikeErr + nTrialCorr;
    
    %% Plotting
    subplot(3,3,IDX_DD_PLOT(dd)); hold on
    
    plot(tSpikeCorr-3500, trialSpikeCorr, '.', 'Color',[.3 .3 .3], 'MarkerSize',4)
%     plot(tSpikeErr-3500, trialSpikeErr, '.', 'Color',[.3 .7 .4], 'MarkerSize',4)
    plot(tSpikeErr-3500, trialSpikeErr, '.', 'Color',[1 .5 .5], 'MarkerSize',4)
    
    plot([0 0], [0 nTrialCorr+nTrialErr], 'k-', 'LineWidth',1.0) %time zero (time of response)
    plot(-RTcorr, (1:nTrialCorr), 'o', 'Color','k', 'MarkerSize',3) %stimulus ON (correct)
    plot(ISIerr, nTrialCorr+(1:nTrialErr), 'o', 'Color','k', 'MarkerSize',3) %time of post-primary (error)
    plot(-RTerr, nTrialCorr+(1:nTrialErr), 'o', 'Color','k', 'MarkerSize',3) %stimulus ON (error)
    
    if (IDX_DD_PLOT(dd) == 4)
      ylabel('Trial')
      xticklabels([])
    elseif (IDX_DD_PLOT(dd) == 8)
      xlabel('Time from response (ms)')
      yticklabels([])
    else
      xticklabels([])
      yticklabels([])
    end
    
    xlim([T_PLOT(1) T_PLOT(end)]-3500)
    xticks((T_PLOT(1) : 200 : T_PLOT(end)) - 3500)
    yLim = get(gca, 'ylim');
    if (yLim(2) > yMax)
      yMax = yLim(2);
      yTicks = get(gca, 'ytick');
    end
    
    pause(0.05)
  end%for:direction(dd)
  
  %make axis ticks and limits consistent across plots
  for dd = 1:8
    subplot(3,3,IDX_DD_PLOT(dd))
    yticks(yTicks); ylim([0 yMax])
  end
  
  subplot(3,3,5); xticks([]); yticks([]); print_session_unit(gca , ninfo(cc), binfo(kk), 'horizontal')
  ppretty('image_size',[12,8])
  pause(0.1); print(['~/Dropbox/Speed Accuracy/SEF_SAT/Figs/0-Raster/Raster-PostChoiceError-ACC/', ...
    ninfo(cc).area,'-',ninfo(cc).sess,'-',ninfo(cc).unit,'.tif'], '-dtiff')
  pause(0.1); close()
%   pause()
  
end%for:cells(cc)

end%util:plotRasterChoiceErrXdirSAT()

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
