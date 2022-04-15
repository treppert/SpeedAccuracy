% function [  ] = plot_SDF_X_Dir_RF_ErrChoice( behavData , unitData , spikesSAT )
%plot_SDF_X_Dir_RF_ErrChoice() Summary of this function goes here
%   Detailed explanation goes here

PLOT = true;
FIG_VISIBILITY = 'off';
RT_MAX = 900; %hard ceiling on primary RT
PRINTDIR = 'C:\Users\Thomas Reppert\Documents\Figs - SAT\';

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});
idxFunction = (unitData.Grade_Err == 1);
idxKeep = (idxArea & idxMonkey & idxFunction);

NUM_UNIT = sum(idxKeep);
unitTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

OFFSET_PRE  = 300;
OFFSET_POST = 600;
tPlot = 3500 + (-OFFSET_PRE : OFFSET_POST); %plot time vector
NUM_SAMP = length(tPlot);

tSig_Fast = NaN(NUM_UNIT,1); %error signal onset
tSig_Acc  = tSig_Fast;

for uu = 1:NUM_UNIT
  fprintf('%s \n', unitTest.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitTest.Task_Session(uu));
  
  RT_P = behavData.Sacc_RT{kk}; %Primary saccade RT
  RT_P(RT_P > RT_MAX) = NaN; %hard limit on primary RT
  RT_S = behavData.Sacc2_RT{kk}; %Second saccade RT
  RT_S(RT_S == 0) = NaN;
  ISI = RT_S - RT_P; %Inter-saccade interval
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitTest.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  idxErr = (behavData.Task_ErrChoice{kk} & ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  %index by saccade octant re. response field (RF)
  Octant_Sacc1 = behavData.Sacc_Octant{kk};
  Octant_Sacc2 = behavData.Sacc2_Octant{kk};
  idxRFP  = ismember(Octant_Sacc1, unitTest.RF{uu}); %primary saccade into RF
  idxRFS  = ismember(Octant_Sacc2, unitTest.RF{uu}); %second saccade into RF
  idxRFPn = (~idxRFP & (Octant_Sacc1 ~= 0)); %primary saccade NOT into RF
  idxRFSn = (~idxRFS & (Octant_Sacc2 ~= 0)); %second saccade NOT into RF
  
  %combine indexing
  idxAC = (idxAcc & idxCorr);    idxAE = (idxAcc & idxErr);
  idxFC = (idxFast & idxCorr);   idxFE = (idxFast & idxErr);
  
  %set "ISI" of correct trials as median ISI of error trials
  isiAE = ISI(idxAE);   medISI_AE = round(nanmedian(isiAE));
  isiFE = ISI(idxFE);   medISI_FE = round(nanmedian(isiFE));
  RT_S(idxAC) = RT_P(idxAC) + medISI_AE;
  RT_S(idxFC) = RT_P(idxFC) + medISI_FE;
  ISI = RT_S - RT_P;
  
  %compute spike density function and align appropriately
  sdfA = compute_spike_density_fxn(spikesTest{uu});  %sdf from Array
  sdfP = align_signal_on_response(sdfA, RT_P); %sdf from Primary
  sdfS = align_signal_on_response(sdfA, RT_S); %sdf from Second
  
  %% Compute mean SDF for response into RF
  sdfFC = NaN(NUM_SAMP,6); % re. array | re. primary | re. second (IN|OUT)
  sdfFE = sdfFC;
  sdfAC = sdfFC;
  sdfAE = sdfFC;
  RT_F = NaN(4,1);
  RT_A = RT_F;
  ISI_F = RT_F;
  ISI_A = RT_F;
  
  %Correct trials - Fast
  sdfFC(:,1) = nanmean(sdfA(idxFC &  idxRFP, tPlot));
  sdfFC(:,2) = nanmean(sdfP(idxFC &  idxRFP, tPlot));
  sdfFC(:,3) = nanmean(sdfS(idxFC &  idxRFS, tPlot));
  RT_F(1)  = nanmedian(RT_P(idxFC & idxRFP));
  ISI_F(1) = nanmedian(ISI(idxFC & idxRFS));
  sdfFC(:,4) = nanmean(sdfA(idxFC & idxRFPn, tPlot));
  sdfFC(:,5) = nanmean(sdfP(idxFC & idxRFPn, tPlot));
  sdfFC(:,6) = nanmean(sdfS(idxFC & idxRFSn, tPlot));
  RT_F(2)  = nanmedian(RT_P(idxFC & idxRFPn));
  ISI_F(2) = nanmedian(ISI(idxFC & idxRFPn));
  %Correct trials - Accurate
  sdfAC(:,1) = nanmean(sdfA(idxAC &  idxRFP, tPlot));
  sdfAC(:,2) = nanmean(sdfP(idxAC &  idxRFP, tPlot));
  sdfAC(:,3) = nanmean(sdfS(idxAC &  idxRFS, tPlot));
  RT_A(1)  = nanmedian(RT_P(idxAC &  idxRFP));
  ISI_A(1) = nanmedian(ISI(idxAC &  idxRFS));
  sdfAC(:,4) = nanmean(sdfA(idxAC & idxRFPn, tPlot));
  sdfAC(:,5) = nanmean(sdfP(idxAC & idxRFPn, tPlot));
  sdfAC(:,6) = nanmean(sdfS(idxAC & idxRFSn, tPlot));
  RT_A(2)  = nanmedian(RT_P(idxAC & idxRFPn));
  ISI_A(2) = nanmedian(ISI(idxAC & idxRFSn));
  
  %Error trials - Fast
  sdfFE(:,1) = nanmean(sdfA(idxFE &  idxRFP, tPlot));
  sdfFE(:,2) = nanmean(sdfP(idxFE &  idxRFP, tPlot));
  sdfFE(:,3) = nanmean(sdfS(idxFE &  idxRFS, tPlot));
  RT_F(3)  = nanmedian(RT_P(idxFE & idxRFP));
  ISI_F(3) = nanmedian(ISI(idxFE & idxRFS));
  sdfFE(:,4) = nanmean(sdfA(idxFE & idxRFPn, tPlot));
  sdfFE(:,5) = nanmean(sdfP(idxFE & idxRFPn, tPlot));
  sdfFE(:,6) = nanmean(sdfS(idxFE & idxRFSn, tPlot));
  RT_F(4)  = nanmedian(RT_P(idxFE & idxRFPn));
  ISI_F(4) = nanmedian(ISI(idxFE & idxRFSn));
  %Error trials - Accurate
  sdfAE(:,1) = nanmean(sdfA(idxAE &  idxRFP, tPlot));
  sdfAE(:,2) = nanmean(sdfP(idxAE &  idxRFP, tPlot));
  sdfAE(:,3) = nanmean(sdfS(idxAE &  idxRFS, tPlot));
  RT_A(3) = nanmedian(RT_P(idxAE &  idxRFP));
  ISI_A(3) = nanmedian(ISI(idxAE &  idxRFS));
  sdfAE(:,4) = nanmean(sdfA(idxAE & idxRFPn, tPlot));
  sdfAE(:,5) = nanmean(sdfP(idxAE & idxRFPn, tPlot));
  sdfAE(:,6) = nanmean(sdfS(idxAE & idxRFSn, tPlot));
  RT_A(4)  = nanmedian(RT_P(idxAE &  idxRFPn));
  ISI_A(4) = nanmedian(ISI(idxAE &  idxRFSn));
  
  %Compute time of signaling re. primary
%   [tSig_Fast(uu),vecSig_Fast] = calc_tSignal_ChoiceErr(sdfP(idxFC & idxRF, tPlot), sdfP(idxFE & idxRF, tPlot));
%   [tSig_Acc(uu), vecSig_Acc]  = calc_tSignal_ChoiceErr(sdfP(idxAC & idxRF, tPlot), sdfP(idxAE & idxRF, tPlot));
  %% Plot: Mean SDF for response into RF
  if (PLOT)
    SIGDOT_SIZE = 5; %size of significant difference marker
    hFig = figure('visible',FIG_VISIBILITY);

    yLim = [0, max([sdfAC sdfFC sdfAE sdfFE],[],'all')];
    xLim = tPlot([1,NUM_SAMP]) - 3500;

    subplot(4,3,1); hold on %Fast re. array
    plot(tPlot-3500, sdfFC(:,1), 'Color',[0 .7 0], 'LineWidth',1.25)
    plot(tPlot-3500, sdfFE(:,1), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
    plot([RT_F(1) RT_F(1)], yLim, 'k-')
    plot([RT_F(3) RT_F(3)], yLim, 'k:')
    xlim(xLim); ylim(yLim);
    subplot(4,3,4); hold on
    plot(tPlot-3500, sdfFC(:,4), 'Color',[0 .7 0], 'LineWidth',0.75)
    plot(tPlot-3500, sdfFE(:,4), ':', 'Color',[0 .7 0], 'LineWidth',0.75)
    plot([RT_F(2) RT_F(2)], yLim, 'k-')
    plot([RT_F(4) RT_F(4)], yLim, 'k:')
    xlim(xLim); ylim(yLim)

    subplot(4,3,2); hold on %Fast re. primary
    title([unitTest.Properties.RowNames{uu}, '-', unitTest.aArea{uu}], 'FontSize',9)
    plot(tPlot-3500, sdfFC(:,2), 'Color',[0 .7 0], 'LineWidth',1.25)
    plot(tPlot-3500, sdfFE(:,2), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
    plot([ISI_F(1) ISI_F(1)], yLim, 'k-')
    plot([ISI_F(3) ISI_F(3)], yLim, 'k:')
%     plot((tSig_Fast(uu)-OFFSET_PRE)*ones(1,2), yLim, 'k:')
%     scatter(vecSig_Fast-OFFSET_PRE, yLim(2)/25, SIGDOT_SIZE, 'k')
    xlim(xLim); ylim(yLim); set(gca, 'YColor','none')
    subplot(4,3,5); hold on
    plot(tPlot-3500, sdfFC(:,5), 'Color',[0 .7 0], 'LineWidth',0.75)
    plot(tPlot-3500, sdfFE(:,5), ':', 'Color',[0 .7 0], 'LineWidth',0.75)
    plot([ISI_F(2) ISI_F(2)], yLim, 'k-')
    plot([ISI_F(4) ISI_F(4)], yLim, 'k:')
    xlim(xLim); ylim(yLim); set(gca, 'YColor','none')

    subplot(4,3,3); hold on %Fast re. second
    plot(tPlot-3500, sdfFC(:,3), 'Color',[0 .7 0], 'LineWidth',1.25)
    plot(tPlot-3500, sdfFE(:,3), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
    xlim(xLim); ylim(yLim); set(gca, 'YColor','none')
    subplot(4,3,6); hold on
    plot(tPlot-3500, sdfFC(:,6), 'Color',[0 .7 0], 'LineWidth',0.75)
    plot(tPlot-3500, sdfFE(:,6), ':', 'Color',[0 .7 0], 'LineWidth',0.75)
    xlim(xLim); ylim(yLim); set(gca, 'YColor','none')

    subplot(4,3,7); hold on %Accurate re. array
    plot(tPlot-3500, sdfAC(:,1), 'r', 'LineWidth',1.25)
    plot(tPlot-3500, sdfAE(:,1), 'r:', 'LineWidth',1.25)
    plot([RT_A(1) RT_A(1)], yLim, 'k-')
    plot([RT_A(3) RT_A(3)], yLim, 'k:')
    xlim(xLim); ylim(yLim)
    subplot(4,3,10); hold on
    plot(tPlot-3500, sdfAC(:,4), 'r', 'LineWidth',0.75)
    plot(tPlot-3500, sdfAE(:,4), 'r:', 'LineWidth',0.75)
    plot([RT_A(2) RT_A(2)], yLim, 'k-')
    plot([RT_A(4) RT_A(4)], yLim, 'k:')
    xlim(xLim); ylim(yLim)
    xlabel('Time from array (ms)')
    ylabel('Activity (sp/sec)')

    subplot(4,3,8); hold on %Accurate re. primary
    plot(tPlot-3500, sdfAC(:,2), 'r', 'LineWidth',1.25)
    plot(tPlot-3500, sdfAE(:,2), 'r:', 'LineWidth',1.25)
    plot([ISI_A(1) ISI_A(1)], yLim, 'k-')
    plot([ISI_A(3) ISI_A(3)], yLim, 'k:')
%     plot((tSig_Acc(uu)-OFFSET_PRE)*ones(1,2), yLim, 'k:')
%     scatter(vecSig_Acc-OFFSET_PRE, yLim(2)/25, SIGDOT_SIZE, 'k')
    xlim(xLim); ylim(yLim); set(gca, 'YColor','none')
    subplot(4,3,11); hold on
    plot(tPlot-3500, sdfAC(:,5), 'r', 'LineWidth',0.75)
    plot(tPlot-3500, sdfAE(:,5), 'r:', 'LineWidth',0.75)
    plot([ISI_A(2) ISI_A(2)], yLim, 'k-')
    plot([ISI_A(4) ISI_A(4)], yLim, 'k:')
    xlim(xLim); ylim(yLim); set(gca, 'YColor','none')
    xlabel('Time from primary saccade (ms)')

    subplot(4,3,9); hold on %Accurate re. second
    plot(tPlot-3500, sdfAC(:,3), 'r', 'LineWidth',1.25)
    plot(tPlot-3500, sdfAE(:,3), 'r:', 'LineWidth',1.25)
    xlim(xLim); ylim(yLim); set(gca, 'YColor','none')
    subplot(4,3,12); hold on
    plot(tPlot-3500, sdfAC(:,6), 'r', 'LineWidth',0.75)
    plot(tPlot-3500, sdfAE(:,6), 'r:', 'LineWidth',0.75)
    xlim(xLim); ylim(yLim); set(gca, 'YColor','none')
    xlabel('Time from second saccade (ms)')

    ppretty([10,6])

    pause(0.1); print(hFig, [PRINTDIR,unitTest.Properties.RowNames{uu},'-',unitTest.aArea{uu},'.tif'], '-dtiff')
    pause(0.1); close(hFig); pause(0.1)
    
  end % if (PLOT)
  
end % for : unit(uu)

tSig_Acc  = tSig_Acc - OFFSET_PRE;
tSig_Fast = tSig_Fast - OFFSET_PRE;

clearvars -except behavData unitData spikesSAT tSig_Fast tSig_Acc
% end % fxn : plot_SDF_X_Dir_RF_ErrChoice()
