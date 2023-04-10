%plot_SDF_X_Dir_Pair() Summary of this function goes here
%   Detailed explanation goes here

% ROOTDIR_SAT = 'C:\Users\thoma\Dropbox\SAT-Local\';
% load([ROOTDIR_SAT, 'behavData.mat'])
% load([ROOTDIR_SAT, 'unitData.mat'])
% load([ROOTDIR_SAT, 'pairData.mat'])
% load([ROOTDIR_SAT, 'spkCorr.mat'])

PRINTDIR = 'C:\Users\Thomas Reppert\Documents\Figs - SAT\';

idx_YArea = ismember(pairData.Y_Area, {'SC'});
idx_XFxn  = ismember(pairData.X_FxnType, {'V','VC','VT','VCT'});
idx_YFxn  = ismember(pairData.Y_FxnType, {'M'});

pairTest = pairData( idx_YArea & idx_YFxn & idx_XFxn , : );
nPair = 1;%size(pairTest,1);

tWin.VR = (-100 : 300);
tWin.PS = (-100 : 300);
iWin.VR = 3500 + tWin.VR;
iWin.PS = 3500 + tWin.PS;
nSamp = length(tWin.VR);

for pp = 1:nPair
  iX = pairTest.X_Index(pp); %get index for unitData
  iY = pairTest.Y_Index(pp);
  kk = pairTest.SessionID(pp); %get session number

  nTrial = behavData.NumTrials(kk);
  RT_P = behavData.Sacc_RT{kk}; %primary saccade RT

  %index by isolation quality
  idxIso = removeTrials_Isolation(unitData.TrialRemoveSAT{iX}, nTrial);
  idxIso = idxIso | removeTrials_Isolation(unitData.TrialRemoveSAT{iY}, nTrial);
  %index by condition
  idxAcc = ((behavData.Condition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Condition{kk} == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Correct{kk};
  
  %% Compute spike density function and align to epochs of interest
  spikes_X = load_spikes_SAT(iX);
  spikes_Y = load_spikes_SAT(iY);
  sdfX.VR = compute_SDF_SAT(spikes_X);
  sdfY.VR = compute_SDF_SAT(spikes_Y);
  sdfX.PS = align_signal_on_response(sdfX.VR, RT_P); 
  sdfY.PS = align_signal_on_response(sdfY.VR, RT_P); 
  
  %% Compute mean FR by direction
  nDir = 8;
  sdfX_Acc  = struct('VR',NaN(nSamp,nDir), 'PS',NaN(nSamp,nDir));
  epoch = fieldnames(sdfX_Acc);
  sdfX_Fast = sdfX_Acc;
  sdfY_Acc  = sdfX_Acc;
  sdfY_Fast = sdfX_Acc;
  for ep = 1:2 %epoch
    for dd = 1:nDir %direction
      idxDir = (behavData.Sacc_Octant{kk} == dd);
      sdfX_Acc.(epoch{ep})(:,dd)  = mean(sdfX.(epoch{ep})(idxAcc  & idxCorr & idxDir, iWin.(epoch{ep})),'omitnan');
      sdfX_Fast.(epoch{ep})(:,dd) = mean(sdfX.(epoch{ep})(idxFast & idxCorr & idxDir, iWin.(epoch{ep})),'omitnan');
      sdfY_Acc.(epoch{ep})(:,dd)  = mean(sdfY.(epoch{ep})(idxAcc  & idxCorr & idxDir, iWin.(epoch{ep})),'omitnan');
      sdfY_Fast.(epoch{ep})(:,dd) = mean(sdfY.(epoch{ep})(idxFast & idxCorr & idxDir, iWin.(epoch{ep})),'omitnan');
    end % for : direction (dd)
  end % for : epoch (ep)
  
  %% Plotting
  nRow = 3;
  nCol = 13;
  margin = [0.08,0.015]; %margins between subplots
  idxPlot_X.VR = [18 5 3 1 14 27 29 31 16];
  idxPlot_X.PS = [19 6 4 2 15 28 30 32 17];
  idxPlot_Y.VR = [25 12 10 8 21 34 36 38 23];
  idxPlot_Y.PS = [26 13 11 9 22 35 37 39 24];
  hFig = figure('visible','on');
  yLim_X = [0, max([sdfX_Acc.VR; sdfX_Fast.VR; sdfX_Acc.PS; sdfX_Fast.PS],[],'all')];
  yLim_Y = [0, max([sdfY_Acc.VR; sdfY_Fast.VR; sdfY_Acc.PS; sdfY_Fast.PS],[],'all')];
  xLim = tWin.VR([1,nSamp]);
  
  %% Neuron X (SEF)
  h_ax_X = cell(nDir+1,2);
  for ep = 1:2 %epoch
    for dd = 1:nDir %direction
      h_ax_X{dd,ep} = subplot_tight(nRow,nCol, idxPlot_X.(epoch{ep})(dd)+0.2, margin);
      plot([0 0], yLim_X, 'k:'); hold on
      plot(tWin.(epoch{ep}), sdfX_Acc.(epoch{ep})(:,dd), 'r-');
      plot(tWin.(epoch{ep}), sdfX_Fast.(epoch{ep})(:,dd), '-', 'Color',[0 .7 0]);
      xlim(xLim)

      if (dd == 6) %bottom left
        if (ep == 1)
          ylabel('Activity (sp/sec)')
          xlabel('Time from array (ms)')
          print_session_unit(gca, unitData.ID(iX), unitData.Area(iX), 'horizontal')
        elseif (ep == 2)
          xlabel('Time from saccade (ms)')
        end
      else
        xticklabels([])
        yticklabels([])
      end
    end % for : direction (dd)
  end % for : epoch (ep)
  
  %% Neuron Y (FEF/SC)
  h_ax_Y = cell(nDir+1,2);
  for ep = 1:2 %epoch
    for dd = 1:nDir %loop over directions and plot
      h_ax_Y{dd,ep} = subplot_tight(nRow,nCol, idxPlot_Y.(epoch{ep})(dd)-0.2, margin);
      plot([0 0], yLim_Y, 'k:'); hold on
      plot(tWin.(epoch{ep}), sdfY_Acc.(epoch{ep})(:,dd), 'r-');
      plot(tWin.(epoch{ep}), sdfY_Fast.(epoch{ep})(:,dd), '-', 'Color',[0 .7 0]);
      xlim(xLim)

      if (dd == 6) %bottom left
        if (ep == 1)
          ylabel('Activity (sp/sec)')
          xlabel('Time from array (ms)')
          print_session_unit(gca, unitData.ID(iY), unitData.Area(iY), 'horizontal')
        elseif (ep == 2)
          xlabel('Time from saccade (ms)')
        end
      else
        xticklabels([])
        yticklabels([])
      end
    end % for : direction (dd)
  end % for : epoch (ep)
  
  ppretty([18,4], 'YColor','none')
  set(h_ax_X{6,1}, 'YColor','k')
  set(h_ax_Y{6,1}, 'YColor','k')
  
%   fname = [pairTest.Pair_UID{pp},'-',pairTest.Session{pp},'-',pairTest.X_Area{pp},'-',pairTest.Y_Area{pp}];
%   print([PRINTDIR,fname,'.tif'], '-dtiff'); pause(0.1); close(hFig); pause(0.1)
end % for : pair(pp)

clearvars -except behavData unitData pairData spkCorr ROOTDIR*
