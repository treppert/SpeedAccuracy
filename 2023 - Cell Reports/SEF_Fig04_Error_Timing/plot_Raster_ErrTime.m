function [  ] = plot_Raster_ErrTime( unitData , behavData , varargin )
%plot_Raster_ErrTime Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'minISI=',1000}});

NUM_UNIT = size(unitData,1);
IDX_TEST = [-500 1200] + 3500;
TLIM_REW = [-400, 1000];

for uu = 1:NUM_UNIT
  fprintf('%s \n', unitData.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitData.Session(uu));
  
  RTerr = behavData.Sacc_RTerr{kk}; %RT relative to deadline
  RT_P = behavData.Sacc_RT{kk}; %RT of primary saccade
  RT_S = behavData.Sacc2_RT{kk}; %RT of second saccade
  ISI = RT_S - RT_P; %inter-saccade interval

  tRew = behavData.Task_TimeReward(kk); %time of reward (fixed)
  tRew = RT_P + tRew; %re. array
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitData.TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  idxErr = behavData.Task_ErrTimeOnly{kk};
  
  %combine indexing
  idxAC = (idxAcc & idxCorr);    idxAE = (idxAcc & idxErr & (ISI >= args.minISI) & (RTerr < 0));
  idxFC = (idxFast & idxCorr);   idxFE = (idxFast & idxErr & (ISI >= args.minISI) & (RTerr > 0));
  trialAC = find(idxAC);  trialAE = find(idxAE);  %trialAE = datasample(trialAE, 40, 'Replace',false);
  trialFC = find(idxFC);  trialFE = find(idxFE);
  nTrialAC = sum(idxAC);  nTrialAE = sum(idxAE);  %nTrialAE = length(trialAE);
  nTrialFC = sum(idxAC);  nTrialFE = sum(idxFE);
  
  %collect spike times for this unit
  spikes = load_spikes_SAT(unitData.Index(uu));
  [tSpike_AE, trial_AE, RTS_AE] = collect_SpikeTimes(spikes(trialAE), IDX_TEST, ...
    tRew(trialAE), RT_S(trialAE));
  
  %limit correct trial counts by number of Accurate errors
  trialAC = datasample(trialAC, nTrialAE, 'Replace',false);
  trialFC = datasample(trialFC, nTrialAE, 'Replace',false);
  
  [tSpike_AC, trial_AC, ~] = collect_SpikeTimes(spikes(trialAC), IDX_TEST, ...
    tRew(trialAC), RT_S(trialAC));
  [tSpike_FE, trial_FE, RTS_FE] = collect_SpikeTimes(spikes(trialFE), IDX_TEST, ...
    tRew(trialFE), RT_S(trialFE));
  [tSpike_FC, trial_FC, ~] = collect_SpikeTimes(spikes(trialFC), IDX_TEST, ...
    tRew(trialFC), RT_S(trialFC));
  
  %% Plotting
  MARKERSIZE = 3;

  figure()
  
  subplot(2,2,1); hold on %Accurate error
  scatter(tSpike_AE-3500, trial_AE, MARKERSIZE, 'r', 'filled')
  plot([0 0], [0 nTrialAE], 'k:', 'LineWidth',1.2)
  scatter(RTS_AE, (1:nTrialAE), 20, 'k')
  xlim(TLIM_REW); xticks([])
  ylabel('Trial')
  
  subplot(2,2,2); hold on %Fast error
  scatter(tSpike_FE-3500, trial_FE, MARKERSIZE, [0 .7 0], 'filled')
  plot([0 0], [0 nTrialAE], 'k:', 'LineWidth',1.2)
  scatter(RTS_FE, (1:nTrialFE), 20, 'k')
  xlim(TLIM_REW); xticks([]); yticks([])
  
  subplot(2,2,3); hold on %Accurate correct
  scatter(tSpike_AC-3500, trial_AC, MARKERSIZE, [.4 .4 .4], 'filled')
  plot([0 0], [0 nTrialAE], 'k:', 'LineWidth',1.2)
  xlim(TLIM_REW); xlabel('Time from reward (ms)')
  ylabel('Trial')
  
  subplot(2,2,4); hold on %Fast correct
  scatter(tSpike_FC-3500, trial_FC, MARKERSIZE, [.4 .4 .4], 'filled')
  plot([0 0], [0 nTrialAE], 'k:', 'LineWidth',1.2)
  xlim(TLIM_REW); yticks([])
  xlabel('Time from reward (ms)')
  
  ppretty([6,3])
  
end % for : unit(uu)

end % fxn : plot_Raster_ErrTime()
