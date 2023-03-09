%plot_FR_X_Dir_Pair() Summary of this function goes here
%   Detailed explanation goes here

%polarplot(theta,rho)
% PRINTDIR = 'C:\Users\Tom\Documents\Figs - SAT\';

idx_YArea = ismember(pairData.Y_Area, {'SC'});
idx_YFxn  = ismember(pairData.Y_FxnType, {'V'});
idx_XFxn  = ismember(pairData.X_FxnType, {'V'});

pairTest = pairData(idx_YArea & idx_YFxn & idx_XFxn , : );
nPair = 1;%size(pairTest,1);

unitTest = unitData(41,:);

tWin = (-100 : 300);
iWin = 3500 + tWin;
nSamp = length(tWin);
nDir = 8;

for pp = 1:nPair
  iX = pairTest.X_Index(pp); %get index for unitData
  iY = pairTest.Y_Index(pp);
  kk = pairTest.SessionID(pp); %get session number

  nTrial = behavData.NumTrials(kk);
  RT_P = behavData.Sacc_RT{kk}; %primary saccade RT

  %compute spike density function and align on primary response
  spikes_X = load_spikes_SAT(iX);
  spikes_Y = load_spikes_SAT(iY);
  sdfX_A = compute_spike_density_fxn(spikes_X);
  sdfY_A = compute_spike_density_fxn(spikes_Y);
  sdfX_P = align_signal_on_response(sdfX_A, RT_P); 
  sdfY_P = align_signal_on_response(sdfY_A, RT_P); 
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitData.TrialRemoveSAT{iX}, nTrial);
  idxIso = idxIso | removeTrials_Isolation(unitData.TrialRemoveSAT{iY}, nTrial);
  %index by condition
  idxAcc = ((behavData.Condition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Condition{kk} == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Correct{kk};
  
  %% Compute mean FR by direction
  sdfX_Acc  = NaN(nSamp,nDir+1);
  sdfX_Fast = sdfX_Acc;
  sdfY_Acc  = sdfX_Acc;
  sdfY_Fast = sdfX_Acc;
  for dd = 1:nDir
    idxDir = (behavData.Sacc_Octant{kk} == dd);
    sdfX_Acc(:,dd)  = mean(sdfX_A(idxAcc  & idxCorr & idxDir, iWin));
    sdfX_Fast(:,dd) = mean(sdfX_A(idxFast & idxCorr & idxDir, iWin));
    sdfY_Acc(:,dd)  = mean(sdfY_A(idxAcc  & idxCorr & idxDir, iWin));
    sdfY_Fast(:,dd) = mean(sdfY_A(idxFast & idxCorr & idxDir, iWin));
  end % for : direction (dd)
  
  sdfX_Acc(:,nDir+1)  = mean(sdfX_A(idxAcc & idxCorr, iWin)); %mean across all directions
  sdfX_Fast(:,nDir+1) = mean(sdfX_A(idxFast & idxCorr, iWin));
  sdfY_Acc(:,nDir+1)  = mean(sdfY_A(idxAcc & idxCorr, iWin));
  sdfY_Fast(:,nDir+1) = mean(sdfY_A(idxFast & idxCorr, iWin));

  %% Plotting
  idxPlot_X = [10 3 2 1 8 15 16 17 9];
  idxPlot_Y = [14 7 6 5 12 19 20 21 13];
  hFig = figure('visible','on');
  yLim_X = [0, max([sdfX_Acc; sdfX_Fast],[],'all')];
  yLim_Y = [0, max([sdfY_Acc; sdfY_Fast],[],'all')];
  xLim = tWin([1,nSamp]);
  
  %% Neuron X (SEF)
  for dd = 1:nDir+1 %loop over directions and plot
    subplot(3,7,idxPlot_X(dd)); hold on %re. array
    plot([0 0], yLim_X, 'k:')
    plot(tWin, sdfX_Acc(:,dd), 'r-');
    plot(tWin, sdfX_Fast(:,dd), '-', 'Color',[0 .7 0]);
    xlim(xLim)
    
    if (dd == 6) %bottom left
      ylabel('Activity (sp/sec)')
      xlabel('Time from array (ms)')
    else
      xticklabels([])
      yticklabels([])
    end
  end%for:direction(dd)
  
  subplot(3,7,2)
  print_session_unit(gca, unitData.ID{iX}, 'horizontal')

  %% Neuron Y (FEF/SC)
  for dd = 1:nDir+1 %loop over directions and plot
    subplot(3,7,idxPlot_Y(dd)); hold on %re. array
    plot([0 0], yLim_Y, 'k:')
    plot(tWin, sdfY_Acc(:,dd), 'r-');
    plot(tWin, sdfY_Fast(:,dd), '-', 'Color',[0 .7 0]);
    xlim(xLim)
    
    if (dd == 6) %bottom left
      ylabel('Activity (sp/sec)')
      xlabel('Time from array (ms)')
    else
      xticklabels([])
      yticklabels([])
    end
  end%for:direction(dd)
  
  subplot(3,7,6)
  print_session_unit(gca, unitData.ID{iY}, 'horizontal')

  ppretty([15,4])
  
end % for : pair(pp)

clearvars -except behavData unitData pairData ROOTDIR*
