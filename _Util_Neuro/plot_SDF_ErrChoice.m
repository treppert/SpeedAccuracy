% function [  ] = plot_SDF_ErrChoice( behavData , unitData , spikesSAT )
%plot_SDF_X_Dir_RF_ErrChoice() Summary of this function goes here
%   Detailed explanation goes here

PLOT = true;
FIG_VISIBILITY = 'off';
RT_MAX = 900; %hard ceiling on primary RT
PRINTDIR = 'C:\Users\Thomas Reppert\Documents\Figs - SAT\';

idxArea = ismember(unitData.Area, {'SEF'});
idxMonkey = ismember(unitData.Monkey, {'D','E'});
idxFunction = ismember(unitData.Grade_Err, [-1,1]);
% idxFunction = ~cellfun(@isempty,unitData.RF);
idxKeep = (idxArea & idxMonkey & idxFunction);

NUM_UNIT = sum(idxKeep);
unitTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

tLim_Plot = [-500,+500];
tPlot = 3500 + (tLim_Plot(1) : tLim_Plot(2));
nSamp_Plot = length(tPlot);

tLim_Test = [-500,+500];
tTest = 3500 + (tLim_Test(1) : tLim_Test(2));

tSig_Fast = NaN(NUM_UNIT,4); %error signal start/end (re. P, re.S)
tSig_Acc  = tSig_Fast;

magFast = NaN(NUM_UNIT,2); %(re. P, re. S)
magAcc = magFast;

for uu = 6:6%1:NUM_UNIT
  fprintf('%s \n', unitTest.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitTest.Session(uu));
  
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
  sdfFC = NaN(nSamp_Plot,3); % re. array | re. primary | re. second
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
  
  %Compute time of signaling
  [tSig_Fast(uu,1:2), vecSig_Fast_P] = calc_tErrorSignal_SAT(sdfP(idxFC, tTest), sdfP(idxFE, tTest)); %re. P
  [tSig_Fast(uu,3:4), vecSig_Fast_S] = calc_tErrorSignal_SAT(sdfS(idxFC, tTest), sdfS(idxFE, tTest)); %re. S
  [tSig_Acc(uu,1:2),  vecSig_Acc_P]  = calc_tErrorSignal_SAT(sdfP(idxAC, tTest), sdfP(idxAE, tTest));
  [tSig_Acc(uu,3:4),  vecSig_Acc_S]  = calc_tErrorSignal_SAT(sdfS(idxAC, tTest), sdfS(idxAE, tTest));
  tSig_Fast(uu,[1,3]) = tLim_Test(1) + tSig_Fast(uu,[1,3]);
  tSig_Fast(uu,[2,4]) = tLim_Test(2) - tSig_Fast(uu,[2,4]);
  tSig_Acc(uu,[1,3])  = tLim_Test(1) + tSig_Acc(uu,[1,3]);
  tSig_Acc(uu,[2,4])  = tLim_Test(2) - tSig_Acc(uu,[2,4]);
  
  %Compute magnitude of the error signal
%   magFast(uu,1) = calc_ErrorSignalMag_SAT(sdfFC(:,2) ,sdfFE(:,2) ,'idxTest',IDX_CALC_MAG-tLim_Plot(1), 'abs'); %re. primary
%   magFast(uu,2) = calc_ErrorSignalMag_SAT(sdfFC(:,3) ,sdfFE(:,3) ,'idxTest',IDX_CALC_MAG, 'abs'); %re. second
%   magAcc(uu,1)  = calc_ErrorSignalMag_SAT(sdfAC(:,2) ,sdfAE(:,2) ,'idxTest',IDX_CALC_MAG-tLim_Plot(1), 'abs');
%   magAcc(uu,2)  = calc_ErrorSignalMag_SAT(sdfAC(:,3) ,sdfAE(:,3) ,'idxTest',IDX_CALC_MAG, 'abs');
  
  %% Plot: Mean SDF for response into RF
  if (PLOT)
    SIGDOT_SIZE = 3; %size of significant difference marker
    hFig = figure('visible',FIG_VISIBILITY);

    yLim = [0, max([sdfAC sdfFC sdfAE sdfFE],[],'all')];
    xLim = tPlot([1,nSamp_Plot]) - 3500;

    subplot(2,3,1); hold on %Fast re. array
    title([unitTest.Properties.RowNames{uu},'-',unitTest.Area{uu}], 'FontSize',9)
    plot(tPlot-3500, sdfFC(:,1), 'Color',[0 .7 0], 'LineWidth',1.25)
    plot(tPlot-3500, sdfFE(:,1), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
    xlim(xLim); ylim(yLim);

    subplot(2,3,2); hold on %Fast re. primary
    plot(tPlot-3500, sdfFC(:,2), 'Color',[0 .7 0], 'LineWidth',1.25)
    plot(tPlot-3500, sdfFE(:,2), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
    scatter(tLim_Test(1)+vecSig_Fast_P, yLim(2)/25, SIGDOT_SIZE, 'k')
    plot(tSig_Fast(uu,1)*ones(1,2), yLim, 'k:') %start
    plot(tSig_Fast(uu,2)*ones(1,2), yLim, 'k:') %end
    xlim(xLim); ylim(yLim); set(gca, 'YColor','none')

    subplot(2,3,3); hold on %Fast re. second
    plot(tPlot-3500, sdfFC(:,3), 'Color',[0 .7 0], 'LineWidth',1.25)
    plot(tPlot-3500, sdfFE(:,3), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
    scatter(tLim_Test(1)+vecSig_Fast_S, yLim(2)/25, SIGDOT_SIZE, 'k')
    plot(tSig_Fast(uu,3)*ones(1,2), yLim, 'k:')
    plot(tSig_Fast(uu,4)*ones(1,2), yLim, 'k:')
    xlim(xLim); ylim(yLim); set(gca, 'YColor','none')

    subplot(2,3,4); hold on %Accurate re. array
    plot(tPlot-3500, sdfAC(:,1), 'r', 'LineWidth',1.25)
    plot(tPlot-3500, sdfAE(:,1), 'r:', 'LineWidth',1.25)
    ylabel('Activity (sp/sec)')
    xlabel('Time from array (ms)')
    xlim(xLim); ylim(yLim)

    subplot(2,3,5); hold on %Accurate re. primary
    plot(tPlot-3500, sdfAC(:,2), 'r', 'LineWidth',1.25)
    plot(tPlot-3500, sdfAE(:,2), 'r:', 'LineWidth',1.25)
    scatter(tLim_Test(1)+vecSig_Acc_P, yLim(2)/25, SIGDOT_SIZE, 'k')
    plot(tSig_Acc(uu,1)*ones(1,2), yLim, 'k:') %start
    plot(tSig_Acc(uu,2)*ones(1,2), yLim, 'k:') %end
    xlabel('Time from primary saccade (ms)')
    xlim(xLim); ylim(yLim); set(gca, 'YColor','none')

    subplot(2,3,6); hold on %Accurate re. second
    plot(tPlot-3500, sdfAC(:,3), 'r', 'LineWidth',1.25)
    plot(tPlot-3500, sdfAE(:,3), 'r:', 'LineWidth',1.25)
    scatter(tLim_Test(1)+vecSig_Acc_S, yLim(2)/25, SIGDOT_SIZE, 'k')
    plot(tSig_Acc(uu,3)*ones(1,2), yLim, 'k:')
    plot(tSig_Acc(uu,4)*ones(1,2), yLim, 'k:')
    xlabel('Time from second saccade (ms)')
    xlim(xLim); ylim(yLim); set(gca, 'YColor','none')

    ppretty([8,3])

    pause(0.1); print(hFig, [PRINTDIR,unitTest.Properties.RowNames{uu},'-',unitTest.Area{uu},'.tif'], '-dtiff')
    pause(0.1); close(hFig); pause(0.1)
    
  end % if (PLOT)
  
end % for : unit(uu)

clearvars -except ROOTDIR_DATA_SAT behavData unitData spikesSAT tSig_*
% end % fxn : plot_SDF_ErrChoice()
