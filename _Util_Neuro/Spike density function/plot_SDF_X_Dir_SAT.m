%plot_SDF_X_Dir_SAT() This script plots activity of single neurons recorded
%during the SAT visual search task. Activity is plotted as a function of
%target location (8 octants).
% 
% ROOTDIR_SAT = 'C:\Users\thoma\Dropbox\SAT-Local\';
% load([ROOTDIR_SAT, 'behavData.mat'])
% load([ROOTDIR_SAT, 'unitData.mat'])
% load([ROOTDIR_SAT, 'pairData.mat'])
% load([ROOTDIR_SAT, 'spkCorr.mat'])

idx_Sess = ismember(unitData.SessionID, 1:49);
idx_Area = ismember(unitData.Area, {'SC'});
% idx_Fxn = ~(unitData.FxnType == "None");

unitTest = unitData( idx_Sess & idx_Area , : );
nUnit = size(unitTest,1);

EPOCH = {'VR' 'PS' 'REW'}; %within-trial time intervals of interest
nEpoch = 3;
tWin.VR.Acc  = (-200 : +400);   nSamp.VR.Acc   = length(tWin.VR.Acc);
tWin.VR.Fast = (-200 : +200);   nSamp.VR.Fast  = length(tWin.VR.Fast);
tWin.PS.Acc = (-200 : +400);    nSamp.PS.Acc   = length(tWin.PS.Acc);
tWin.PS.Fast = (-100 : +400);   nSamp.PS.Fast  = length(tWin.PS.Fast);
tWin.REW.Acc  = (-300 : +300);  nSamp.REW.Acc  = length(tWin.REW.Acc);
tWin.REW.Fast = (-300 : +300);  nSamp.REW.Fast = length(tWin.REW.Fast);

nDir = 8;

for uu = 1:nUnit
  fprintf('%s \n', unitTest.ID{uu})
  kk = unitTest.SessionID(uu); %get session number

  nTrial = behavData.NumTrials(kk); %number of trials
  tResp = behavData.Sacc_RT{kk}; %primary saccade RT

  if ismember(unitTest.Monkey(uu), {'Q','S'})
    tRew = 700; %rough estimate (re saccade)
  else %{'D','E'}
    tRew = behavData.RewTime(kk); %time of reward delivery (re saccade)
  end
  
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitTest.TrialRemoveSAT{uu}, nTrial);
  %index by condition
  idxAcc = ((behavData.Condition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Condition{kk} == 3) & ~idxIso);
  idxNeut = ((behavData.Condition{kk} == 2) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Correct{kk};
  
  %% Compute spike density function and align to epochs of interest
  spikes = load_spikes_SAT(unitTest.Index(uu)); %load spike times
  sdf.VR = compute_SDF_SAT(spikes);
  sdf.PS = align_signal_on_response(sdf.VR, tResp);
  sdf.REW = align_signal_on_response(sdf.VR, tResp+tRew);
  
  %% Compute mean FR by direction
  sdfAcc  = struct('VR',NaN(nSamp.VR.Acc,nDir+1),  'PS',NaN(nSamp.PS.Acc,nDir+1),  'REW',NaN(nSamp.REW.Acc,nDir+1));
  sdfFast = struct('VR',NaN(nSamp.VR.Fast,nDir+1), 'PS',NaN(nSamp.PS.Fast,nDir+1), 'REW',NaN(nSamp.REW.Acc,nDir+1));
  sdfNeut = sdfFast;
  for ep = 1:nEpoch
    for dd = 1:nDir
      idxDir = (behavData.Sacc_Octant{kk} == dd);
      sdfAcc.(EPOCH{ep})(:,dd)  = mean(sdf.(EPOCH{ep})(idxAcc  & idxCorr & idxDir, 3500+tWin.(EPOCH{ep}).Acc),'omitnan');
      sdfFast.(EPOCH{ep})(:,dd) = mean(sdf.(EPOCH{ep})(idxFast & idxCorr & idxDir, 3500+tWin.(EPOCH{ep}).Fast),'omitnan');
      sdfNeut.(EPOCH{ep})(:,dd) = mean(sdf.(EPOCH{ep})(idxNeut & idxCorr & idxDir, 3500+tWin.(EPOCH{ep}).Fast),'omitnan');
    end % for : direction (dd)
    sdfAcc.(EPOCH{ep})(:,nDir+1)  = mean(sdf.(EPOCH{ep})(idxAcc  & idxCorr, 3500+tWin.(EPOCH{ep}).Acc),'omitnan'); %across all directions
    sdfFast.(EPOCH{ep})(:,nDir+1) = mean(sdf.(EPOCH{ep})(idxFast  & idxCorr, 3500+tWin.(EPOCH{ep}).Fast),'omitnan');
    sdfNeut.(EPOCH{ep})(:,nDir+1) = mean(sdf.(EPOCH{ep})(idxNeut  & idxCorr, 3500+tWin.(EPOCH{ep}).Fast),'omitnan');
  end % for : epoch (ep)
  
  %% Plotting
  PRINTDIR = 'C:\Users\thoma\Dropbox\SAT-Local\Figs - SDF X Dir - SAT\';
  colorArea = colororder; %colors for shaded areas of interest
  colorArea = colorArea(2:4,:);
  xArea = { [+50 +250] , [0 +200] , [0 +200] };
  MARGIN = [0.08,0.02]; %margin between subplots
  idxPlot = [16 7 4 1 10 19 22 25 13]; %indexes for visual response epoch
  yLim = [0, max([sdfAcc.VR ; sdfFast.VR ; sdfAcc.PS ; sdfFast.PS ; sdfAcc.REW ; sdfFast.REW],[],'all')];
  hFig = figure('visible','off');
  
  h_ax = cell(nDir+1,nEpoch);
  for ep = 1:nEpoch %epoch
    for dd = 1:nDir+1 %direction
      h_ax{dd,ep} = subplot_tight(3,9, idxPlot(dd)+(ep-1), MARGIN);
      plot([0 0], yLim, 'k:'); hold on
      plot(tWin.(EPOCH{ep}).Fast, sdfNeut.(EPOCH{ep})(:,dd), 'k-');
      plot(tWin.(EPOCH{ep}).Acc, sdfAcc.(EPOCH{ep})(:,dd), 'r-');
      plot(tWin.(EPOCH{ep}).Fast, sdfFast.(EPOCH{ep})(:,dd), '-', 'Color',[0 .7 0]);
      area(xArea{ep}, [yLim(2) yLim(2)], 'EdgeColor','none', 'FaceColor',colorArea(ep,:), 'FaceAlpha',0.2)
      xlim(tWin.(EPOCH{ep}).Acc([1,end]))

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
