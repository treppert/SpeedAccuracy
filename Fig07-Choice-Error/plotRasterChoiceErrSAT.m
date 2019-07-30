function [  ] = plotRasterChoiceErrSAT( binfo , moves , movesPP , ninfo , spikes )
%plotRasterChoiceErrSAT Summary of this function goes here
%   Detailed explanation goes here

ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\SAT\Figs-ChcErr-SEF\Raster\';

idxSEF = ismember({ninfo.area}, {'SEF'});
idxMonkey = ismember({ninfo.monkey}, {'D','E'});

idxErr = (([ninfo.errGrade]) >= 2);
idxEff = ismember([ninfo.taskType], [1,2]);

idxKeep = (idxSEF & idxMonkey & idxErr & idxEff);

NUM_CELLS = 1;%sum(idxKeep);
ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

T_PLOT  = 3500 + (-200 : 450);

for cc = 1:NUM_CELLS
  fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  RTPkk = double(moves(kk).resptime); %RT of primary saccade
  RTPkk(RTPkk > 900) = NaN; %hard limit on primary RT
  RTSkk = double(movesPP(kk).resptime) - RTPkk; %RT of secondary saccade
  RTSkk(RTSkk < 0) = NaN; %trials with no secondary saccade
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials, 'task','SAT');
  %index by condition
  idxAcc = ((binfo(kk).condition == 1) & ~idxIso);
  idxFast = ((binfo(kk).condition == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold | binfo(kk).err_nosacc);
  idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  %perform RT matching and group trials by condition and outcome
  trials = groupTrialsRTmatched(RTPkk, idxAcc, idxFast, idxCorr, idxErr);
  
  nAcc = length(trials.AccCorr);
  nFast = length(trials.FastCorr);
  
  spTimesAC = spikes(cc).SAT(trials.AccCorr);   spTimesAE = spikes(cc).SAT(trials.AccErr);
  spTimesFC = spikes(cc).SAT(trials.FastCorr);  spTimesFE = spikes(cc).SAT(trials.FastErr);
  
  RT_AC = RTPkk(trials.AccCorr);   RT_AE = RTPkk(trials.AccErr);    ISI_AE = RTSkk(trials.AccErr);
  RT_FC = RTPkk(trials.FastCorr);  RT_FE = RTPkk(trials.FastErr);   ISI_FE = RTSkk(trials.FastErr);
  
  %plot spike times relative to time of primary saccade
  for jj = 1:nAcc %Accurate condition
    spTimesAC{jj} = spTimesAC{jj} - RT_AC(jj);
    spTimesAE{jj} = spTimesAE{jj} - RT_AE(jj);
  end
  for jj = 1:nFast %Fast condition
    spTimesFC{jj} = spTimesFC{jj} - RT_FC(jj);
    spTimesFE{jj} = spTimesFE{jj} - RT_FE(jj);
  end
  
  %sort error trials by time of secondary saccade
  [ISI_AE,idxISI_AE] = sort(ISI_AE);    [ISI_FE,idxISI_FE] = sort(ISI_FE);
  spTimesAE = spTimesAE(idxISI_AE);     spTimesFE = spTimesFE(idxISI_FE);
  RT_AE = RT_AE(idxISI_AE);             RT_FE = RT_FE(idxISI_FE);
  
  %collect spikes and corresponding trials
  [spTimesAE,trialAE] = collectSpikeTimes(spTimesAE, T_PLOT);
  [spTimesAC,trialAC] = collectSpikeTimes(spTimesAC, T_PLOT);
  [spTimesFE,trialFE] = collectSpikeTimes(spTimesFE, T_PLOT);
  [spTimesFC,trialFC] = collectSpikeTimes(spTimesFC, T_PLOT);
  
  %shift error trials up on the plot
  trialAE = trialAE + nAcc;
  trialFE = trialFE + nFast;
  
  %% Plotting
  figure()
  
  subplot(2,1,1); hold on %Fast condition
  
  plot(spTimesFC-3500, trialFC, '.', 'Color',[.3 .3 .3], 'MarkerSize',7)
  plot(spTimesFE-3500, trialFE, '.', 'Color',[0 .7 0], 'MarkerSize',7)

  plot([0 0], [0 2*nFast], 'k-', 'LineWidth',1.0) %time zero (time of response)
  plot(-RT_FC, (1:nFast), 'o', 'Color','k', 'MarkerSize',3) %stimulus ON (correct)
  plot(-RT_FE, nFast+(1:nFast), 'o', 'Color','k', 'MarkerSize',3) %stimulus ON (error)
  plot(ISI_FE, nFast+(1:nFast), 'o', 'Color','k', 'MarkerSize',3) %time of secondary saccade

  xlim([T_PLOT(1) T_PLOT(end)]-3500)
%   xticks((T_PLOT(1) : 200 : T_PLOT(end)) - 3500)
  yLimFast = get(gca, 'ylim');
  print_session_unit(gca, ninfo(cc), binfo(kk), 'horizontal')
  
  subplot(2,1,2); hold on %Accurate condition

  plot(spTimesAC-3500, trialAC, '.', 'Color',[.3 .3 .3], 'MarkerSize',7)
  plot(spTimesAE-3500, trialAE, '.', 'Color',[1 0 0], 'MarkerSize',7)

  plot([0 0], [0 2*nAcc], 'k-', 'LineWidth',1.0) %time zero (time of response)
  plot(-RT_AC, (1:nAcc), 'o', 'Color','k', 'MarkerSize',3) %stimulus ON (correct)
  plot(-RT_AE, nAcc+(1:nAcc), 'o', 'Color','k', 'MarkerSize',3) %stimulus ON (error)
  plot(ISI_AE, nAcc+(1:nAcc), 'o', 'Color','k', 'MarkerSize',3) %time of secondary saccade

  xlim([T_PLOT(1) T_PLOT(end)]-3500)
%   xticks((T_PLOT(1) : 200 : T_PLOT(end)) - 3500)
  set(gca, 'ylim', yLimFast)
  
  ppretty([5,4])
  
%   print([ROOTDIR, ninfo(cc).sess,'-',ninfo(cc).unit,'.tif'], '-dtiff'); pause(0.1); close()
  
end%for:cells(cc)

end%util:plotRasterChoiceErrSAT()

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


function [ trialsGrouped ] = groupTrialsRTmatched(RT, idxAcc, idxFast, idxCorr, idxErr)

%Fast condition
trial_FC = find(idxFast & idxCorr);    RT_FC = RT(idxFast & idxCorr);
trial_FE = find(idxFast & idxErr);     RT_FE = RT(idxFast & idxErr);
[OLdist1, OLdist2, ~,~] = DistOverlap_Amir([trial_FC;RT_FC]', [trial_FE;RT_FE]');
trial_FC = OLdist1(:,1);
trial_FE = OLdist2(:,1);

%Accurate condition
trial_AC = find(idxAcc & idxCorr);    RT_AC = RT(idxAcc & idxCorr);
trial_AE = find(idxAcc & idxErr);     RT_AE = RT(idxAcc & idxErr);
[OLdist1, OLdist2, ~,~] = DistOverlap_Amir([trial_AC;RT_AC]', [trial_AE;RT_AE]');
trial_AC = OLdist1(:,1);
trial_AE = OLdist2(:,1);

%output
trialsGrouped = struct('AccCorr',trial_AC, 'AccErr',trial_AE, 'FastCorr',trial_FC, 'FastErr',trial_FE);

end%util:groupTrialsRTmatched()
