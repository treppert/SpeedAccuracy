%plot_SDF_X_Dir_SAT() Summary of this function goes here
%   Detailed explanation goes here

uPlot = [93,98];
GREEN = [0 .7 0];

iStim = 3500 + (-300 : +300); tStim = iStim - 3500;
iResp = 3500 + (-300 : +300); tResp = iResp - 3500;
iRew  = 3500 + (-300 : +300); tRew = iRew - 3500;

for u = 1:numel(uPlot)
  up = uPlot(u);
  fprintf('%s\n', unitData.Session{up}, unitData.ID{up})
  k = ismember(behavData.Task_Session, unitData.Session{up});

  RT_P = behavData.Sacc_RT{k}; %Primary saccade RT
  RewT = RT_P + behavData.Task_TimeReward(k); %time of reward - fixed re. saccade
  
  %compute spike density function and align appropriately
  spikes_u = load_spikes_SAT(unitData.Index(up));
  sdfA = compute_spike_density_fxn(spikes_u);  %sdf from Array
  sdfP = align_signal_on_response(sdfA, RT_P); %sdf from Primary
  sdfR = align_signal_on_response(sdfA, RewT); %sdf from Reward

  %index by isolation quality
  idxIso = removeTrials_Isolation(unitData.TrialRemoveSAT{up}, behavData.Task_NumTrials(k));
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{k} == 1) & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{k} == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Task_Correct{k};
  %index by saccade octant re. response field (RF)
  idxRF = ismember(behavData.Sacc_Octant{k}, unitData.RF{up});

  %combine indexing
  idxAC = (idxAcc & idxCorr & idxRF);
  idxFC = (idxFast & idxCorr & idxRF);
  
  %% Compute mean SDF
  %Accurate
  sdfAC_A = mean(sdfA(idxAC, iStim));
  sdfAC_P = nanmean(sdfP(idxAC, iResp));
  sdfAC_R = nanmean(sdfR(idxAC, iRew));
  %Fast
  sdfFC_A = mean(sdfA(idxFC, iStim));
  sdfFC_P = nanmean(sdfP(idxFC, iResp));
  sdfFC_R = nanmean(sdfR(idxFC, iRew));
  
  %% Plotting
  yLim = [0, max([sdfAC_A sdfAC_P sdfFC_A sdfFC_P sdfFC_R],[],'all')];
  xLim = [-300,+300];
  
  figure()
  subplot(1,3,1); hold on %re. array
  title(unitData.ID{up})
  plot(tStim, sdfAC_A, 'r-')
  plot(tStim, sdfFC_A, '-', 'Color',GREEN)
  ylabel('Activity (sp/sec)')
  xlabel('Time from array (ms)')
  xlim(xLim); ylim(yLim)

  subplot(1,3,2); hold on %re. response
  plot(tResp, sdfAC_P, 'r-')
  plot(tResp, sdfFC_P, '-', 'Color',GREEN)
  xlabel('Time from response (ms)')
  xlim(xLim); ylim(yLim)

  subplot(1,3,3); hold on %re. reward
  plot(tRew, sdfAC_R, 'r-')
  plot(tRew, sdfFC_R, '-', 'Color',GREEN)
  xlabel('Time from reward (ms)')
  xlim(xLim); ylim(yLim)

  drawnow
  ppretty([8,1.6])
  
end % for : unit(u)

clearvars -except ROOTDIR_SAT behavData unitData spkCorr_
