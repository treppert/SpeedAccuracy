% function [  ] = plot_SDF_X_Dir_RF_ErrChoice_X_ISI_Bootstrap( behavData , unitData , spikesSAT )
%plot_SDF_X_Dir_RF_ErrChoice() Summary of this function goes here
%   Detailed explanation goes here

NUM_ITER = 60; %number of iterations of sub-sampling procedure
NUM_TRIAL = 20; %number of trials to sub-sample on each iteration

PVAL_MW = .05; %parameters for Mann-Whitney U-test of difference
TAIL_MW = 'left';

TEST = false;
RT_MAX = 900; %hard ceiling on primary RT

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});
idxFunction = ismember(unitData.Grade_Err, 1);
idxKeep = (idxArea & idxMonkey & idxFunction);

NUM_UNIT = sum(idxKeep);
unitTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

OFFSET_PRE = 800;
OFFSET_POST = 500;
tPlot = 3500 + (-OFFSET_PRE : OFFSET_POST); %plot time vector
NUM_SAMP = length(tPlot);

for uu = NUM_UNIT:-1:1
  fprintf('%s \n', unitTest.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitTest.Task_Session(uu));
  
  RTP_kk = behavData.Sacc_RT{kk}; %Primary saccade RT
  RTP_kk(RTP_kk > RT_MAX) = NaN; %hard limit on primary RT
  RTS_kk = behavData.Sacc2_RT{kk}; %Second saccade RT
  ISI_kk = RTS_kk - RTP_kk; %Inter-saccade interval
  
  %compute spike density function and align on primary response
  sdfA_kk = compute_spike_density_fxn(spikesTest{uu});  %sdf from Array
  sdfP_kk = align_signal_on_response(sdfA_kk, RTP_kk); %sdf from Primary
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitTest.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by condition
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  idxErr = (behavData.Task_ErrChoice{kk} & ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  
  %index by saccade octant re. response field (RF)
  RF = unitTest.RF{uu};
  if ( isempty(RF) || (ismember(9,RF)) ) %average over all possible directions
    idxRF_P = true(behavData.Task_NumTrials(kk),1);
    idxRF_S = true(behavData.Task_NumTrials(kk),1);
  else %average only trials with saccade into RF
    idxRF_P = ismember(behavData.Sacc_Octant{kk}, RF);
    idxRF_S = ismember(behavData.Sacc2_Octant{kk}, RF);
  end
  
  trialFastCorr = {find(idxFast & idxCorr & idxRF_P) , find(idxFast & idxCorr & idxRF_S)};
  trialFastErr  = {find(idxFast & idxErr & idxRF_P) , find(idxFast & idxErr & idxRF_S)};
  trialAccCorr = {find(idxAcc & idxCorr & idxRF_P) , find(idxAcc & idxCorr & idxRF_S)};
  trialAccErr  = {find(idxAcc & idxErr & idxRF_P) , find(idxAcc & idxErr & idxRF_S)};
  fprintf('Trial counts -- Fast: %4i %4i   Accurate: %4i %4i\n', ...
    length(trialFastErr{1}), length(trialAccErr{1}), length(trialFastErr{2}), length(trialAccErr{2}))
  
  %set "RT2" of correct trials as the mean RT2 on error trials
  meanISI_FastErr = nanmean(ISI_kk(idxFast & idxErr));
  meanISI_AccErr  = nanmean(ISI_kk(idxAcc & idxErr));
  RTS_kk(idxFast & idxCorr) = RTP_kk(idxFast & idxCorr) + round(meanISI_FastErr);
  RTS_kk(idxAcc  & idxCorr) = RTP_kk(idxAcc & idxCorr)  + round(meanISI_AccErr);
  sdfS_kk = align_signal_on_response(sdfA_kk, RTS_kk); %sdf from Second
  
  %% Bootstrap methodology
  meanISI_FastErr = NaN(NUM_ITER,1); %time of second saccade re. primary saccade
  meanISI_AccErr  = meanISI_FastErr;
  tSig_Fast_P = NaN(NUM_ITER,1); %time of error signal re. *primary* saccade
  tSig_Acc_P  = tSig_Fast_P;
  tSig_Fast_S = tSig_Fast_P; %time of error signal re. *second* saccade
  tSig_Acc_S = tSig_Fast_P;
  
  parfor ii = 1:NUM_ITER
    %sample NUM_TRIAL error trials with replacement
    jjFastErr_P = datasample(trialFastErr{1}, NUM_TRIAL, 'Replace',true);
    jjAccErr_P  = datasample(trialAccErr{1},  NUM_TRIAL, 'Replace',true);
    jjFastErr_S = datasample(trialFastErr{2}, NUM_TRIAL, 'Replace',true);
    jjAccErr_S  = datasample(trialAccErr{2},  NUM_TRIAL, 'Replace',true);
    
    meanISI_FastErr(ii) = nanmean(ISI_kk(jjFastErr_P));
    meanISI_AccErr(ii)  = nanmean(ISI_kk(jjAccErr_P));
    
    %calculate window of signaling re. primary saccade
    [tSig_Fast_P(ii),vecSig_Fast_P] = calc_tSignal_ChoiceErr(sdfP_kk(trialFastCorr{1}, tPlot), ...
      sdfP_kk(jjFastErr_P, tPlot), 'pvalMW',PVAL_MW, 'tailMW',TAIL_MW);
    [tSig_Acc_P(ii), vecSig_Acc_P]  = calc_tSignal_ChoiceErr(sdfP_kk(trialAccCorr{1}, tPlot), ...
      sdfP_kk(jjAccErr_P, tPlot),  'pvalMW',PVAL_MW, 'tailMW',TAIL_MW);
    %calculate window of signaling re. second saccade
    [tSig_Fast_S(ii),vecSig_Fast_S] = calc_tSignal_ChoiceErr(sdfS_kk(trialFastCorr{2}, tPlot), ...
      sdfS_kk(jjFastErr_S, tPlot), 'pvalMW',PVAL_MW, 'tailMW',TAIL_MW);
    [tSig_Acc_S(ii), vecSig_Acc_S]  = calc_tSignal_ChoiceErr(sdfS_kk(trialAccCorr{2}, tPlot), ...
      sdfS_kk(jjAccErr_S, tPlot),  'pvalMW',PVAL_MW, 'tailMW',TAIL_MW);

    if (TEST)
      SDF_FastCorr = [nanmean(sdfP_kk(trialFastCorr{1}, tPlot)); nanmean(sdfS_kk(trialFastCorr{2}, tPlot))];
      SDF_AccCorr  = [nanmean(sdfP_kk(trialAccCorr{1}, tPlot));  nanmean(sdfS_kk(trialAccCorr{2}, tPlot))];
      SDF_FastErr = [nanmean(sdfP_kk(jjFastErr_P, tPlot)); nanmean(sdfS_kk(jjFastErr_S, tPlot))];
      SDF_AccErr =  [nanmean(sdfP_kk(jjAccErr_P, tPlot));  nanmean(sdfS_kk(jjAccErr_S, tPlot))];

      figure()
      yLim = [0, max([SDF_FastCorr SDF_FastErr SDF_AccCorr SDF_AccErr],[],'all')];

      subplot(2,2,1); hold on; xlim(tPlot([1,NUM_SAMP])-3500) %Fast condition
      plot(tPlot-3500, SDF_FastCorr(1,:), 'Color',[0 .7 0], 'LineWidth',1.25)
      plot(tPlot-3500, SDF_FastErr(1,:), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
      plot((tSig_Fast_P(ii)-OFFSET_PRE)*ones(1,2), yLim, 'b-')
      plot(meanISI_FastErr(ii)*ones(1,2), yLim, 'k-')
      scatter(vecSig_Fast_P-OFFSET_PRE, yLim(2)/30, 4, [.4 .6 1], 'filled')

      subplot(2,2,2); hold on; xlim(tPlot([1,NUM_SAMP])-3500)
      plot(tPlot-3500, SDF_FastCorr(2,:), 'Color',[0 .7 0], 'LineWidth',1.25)
      plot(tPlot-3500, SDF_FastErr(2,:), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
      plot((tSig_Fast_S(ii)-OFFSET_PRE)*ones(1,2), yLim, 'b-')
      scatter(vecSig_Fast_S-OFFSET_PRE, yLim(2)/30, 4, [.4 .6 1], 'filled')
      set(gca, 'YColor','none')
      
      subplot(2,2,3); hold on; xlim(tPlot([1,NUM_SAMP])-3500) %Accurate condition
      plot(tPlot-3500, SDF_AccCorr(1,:), 'r', 'LineWidth',1.25)
      plot(tPlot-3500, SDF_AccErr(1,:), 'r:', 'LineWidth',1.25)
      plot((tSig_Acc_P(ii)-OFFSET_PRE)*ones(1,2), yLim, 'b-')
      plot(meanISI_AccErr(ii)*ones(1,2), yLim, 'k-')
      scatter(vecSig_Acc_P-OFFSET_PRE, yLim(2)/30, 4, [.4 .6 1], 'filled')
      xlabel('Time from primary saccade (ms)')
      ylabel('Activity (sp/sec)')

      subplot(2,2,4); hold on; xlim(tPlot([1,NUM_SAMP])-3500)
      plot(tPlot-3500, SDF_AccCorr(2,:), 'r', 'LineWidth',1.25)
      plot(tPlot-3500, SDF_AccErr(2,:), 'r:', 'LineWidth',1.25)
      plot((tSig_Acc_S(ii)-OFFSET_PRE)*ones(1,2), yLim, 'b-')
      scatter(vecSig_Acc_S-OFFSET_PRE, yLim(2)/30, 4, [.4 .6 1], 'filled')
      xlabel('Time from second saccade (ms)')
      ylabel('Activity (sp/sec)')
      set(gca, 'YColor','none')
      
      ppretty([7,5])
%       return
    end % if(TEST)
    
  end % for : subsample-iteration (ii)
  
  figure()
  XLIM = [300 450]; YLIM = [-600 300];
  subplot(1,2,1); hold on
  scatter(meanISI_FastErr, tSig_Fast_P-OFFSET_PRE, 20, 'k')
  scatter(meanISI_FastErr, tSig_Fast_S-OFFSET_PRE, 20, [0 .7 0])
  xlim(XLIM); xlabel('Mean inter-saccade interval (ms)')
  ylim(YLIM); ylabel('Error signal onset (ms)')
  
  subplot(1,2,2); hold on
  scatter(meanISI_AccErr,  tSig_Acc_P-OFFSET_PRE, 20, 'k')
  scatter(meanISI_AccErr,  tSig_Acc_S-OFFSET_PRE, 20, 'r')
  xlabel('Mean inter-saccade interval (ms)')
  xlim(XLIM); ylim(YLIM)
  ppretty([7,4])
  
end % for : unit(uu)

clearvars -except behavData unitData spikesSAT
% end % fxn : plot_SDF_X_Dir_RF_ErrChoice_X_ISI_Bootstrap()
