% function [ ] = plot_SignalCorr_SAT( )
%plot_SignalCorr_SAT This function plots the relationship between
%signal-related activation of two neurons for the SAT data set. It provides
%a look at the change in activation across all 8 directions separately for
%each neuron, and a combined look at the paired activation for each
%direction.
%   Detailed explanation goes here

idx_Monk = ismember(pairData.Monkey, {'D'});
idx_YArea = ismember(pairData.Y_Area, {'SC'});
idx_XFxn  = ismember(pairData.X_FxnType, {'V','VC','VT','VCT'});
idx_YFxn  = ismember(pairData.Y_FxnType, {'V'});

pairTest = pairData( idx_Monk & idx_YArea & idx_YFxn & idx_XFxn , : );
nPair = 1;%size(pairTest,1);

for pp = 1:nPair
  iX = pairTest.X_Index(pp); %get index for unitData
  iY = pairTest.Y_Index(pp);
  kk = pairTest.SessionID(pp); %get session number

  nTrial = behavData.NumTrials(kk);
  tResp = behavData.Sacc_RT{kk};

  [pplotX,axX] = plotSpkCt_X_Epoch(unitData(iX,:), behavData); drawnow
  [pplotY,axY] = plotSpkCt_X_Epoch(unitData(iY,:), behavData); drawnow
  
  %% Figure - Polar plots
  hFig = figure();
  axtmp = subplot(2,2,1, polaraxes);
  axXFast = copyobj(axX{1}, hFig);
  set(axXFast,'Position', get(axtmp,'Position')); delete(axtmp)

  axtmp = subplot(2,2,2, polaraxes);
  axXAcc = copyobj(axX{2}, hFig);
  set(axXAcc,'Position', get(axtmp,'Position')); delete(axtmp)

  axtmp = subplot(2,2,3, polaraxes);
  axYFast = copyobj(axY{1}, hFig);
  set(axYFast,'Position', get(axtmp,'Position')); delete(axtmp)
  
  axtmp = subplot(2,2,4, polaraxes);
  axYAcc = copyobj(axY{2}, hFig);
  set(axYAcc,'Position', get(axtmp,'Position')); delete(axtmp)
  ppretty([7,6]); drawnow

  %% Figure - Cartesian plots
  GREEN = [0 0.7 0];
  hFig = figure();
  ANGLE = 0:45:360;

  ymaxSEF = 0;
  ymaxFEFSC = 0;
  for ep = 1:4
    hplotAct = subplot(2,4,ep); hold on %activation vs direction
    plot(ANGLE,pplotX{1}(ep).RData, '.-', 'Color',GREEN)
    plot(ANGLE,pplotX{2}(ep).RData, '.-', 'Color','r')
    plot(ANGLE,pplotY{1}(ep).RData, '.:', 'Color',GREEN)
    plot(ANGLE,pplotY{2}(ep).RData, '.:', 'Color','r')
    xticks(ANGLE(1:2:end))
    xlim([-5 365])

    ylimtmp = get(gca, 'YLim');
    if (ylimtmp(2) > ymaxSEF);   ymaxSEF = ylimtmp(2); end
    if (ylimtmp(2) > ymaxFEFSC); ymaxFEFSC = ylimtmp(2); end

    if (ep == 1)
      xlabel('Target location (deg)')
      ylabel('Spike count')
      title('Baseline')
    elseif (ep == 2)
      title('Visual response')
    elseif (ep == 3)
      title('Post-saccade')
    elseif (ep == 4)
      title('Post-reward')
    end

    hplotCorr = subplot(2,4,ep+4); hold on %signal correlation
    scatter(pplotX{1}(ep).RData,pplotY{1}(ep).RData, 20,GREEN,'filled', 'MarkerFaceAlpha',0.5)
    scatter(pplotX{2}(ep).RData,pplotY{2}(ep).RData, 20,'r','filled', 'MarkerFaceAlpha',0.5)

    if (ep == 1)
      xlabel('Spike count SEF')
      ylabel('Spike count FEF/SC')
    end

  end % for : epoch (ep)
  
  for ep = 1:4
    subplot(2,4,ep); ylim([0 ymaxSEF])
    subplot(2,4,ep+4); xlim([0 ymaxSEF]); ylim([0 ymaxFEFSC])
  end
  ppretty([10,4])

end % for : pair (pp)


% end % fxn : plot_SignalCorr_SAT()

clearvars -except behavData unitData pairData spkCorr ROOTDIR*
