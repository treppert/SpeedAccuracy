% plot_SpikeCount_Polar_SAT.m
% This script plots spike count by target direction for specified recording
% session(s) of interest. Data for all neurons recorded in that session are
% plotted in the same file. These plots show differences in activation for
% the memory-guided (MG) and visual search (SAT) tasks. Some neurons fired
% much more for MG, with others firing much more for SAT of search.
% 
% Polar snapshots of spike counts are plotted for four epochs:
% 1. Baseline (pre-array)
% 2. Visual response (post-array)
% 3. Peri-saccade
% 4. Peri-reward
% 

PRINTDIR = "C:\Users\thoma\Dropbox\SAT-Local\";
VECDIR = deg2rad(linspace(0, 360, 9));
EPOCH = {'BL [-300,-200]','VR [+50,+150]','PS [-50,+50]','PR [-50,+50]'};
nEpoch = 4;

for kk = 49:49
  fprintf('%s \n', behavData.Session{kk})

  %index units by session, area, etc.
  idx_Sess = ismember(unitData.SessionID, kk);
  idx_Area = ismember(unitData.Area, {'FEF'});
  
  unitTest = unitData( idx_Area & idx_Sess , : );
  nUnit = size(unitTest,1);
  
  hFig = figure("Visible","off");
  
  for uu = 1:nUnit
    fprintf('%s \n', unitTest.ID{uu})
  
    %% Compute spike count X condition X direction
    [scAcc, scFast] = computeSpikeCount_Search(unitTest(uu,:), behavData(kk,:));
    scAcc  = cat(1, scAcc,  scAcc(1,:)); %complete the circle for plotting
    scFast = cat(1, scFast, scFast(1,:));
    
    scMG = computeSpikeCount_MG(unitTest(uu,:), behavDataMG(kk,:));
    scMG = cat(1, scMG, scMG(1,:));
  
    %% Plotting
    MARKERSIZE = 15;
    rLim = ceil(max([scFast scAcc scMG],[],'all'));
  
    for ep = 1:4
      iPlot = nEpoch*(uu-1) + ep;
      subplot(nUnit,nEpoch,iPlot, polaraxes); hold on;

      polarplot(VECDIR, scMG(:,ep),   '.-', 'Color',[.2 .2 .2], 'MarkerSize',MARKERSIZE);
      polarplot(VECDIR, scFast(:,ep), '.-', 'Color',[0 .7 0], 'MarkerSize',MARKERSIZE);
      polarplot(VECDIR, scAcc(:,ep),  '.-', 'Color','r',   'MarkerSize',MARKERSIZE);

      rlim([0 rLim]); thetaticks([])
      if (ep > 1); rticklabels([]); end
      if (uu == nUnit); text(deg2rad(245), 1.2*rLim, EPOCH{ep}); end

    end % for : epoch (ep)
  
    title(unitTest.ID(uu))
  
  end % for : unit (uu)
  
  text(deg2rad(45), 1.1*rLim, 'spike count')
  ppretty([10,2*nUnit]); drawnow
  print(PRINTDIR + behavData.Session(kk) + ".tif", '-dtiff'); close(hFig)

end % for : session (sess)

clearvars -except ROOTDIR* behavData* unitData* pairData* *Noise* *Signal*
