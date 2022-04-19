%plot_SDF_X_Dir_SAT() Summary of this function goes here
%   Detailed explanation goes here

PRINTDIR = 'C:\Users\Tom\Documents\Figs - SAT\';

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D'});
% idxFunction = (unitTest.Grade_Err == 1);
idxKeep = (idxArea & idxMonkey);

NUM_UNIT = sum(idxKeep);
unitTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

T_STIM_Acc = 3500 + (-300 : 500);
T_RESP_Acc = 3500 + (-500 : 300);
NUM_SAMP_Acc = length(T_STIM_Acc);
T_STIM_Fast = 3500 + (-200 : 300);
T_RESP_Fast = 3500 + (-300 : 200);
NUM_SAMP_Fast = length(T_STIM_Fast);

IDX_STIM_PLOT = [11, 5, 3, 1, 7, 13, 15, 17];
IDX_RESP_PLOT = IDX_STIM_PLOT + 1;

for uu = 1:NUM_UNIT
  fprintf('%s - %s\n', unitTest.Task_Session{uu}, unitTest.aID{uu})
  kk = ismember(behavData.Task_Session, unitTest.Task_Session{uu});
  RT_P = behavData.Sacc_RT{kk}; %Primary saccade RT
  
  %compute spike density function and align on primary response
  sdfA = compute_spike_density_fxn(spikesTest{uu});
  sdfP = align_signal_on_response(sdfA, RT_P); 
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitTest.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  
  %% Compute mean SDF for each direction
  Octant_Sacc1 = behavData.Sacc_Octant{kk};
  sdfAccA = NaN(NUM_SAMP_Acc,8); %re. array
  sdfAccP = sdfAccA; %re. primary
  sdfFastA = NaN(NUM_SAMP_Fast,8);
  sdfFastP = sdfFastA;
  RT_Acc = NaN(8,1);
  RT_Fast = RT_Acc;
  for dd = 1:8 %loop over response directions
    idxDir = (behavData.Sacc_Octant{kk} == dd);
    sdfAccA(:,dd) = nanmean(sdfA(idxAcc & idxCorr & idxDir, T_STIM_Acc));
    sdfAccP(:,dd) = nanmean(sdfP(idxAcc & idxCorr & idxDir, T_RESP_Acc));
    sdfFastA(:,dd) = nanmean(sdfA(idxFast & idxCorr & idxDir, T_STIM_Fast));
    sdfFastP(:,dd) = nanmean(sdfP(idxFast & idxCorr & idxDir, T_RESP_Fast));
    RT_Acc(dd) = nanmedian(RT_P(idxAcc & idxCorr & idxDir));
    RT_Fast(dd) = nanmedian(RT_P(idxFast & idxCorr & idxDir));
  end%for:direction(dd)
  
  %% Plotting
  hFig = figure('visible','off');
  yLim = [0, max([sdfAccA; sdfAccP; sdfFastA; sdfFastP],[],'all')];
  xLimStim = T_STIM_Acc([1,NUM_SAMP_Acc]) - 3500;
  xLimResp = T_RESP_Acc([1,NUM_SAMP_Acc]) - 3500;
  
  for dd = 1:8 %loop over directions and plot
    
    subplot(3,6,IDX_STIM_PLOT(dd)); hold on %re. array
    plot([0 0], yLim, 'k:')
    plot(RT_Acc(dd)*ones(1,2), yLim, 'r:')
    plot(RT_Fast(dd)*ones(1,2), yLim, ':', 'Color',[0 .7 0])
    plot(T_STIM_Acc-3500, sdfAccA(:,dd), 'r-');
    plot(T_STIM_Fast-3500, sdfFastA(:,dd), '-', 'Color',[0 .7 0]);
    xlim(xLimStim)
    
    if (IDX_STIM_PLOT(dd) == 13)
      ylabel('Activity (sp/sec)');  xticklabels([])
      xlabel('Time from array (ms)');  yticklabels([])
      print_session_unit(gca , unitTest(uu,:), behavData(kk,:))
    end
    
    subplot(3,6,IDX_RESP_PLOT(dd)); hold on %re. response
    plot([0 0], yLim, 'k:')
    plot(-RT_Acc(dd)*ones(1,2), yLim, 'r:')
    plot(-RT_Fast(dd)*ones(1,2), yLim, ':', 'Color',[0 .7 0])
    plot(T_RESP_Acc-3500, sdfAccP(:,dd), 'r-');
    plot(T_RESP_Fast-3500, sdfFastP(:,dd), '-', 'Color',[0 .7 0]);
    xlim(xLimResp)
    set(gca, 'YAxisLocation','right')
    
    if (IDX_RESP_PLOT(dd) == 14)
      xlabel('Time from response (ms)');  yticklabels([])
    end
    
    pause(.01)
    
  end%for:direction(dd)
  
  ppretty([12,6])
  
  pause(0.1); print([PRINTDIR,unitTest.Properties.RowNames{uu},'-',unitTest.aArea{uu},'.tif'], '-dtiff')
  pause(0.1); close(hFig); pause(0.1)
  
end%for:cells(uu)

clearvars -except behavData unitData spikesSAT tSig_Fast tSig_Acc
