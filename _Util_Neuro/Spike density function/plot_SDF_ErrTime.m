% plot_SDF_ErrTime.m
% 

PLOT = false;
PRINTDIR = 'C:\Users\Tom\Documents\Figs - SAT\';
COMPUTE_TIMING = false;

idxArea = ismember(unitData.Area, {'SEF'});
idxMonkey = ismember(unitData.Monkey, {'D','E'});
idxFunction = ismember(unitData.Grade_TErr, [+1,-1]);
idxKeep = (idxArea & idxMonkey & idxFunction);

NUM_UNIT = sum(idxKeep);
unitTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

iPlot    = 3500 + (-1300 : 400);
iPlotRew = 3500 + (-500 : 1200);
NUM_SAMP = length(iPlot);

%store average SDF
sdfFC = cell(NUM_UNIT,1); %Fast correct
sdfAC = sdfFC; %Accurate correct
sdfFE = sdfFC; %Fast error
sdfAE = sdfFC; %Accurate error

%store signal timing
tSig_Acc = NaN(NUM_UNIT,2); %start|end
vecSig_Acc = cell(NUM_UNIT,1);

%bin by timing error magnitude
% ERR_LIM = linspace(0, 1, 4);
ERR_LIM = [.4 1];
NUM_BIN = length(ERR_LIM) - 1;
errLim_Acc = NaN(NUM_UNIT,NUM_BIN+1);
errLim_Fast = errLim_Acc;

for uu = 1:NUM_UNIT
  fprintf('%s \n', unitTest.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitTest.Session(uu));
  
  RTerr = behavData.Sacc_RTerr{kk}; %RT relative to deadline
  RT_P = behavData.Sacc_RT{kk}; %RT of primary saccade
  RT_S = behavData.Sacc2_RT{kk}; %RT of second saccade
  ISI = RT_S - RT_P; %inter-saccade interval
  tRew = median(behavData.Task_TimeReward{kk}); %time of reward (fixed)
  tRew = RT_P + tRew; %re. array
  
  %compute spike density function and align appropriately
  sdfA = compute_spike_density_fxn(spikesTest{uu});  %sdf from Array
  sdfP = align_signal_on_response(sdfA, RT_P); %sdf from Primary
  sdfR = align_signal_on_response(sdfA, tRew); %sdf from Reward
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitTest.TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  idxErr = (behavData.Task_ErrTime{kk} & ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
%   idxErr = (behavData.Task_ErrTime{kk} & ~behavData.Task_ErrChoice{kk});
  
  %combine indexing
  idxAC = (idxAcc & idxCorr);    idxAE = (idxAcc & idxErr & (ISI >= 600) & (RTerr < 0));
  idxFC = (idxFast & idxCorr);   idxFE = (idxFast & idxErr & (ISI >= 600) & (RTerr > 0));
  
  %work off of absolute error for Accurate condition
  RTerr = abs(RTerr);
  %compute RT error quantiles for binning based on distribution of error
  errLim_Acc(uu,:)  = quantile(RTerr(idxAE), ERR_LIM);
  errLim_Fast(uu,:) = quantile(RTerr(idxFE), ERR_LIM);
  
  %% Compute mean SDF
  sdfAC{uu} = NaN(NUM_SAMP,3); % re. array | re. primary | re. second
  sdfAE{uu} = NaN(NUM_SAMP,3*NUM_BIN);
  sdfFC{uu} = sdfAC{uu};
  sdfFE{uu} = sdfAE{uu};
  
  %Correct trials - Fast
  sdfFC{uu}(:,1) = nanmean(sdfA(idxFC, iPlot));
  sdfFC{uu}(:,2) = nanmean(sdfP(idxFC, iPlot));
  sdfFC{uu}(:,3) = nanmean(sdfR(idxFC, iPlotRew));
  
  %Correct trials - Accurate
  sdfAC{uu}(:,1) = nanmean(sdfA(idxAC, iPlot));
  sdfAC{uu}(:,2) = nanmean(sdfP(idxAC, iPlot));
  sdfAC{uu}(:,3) = nanmean(sdfR(idxAC, iPlotRew));
  
  %Error trials - Fast
  for bb = 1:NUM_BIN
    idxBin = (RTerr > errLim_Fast(uu,bb)) & (RTerr <= errLim_Fast(uu,bb+1));
    idxFEbb = (idxFE & idxBin);
    sdfFE{uu}(:,3*(bb-1)+1) = nanmean(sdfA(idxFEbb, iPlot));
    sdfFE{uu}(:,3*(bb-1)+2) = nanmean(sdfP(idxFEbb, iPlot));
    sdfFE{uu}(:,3*(bb-1)+3) = nanmean(sdfR(idxFEbb, iPlotRew));
  end
  
  %Error trials - Accurate
  for bb = 1:NUM_BIN
    idxBin = (RTerr > errLim_Acc(uu,bb)) & (RTerr <= errLim_Acc(uu,bb+1));
    idxAEbb = (idxAE & idxBin);
    sdfAE{uu}(:,3*(bb-1)+1) = nanmean(sdfA(idxAEbb, iPlot));
    sdfAE{uu}(:,3*(bb-1)+2) = nanmean(sdfP(idxAEbb, iPlot));
    sdfAE{uu}(:,3*(bb-1)+3) = nanmean(sdfR(idxAEbb, iPlotRew));
  end
  
  %% Compute time of error signaling
  if (COMPUTE_TIMING)
    [tSig_Acc(uu,:), vecSig_Acc{uu}] = calc_tErrorSignal_SAT(sdfR(idxAC, iPlotRew), sdfR(idxAEbb, iPlotRew), 'minDur',300);
    tSig_Acc(uu,1) = iPlotRew(1) + tSig_Acc(uu,1) - 3500;
    tSig_Acc(uu,2) = iPlotRew(end) - tSig_Acc(uu,2) - 3500;
    vecSig_Acc{uu} = iPlotRew(1) + vecSig_Acc{uu} - 3500;
  end
  
  %% Plotting
  if (PLOT)
    tPlot = iPlot - 3500;
    tPlotRew = iPlotRew - 3500;
    colorPlot = linspace(0.8, 0.5, NUM_BIN);
    GREEN = [0 .7 0];
    figure('visible', 'on');
    SIGDOT_SIZE = 3;
    
    yLim = [0, max([sdfAC{uu} sdfFC{uu} sdfAE{uu}],[],'all')];
    xLimA = [-400 250];
    xLimP = [-250 400];
    xLimR = [-500 1200];

    subplot(2,4,1); hold on %Accurate re. array
    title([unitTest.Properties.RowNames{uu},'-',unitTest.Area{uu}], 'FontSize',9)
    plot(tPlot, sdfFC{uu}(:,1), 'Color', GREEN, 'LineWidth',1.25)
    plot(tPlot, sdfAC{uu}(:,1), 'r', 'LineWidth',1.25)
    for bb = 1:NUM_BIN
      plot(tPlot, sdfAE{uu}(:,3*(bb-1)+1), ':', 'Color',[colorPlot(bb) 0 0], 'LineWidth',1.25)
    end
    xlim(xLimA); ylim(yLim)
    ylabel('Activity (sp/sec)')

    subplot(2,4,2); hold on %Accurate re. primary
    plot(tPlot, sdfFC{uu}(:,2), 'Color', GREEN, 'LineWidth',1.25)
    plot(tPlot, sdfAC{uu}(:,2), 'r', 'LineWidth',1.25)
    for bb = 1:NUM_BIN
      plot(tPlot, sdfAE{uu}(:,3*(bb-1)+2), ':', 'Color',[colorPlot(bb) 0 0], 'LineWidth',1.25)
    end
    xlim(xLimP); ylim(yLim); set(gca, 'YColor','none')

    subplot(2,4,[3 4]); hold on %Accurate re. reward
    plot(tPlotRew, sdfFC{uu}(:,3), 'Color', GREEN, 'LineWidth',1.25)
    plot(tPlotRew, sdfAC{uu}(:,3), 'r', 'LineWidth',1.25)
    for bb = 1:NUM_BIN
      plot(tPlotRew, sdfAE{uu}(:,3*(bb-1)+3), ':', 'Color',[colorPlot(bb) 0 0], 'LineWidth',1.25)
    end
    if (COMPUTE_TIMING)
      scatter(vecSig_Acc{uu}(1:2:end), yLim(2)/25, SIGDOT_SIZE, 'k')
      plot(ones(2,1)*tSig_Acc(uu,:), yLim, 'k:')
    else
      line(ones(2,1)*unitTest.SignalTE_Time(uu,:), yLim, 'color','k', 'linestyle',':')
    end
    xlim(xLimR); ylim(yLim); set(gca, 'YColor','none')
    
    subplot(2,4,5); hold on %Fast re. array
    plot(tPlot, sdfFC{uu}(:,1), 'Color', GREEN, 'LineWidth',1.25)
    plot(tPlot, sdfAC{uu}(:,1), 'r', 'LineWidth',1.25)
    for bb = 1:NUM_BIN
      plot(tPlot, sdfFE{uu}(:,3*(bb-1)+1), ':', 'Color',[0 colorPlot(bb) 0], 'LineWidth',1.25)
    end
    xlim(xLimA); ylim(yLim)
    xlabel('Time from array (ms)')
    ylabel('Activity (sp/sec)')

    subplot(2,4,6); hold on %Fast re. primary
    plot(tPlot, sdfFC{uu}(:,2), 'Color', GREEN, 'LineWidth',1.25)
    plot(tPlot, sdfAC{uu}(:,2), 'r', 'LineWidth',1.25)
    for bb = 1:NUM_BIN
      plot(tPlot, sdfFE{uu}(:,3*(bb-1)+2), ':', 'Color',[0 colorPlot(bb) 0], 'LineWidth',1.25)
    end
    xlim(xLimP); ylim(yLim); set(gca, 'YColor','none')
    xlabel('Time from response (ms)')

    subplot(2,4,[7 8]); hold on %Fast re. reward
    plot(tPlotRew, sdfFC{uu}(:,3), 'Color', GREEN, 'LineWidth',1.25)
    plot(tPlotRew, sdfAC{uu}(:,3), 'r', 'LineWidth',1.25)
    for bb = 1:NUM_BIN
      plot(tPlotRew, sdfFE{uu}(:,3*(bb-1)+3), ':', 'Color',[0 colorPlot(bb) 0], 'LineWidth',1.25)
    end
    xlim(xLimR); ylim(yLim'); set(gca, 'YColor','none')
    xlabel('Time from reward (ms)')
    
    ppretty([8,2])

    pause(0.1); print([PRINTDIR,unitTest.Properties.RowNames{uu},'-',unitTest.Area{uu},'.tif'], '-dtiff')
    pause(0.1); close(); pause(0.1)
    
  end % if (PLOT)
  
end% for : unit (uu)

clearvars -except behavData unitData spikesSAT ROOTDIR_SAT sdfAC sdfAE sdfFC sdfFE