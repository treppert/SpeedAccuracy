% plot_SDF_SAT.m
% 
% ROOTDIR_SAT = 'C:\Users\thoma\Dropbox\SAT-Local\';
% load([ROOTDIR_SAT, 'behavData.mat'])
% load([ROOTDIR_SAT, 'unitData.mat'])
% load([ROOTDIR_SAT, 'pairData.mat'])
% load([ROOTDIR_SAT, 'spkCorr.mat'])

idx_Sess = ismember(unitData.SessionID, 34:49);
idx_Area = ismember(unitData.Area, {'FEF'});
% idx_Fxn = ~(unitData.FxnType == "None");

unitTest = unitData( idx_Sess & idx_Area , : );
nUnit = size(unitTest,1);

EPOCH = {'VR' 'PS' 'REW'}; %within-trial time intervals of interest
nEpoch = 3;

tWin.VR.Acc  = (-1000 : +400);   nSamp.VR.Acc   = length(tWin.VR.Acc);
tWin.VR.Fast = (-1000 : +200);   nSamp.VR.Fast  = length(tWin.VR.Fast);
tWin.PS.Acc = (-200 : +400);    nSamp.PS.Acc   = length(tWin.PS.Acc);
tWin.PS.Fast = (-100 : +400);   nSamp.PS.Fast  = length(tWin.PS.Fast);
tWin.REW.Acc  = (-300 : +1100);  nSamp.REW.Acc  = length(tWin.REW.Acc);
tWin.REW.Fast = (-300 : +1100);  nSamp.REW.Fast = length(tWin.REW.Fast);

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
  idxIso = removeTrials_Isolation(unitTest.isoSAT{uu}, nTrial);
  %index by condition
  idxAcc = ((behavData.Condition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Condition{kk} == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Correct{kk};
  
  %% Compute spike density function and align to epochs of interest
  spikes = load_spikes_SAT(unitTest.Unit(uu), 'task','Search'); %load spike times
  sdf.VR = compute_SDF_SAT(spikes);
  sdf.PS = align_signal_on_response(sdf.VR, tResp);
  sdf.REW = align_signal_on_response(sdf.VR, tResp+tRew);
  
  %% Compute mean FR by direction
  sdfAcc  = struct('VR',NaN(nSamp.VR.Acc,1),  'PS',NaN(nSamp.PS.Acc,1),  'REW',NaN(nSamp.REW.Acc,1));
  sdfFast = struct('VR',NaN(nSamp.VR.Fast,1), 'PS',NaN(nSamp.PS.Fast,1), 'REW',NaN(nSamp.REW.Fast,1));
  for ep = 1:nEpoch
    sdfAcc.(EPOCH{ep})(:)  = mean(sdf.(EPOCH{ep})(idxAcc  & idxCorr, 3500+tWin.(EPOCH{ep}).Acc),'omitnan');
    sdfFast.(EPOCH{ep})(:) = mean(sdf.(EPOCH{ep})(idxFast  & idxCorr, 3500+tWin.(EPOCH{ep}).Fast),'omitnan');
  end % for : epoch (ep)
  
  %% Plotting
  PRINTDIR = 'C:\Users\thoma\Dropbox\SAT-Local\';
  colorArea = colororder; %colors for shaded areas of interest
  colorArea = colorArea(2:4,:);
  xArea = { [+50 +150] , [-50 +50] , [-50 +50] };
  yLim = [0, max([sdfAcc.VR ; sdfFast.VR ; sdfAcc.PS ; sdfFast.PS ; sdfAcc.REW ; sdfFast.REW],[],'all')];

  hFig = figure('visible','off');
  posAxis = {[1 2] , 3 , [4 5]}; %relative widths of axes
  hAxis = cell(nEpoch,1);

  for ep = 1:nEpoch %epoch
    hAxis{ep} = subplot(1,5, posAxis{ep}); hold on
    plot([0 0], yLim, 'k-', 'LineWidth',0.75)
    area(xArea{ep}, [yLim(2) yLim(2)], 'EdgeColor','none', 'FaceColor',colorArea(ep,:), 'FaceAlpha',0.2)

    plot(tWin.(EPOCH{ep}).Fast, sdfFast.(EPOCH{ep}), '-', 'Color',[0 .7 0], 'LineWidth',1.6);
    plot(tWin.(EPOCH{ep}).Acc,  sdfAcc.(EPOCH{ep}),  '-', 'Color','r', 'LineWidth',1.4);
    xlim(tWin.(EPOCH{ep}).Acc([1,end]))

    switch (ep)
      case 1 %Baseline / VR
        ylabel('Activity (sp/sec)')
        xlabel('Time from array (ms)')
      case 2 %Peri-saccade
        title(unitTest.ID(uu))
        xlabel('Time from saccade (ms)')
      case 3 %Reward
        xlabel('Time from reward (ms)')
    end

  end % for : epoch (ep)
  
  ppretty([12,4], 'YColor','none'); drawnow
  set(hAxis{1}, 'YColor','k')
  set(hAxis{2}, 'FontSize',10)
  
  print(PRINTDIR + unitTest.ID(uu) + ".tif", '-dtiff'); close(hFig)
end % for : unit(uu)

clearvars -except behavData* unitData pairData ROOTDIR* hAxis*
