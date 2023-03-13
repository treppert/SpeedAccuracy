%plot_FR_X_Dir_SAT() Summary of this function goes here
%   Detailed explanation goes here

%polarplot(theta,rho)
% PRINTDIR = 'C:\Users\Tom\Documents\Figs - SAT\';

idxArea = ismember(unitData.Area, {'SEF'});
idxMonkey = ismember(unitData.Monkey, {'D'});
idxFunction = (unitData.Grade_Vis > 2);
idxKeep = (idxArea & idxMonkey & idxFunction);

NUM_UNIT = 1;%sum(idxKeep);
unitTest = unitData(41,:);

tWin = (-100 : 300);
iWin = 3500 + tWin;
nSamp = length(tWin);

for uu = 1:NUM_UNIT
  fprintf('%s - %s\n', unitTest.Session{uu}, unitTest.ID{uu})
  kk = ismember(behavData.Session, unitTest.Session{uu});
  RT_P = behavData.Sacc_RT{kk}; %Primary saccade RT
  
  %compute spike density function and align on primary response
  spikes_uu = load_spikes_SAT(unitTest.Index(uu));
  sdfA = compute_spike_density_fxn(spikes_uu);
  sdfP = align_signal_on_response(sdfA, RT_P); 
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitTest.TrialRemoveSAT{uu}, behavData.NumTrials(kk));
  %index by condition
  idxAcc = ((behavData.Condition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Condition{kk} == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Correct{kk};
  
  %% Compute mean FR by direction
  Octant_Resp = behavData.Sacc_Octant{kk};
  sdfAcc = NaN(nSamp,8);    frAcc = NaN(8,1);
  sdfFast = sdfAcc;         frFast = frAcc;
  for dd = 1:8 %loop over response directions
    idxDir = (Octant_Resp == dd);
    sdfAcc(:,dd)  = mean(sdfA(idxAcc  & idxCorr & idxDir, iWin));
    frAcc(dd) = mean(sdfAcc(:,dd));
    sdfFast(:,dd) = mean(sdfA(idxFast & idxCorr & idxDir, iWin));
    frFast(dd) = mean(sdfFast(:,dd));
  end%for:direction(dd)
  
  %% Plotting
  IDX_PLOT = [6 3 2 1 4 7 8 9];
  hFig = figure('visible','on');
  yLim = [0, max([sdfAcc; sdfFast],[],'all')];
  xLim = tWin([1,nSamp]);
  
  for dd = 1:8 %loop over directions and plot
    
    subplot(3,3,IDX_PLOT(dd)); hold on %re. array
    plot([0 0], yLim, 'k:')
    plot(tWin, sdfAcc(:,dd), 'r-');
    plot(tWin, sdfFast(:,dd), '-', 'Color',[0 .7 0]);
    xlim(xLim)
    
    if (IDX_PLOT(dd) == 7)
      ylabel('Activity (sp/sec)')
      xlabel('Time from array (ms)')
    else
      xticklabels([])
      yticklabels([])
    end
    
  end%for:direction(dd)
  
  subplot(3,3,5); print_session_unit(gca, unitTest(uu,:), behavData(kk,:), 'horizontal'); axis('off')
  ppretty([5,4])
  
%   pause(0.1); print([PRINTDIR,unitTest.Properties.RowNames{uu},'-',unitTest.aArea{uu},'.tif'], '-dtiff')
%   pause(0.1); close(hFig); pause(0.1)
  
end % for : unit(uu)

clearvars -except behavData unitData pairData ROOTDIR*
