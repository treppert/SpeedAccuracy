%plot_SDF_ErrTime() Summary of this function goes here

PLOT = true;
PRINTDIR = 'C:\Users\Tom\Documents\Figs - SAT\';
COMPUTE_TIMING = false;

idxArea = ismember(unitData.Area, {'SEF'});
idxMonkey = ismember(unitData.Monkey, {'D','E'});
idxFunction = ismember(unitData.Grade_TErr, [-1,1]);
idxKeep = (idxArea & idxMonkey & idxFunction);
% idxKeep = true(436,1);

NUM_UNIT = sum(idxKeep);
unitTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

tPlot = 3500 + (-1300 : 400); %plot time vector
NUM_SAMP = length(tPlot);
tPlotRew = 3500 + (-500 : 1200);

%store average SDF
sdfFC = cell(NUM_UNIT,1); %Fast correct
sdfAC = sdfFC; %Accurate correct
sdfFE = sdfFC; %Fast error
sdfAE = sdfFC; %Accurate error

%store signal timing
tSig_Acc = NaN(NUM_UNIT,2); %start|end
vecSig_Acc = cell(NUM_UNIT,1);

%bin by timing error magnitude
ERR_LIM = linspace(0, 1, 5);
% ERR_LIM = [0 1];
NUM_BIN = length(ERR_LIM) - 1;
errLim_Acc = NaN(NUM_UNIT,NUM_BIN+1);

for uu = 1:NUM_UNIT
  fprintf('%s \n', unitTest.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitTest.Session(uu));
  
  RTerr = behavData.Sacc_RTerr{kk}; %RT relative to deadline
  RT_P = behavData.Sacc_RT{kk}; %RT of primary saccade
  tRew = round(nanmedian(behavData.Task_TimeReward{kk})); %time of reward (fixed)
  tRew = RT_P + tRew; %re. array
  
  %compute spike density function and align appropriately
  sdfA = compute_spike_density_fxn(spikesTest{uu});  %sdf from Array
  sdfP = align_signal_on_response(sdfA, RT_P); %sdf from Primary
  sdfR = align_signal_on_response(sdfA, tRew); %sdf from Reward
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitTest.TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by screen clear on Fast trials
  idxClear = logical(behavData.Task_ClearDisplayFast{kk});
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);% & ~idxClear);
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  idxErr = (behavData.Task_ErrTime{kk} & ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
    
  %combine indexing
  idxAC = (idxAcc & idxCorr);    idxAE = (idxAcc & idxErr & (RTerr < 0));
  idxFC = (idxFast & idxCorr);   idxFE = (idxFast & idxErr & (RTerr > 0));
  
  %work off of absolute error for Accurate condition
  RTerr = abs(RTerr);
  %compute RT error quantiles for binning based on distribution of error
  errLim_Acc(uu,:)  = quantile(RTerr(idxAE), ERR_LIM);
  errLim_Fast = quantile(RTerr(idxFE), ERR_LIM);
  
  %% Compute mean SDF
  sdfAC{uu} = NaN(NUM_SAMP,3); % re. array | re. primary | re. second
  sdfAE{uu} = NaN(NUM_SAMP,3*NUM_BIN);
  sdfFC{uu} = sdfAC{uu};
  sdfFE{uu} = sdfAC{uu};
  
  %Correct trials - Fast
  sdfFC{uu}(:,1) = nanmean(sdfA(idxFC, tPlot));
  sdfFC{uu}(:,2) = nanmean(sdfP(idxFC, tPlot));
  sdfFC{uu}(:,3) = nanmean(sdfR(idxFC, tPlotRew));
  
  %Correct trials - Accurate
  sdfAC{uu}(:,1) = nanmean(sdfA(idxAC, tPlot));
  sdfAC{uu}(:,2) = nanmean(sdfP(idxAC, tPlot));
  sdfAC{uu}(:,3) = nanmean(sdfR(idxAC, tPlotRew));
  
  %Error trials - Accurate
  for bb = 1:NUM_BIN
    idxAccBB = (RTerr > errLim_Acc(uu,bb)) & (RTerr <= errLim_Acc(uu,bb+1));
    idxAEbb = (idxAE & idxAccBB);
    sdfAE{uu}(:,3*(bb-1)+1) = nanmean(sdfA(idxAEbb, tPlot));
    sdfAE{uu}(:,3*(bb-1)+2) = nanmean(sdfP(idxAEbb, tPlot));
    sdfAE{uu}(:,3*(bb-1)+3) = nanmean(sdfR(idxAEbb, tPlotRew));
  end
  
  %% Compute time of error signaling
  if (COMPUTE_TIMING)
    [tSig_Acc(uu,:), vecSig_Acc{uu}] = calc_tErrorSignal_SAT(sdfR(idxAC, tPlotRew), sdfR(idxAE, tPlotRew));
    tSig_Acc(uu,1) = tPlotRew(1) + tSig_Acc(uu,1) - 3500;
    tSig_Acc(uu,2) = tPlotRew(end) - tSig_Acc(uu,2) - 3500;
    vecSig_Acc{uu} = tPlotRew(1) + vecSig_Acc{uu} - 3500;
  end
  
  %% Plotting
  if (PLOT)
    colorPlot = linspace(0.8, 0.0, NUM_BIN);
    figure('visible', 'off')
    SIGDOT_SIZE = 3;
    
    yLim = [0, max([sdfAC{uu} sdfFC{uu} sdfAE{uu} sdfFE{uu}],[],'all')];
    xLimA = [-350 250];
    xLimP = [-250 350];
    xLimR1 = [-350 250];
    xLimR2 = [250 850];

    subplot(1,4,1); hold on %Accurate re. array
    plot(tPlot-3500, sdfFC{uu}(:,1), 'Color', [0 .7 0], 'LineWidth',1.25)
    plot(tPlot-3500, sdfAC{uu}(:,1), 'r', 'LineWidth',1.25)
    for bb = 1:NUM_BIN
      plot(tPlot-3500, sdfAE{uu}(:,3*(bb-1)+1), ':', 'Color',[colorPlot(bb) 0 0], 'LineWidth',1.25)
    end
    xlim(xLimA); ylim(yLim)
    xlabel('Time from array (ms)')
    ylabel('Activity (sp/sec)')

    subplot(1,4,2); hold on %Accurate re. primary
    title([unitTest.Properties.RowNames{uu},'-',unitTest.Area{uu}], 'FontSize',9)
    plot(tPlot-3500, sdfFC{uu}(:,2), 'Color', [0 .7 0], 'LineWidth',1.25)
    plot(tPlot-3500, sdfAC{uu}(:,2), 'r', 'LineWidth',1.25)
    for bb = 1:NUM_BIN
      plot(tPlot-3500, sdfAE{uu}(:,3*(bb-1)+2), ':', 'Color',[colorPlot(bb) 0 0], 'LineWidth',1.25)
    end
    xlim(xLimP); ylim(yLim); set(gca, 'YColor','none')
    xlabel('Time from response (ms)')

    subplot(1,4,3); hold on %Accurate re. reward #1
    plot(tPlotRew-3500, sdfFC{uu}(:,3), 'Color', [0 .7 0], 'LineWidth',1.25)
    plot(tPlotRew-3500, sdfAC{uu}(:,3), 'r', 'LineWidth',1.25)
    for bb = 1:NUM_BIN
      plot(tPlotRew-3500, sdfAE{uu}(:,3*(bb-1)+3), ':', 'Color',[colorPlot(bb) 0 0], 'LineWidth',1.25)
    end
    if (COMPUTE_TIMING); scatter(vecSig_Acc{uu}, yLim(2)/25, SIGDOT_SIZE, 'k'); end
    plot(tSig_Acc(uu,1)*ones(1,2), yLim, 'k:')
    plot(tSig_Acc(uu,2)*ones(1,2), yLim, 'k:')
    xlim(xLimR1); ylim(yLim); set(gca, 'YColor','none')
    xlabel('Time from reward (ms)')
    
    subplot(1,4,4); hold on %Accurate re. reward #2
    plot(tPlotRew-3500, sdfFC{uu}(:,3), 'Color', [0 .7 0], 'LineWidth',1.25)
    plot(tPlotRew-3500, sdfAC{uu}(:,3), 'r', 'LineWidth',1.25)
    for bb = 1:NUM_BIN
      plot(tPlotRew-3500, sdfAE{uu}(:,3*(bb-1)+3), ':', 'Color',[colorPlot(bb) 0 0], 'LineWidth',1.25)
    end
    if (COMPUTE_TIMING); scatter(vecSig_Acc{uu}, yLim(2)/25, SIGDOT_SIZE, 'k'); end
    plot(tSig_Acc(uu,1)*ones(1,2), yLim, 'k:')
    plot(tSig_Acc(uu,2)*ones(1,2), yLim, 'k:')
    xlim(xLimR2); ylim(yLim); set(gca, 'YColor','none')
    xlabel('Time from reward (ms)')
    
    ppretty([14,1.8])

    pause(0.1); print([PRINTDIR,unitTest.Properties.RowNames{uu},'-',unitTest.Area{uu},'.tif'], '-dtiff')
    pause(0.1); close(); pause(0.1)
    
  end % if (PLOT)
  
end% for : unit (uu)

clearvars -except behavData unitData spikesSAT sdfAC sdfAE sdfFC sdfFE tSig_Acc vecSig_Acc errLim_Acc

