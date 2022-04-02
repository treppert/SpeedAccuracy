% function [  ] = plot_SDF_X_Dir_RF_ErrChoice_X_ISI_Full( behavData , unitData , spikesSAT )
%plot_SDF_X_Dir_RF_ErrChoice() Summary of this function goes here
%   Detailed explanation goes here

NUM_ITER = 50; %number of iterations of sub-sampling procedure
NUM_TRIAL = 20; %number of trials to sub-sample on each iteration

PVAL_MW = .05; %parameters for Mann-Whitney U-test of difference
TAIL_MW = 'both';

TEST = false;
% MIN_TRIAL_COUNT = 3;
RT_MAX = 900; %hard ceiling on primary RT

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});
idxFunction = ismember(unitData.Grade_Err, 1);
idxKeep = (idxArea & idxMonkey & idxFunction);

NUM_UNIT = sum(idxKeep);
unitTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

OFFSET_PRE = 350;
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
  sdfS_kk = align_signal_on_response(sdfA_kk, RTS_kk); %sdf from Second
  
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
  
  %% Bootstrap methodology
  meanISI_FastErr = NaN(NUM_ITER,1); %time of second saccade re. primary saccade
  meanISI_AccErr  = NaN(NUM_ITER,1);
  tSig_Fast = NaN(NUM_ITER,2); %time of error signal re. primary | second
  tSig_Acc  = tSig_Fast;
  
  for ii = 1:NUM_ITER
    %sample NUM_TRIAL error trials with replacement
    jjFastErr_P = datasample(trialFastErr{1}, NUM_TRIAL, 'Replace',true);
    jjAccErr_P  = datasample(trialAccErr{1},  NUM_TRIAL, 'Replace',true);
    jjFastErr_S = datasample(trialFastErr{2}, NUM_TRIAL, 'Replace',true);
    jjAccErr_S  = datasample(trialAccErr{2},  NUM_TRIAL, 'Replace',true);
    
    meanISI_FastErr(ii) = nanmean(ISI_kk(jjFastErr_P));
    meanISI_AccErr(ii)  = nanmean(ISI_kk(jjAccErr_P));
    
    %calculate window of signaling re. primary saccade
    [tSig_Fast(ii,1),vecSig_Fast{ii,1}] = calc_tSignal_ChoiceErr(sdfP_kk(trialFastCorr{1}, tPlot), ...
      sdfP_kk(jjFastErr_P, tPlot), 'pvalMW',PVAL_MW, 'tailMW',TAIL_MW);
    [tSig_Acc(ii,1), vecSig_Acc{ii,1}]  = calc_tSignal_ChoiceErr(sdfP_kk(trialAccCorr{1}, tPlot), ...
      sdfP_kk(jjAccErr_P, tPlot),  'pvalMW',PVAL_MW, 'tailMW',TAIL_MW);
    %calculate window of signaling re. second saccade
    [tSig_Fast(ii,2),vecSig_Fast{ii,2}] = calc_tSignal_ChoiceErr(fliplr(sdfS_kk(trialFastCorr{2}, tPlot)), ...
      fliplr(sdfS_kk(jjFastErr_S, tPlot)), 'pvalMW',PVAL_MW, 'tailMW',TAIL_MW);
    [tSig_Acc(ii,2), vecSig_Acc{ii,2}]  = calc_tSignal_ChoiceErr(fliplr(sdfS_kk(trialAccCorr{2}, tPlot)), ...
      fliplr(sdfS_kk(jjAccErr_S, tPlot)),  'pvalMW',PVAL_MW, 'tailMW',TAIL_MW);

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
      plot((tSig_Fast(ii,1)-OFFSET_PRE)*ones(1,2), yLim, 'b-')
      plot(meanISI_FastErr(ii)*ones(1,2), yLim, 'k-')
      scatter(vecSig_Fast{ii,1}-OFFSET_PRE, yLim(2)/30, 4, [.4 .6 1], 'filled')

      subplot(2,2,2); hold on; xlim(tPlot([1,NUM_SAMP])-3500)
      plot(tPlot-3500, SDF_FastCorr(2,:), 'Color',[0 .7 0], 'LineWidth',1.25)
      plot(tPlot-3500, SDF_FastErr(2,:), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
      plot((OFFSET_POST-tSig_Fast(ii,2))*ones(1,2), yLim, 'b-')
      scatter(OFFSET_POST-vecSig_Fast{ii,2}, yLim(2)/30, 4, [.4 .6 1], 'filled')
      set(gca, 'YColor','none')
      
      subplot(2,2,3); hold on; xlim(tPlot([1,NUM_SAMP])-3500) %Accurate condition
      plot(tPlot-3500, SDF_AccCorr(1,:), 'r', 'LineWidth',1.25)
      plot(tPlot-3500, SDF_AccErr(1,:), 'r:', 'LineWidth',1.25)
      plot((tSig_Acc(ii,1)-OFFSET_PRE)*ones(1,2), yLim, 'b-')
      plot(meanISI_AccErr(ii)*ones(1,2), yLim, 'k-')
      scatter(vecSig_Acc{ii,1}-OFFSET_PRE, yLim(2)/30, 4, [.4 .6 1], 'filled')
      xlabel('Time from primary saccade (ms)')

      subplot(2,2,4); hold on; xlim(tPlot([1,NUM_SAMP])-3500)
      plot(tPlot-3500, SDF_AccCorr(2,:), 'r', 'LineWidth',1.25)
      plot(tPlot-3500, SDF_AccErr(2,:), 'r:', 'LineWidth',1.25)
      plot((OFFSET_POST-tSig_Acc(ii,2))*ones(1,2), yLim, 'b-')
      scatter(OFFSET_POST-vecSig_Acc{ii,2}, yLim(2)/30, 4, [.4 .6 1], 'filled')
      xlabel('Time from primary saccade (ms)')
      ylabel('Activity (sp/sec)')
      set(gca, 'YColor','none')
      
      ppretty([7,5])
      return
    end % if(TEST)
    
  end % for : subsample-iteration (ii)
  
  figure()
  subplot(2,2,1); scatter(meanISI_FastErr, tSig_Fast(:,1)-OFFSET_PRE, 20, [0 .7 0], 'filled')
  subplot(2,2,2); scatter(meanISI_FastErr, OFFSET_POST-tSig_Fast(:,2), 20, [0 .7 0], 'filled')
  subplot(2,2,3); scatter(meanISI_AccErr,  tSig_Acc(:,1)-OFFSET_PRE,  20, 'r', 'filled')
  subplot(2,2,4); scatter(meanISI_AccErr,  OFFSET_POST-tSig_Acc(:,2),  20, 'r', 'filled')
  ppretty([7,6]); subplot(2,2,1); axis equal
  
end % for : unit(uu)

clearvars -except behavData unitData spikesSAT
% end % fxn : plot_SDF_X_Dir_RF_ErrChoice_X_ISI_Full()
