% plot_SDF_X_Dir() This script plots activity of single neurons as a
% function of target location (8 octants).
% 

PRINTDIR = 'C:\Users\thoma\Dropbox\SAT-Local\Figures\';

idx_Sess = ismember(unitData.SessionID, 1:16);
idx_Area = ismember(unitData.Area, {'SEF'});

unitTest = unitData( idx_Sess & idx_Area , : );
nUnit = size(unitTest,1);

EPOCH = {'VR' 'PS' 'REW'}; %within-trial time intervals of interest
nEpoch = 3;
nDir = 8;

%initialize time windows
tWin.VR.MG   = (-300 : +500);  tWin.VR.Acc  = (-200 : +400);  tWin.VR.Fast  = (-200 : +200);
tWin.PS.MG   = (-400 : +400);  tWin.PS.Acc  = (-200 : +400);  tWin.PS.Fast  = (-100 : +400);
tWin.REW.MG  = (-400 : +400);  tWin.REW.Acc = (-300 : +300);  tWin.REW.Fast = (-300 : +300);

%initialize sample counts
for ep = 1:nEpoch
  nSamp.(EPOCH{ep}).MG   = length(tWin.(EPOCH{ep}).MG);
  nSamp.(EPOCH{ep}).Acc  = length(tWin.(EPOCH{ep}).Acc);
  nSamp.(EPOCH{ep}).Fast = length(tWin.(EPOCH{ep}).Fast);
end

for uu = 1:nUnit
  fprintf('%s \n', unitTest.ID{uu})
  kk = unitTest.SessionID(uu); %get session number

  nTrial_MG  = behavDataMG.NumTrials(kk); %number of trials
  nTrial_SAT = behavData.NumTrials(kk);

  tResp_MG  = behavDataMG.Sacc_RT{kk}; %primary saccade RT
  tResp_SAT = behavData.Sacc_RT{kk};

  if ismember(unitTest.Monkey(uu), {'Q','S'})
    tRew_MG = 900;  %estimate (re saccade)
    tRew_SAT = 700;
  else %{'D','E'}
    tRew_MG  = behavDataMG.RewTime(kk); %time of reward delivery (re saccade)
    tRew_SAT = behavData.RewTime(kk);
  end
  
  %index by isolation quality
  idxIsoMG  = removeTrials_Isolation(unitTest.isoMG{uu}, nTrial_MG);
  idxIsoSAT = removeTrials_Isolation(unitTest.isoSAT{uu}, nTrial_SAT);

  %index by trial outcome
  idxCorrMG  = ~(behavDataMG.ErrChoice{kk} | behavDataMG.ErrHold{kk} | behavDataMG.ErrNoSacc{kk} | idxIsoMG);
  idxCorrSAT = behavData.Correct{kk};
  
  %index by condition (SAT)
  idxAcc = ((behavData.Condition{kk} == 1) & ~idxIsoSAT);
  idxFast = ((behavData.Condition{kk} == 3) & ~idxIsoSAT);
  idxNeut = ((behavData.Condition{kk} == 2) & ~idxIsoSAT);

  %% Compute spike density function and align to epochs of interest
  spikesMG  = load_spikes_SAT(unitTest.Unit(uu), 'task','MG');
  spikesSAT = load_spikes_SAT(unitTest.Unit(uu), 'task','Search');

  sdfMG.VR  = compute_SDF_SAT(spikesMG);
  sdfMG.PS  = align_signal_on_response(sdfMG.VR, tResp_MG);
  sdfMG.REW = align_signal_on_response(sdfMG.VR, tResp_MG + tRew_MG);
  
  sdfSAT.VR  = compute_SDF_SAT(spikesSAT);
  sdfSAT.PS  = align_signal_on_response(sdfSAT.VR, tResp_SAT);
  sdfSAT.REW = align_signal_on_response(sdfSAT.VR, tResp_SAT + tRew_SAT);
  
  %% Compute mean SDF by direction
  sdfMGCorr = struct('VR',NaN(nSamp.VR.MG,nDir+1),  'PS',NaN(nSamp.PS.MG,nDir+1),   'REW',NaN(nSamp.REW.MG,nDir+1));
  sdfAcc   = struct('VR',NaN(nSamp.VR.Acc,nDir+1),  'PS',NaN(nSamp.PS.Acc,nDir+1),  'REW',NaN(nSamp.REW.Acc,nDir+1));
  sdfFast  = struct('VR',NaN(nSamp.VR.Fast,nDir+1), 'PS',NaN(nSamp.PS.Fast,nDir+1), 'REW',NaN(nSamp.REW.Acc,nDir+1));

  for ep = 1:nEpoch
    for dd = 1:nDir
      idxDirMG = (behavDataMG.Sacc_Octant{kk} == dd);
      idxDirSAT = (behavData.Sacc_Octant{kk} == dd);
      sdfMGCorr.(EPOCH{ep})(:,dd) = mean(sdfMG.(EPOCH{ep})(idxCorrMG & idxDirMG, 3500+tWin.(EPOCH{ep}).MG),'omitnan');
      sdfAcc.(EPOCH{ep})(:,dd)    = mean(sdfSAT.(EPOCH{ep})(idxAcc  & idxCorrSAT & idxDirSAT, 3500+tWin.(EPOCH{ep}).Acc),'omitnan');
      sdfFast.(EPOCH{ep})(:,dd)   = mean(sdfSAT.(EPOCH{ep})(idxFast & idxCorrSAT & idxDirSAT, 3500+tWin.(EPOCH{ep}).Fast),'omitnan');
    end % for : direction (dd)

    %across all directions
    sdfMGCorr.(EPOCH{ep})(:,nDir+1) = mean(sdfMG.(EPOCH{ep})(idxCorrMG, 3500+tWin.(EPOCH{ep}).MG),'omitnan');
    sdfAcc.(EPOCH{ep})(:,nDir+1)  = mean(sdfSAT.(EPOCH{ep})(idxAcc  & idxCorrSAT, 3500+tWin.(EPOCH{ep}).Acc),'omitnan');
    sdfFast.(EPOCH{ep})(:,nDir+1) = mean(sdfSAT.(EPOCH{ep})(idxFast  & idxCorrSAT, 3500+tWin.(EPOCH{ep}).Fast),'omitnan');

  end % for : epoch (ep)
  
  %% Plotting
  MARGIN = [0.08,0.02]; %margin between subplots

  xArea = { [+50 +250] , [-100 +100] , [-100 +100] }; % [VR,PS,REW]
  colorArea = colororder; %colors for shaded areas of interest
  colorArea = colorArea(2:4,:);

  idxPlotMG  = [16 7 4 1 10 19 22 25 13]; %index for VR epoch
  idxPlotSAT = idxPlotMG + 27;

  yLimMG  = [0, max([sdfMGCorr.VR ; sdfMGCorr.PS ; sdfMGCorr.REW],[],'all')];
  yLimSAT = [0, max([sdfAcc.VR ; sdfFast.VR ; sdfAcc.PS ; sdfFast.PS ; sdfAcc.REW ; sdfFast.REW],[],'all')];

  hFig = figure("Visible","off");

  hAxisMG  = cell(nDir+1,nEpoch);
  hAxisSAT = hAxisMG;

  for ep = 1:nEpoch %epoch
    for dd = 1:nDir+1 %direction

      %% Plotting - MG
      hAxisMG{dd,ep} = subplot_tight(6,9, idxPlotMG(dd)+(ep-1), MARGIN);
      plot([0 0], yLimMG, 'k:'); hold on
      plot(tWin.(EPOCH{ep}).MG,  sdfMGCorr.(EPOCH{ep})(:,dd),  '-', 'Color','k');
      area(xArea{ep}, [yLimMG(2) yLimMG(2)], 'EdgeColor','none', 'FaceColor',colorArea(ep,:), 'FaceAlpha',0.2)
      xlim(tWin.(EPOCH{ep}).MG([1,end]))

      if (dd == 6) %bottom left
        if (ep == 2); title(unitTest.ID(uu) + "-MG"); end
      else
        xticklabels([]); yticklabels([])
      end

      %% Plotting - SAT
      hAxisSAT{dd,ep} = subplot_tight(6,9, idxPlotSAT(dd)+(ep-1), MARGIN);
      plot([0 0], yLimSAT, 'k:'); hold on
      plot(tWin.(EPOCH{ep}).Acc,  sdfAcc.(EPOCH{ep})(:,dd),  '-', 'Color','r');
      plot(tWin.(EPOCH{ep}).Fast, sdfFast.(EPOCH{ep})(:,dd), '-', 'Color',[0 .7 0]);
      area(xArea{ep}, [yLimSAT(2) yLimSAT(2)], 'EdgeColor','none', 'FaceColor',colorArea(ep,:), 'FaceAlpha',0.2)
      xlim(tWin.(EPOCH{ep}).Acc([1,end]))

      if (dd == 6) %bottom left
        if (ep == 1)
          xlabel('Time from array (ms)'); ylabel('Activity (sp/sec)')
        elseif (ep == 2)
          title(unitTest.ID(uu) + "-SAT")
          xlabel('Time from saccade (ms)')
        elseif (ep == 3)
          xlabel('Time from reward (ms)')
        end
      else %not bottom left
        xticklabels([]); yticklabels([])
      end

    end % for : direction (dd)

  end % for : epoch (ep)
  
  ppretty([12,7], 'YColor','none'); drawnow
  set(hAxisMG{6,1},  'YColor','k')
  set(hAxisSAT{6,1}, 'YColor','k')
  
  print(PRINTDIR + unitTest.ID(uu) + "-SAT.tif", '-dtiff'); close(hFig)
end % for : unit(uu)

clearvars -except behavData* unitData* pairData* ROOTDIR*
