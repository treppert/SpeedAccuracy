%plot_SDF_X_Dir_MG() This script plots activity of single neurons recorded
%during the memory-guided saccade task. Activity is plotted as a function of
%target location (8 octants).
% 

idx_Sess = ismember(unitData.SessionID, 1:49);
idx_Area = ismember(unitData.Area, {'SC'});
% idx_Fxn = ~(unitData.FxnType == "None");

unitTest = unitData( idx_Sess & idx_Area , : );
nUnit = size(unitTest,1);

EPOCH = {'VR' 'PS' 'PR'}; %within-trial time intervals of interest
nEpoch = 3;
tWin.VR = (-300 : 500);
tWin.PS = (-400 : 400);
tWin.PR = (-400 : 400);
nSamp = length(tWin.VR);
nDir = 8;

for uu = 1:nUnit
  fprintf('%s \n', unitTest.ID{uu})
  kk = unitTest.SessionID(uu); %get session number

  nTrial = behavDataMG.NumTrials(kk); %number of trials
  tResp = behavDataMG.Sacc_RT{kk}; %primary saccade RT

  if ismember(unitTest.Monkey(uu), {'Q','S'})
    tRew = 900; %rough estimate (re saccade)
  else %{'D','E'}
    tRew = behavDataMG.RewTime{kk}; %time of reward delivery (re saccade)
  end
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitTest.TrialRemoveMG{uu}, nTrial);
  %index by trial outcome
  idxCorr = ~(behavDataMG.ErrChoice{kk} | behavDataMG.ErrHold{kk} | behavDataMG.ErrNoSacc{kk} | idxIso);
  
  %% Compute spike density function and align to epochs of interest
  spikes = load_spikes_SAT(unitTest.Index(uu), 'task','MG'); %load spike times
  sdf.VR = compute_SDF_SAT(spikes);
  sdf.PS = align_signal_on_response(sdf.VR, tResp);
  sdf.PR = align_signal_on_response(sdf.VR, tResp+tRew);
  
  %% Compute mean SDF by direction
  sdf_uu = struct('VR',NaN(nSamp,nDir+1), 'PS',NaN(nSamp,nDir+1), 'PR',NaN(nSamp,nDir+1));
  for ep = 1:nEpoch
    for dd = 1:nDir
      idxDir = (behavDataMG.Sacc_Octant{kk} == dd);
      sdf_uu.(EPOCH{ep})(:,dd) = mean(sdf.(EPOCH{ep})(idxCorr & idxDir, 3500+tWin.(EPOCH{ep})),'omitnan');
    end % for : direction (dd)
    sdf_uu.(EPOCH{ep})(:,nDir+1) = mean(sdf.(EPOCH{ep})(idxCorr, 3500+tWin.(EPOCH{ep})),'omitnan'); %across all directions
  end % for : epoch (ep)
  
  %% Plotting
  PRINTDIR = 'C:\Users\thoma\Dropbox\SAT-Local\Figs - SDF X Dir - MG\';
  colorArea = colororder; %colors for shaded areas of interest
  colorArea = colorArea(2:4,:);
  xArea = { [+50 +250] , [0 +200] , [0 +200] };
  MARGIN = [0.08,0.02]; %margin between subplots
  idxPlot = [16 7 4 1 10 19 22 25 13]; %indexes for visual response epoch
  yLim = [0, max([sdf_uu.VR sdf_uu.PS sdf_uu.PR],[],'all')];
  hFig = figure('visible','off');
  
  h_ax = cell(nDir+1,nEpoch);
  for ep = 1:nEpoch %epoch
    for dd = 1:nDir+1 %direction
      h_ax{dd,ep} = subplot_tight(3,9, idxPlot(dd)+(ep-1), MARGIN);
      plot([0 0], yLim, 'k:'); hold on
      plot(tWin.(EPOCH{ep}), sdf_uu.(EPOCH{ep})(:,dd), 'k-');
      area(xArea{ep}, [yLim(2) yLim(2)], 'EdgeColor','none', 'FaceColor',colorArea(ep,:), 'FaceAlpha',0.2)
      xlim(tWin.(EPOCH{ep})([1,end]))

      if (dd == 6) %bottom left
        if (ep == 1)
          ylabel('Activity (sp/sec)')
          xlabel('Time from array (ms)')
        elseif (ep == 2)
          title(unitTest.ID(uu))
          xlabel('Time from saccade (ms)')
        elseif (ep == 3)
          xlabel('Time from reward (ms)')
        end
      else
        xticklabels([])
        yticklabels([])
      end
    end % for : direction (dd)
  end % for : epoch (ep)
  
  ppretty([12,4], 'YColor','none'); drawnow
  set(h_ax{6,1}, 'YColor','k')
  
  print(PRINTDIR + unitTest.ID(uu) + ".tif", '-dtiff'); close(hFig)
end % for : unit(uu)

clearvars -except behavData* unitData pairData ROOTDIR*
