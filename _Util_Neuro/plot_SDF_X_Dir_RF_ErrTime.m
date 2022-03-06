% function [ varargout ] = plot_SDF_X_Dir_RF_ErrTime( behavData , unitData , spikesSAT )
%plot_SDF_X_Dir_RF_ErrTime() Summary of this function goes here
%   Detailed explanation goes here

MIN_TRIAL_COUNT = 3;
PLOT = true;
FIG_VISIBLE = 'on';
PRINTDIR = 'C:\Users\Thomas Reppert\Documents\Figs - SAT\';

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'E'});
idxFunction = (unitData.Grade_Err == 1);
idxKeep = (idxArea & idxMonkey & idxFunction);

NUM_UNIT = sum(idxKeep);
unitTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

OFFSET_PRE = 200;
tPlot = 3500 + (-OFFSET_PRE : 600); %plot time vector
NUM_SAMP = length(tPlot);

RT_MAX = 900; %hard ceiling on primary RT
RT_THRESH_ERR = 120; %threshold between large and small errors in RT

NUM_DIR = 9; %binning by saccade direction for heatmap
BIN_DIR = linspace(-pi, pi, NUM_DIR);

%initializations
mean_dFR = NaN(NUM_UNIT,2); 

for uu = 3:3%1:NUM_UNIT
  fprintf('%s \n', unitTest.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitTest.Task_Session(uu));
  
  RTkk = behavData.Sacc_RT{kk}; %RT of primary saccade
  RTkk(RTkk > RT_MAX) = NaN; %hard limit on primary RT
  
  tRew_kk = RTkk + behavData.Task_TimeReward{kk};
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitTest.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by screen clear on Fast trials
  idxClear = logical(behavData.Task_ClearDisplayFast{kk});
  %index by condition
  idxFast = (behavData.Task_SATCondition{kk} == 3 & ~idxIso & ~idxClear);
  idxAcc = (behavData.Task_SATCondition{kk} == 1 & ~idxIso);
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  idxErr = (behavData.Task_ErrTime{kk} & ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  
  %compute error in RT for each condition
  dlineAcc =  median(behavData.Task_Deadline{kk}(idxAcc));
  dlineFast = median(behavData.Task_Deadline{kk}(idxFast));
  errRT = NaN(behavData.Task_NumTrials(kk),1);
  errRT(idxFast) = RTkk(idxFast) - dlineFast;
  errRT(idxAcc)  = RTkk(idxAcc)  - dlineAcc;
  %index by error magnitude
  rtThresh_Acc = abs(nanmedian(errRT(idxAcc & idxErr)));
  idxLargeErr = (abs(errRT) > rtThresh_Acc);
  idxSmallErr = (abs(errRT) < rtThresh_Acc);
  
  %compute spike density function and align on primary response
  sdfA_kk = compute_spike_density_fxn(spikesTest{uu});  %sdf from Array
  sdfP_kk = align_signal_on_response(sdfA_kk, RTkk); %sdf from Primary
  sdfR_kk = align_signal_on_response(sdfA_kk, round(tRew_kk)); %sdf from Reward
  
  %% Compute mean SDF for response into RF
  meanSDF_Fast_Corr = NaN(NUM_SAMP,3); %sdf re. array | sdf re. primary | sdf re. reward
  meanSDF_Fast_Err = meanSDF_Fast_Corr; %sdf re. array | sdf re. primary | sdf re. reward
  meanSDF_Acc_Corr = meanSDF_Fast_Corr;
  meanSDF_Acc_Err = meanSDF_Fast_Corr;
%   meanSDF_Acc_ErrLrg = meanSDF_Fast_Corr;
%   meanSDF_Acc_ErrSml = meanSDF_Fast_Corr;
  tSigR_Acc = struct('p10',NaN, 'p05',NaN, 'p01',NaN);
  tSigR_Fast = tSigR_Acc;
  
  %index by saccade octant re. response field (RF)
  Octant_Sacc1 = behavData.Sacc_Octant{kk};
  RF = unitTest.RF{uu};
  
  if ( isempty(RF) || (ismember(9,RF)) ) %average over all possible directions
    idxRF = true(behavData.Task_NumTrials(kk),1);
  else %average only trials with saccade into RF
    idxRF = ismember(Octant_Sacc1, RF);
  end
  
  idxFC = (idxFast & idxCorr & idxRF);
  idxAC = (idxAcc  & idxCorr & idxRF);
  idxFE = (idxFast & idxErr & idxRF);
  idxAE = (idxAcc  & idxErr & idxRF);
%   idxAEL = (idxAcc  & idxErr & idxRF & idxLargeErr);
%   idxAES = (idxAcc  & idxErr & idxRF & idxSmallErr);
  
  meanSDF_Fast_Corr(:,1) = nanmean(sdfA_kk(idxFC, tPlot)); %re. array
  meanSDF_Fast_Corr(:,2) = nanmean(sdfP_kk(idxFC, tPlot)); %re. primary
  meanSDF_Fast_Corr(:,3) = nanmean(sdfR_kk(idxFC, tPlot)); %re. reward
  if (sum(idxFE) > MIN_TRIAL_COUNT)
    meanSDF_Fast_Err(:,1) = nanmean(sdfA_kk(idxFE, tPlot)); %re. array
    meanSDF_Fast_Err(:,2) = nanmean(sdfP_kk(idxFE, tPlot)); %re. primary
    meanSDF_Fast_Err(:,3) = nanmean(sdfR_kk(idxFE, tPlot)); %re. reward
    tSigR_Fast = calc_tSignal_ChoiceErr(sdfR_kk(idxFC, tPlot), sdfR_kk(idxFE, tPlot));
  end
  meanSDF_Acc_Corr(:,1) = nanmean(sdfA_kk(idxAC, tPlot));
  meanSDF_Acc_Corr(:,2) = nanmean(sdfP_kk(idxAC, tPlot));
  meanSDF_Acc_Corr(:,3) = nanmean(sdfR_kk(idxAC, tPlot));
  if (sum(idxAE) > MIN_TRIAL_COUNT)
    meanSDF_Acc_Err(:,1) = nanmean(sdfA_kk(idxAE, tPlot));
    meanSDF_Acc_Err(:,2) = nanmean(sdfP_kk(idxAE, tPlot));
    meanSDF_Acc_Err(:,3) = nanmean(sdfR_kk(idxAE, tPlot));
%     meanSDF_Acc_ErrLrg(:,1) = nanmean(sdfA_kk(idxAEL, tPlot));
%     meanSDF_Acc_ErrLrg(:,2) = nanmean(sdfP_kk(idxAEL, tPlot));
%     meanSDF_Acc_ErrLrg(:,3) = nanmean(sdfR_kk(idxAEL, tPlot));
%     meanSDF_Acc_ErrSml(:,1) = nanmean(sdfA_kk(idxAES, tPlot));
%     meanSDF_Acc_ErrSml(:,2) = nanmean(sdfP_kk(idxAES, tPlot));
%     meanSDF_Acc_ErrSml(:,3) = nanmean(sdfR_kk(idxAES, tPlot));
    tSigR_Acc = calc_tSignal_ChoiceErr(sdfR_kk(idxAC, tPlot), sdfR_kk(idxAE, tPlot));
  end
  
  %compute mean diff in firing rate X magnitude of timing error (Accurate)
  idxTestDFR = OFFSET_PRE + (1:600);
%   idxTestDFR = OFFSET_PRE + (unitData.RewardSignal_Time(uu,3) : unitData.RewardSignal_Time(uu,4));
%   mean_dFR(uu,:) = compute_FR_X_TErrMag(meanSDF_Acc_ErrSml(idxTestDFR,:), ...
%     meanSDF_Acc_ErrLrg(idxTestDFR,:), meanSDF_Acc_Corr(idxTestDFR,:));
  
  if (PLOT)
  %% Plot: Mean SDF for response into RF
  figure('visible', FIG_VISIBLE)
  yTickLabel = num2cell(rad2deg(BIN_DIR));
  yTickLabel(2:2:end) = {''};
  
  sdfAll = [meanSDF_Fast_Corr meanSDF_Fast_Err meanSDF_Acc_Corr meanSDF_Acc_Err];
  maxFR = max(sdfAll,[],'all');
  yLim = [0, maxFR];

  subplot(2,3,1); hold on %Fast re. array
  title([unitTest.Properties.RowNames{uu}, '-', unitTest.aArea{uu}, '  ', ...
    'RF = ', num2str(rad2deg(convert_tgt_octant_to_angle(RF)))], 'FontSize',9)
  plot(tPlot-3500, meanSDF_Fast_Corr(:,1), 'Color',[0 .7 0])
  plot(tPlot-3500, meanSDF_Fast_Err(:,1), ':', 'Color',[0 .7 0])
  plot([0 0], yLim, 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500)

  subplot(2,3,2); hold on %Fast re. primary
  plot(tPlot-3500, meanSDF_Fast_Corr(:,2), 'Color',[0 .7 0])
  plot(tPlot-3500, meanSDF_Fast_Err(:,2), ':', 'Color',[0 .7 0])
  plot([0 0], yLim, 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500)
  set(gca, 'YColor','none')

  subplot(2,3,3); hold on %Fast re. reward
  plot(tPlot-3500, meanSDF_Fast_Corr(:,3), 'Color',[0 .7 0])
  plot(tPlot-3500, meanSDF_Fast_Err(:,3), ':', 'Color',[0 .7 0])
  plot([0 0], yLim, 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500)
  set(gca, 'YColor','none')
  scatter(tSigR_Fast.p05-OFFSET_PRE, 3, 20, [.4 .6 1], 'filled')
  scatter(tSigR_Fast.p01-OFFSET_PRE, 3, 20, [.1 .2 1], 'filled')

  subplot(2,3,4); hold on %Accurate re. array
  plot(tPlot-3500, meanSDF_Acc_Corr(:,1), 'r')
  plot(tPlot-3500, meanSDF_Acc_Err(:,1), 'r:')
%   plot(tPlot-3500, meanSDF_Acc_ErrLrg(:,1), 'r:', 'LineWidth',1.8)
%   plot(tPlot-3500, meanSDF_Acc_ErrSml(:,1), 'r:')
  plot([0 0], yLim, 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500)
  xlabel('Time from array (ms)')
  ylabel('Activity (sp/sec)')

  subplot(2,3,5); hold on %Accurate re. primary
  plot(tPlot-3500, meanSDF_Acc_Corr(:,2), 'r')
  plot(tPlot-3500, meanSDF_Acc_Err(:,2), 'r:')
%   plot(tPlot-3500, meanSDF_Acc_ErrLrg(:,2), 'r:', 'LineWidth',1.8)
%   plot(tPlot-3500, meanSDF_Acc_ErrSml(:,2), 'r:')
  plot([0 0], yLim, 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500)
  set(gca, 'YColor','none')
  xlabel('Time from primary saccade (ms)')

  subplot(2,3,6); hold on %Accurate re. reward
  plot(tPlot-3500, meanSDF_Acc_Corr(:,3), 'r')
  plot(tPlot-3500, meanSDF_Acc_Err(:,3), 'r:')
%   plot(tPlot-3500, meanSDF_Acc_ErrLrg(:,3), 'r:', 'LineWidth',1.8)
%   plot(tPlot-3500, meanSDF_Acc_ErrSml(:,3), 'r:')
  plot([0 0], yLim, 'k:', 'LineWidth',1.5)
  xlim(tPlot([1,NUM_SAMP])-3500)
  set(gca, 'YColor','none')
  xlabel('Time from reward (ms)')
  scatter(tSigR_Acc.p05-OFFSET_PRE, 3, 20, [.4 .6 1], 'filled')
  scatter(tSigR_Acc.p01-OFFSET_PRE, 3, 20, [.1 .2 1], 'filled')

  ppretty([10,4])
  
%   pause(0.1); print([PRINTDIR,unitData.Properties.RowNames{uu},'-',unitData.aArea{uu},'.tif'], '-dtiff')
%   pause(0.1); close(); pause(0.1)
  end % if (PLOT)
  
end% for : unit (uu)

% if (nargout > 0)
%   varargout{1} = mean_dFR;
%   
%   %plot distribution of dFR X timing error magnitude
%   figure(); hold on
%   title('Accurate condition', 'FontSize',10)
%   muPlot = mean(mean_dFR);
%   sePlot = std(mean_dFR) / sqrt(NUM_UNIT);
%   bar(muPlot, 'FaceColor','w')
%   errorbar(muPlot, sePlot, 'Color','k', 'CapSize',0)
%   ylabel('Diff. in firing rate (sp/sec)')
%   xticks(1:2); xticklabels({'Small error','Large error'})
%   ppretty([3,3])
%   
% end

clearvars -except behavData unitData spikesSAT
% end%fxn:plot_SDF_X_Dir_RF_ErrTime()


function [ diff_FR ] = compute_FR_X_TErrMag( sdf_ErrSml , sdf_ErrLrg , sdf_Corr )

%compute firing rate for SDF re. reward
FR_ErrSml = mean(sdf_ErrSml(:,3),1);
FR_ErrLrg = mean(sdf_ErrLrg(:,3),1);
FR_Corr = mean(sdf_Corr(:,3),1);

diff_FR = [FR_ErrSml , FR_ErrLrg] - FR_Corr;

%normalize by the max FR on correct trials (across all epochs)
diff_FR = diff_FR / max(FR_Corr,[],'all');

end % fxn : compute_FR_X_TErrMag()



