% function [ ] = plot_SignalCorr_SAT( )
%plot_SignalCorr_SAT This function plots the relationship between
%signal-related activation of two neurons for the SAT data set. It provides
%a look at the change in activation across all 8 directions separately for
%each neuron, and a combined look at the paired activation for each
%direction.
%   Detailed explanation goes here

PRINTDIR = 'C:\Users\thoma\Documents\Figs - SAT\';

idx_Sess = (pairData.SessionID == 12);
idx_Monk = ismember(pairData.Monkey, {'D','E'});
idx_YArea = ismember(pairData.Y_Area, 'SC');
idx_XFxn  = ismember(pairData.X_FxnType, {'V','VC','VT','VCT'});
idx_YFxn  = ismember(pairData.Y_FxnType, {'V','VM','M'});

pairTest = pairData( idx_Sess & idx_Monk & idx_YArea & idx_YFxn & idx_XFxn , : );
nPair = size(pairTest,1);

for pp = 1:nPair
  iX = pairTest.X_Index(pp); %get index for unitData (X=SEF)
  iY = pairTest.Y_Index(pp); %(Y=FEF/SC)
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
  print([PRINTDIR, 'Polar-Pair-',char(unitData.ID(iY)),'-',char(unitData.ID(iX)),'.tif'], '-dtiff'); close(hFig)
  
  %% Figure - Cartesian plots
  GREEN = [0 0.7 0];
  hFig = figure();
  ANGLE = 0:45:360;

  RData_SEF_Fast = [pplotX{1}(1).RData pplotX{1}(2).RData pplotX{1}(3).RData pplotX{1}(4).RData];
  RData_SEF_Acc  = [pplotX{2}(1).RData pplotX{2}(2).RData pplotX{2}(3).RData pplotX{2}(4).RData];
  RData_SEF = [RData_SEF_Fast RData_SEF_Acc];
  RData_SC_Fast =  [pplotY{1}(1).RData pplotY{1}(2).RData pplotY{1}(3).RData pplotY{1}(4).RData];
  RData_SC_Acc  =  [pplotY{2}(1).RData pplotY{2}(2).RData pplotY{2}(3).RData pplotY{2}(4).RData];
  RData_SC = [RData_SC_Fast RData_SC_Acc];

  rangeSEF = [min(RData_SEF,[],'all') max(RData_SEF,[],'all')];
  rangeSC  = [min(RData_SC,[],'all')  max(RData_SC,[],'all')];
  rangeAll = [min([RData_SEF RData_SC]) max([RData_SEF RData_SC])];

  for ep = 1:4
    %% Activation by location
    hplotAct = subplot(2,4,ep); hold on %activation vs direction
    plot(ANGLE,pplotX{1}(ep).RData, '.-', 'Color',GREEN)
    plot(ANGLE,pplotX{2}(ep).RData, '.-', 'Color','r')
    plot(ANGLE,pplotY{1}(ep).RData, '.:', 'Color',GREEN)
    plot(ANGLE,pplotY{2}(ep).RData, '.:', 'Color','r')
    xticks(ANGLE(1:2:end))
    xlim([-5 365])

    %labels
    if (ep == 1)
      xlabel('Target location (deg)')
      ylabel('Spike count')
      title('Baseline')
      X_Area = string(pairTest.X_Area(pp));
      Y_Area = string(pairTest.Y_Area(pp));
      legend([X_Area,X_Area,Y_Area,Y_Area])
    elseif (ep == 2)
      title('Visual response')
    elseif (ep == 3)
      title('Post-saccade')
    elseif (ep == 4)
      title('Post-reward')
    end

    %% Scatter
    hplotCorr = subplot(2,4,ep+4); hold on %signal correlation
    scatter(pplotX{1}(ep).RData,pplotY{1}(ep).RData, 20,GREEN,'filled', 'MarkerFaceAlpha',0.5)
    scatter(pplotX{2}(ep).RData,pplotY{2}(ep).RData, 20,'r','filled', 'MarkerFaceAlpha',0.5)
    
    %labels
    if (ep == 1)
      xlabel('Spike count SEF')
      ylabel('Spike count FEF/SC')
    end
  end % for : epoch (ep)
  
  for ep = 1:4 %set consistent axis limits across subplots
    subplot(2,4,ep); ylim(rangeAll)
    subplot(2,4,ep+4); xlim(rangeSEF); ylim(rangeSC)
    if (ep > 1)
      subplot(2,4,ep); xticks([]); yticks([])
      subplot(2,4,ep+4); xticks([]); yticks([])
    end
  end

  ppretty([10,4]); drawnow
  print([PRINTDIR, 'SignalCorr-',char(unitData.ID(iY)),'-',char(unitData.ID(iX)),'.tif'], '-dtiff'); close(hFig)

end % for : pair (pp)


% end % fxn : plot_SignalCorr_SAT()

clearvars -except behavData unitData pairData spkCorr ROOTDIR*
