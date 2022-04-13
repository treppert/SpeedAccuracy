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

OFFSET_PRE  = 350;
OFFSET_POST = 550;
tPlot = 3500 + (-OFFSET_PRE : OFFSET_POST); %plot time vector
NUM_SAMP = length(tPlot);

tSig_Fast = NaN(NUM_UNIT,1); %error signal onset
tSig_Acc  = tSig_Fast;

for uu = 1:NUM_UNIT
  fprintf('%s \n', unitTest.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitTest.Task_Session(uu));
  
  RTP_kk = behavData.Sacc_RT{kk}; %Primary saccade RT
  RTP_kk(RTP_kk > RT_MAX) = NaN; %hard limit on primary RT
  RTS_kk = behavData.Sacc2_RT{kk}; %Second saccade RT
  RTS_kk(RTS_kk == 0) = NaN;
  ISI_kk = RTS_kk - RTP_kk; %Inter-saccade interval
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitTest.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  idxErr = (behavData.Task_ErrChoice{kk} & ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  
  %combine indexing
  idxAC = (idxAcc & idxCorr);    idxAE = (idxAcc & idxErr);
  idxFC = (idxFast & idxCorr);   idxFE = (idxFast & idxErr);
  
  %set "ISI" of correct trials as median ISI of error trials
  isiAE = ISI_kk(idxAE);   medISI_AE = round(nanmedian(isiAE));
  isiFE = ISI_kk(idxFE);   medISI_FE = round(nanmedian(isiFE));
  RTS_kk(idxAC) = RTP_kk(idxAC) + medISI_AE;
  RTS_kk(idxFC) = RTP_kk(idxFC) + medISI_FE;
  
  %compute spike density function and align appropriately
  sdfA = compute_spike_density_fxn(spikesTest{uu});  %sdf from Array
  sdfP = align_signal_on_response(sdfA, RTP_kk); %sdf from Primary
  sdfS = align_signal_on_response(sdfA, RTS_kk); %sdf from Second
  
  %index by saccade octant re. response field (RF)
%   Octant_Sacc1 = behavData.Sacc_Octant{kk};
%   Octant_Sacc2 = behavData.Sacc2_Octant{kk};
%   idxRF1 = ismember(Octant_Sacc1, unitTest.RF{uu});
%   idxRF2 = ismember(Octant_Sacc2, unitTest.RF{uu});
  
  %% Compute mean SDF for response into RF
  sdfFC = NaN(NUM_SAMP,3); % re. array | re. primary | re. second
  sdfFE = sdfFC;
  sdfAC = sdfFC;
  sdfAE = sdfFC;
  
  %Correct trials - Fast
  sdfFC(:,1) = nanmean(sdfA(idxFC, tPlot));
  sdfFC(:,2) = nanmean(sdfP(idxFC, tPlot));
  sdfFC(:,3) = nanmean(sdfS(idxFC, tPlot));
  %Correct trials - Accurate
  sdfAC(:,1) = nanmean(sdfA(idxAC, tPlot));
  sdfAC(:,2) = nanmean(sdfP(idxAC, tPlot));
  sdfAC(:,3) = nanmean(sdfS(idxAC, tPlot));
  
  %Error trials - Fast
  sdfFE(:,1) = nanmean(sdfA(idxFE, tPlot));
  sdfFE(:,2) = nanmean(sdfP(idxFE, tPlot));
  sdfFE(:,3) = nanmean(sdfS(idxFE, tPlot));
  
  %Error trials - Accurate
  sdfAE(:,1) = nanmean(sdfA(idxAE, tPlot));
  sdfAE(:,2) = nanmean(sdfP(idxAE, tPlot));
  sdfAE(:,3) = nanmean(sdfS(idxAE, tPlot));
  
  %Compute time of signaling re. primary
  [tSig_Fast(uu),vecSig_Fast] = calc_tSignal_ChoiceErr(sdfP(idxFC, tPlot), sdfP(idxFE, tPlot));
  [tSig_Acc(uu),vecSig_Acc] = calc_tSignal_ChoiceErr(sdfP(idxAC, tPlot), sdfP(idxAE, tPlot));
  
  %% Plot: Mean SDF for response into RF
  if (PLOT)
    SIGDOT_SIZE = 5; %size of significant difference marker
    hFig = figure('visible',FIG_VISIBILITY);

    yLim = [0, max([sdfAC sdfFC sdfAE sdfFE],[],'all')];
    xLim = tPlot([1,NUM_SAMP]) - 3500;

    subplot(2,3,1); hold on %Fast re. array
    plot(tPlot-3500, sdfFC(:,1), 'Color',[0 .7 0], 'LineWidth',1.25)
    plot(tPlot-3500, sdfFE(:,1), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
    xlim(xLim); ylim(yLim)

    subplot(2,3,2); hold on %Fast re. primary
    title([unitTest.Properties.RowNames{uu}, '-', unitTest.aArea{uu}], 'FontSize',9)
    plot(tPlot-3500, sdfFC(:,2), 'Color',[0 .7 0], 'LineWidth',1.25)
    plot(tPlot-3500, sdfFE(:,2), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
    plot((tSig_Fast(uu)-OFFSET_PRE)*ones(1,2), yLim, 'k:')
    scatter(vecSig_Fast-OFFSET_PRE, yLim(2)/25, SIGDOT_SIZE, 'k')
    xlim(xLim); ylim(yLim)
    set(gca, 'YColor','none')

    subplot(2,3,3); hold on %Fast re. second
    plot(tPlot-3500, sdfFC(:,3), 'Color',[0 .7 0], 'LineWidth',1.25)
    plot(tPlot-3500, sdfFE(:,3), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
    xlim(xLim); ylim(yLim)
    set(gca, 'YColor','none')

    subplot(2,3,4); hold on %Accurate re. array
    plot(tPlot-3500, sdfAC(:,1), 'r', 'LineWidth',1.25)
    plot(tPlot-3500, sdfAE(:,1), 'r:', 'LineWidth',1.25)
    xlim(xLim); ylim(yLim)
    xlabel('Time from array (ms)')
    ylabel('Activity (sp/sec)')

    subplot(2,3,5); hold on %Accurate re. primary
    plot(tPlot-3500, sdfAC(:,2), 'r', 'LineWidth',1.25)
    plot(tPlot-3500, sdfAE(:,2), 'r:', 'LineWidth',1.25)
    plot((tSig_Acc(uu)-OFFSET_PRE)*ones(1,2), yLim, 'k:')
    scatter(vecSig_Acc-OFFSET_PRE, yLim(2)/25, SIGDOT_SIZE, 'k')
    xlim(xLim); ylim(yLim)
    set(gca, 'YColor','none')
    xlabel('Time from primary saccade (ms)')

    subplot(2,3,6); hold on %Accurate re. second
    plot(tPlot-3500, sdfAC(:,3), 'r', 'LineWidth',1.25)
    plot(tPlot-3500, sdfAE(:,3), 'r:', 'LineWidth',1.25)
    xlim(xLim); ylim(yLim)
    set(gca, 'YColor','none')
    xlabel('Time from second saccade (ms)')

    ppretty([10,4])

    pause(0.1); print(hFig, [PRINTDIR,unitTest.Properties.RowNames{uu},'-',unitTest.aArea{uu},'.tif'], '-dtiff')
    pause(0.1); close(hFig); pause(0.1)
    
  end % if (PLOT)
  
end % for : unit(uu)

tSig_Acc  = tSig_Acc - OFFSET_PRE;
tSig_Fast = tSig_Fast - OFFSET_PRE;

clearvars -except behavData unitData spikesSAT tSig_Fast tSig_Acc
% end % fxn : plot_SDF_X_Dir_RF_ErrChoice()
