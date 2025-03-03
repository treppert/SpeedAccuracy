function [  ] = plot_Raster_ErrChoice( behavData , unitData , varargin )
%plot_Raster_ErrChoice Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=',{'SEF'}}, {'monkey=',{'D','E'}}, {'uID=',[]}});

if isempty(args.uID)
  idxArea = ismember(unitData.Area, args.area);
  idxMonkey = ismember(unitData.Monkey, args.monkey);
  idxFunction = ismember(unitData.Grade_Err, [-1,+1]);
  idxKeep = (idxArea & idxMonkey & idxFunction);
else % plot unit specified
  idxKeep = false(size(unitData,1),1);
  idxKeep(args.uID) = true;
end

NUM_UNIT = sum(idxKeep);
unitTest = unitData(idxKeep,:);

TLIM_PLOT = [-350 , 500];
TVEC_PLOT  = 3500 + (TLIM_PLOT(1):TLIM_PLOT(2));

for uu = NUM_UNIT:NUM_UNIT
  fprintf('%s \n', unitTest.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitTest.Session(uu));

  RT_P = behavData.Sacc_RT{kk}; %Primary saccade RT
  RT_S = behavData.Sacc2_RT{kk}; %Second saccade RT
  RT_S(RT_S == 0) = NaN;
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitTest.TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by task condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  idxErr  = behavData.Task_ErrChoiceOnly{kk};
  
  %combine indexing
  trialAC = find(idxAcc & idxCorr);
  trialAE = find(idxAcc & idxErr);
  trialFC = find(idxFast & idxCorr);
  trialFE = find(idxFast & idxErr);
  
  %prepare to plot spikes
  spikes_uu = load_spikes_SAT(unitTest.Index(uu));
  [tSpike_AE, trial_AE, RTS_AE] = collect_SpikeTimes(spikes_uu(trialAE), TVEC_PLOT([1,end]), ...
    RT_P(trialAE), RT_S(trialAE));
  
  %limit trial counts by number of Accurate choice errors
  nTrial = length(RTS_AE);
  trialAC = datasample(trialAC, nTrial, 'Replace',false);
  trialFE = datasample(trialFE, nTrial, 'Replace',false);
  trialFC = datasample(trialFC, nTrial, 'Replace',false);
  
  [tSpike_AC, trial_AC, ~] = collect_SpikeTimes(spikes_uu(trialAC), TVEC_PLOT([1,end]), ...
    RT_P(trialAC), RT_S(trialAC));
  
  [tSpike_FE, trial_FE, RTS_FE] = collect_SpikeTimes(spikes_uu(trialFE), TVEC_PLOT([1,end]), ...
    RT_P(trialFE), RT_S(trialFE));
  
  [tSpike_FC, trial_FC, ~] = collect_SpikeTimes(spikes_uu(trialFC), TVEC_PLOT([1,end]), ...
    RT_P(trialFC), RT_S(trialFC));
  
  %% Plotting
  MARKER_SIZE = 3;

  figure()
  
  subplot(2,2,1); hold on %Fast error
  scatter(tSpike_FE-3500, trial_FE, MARKER_SIZE, [0 .7 0], 'filled')
  plot([0 0], [0 nTrial], 'k:', 'LineWidth',1.2)
  scatter(RTS_FE, (1:nTrial), 20, [.4 .4 .4])
  xlim(TLIM_PLOT); xticks([])
  ylabel('Trial')
  
  subplot(2,2,2); hold on %Accurate error
  scatter(tSpike_AE-3500, trial_AE, MARKER_SIZE,'r', 'filled')
  plot([0 0], [0 nTrial], 'k:', 'LineWidth',1.2)
  scatter(RTS_AE, (1:nTrial), 20, [.4 .4 .4])
  xlim(TLIM_PLOT); xticks([]); yticks([])
  
  subplot(2,2,3); hold on %Fast correct
  scatter(tSpike_FC-3500, trial_FC, MARKER_SIZE, [.4 .4 .4], 'filled')
  plot([0 0], [0 nTrial], 'k:', 'LineWidth',1.2)
  xlim(TLIM_PLOT)
  xlabel('Time from primary saccade (ms)')
  ylabel('Trial')
  
  subplot(2,2,4); hold on %Accurate correct
  scatter(tSpike_AC-3500, trial_AC, MARKER_SIZE, [.4 .4 .4], 'filled')
  plot([0 0], [0 nTrial], 'k:', 'LineWidth',1.2)
  xlim(TLIM_PLOT); yticks([])
  xlabel('Time from primary saccade (ms)')
  
  ppretty([6,3])
  
end % for : unit(uu)

end % fxn : plot_Raster_ErrChoice()
