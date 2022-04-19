%plot_SDF_X_Dir_MG() Summary of this function goes here
%   Detailed explanation goes here

PRINTDIR = 'C:\Users\Tom\Documents\Figs - SAT\';

idxArea = ismember(unitData.aArea, {'FEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});
idxKeep = (idxArea & idxMonkey);

NUM_UNIT = sum(idxKeep);
unitTest = unitData(idxKeep,:);
spikesTest = spikesMG(idxKeep);

T_STIM = 3500 + (-300 : 500);
T_RESP = 3500 + (-500 : 300);
NUM_SAMP = length(T_STIM);

IDX_STIM_PLOT = [11, 5, 3, 1, 7, 13, 15, 17];
IDX_RESP_PLOT = IDX_STIM_PLOT + 1;

for uu = 1:NUM_UNIT
  fprintf('%s - %s\n', unitTest.Task_Session{uu}, unitTest.aID{uu})
  kk = ismember(behavDataMG.Task_Session, unitTest.Task_Session{uu});
  RT_P = behavDataMG.Sacc_RT{kk};
  
  %compute spike density function and align on primary response
  sdfMG_A = compute_spike_density_fxn(spikesTest{uu});
  sdfMG_P = align_signal_on_response(sdfMG_A, RT_P); 
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitTest.Task_TrialRemoveSAT{uu}, behavDataMG.Task_NumTrials(kk));
  %index by trial outcome
  idxCorr = ~(behavDataMG.Task_ErrChoice{kk} | behavDataMG.Task_ErrHold{kk} | behavDataMG.Task_ErrNoSacc{kk});
  
  %initializations
  Octant_Sacc1 = behavDataMG.Sacc_Octant{kk};
  sdfA = NaN(NUM_SAMP,8);
  sdfP = sdfA;
  for dd = 1:8 %loop over response directions
    idxDir = (Octant_Sacc1 == dd);
    sdfA(:,dd) = nanmean(sdfMG_A(idxCorr & idxDir, T_STIM));
    sdfP(:,dd) = nanmean(sdfMG_P(idxCorr & idxDir, T_RESP));
  end%for:direction(dd)
  
  %% Plotting
  hFig = figure('visible','off');
  yLim = [0, max([sdfA sdfP],[],'all')];
  xLimStim = T_STIM([1,NUM_SAMP]) - 3500;
  xLimResp = T_RESP([1,NUM_SAMP]) - 3500;
  
  for dd = 1:8 %loop over directions and plot
    
    subplot(3,6,IDX_STIM_PLOT(dd)); hold on %re. array
    plot([0 0], yLim, 'k:')
    plot(T_STIM-3500, sdfA(:,dd), 'k-');
    xlim(xLimStim)
    
    if (IDX_STIM_PLOT(dd) == 13)
      ylabel('Activity (sp/sec)');  xticklabels([])
      xlabel('Time from array (ms)');  yticklabels([])
      print_session_unit(gca , unitTest(uu,:), behavDataMG(kk,:))
    end
    
    subplot(3,6,IDX_RESP_PLOT(dd)); hold on %re. response
    plot([0 0], yLim, 'k:')
    plot(T_RESP-3500, sdfP(:,dd), 'k-');
    xlim(xLimResp)
    set(gca, 'YAxisLocation','right')
    
    if (IDX_RESP_PLOT(dd) == 14)
      xlabel('Time from response (ms)');  yticklabels([])
    else
      xticklabels([]);  yticklabels([])
    end
    
    pause(.01)
    
  end%for:direction(dd)
  
  ppretty([12,6])
  
  pause(0.1); print([PRINTDIR,unitTest.Properties.RowNames{uu},'-',unitTest.aArea{uu},'.tif'], '-dtiff')
  pause(0.1); close(hFig); pause(0.1)
  
end % for : unit(uu)

clearvars -except behavData behavDataMG unitData spikesSAT spikesMG
