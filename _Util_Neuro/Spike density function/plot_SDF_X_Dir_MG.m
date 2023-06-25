%plot_SDF_X_Dir_MG() This script plots activity of single neurons recorded
%during the memory-guided saccade task. Activity is plotted as a function of
%target location (8 octants).

PRINTDIR = 'C:\Users\Tom\Documents\Figs - SAT\';

idx_Sess = ismember(unitData.SessionID, [2 3 4 6 8 9]);
idx_Area = ismember(unitData.Area, {'SEF','FEF','SC'});
idx_Fxn = ~(unitData.FxnType == "None");

unitTest = unitData( idx_Sess & idx_Area & idx_Fxn , : );
nUnit = size(unitTest,1);

tWin.VR = 3500 + (-300 : 500);
tWin.PS = 3500 + (-500 : 300);
tWin.PR = 3500 + (-300 : 500);
nSamp = length(tWin.VR);

for uu = 1:nUnit
  spikes = load_spikes_SAT(unitTest.Index(uu)); %load spike times
  kk = unitTest.SessionID(uu); %get session number

  nTrial = behavDataMG.NumTrials(kk); %number of trials
  tResp = behavDataMG.Sacc_RT{kk}; %primary saccade RT
  tRew = behavDataMG.RewTime(kk); %time of reward delivery (re saccade)
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitTest.TrialRemoveMG{uu}, behavDataMG.NumTrials(kk));
  %index by trial outcome
  idxCorr = ~(behavDataMG.Task_ErrChoice{kk} | behavDataMG.Task_ErrHold{kk} | behavDataMG.Task_ErrNoSacc{kk});
  
  %compute spike density function and align on primary response
  sdfMG_A = compute_spike_density_fxn(spikesTest{uu});
  sdfMG_P = align_signal_on_response(sdfMG_A, tResp); 
  
  %initializations
  Octant_Sacc1 = behavDataMG.Sacc_Octant{kk};
  sdfA = NaN(nSamp,8);
  sdfP = sdfA;
  for dd = 1:8 %loop over response directions
    idxDir = (Octant_Sacc1 == dd);
    sdfA(:,dd) = nanmean(sdfMG_A(idxCorr & idxDir, tWin.VR));
    sdfP(:,dd) = nanmean(sdfMG_P(idxCorr & idxDir, tWin.PS));
  end%for:direction(dd)
  
  %% Plotting
  hFig = figure('visible','off');
  yLim = [0, max([sdfA sdfP],[],'all')];
  xLimStim = tWin.VR([1,nSamp]) - 3500;
  xLimResp = tWin.PS([1,nSamp]) - 3500;
  
  for dd = 1:8 %loop over directions and plot
    
    subplot(3,6,IDX_STIM_PLOT(dd)); hold on %re. array
    plot([0 0], yLim, 'k:')
    plot(tWin.VR-3500, sdfA(:,dd), 'k-');
    xlim(xLimStim)
    
    if (IDX_STIM_PLOT(dd) == 13)
      ylabel('Activity (sp/sec)');  xticklabels([])
      xlabel('Time from array (ms)');  yticklabels([])
      print_session_unit(gca , unitTest(uu,:), behavDataMG(kk,:))
    end
    
    subplot(3,6,IDX_RESP_PLOT(dd)); hold on %re. response
    plot([0 0], yLim, 'k:')
    plot(tWin.PS-3500, sdfP(:,dd), 'k-');
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

clearvars -except behavData* unitData pairData spkCorr ROOTDIR*
