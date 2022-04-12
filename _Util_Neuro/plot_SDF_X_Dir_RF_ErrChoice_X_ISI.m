% function [  ] = plot_SDF_X_Dir_RF_ErrChoice_X_ISI( behavData , unitData , spikesSAT )
%plot_SDF_X_Dir_RF_ErrChoice() Summary of this function goes here
%   Detailed explanation goes here

PLOT = true;
FIG_VISIBILITY = 'off';
RT_MAX = 900; %hard ceiling on primary RT
PRINTDIR = 'C:\Users\Thomas Reppert\Documents\Figs - SAT\';

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});
idxFunction = ismember(unitData.Grade_Err, 1);
idxKeep = (idxArea & idxMonkey);% & idxFunction);

NUM_UNIT = sum(idxKeep);
unitTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

OFFSET_PRE  = 500;
OFFSET_POST = 700;
tPlot = 3500 + (-OFFSET_PRE : OFFSET_POST); %plot time vector
NUM_SAMP = length(tPlot);

tSig_Fast = NaN(NUM_UNIT,4); % primary (short/long) | second (short/long)
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
  
  %index by inter-saccade interval (short and long)
  isiAE = ISI_kk(idxAE);   medISI_AE = nanmedian(isiAE);
  isiFE = ISI_kk(idxFE);   medISI_FE = nanmedian(isiFE);
  
  %combine indexing and compute mean short and long ISI on error trials
  idxAES = (idxAE & (ISI_kk <= medISI_AE));   muISI_AES = round(nanmean(ISI_kk(idxAES)));
  idxAEL = (idxAE & (ISI_kk >  medISI_AE));   muISI_AEL = round(nanmean(ISI_kk(idxAEL)));
  idxFES = (idxFE & (ISI_kk <= medISI_FE));   muISI_FES = round(nanmean(ISI_kk(idxFES)));
  idxFEL = (idxFE & (ISI_kk >  medISI_FE));   muISI_FEL = round(nanmean(ISI_kk(idxFEL)));
  
  %set ISI of correct trials accordingly
  RTS_ShortISI = RTS_kk;
  RTS_LongISI = RTS_kk;
  RTS_ShortISI(idxAC) = RTP_kk(idxAC) + muISI_AES;
  RTS_LongISI(idxAC)  = RTP_kk(idxAC) + muISI_AEL;
  RTS_ShortISI(idxFC) = RTP_kk(idxFC) + muISI_FES;
  RTS_LongISI(idxFC)  = RTP_kk(idxFC) + muISI_FEL;
  
  %compute spike density functions and align appropriately
  sdfA = compute_spike_density_fxn(spikesTest{uu});  %sdf from Array
  sdfP = align_signal_on_response(sdfA, RTP_kk); %sdf from Primary
  sdfS_Short = align_signal_on_response(sdfA, RTS_ShortISI); %sdf from Second - short ISI
  sdfS_Long  = align_signal_on_response(sdfA, RTS_LongISI); %sdf from Second - long ISI
    
  %% Compute mean SDF
  sdfFC = NaN(NUM_SAMP,4); % re. array | re. primary | re. second (short | long)
  sdfAC = sdfFC;
  sdfFE = NaN(NUM_SAMP,6); % re. array | re. primary | re. second (short | long);
  sdfAE = sdfFE;
  
  %Correct trials - Fast condition
  sdfFC(:,1) = nanmean(sdfA(idxFC, tPlot)); %re. array
  sdfFC(:,2) = nanmean(sdfP(idxFC, tPlot)); %re. primary
  sdfFC(:,3) = nanmean(sdfS_Short(idxFC, tPlot)); %re. second (short)
  sdfFC(:,4) = nanmean(sdfS_Long(idxFC, tPlot)); %re. second (long)
  
  %Correct trials - Accurate condition
  sdfAC(:,1) = nanmean(sdfA(idxAC, tPlot)); %re. array
  sdfAC(:,2) = nanmean(sdfP(idxAC, tPlot)); %re. primary
  sdfAC(:,3) = nanmean(sdfS_Short(idxAC, tPlot)); %re. second (short)
  sdfAC(:,4) = nanmean(sdfS_Long(idxAC, tPlot)); %re. second (long)
  
  %Error trials - Fast - Short ISI
  sdfFE(:,1) = nanmean(sdfA(idxFES, tPlot)); %re. array
  sdfFE(:,2) = nanmean(sdfP(idxFES, tPlot)); %re. primary
  sdfFE(:,3) = nanmean(sdfS_Short(idxFES, tPlot)); %re. second (short)
  %Error trials - Fast - Long ISI
  sdfFE(:,4) = nanmean(sdfA(idxFEL, tPlot)); %re. array
  sdfFE(:,5) = nanmean(sdfP(idxFEL, tPlot)); %re. primary
  sdfFE(:,6) = nanmean(sdfS_Long(idxFEL, tPlot)); %re. second (short)
  
  %Error trials - Accurate - Short ISI
  sdfAE(:,1) = nanmean(sdfA(idxAES, tPlot)); %re. array
  sdfAE(:,2) = nanmean(sdfP(idxAES, tPlot)); %re. primary
  sdfAE(:,3) = nanmean(sdfS_Short(idxAES, tPlot)); %re. second (short)
  %Error trials - Accurate - Long ISI
  sdfAE(:,4) = nanmean(sdfA(idxAEL, tPlot)); %re. array
  sdfAE(:,5) = nanmean(sdfP(idxAEL, tPlot)); %re. primary
  sdfAE(:,6) = nanmean(sdfS_Long(idxAEL, tPlot)); %re. second (short)
  
  %Compute time of signaling re. primary (short & long) - Fast
  [tSig_Fast(uu,1),~] = calc_tSignal_ChoiceErr(sdfP(idxFC, tPlot), sdfP(idxFES, tPlot));
  [tSig_Fast(uu,2),~] = calc_tSignal_ChoiceErr(sdfP(idxFC, tPlot), sdfP(idxFEL, tPlot));
  %Compute time of signaling re. primary (short & long) - Accurate
  [tSig_Acc(uu,1),~] = calc_tSignal_ChoiceErr(sdfP(idxAC, tPlot), sdfP(idxAES, tPlot));
  [tSig_Acc(uu,2),~] = calc_tSignal_ChoiceErr(sdfP(idxAC, tPlot), sdfP(idxAEL, tPlot));
  
  %Compute time of signaling re. second (short) - Fast
  [tSig_Fast(uu,3),~] = calc_tSignal_ChoiceErr(sdfS_Short(idxFC, tPlot), sdfS_Short(idxFES, tPlot));
  %Compute time of signaling re. second (short) - Accurate
  [tSig_Acc(uu,3),~]  = calc_tSignal_ChoiceErr(sdfS_Short(idxAC, tPlot), sdfS_Short(idxAES, tPlot));
  
  %Compute time of signaling re. second (long) - Fast
  [tSig_Fast(uu,4),~] = calc_tSignal_ChoiceErr(sdfS_Long(idxFC, tPlot), sdfS_Long(idxFEL, tPlot));
  %Compute time of signaling re. second (long) - Accurate
  [tSig_Acc(uu,4),~]  = calc_tSignal_ChoiceErr(sdfS_Long(idxAC, tPlot), sdfS_Long(idxAEL, tPlot));
  
  %% Plot: Mean SDF for response into RF
  if (PLOT)
    hFig = figure('visible',FIG_VISIBILITY);
    yLim = [0, max([sdfAC sdfFC sdfAE sdfFE],[],'all')];
    xLim = tPlot([1,NUM_SAMP]) - 3500;

    subplot(2,4,1); hold on %Fast re. array
    plot(tPlot-3500, sdfFC(:,1), 'Color',[0 .7 0], 'LineWidth',1.25)
    plot(tPlot-3500, sdfFE(:,1), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
    plot(tPlot-3500, sdfFE(:,4), ':', 'Color',[0 .3 0], 'LineWidth',0.75)
    xlim(xLim); ylim(yLim)

    subplot(2,4,2); hold on %Fast re. primary
    title([unitTest.Properties.RowNames{uu}, '-', unitTest.aArea{uu}], 'FontSize',9)
    plot(tPlot-3500, sdfFC(:,2), 'Color',[0 .7 0], 'LineWidth',1.25)
    plot(tPlot-3500, sdfFE(:,2), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
    plot(tPlot-3500, sdfFE(:,5), ':', 'Color',[0 .3 0], 'LineWidth',0.75)
    plot((tSig_Fast(uu,1)-OFFSET_PRE)*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.25)
    plot((tSig_Fast(uu,2)-OFFSET_PRE)*ones(1,2), yLim, ':', 'Color',[0 .3 0], 'LineWidth',1.25)
    xlim(xLim); ylim(yLim)
    set(gca, 'YColor','none')

    subplot(2,4,3); hold on %Fast re. second (short)
    plot(tPlot-3500, sdfFC(:,3), 'Color',[0 .7 0], 'LineWidth',1.25)
    plot(tPlot-3500, sdfFE(:,3), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
    plot((tSig_Fast(uu,3)-OFFSET_PRE)*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.25)
    xlim(xLim); ylim(yLim)
    set(gca, 'YColor','none')

    subplot(2,4,4); hold on %Fast re. second (long)
    plot(tPlot-3500, sdfFC(:,4), 'Color',[0 .7 0], 'LineWidth',1.25)
    plot(tPlot-3500, sdfFE(:,6), ':', 'Color',[0 .3 0], 'LineWidth',1.25)
    plot((tSig_Fast(uu,4)-OFFSET_PRE)*ones(1,2), yLim, ':', 'Color',[0 .3 0], 'LineWidth',1.25)
    xlim(xLim); ylim(yLim)
    set(gca, 'YColor','none')

    subplot(2,4,5); hold on %Accurate re. array
    plot(tPlot-3500, sdfAC(:,1), 'r', 'LineWidth',1.25)
    plot(tPlot-3500, sdfAE(:,1), 'r:', 'LineWidth',1.25)
    plot(tPlot-3500, sdfAE(:,4), ':', 'Color',[.5 0 0], 'LineWidth',0.75)
    xlim(xLim); ylim(yLim)
    xlabel('Time from array (ms)')
    ylabel('Activity (sp/sec)')

    subplot(2,4,6); hold on %Accurate re. primary
    plot(tPlot-3500, sdfAC(:,2), 'r', 'LineWidth',1.25)
    plot(tPlot-3500, sdfAE(:,2), 'r:', 'LineWidth',1.25)
    plot(tPlot-3500, sdfAE(:,5), ':', 'Color',[.5 0 0], 'LineWidth',0.75)
    plot((tSig_Acc(uu,1)-OFFSET_PRE)*ones(1,2), yLim, 'r:', 'LineWidth',1.25)
    plot((tSig_Acc(uu,2)-OFFSET_PRE)*ones(1,2), yLim, ':', 'Color',[.5 0 0], 'LineWidth',1.25)
    xlim(xLim); ylim(yLim)
    set(gca, 'YColor','none')
    xlabel('Time from primary saccade (ms)')

    subplot(2,4,7); hold on %Accurate re. second (short)
    plot(tPlot-3500, sdfAC(:,3), 'r', 'LineWidth',1.25)
    plot(tPlot-3500, sdfAE(:,3), 'r:', 'LineWidth',1.25)
    plot((tSig_Acc(uu,3)-OFFSET_PRE)*ones(1,2), yLim, 'r:', 'LineWidth',1.25)
    xlim(xLim); ylim(yLim)
    set(gca, 'YColor','none')
    xlabel('Time from early second saccade (ms)')

    subplot(2,4,8); hold on %Fast re. second (long)
    plot(tPlot-3500, sdfAC(:,4), 'r', 'LineWidth',1.25)
    plot(tPlot-3500, sdfAE(:,6), ':', 'Color',[.5 0 0], 'LineWidth',1.25)
    plot((tSig_Acc(uu,4)-OFFSET_PRE)*ones(1,2), yLim, ':', 'Color',[.5 0 0], 'LineWidth',1.25)
    xlim(xLim); ylim(yLim)
    set(gca, 'YColor','none')
    xlabel('Time from late second saccade (ms)')

    ppretty([11,3.5])

    pause(0.1); print(hFig, [PRINTDIR,unitTest.Properties.RowNames{uu},'-',unitTest.aArea{uu},'.tif'], '-dtiff')
    pause(0.1); close(hFig); pause(0.1)
    
  end % if : (PLOT)
  
end % for : unit(uu)

tSig_Acc  = tSig_Acc - OFFSET_PRE;
tSig_Fast = tSig_Fast - OFFSET_PRE;

clearvars -except behavData unitData spikesSAT tSig_Fast tSig_Acc
% end % fxn : plot_SDF_X_Dir_RF_ErrChoice_X_ISI()
