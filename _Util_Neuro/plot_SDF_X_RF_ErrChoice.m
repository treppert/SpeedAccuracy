% function [  ] = plot_SDF_X_Dir_RF_ErrChoice( behavData , unitData , spikesSAT )
%plot_SDF_X_Dir_RF_ErrChoice() Summary of this function goes here
%   Detailed explanation goes here

PLOT = false;
FIG_VISIBILITY = 'off';
RT_MAX = 900; %hard ceiling on primary RT
PRINTDIR = 'C:\Users\Thomas Reppert\Documents\Figs - SAT\';

idxArea = ismember(unitData.Area, {'SEF'});
idxMonkey = ismember(unitData.Monkey, {'D','E'});
idxFunction = (unitData.SignalPostErr == 1);
% idxFunction = ~cellfun(@isempty,unitData.RF);
idxKeep = (idxArea & idxMonkey & idxFunction);

NUM_UNIT = sum(idxKeep);
unitTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

OFFSET_PRE  = 200;
OFFSET_POST = 400;
tPlot = 3500 + (-OFFSET_PRE : OFFSET_POST); %plot time vector
NUM_SAMP = length(tPlot);

IDX_CALC_MAG = (101 : 300); %indexes for computing signal magnitude

tSig_Fast = NaN(NUM_UNIT,1); %error signal onset
tSig_Acc  = tSig_Fast;

magFast = NaN(NUM_UNIT,4); %Primary saccade into RF (re. P, re. S) || Second saccade into RF
magAcc = magFast;

for uu = 1:NUM_UNIT
  fprintf('%s \n', unitTest.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitTest.Session(uu));
  
  RFuu = unitTest.RF{uu}; %response field
  if (length(RFuu) == 8) %if RF is the entire visual field
    switch unitTest.Monkey{uu}
      case 'D' %set to contralateral hemifield
        RFuu = [4 5 6];
      case 'E'
        RFuu = [8 1 2];
    end
  end
  
  RT_P = behavData.Sacc_RT{kk}; %Primary saccade RT
  RT_P(RT_P > RT_MAX) = NaN; %hard limit on primary RT
  RT_S = behavData.Sacc2_RT{kk}; %Second saccade RT
  RT_S(RT_S == 0) = NaN;
  ISI = RT_S - RT_P; %Inter-saccade interval
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitTest.TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  idxErr = (behavData.Task_ErrChoice{kk} & ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  %index by saccade octant re. response field (RF)
  Octant_Sacc1 = behavData.Sacc_Octant{kk};
  Octant_Sacc2 = behavData.Sacc2_Octant{kk};
  idxRFP  = ismember(Octant_Sacc1, RFuu); %primary saccade into RF
  idxRFS  = ismember(Octant_Sacc2, RFuu); %second saccade into RF
  idxRFPn = (~idxRFP & (Octant_Sacc1 ~= 0)); %primary saccade NOT into RF
  idxRFSn = (~idxRFS & ~isnan(Octant_Sacc2)); %second saccade NOT into RF
  
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
  
  %Correct trials - Fast
  sdfFC(:,1) = nanmean(sdfA(idxFC & idxRFP, tPlot));
  sdfFC(:,2) = nanmean(sdfP(idxFC & idxRFP, tPlot));
  sdfFC(:,3) = nanmean(sdfS(idxFC & idxRFP, tPlot));
  sdfFC(:,4) = nanmean(sdfA(idxFC & idxRFS, tPlot));
  sdfFC(:,5) = nanmean(sdfP(idxFC & idxRFS, tPlot));
  sdfFC(:,6) = nanmean(sdfS(idxFC & idxRFS, tPlot));
  %Correct trials - Accurate
  sdfAC(:,1) = nanmean(sdfA(idxAC & idxRFP, tPlot));
  sdfAC(:,2) = nanmean(sdfP(idxAC & idxRFP, tPlot));
  sdfAC(:,3) = nanmean(sdfS(idxAC & idxRFP, tPlot));
  sdfAC(:,4) = nanmean(sdfA(idxAC & idxRFS, tPlot));
  sdfAC(:,5) = nanmean(sdfP(idxAC & idxRFS, tPlot));
  sdfAC(:,6) = nanmean(sdfS(idxAC & idxRFS, tPlot));
  
  %Error trials - Fast
  sdfFE(:,1) = nanmean(sdfA(idxFE & idxRFP, tPlot));
  sdfFE(:,2) = nanmean(sdfP(idxFE & idxRFP, tPlot));
  sdfFE(:,3) = nanmean(sdfS(idxFE & idxRFP, tPlot));
  sdfFE(:,4) = nanmean(sdfA(idxFE & idxRFS, tPlot));
  sdfFE(:,5) = nanmean(sdfP(idxFE & idxRFS, tPlot));
  sdfFE(:,6) = nanmean(sdfS(idxFE & idxRFS, tPlot));
  %Error trials - Accurate
  sdfAE(:,1) = nanmean(sdfA(idxAE & idxRFP, tPlot));
  sdfAE(:,2) = nanmean(sdfP(idxAE & idxRFP, tPlot));
  sdfAE(:,3) = nanmean(sdfS(idxAE & idxRFP, tPlot));
  sdfAE(:,4) = nanmean(sdfA(idxAE & idxRFS, tPlot));
  sdfAE(:,5) = nanmean(sdfP(idxAE & idxRFS, tPlot));
  sdfAE(:,6) = nanmean(sdfS(idxAE & idxRFS, tPlot));
  
  %Compute time of signaling re. primary
%   [tSig_Fast(uu),vecSig_Fast] = calc_tSignal_ChoiceErr(sdfP(idxFC & idxRF, tPlot), sdfP(idxFE & idxRF, tPlot));
%   [tSig_Acc(uu), vecSig_Acc]  = calc_tSignal_ChoiceErr(sdfP(idxAC & idxRF, tPlot), sdfP(idxAE & idxRF, tPlot));
  
  %Compute magnitude of the error signal - Primary saccade into RF
  magFast(uu,1) = calc_ErrorSignalMag_SAT(sdfFC(:,2) ,sdfFE(:,2) ,'idxTest',OFFSET_PRE+IDX_CALC_MAG, 'abs'); %re. primary
  magFast(uu,2) = calc_ErrorSignalMag_SAT(sdfFC(:,3) ,sdfFE(:,3) ,'idxTest',IDX_CALC_MAG, 'abs'); %re. second
  magAcc(uu,1)  = calc_ErrorSignalMag_SAT(sdfAC(:,2) ,sdfAE(:,2) ,'idxTest',OFFSET_PRE+IDX_CALC_MAG, 'abs');
  magAcc(uu,2)  = calc_ErrorSignalMag_SAT(sdfAC(:,3) ,sdfAE(:,3) ,'idxTest',IDX_CALC_MAG, 'abs');
  %Compute magnitude of the error signal - Second saccade into RF
  magFast(uu,3) = calc_ErrorSignalMag_SAT(sdfFC(:,5) ,sdfFE(:,5) ,'idxTest',OFFSET_PRE+IDX_CALC_MAG, 'abs');
  magFast(uu,4) = calc_ErrorSignalMag_SAT(sdfFC(:,6) ,sdfFE(:,6) ,'idxTest',IDX_CALC_MAG, 'abs');
  magAcc(uu,3)  = calc_ErrorSignalMag_SAT(sdfAC(:,5) ,sdfAE(:,5) ,'idxTest',OFFSET_PRE+IDX_CALC_MAG, 'abs');
  magAcc(uu,4)  = calc_ErrorSignalMag_SAT(sdfAC(:,6) ,sdfAE(:,6) ,'idxTest',IDX_CALC_MAG, 'abs');
  
  %% Plot: Mean SDF for response into RF
  if (PLOT)
    SIGDOT_SIZE = 5; %size of significant difference marker
    hFig = figure('visible',FIG_VISIBILITY);

    yLim = [0, max([sdfAC sdfFC sdfAE sdfFE],[],'all')];
    xLim = tPlot([1,NUM_SAMP]) - 3500;

    subplot(4,3,1); hold on %Fast re. array
    title([unitTest.Properties.RowNames{uu},'-',unitTest.Area{uu},'  RF ',num2str(RFuu)], 'FontSize',9)
    plot(tPlot-3500, sdfFC(:,1), 'Color',[0 .7 0], 'LineWidth',1.25)
    plot(tPlot-3500, sdfFE(:,1), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
    xlim(xLim); ylim(yLim);
    subplot(4,3,4); hold on
    plot(tPlot-3500, sdfFC(:,4), 'Color',[0 .7 0], 'LineWidth',0.75)
    plot(tPlot-3500, sdfFE(:,4), ':', 'Color',[0 .7 0], 'LineWidth',0.75)
    xlim(xLim); ylim(yLim)

    subplot(4,3,2); hold on %Fast re. primary
    title('Primary saccade into RF')
    plot(tPlot-3500, sdfFC(:,2), 'Color',[0 .7 0], 'LineWidth',1.25)
    plot(tPlot-3500, sdfFE(:,2), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
%     plot((tSig_Fast(uu)-OFFSET_PRE)*ones(1,2), yLim, 'k:')
%     scatter(vecSig_Fast-OFFSET_PRE, yLim(2)/25, SIGDOT_SIZE, 'k')
    xlim(xLim); ylim(yLim); set(gca, 'YColor','none')
    subplot(4,3,5); hold on
    title('Second saccade into RF')
    plot(tPlot-3500, sdfFC(:,5), 'Color',[0 .7 0], 'LineWidth',0.75)
    plot(tPlot-3500, sdfFE(:,5), ':', 'Color',[0 .7 0], 'LineWidth',0.75)
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
    xlim(xLim); ylim(yLim)
    subplot(4,3,10); hold on
    plot(tPlot-3500, sdfAC(:,4), 'r', 'LineWidth',0.75)
    plot(tPlot-3500, sdfAE(:,4), 'r:', 'LineWidth',0.75)
    xlim(xLim); ylim(yLim)
    xlabel('Time from array (ms)')
    ylabel('Activity (sp/sec)')

    subplot(4,3,8); hold on %Accurate re. primary
    title('Primary saccade into RF')
    plot(tPlot-3500, sdfAC(:,2), 'r', 'LineWidth',1.25)
    plot(tPlot-3500, sdfAE(:,2), 'r:', 'LineWidth',1.25)
%     plot((tSig_Acc(uu)-OFFSET_PRE)*ones(1,2), yLim, 'k:')
%     scatter(vecSig_Acc-OFFSET_PRE, yLim(2)/25, SIGDOT_SIZE, 'k')
    xlim(xLim); ylim(yLim); set(gca, 'YColor','none')
    subplot(4,3,11); hold on
    title('Second saccade into RF')
    plot(tPlot-3500, sdfAC(:,5), 'r', 'LineWidth',0.75)
    plot(tPlot-3500, sdfAE(:,5), 'r:', 'LineWidth',0.75)
    xlim(xLim); ylim(yLim); set(gca, 'YColor','none')
    xlabel('Time from primary saccade (ms)')

    subplot(4,3,9); hold on %Accurate re. second
    plot(tPlot-3500, sdfAC(:,3), 'r', 'LineWidth',1.25)
    plot(tPlot-3500, sdfAE(:,3), 'r:', 'LineWidth',1.25)
    xlim(xLim); ylim(yLim); set(gca, 'YColor','none')
    subplot(4,3,12); hold on
    plot(tPlot-3500, sdfAC(:,6), 'r', 'LineWidth',0.75)
    plot(tPlot-3500, sdfAE(:,6), 'r--', 'LineWidth',0.75)
    xlim(xLim); ylim(yLim); set(gca, 'YColor','none')
    xlabel('Time from second saccade (ms)')

    ppretty([10,6])

    pause(0.1); print(hFig, [PRINTDIR,unitTest.Properties.RowNames{uu},'-',unitTest.Area{uu},'.tif'], '-dtiff')
    pause(0.1); close(hFig); pause(0.1)
    
  end % if (PLOT)
  
end % for : unit(uu)

tSig_Acc  = tSig_Acc - OFFSET_PRE;
tSig_Fast = tSig_Fast - OFFSET_PRE;

%compute the difference in error-related activation (primary into RF vs. second into RF)
CR_Fast = [compute_ContrastRatio_SAT(magFast(:,1), magFast(:,3)) , compute_ContrastRatio_SAT(magFast(:,2), magFast(:,4))];
CR_Acc  = [compute_ContrastRatio_SAT(magAcc(:,1), magAcc(:,3))  , compute_ContrastRatio_SAT(magAcc(:,2), magAcc(:,4))];
% CR_SEF = [mean(CR_Fast,2) , mean(CR_Acc,2)];

clearvars -except ROOTDIR_DATA_SAT behavData unitData spikesSAT CR_*
% end % fxn : plot_SDF_X_Dir_RF_ErrChoice()
