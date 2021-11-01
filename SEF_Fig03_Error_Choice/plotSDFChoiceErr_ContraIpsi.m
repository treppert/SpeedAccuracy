function [  ] = plotSDFChoiceErr_ContraIpsi( behavData , unitData , spikesSAT )
%plotSDFChoiceErr_ContraIpsi() Summary of this function goes here
%   Detailed explanation goes here
PLOT_INDIVIDUAL_NEURONS = false;

idxSEF = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'E'});
idxErr = (unitData.Basic_ErrGrade >= 2);

idxKeep = (idxSEF & idxMonkey & idxErr);

NUM_CELLS = sum(idxKeep);
unitData = unitData(idxKeep,:);
spikesSAT = spikesSAT(idxKeep);

T_PRIMARY = 3500 + (-200 : 400); %time from primary saccade

sdfCorrLeft  = NaN(NUM_CELLS, length(T_PRIMARY));
sdfCorrRight = NaN(NUM_CELLS, length(T_PRIMARY));
sdfErrLeft  = NaN(NUM_CELLS, length(T_PRIMARY));
sdfErrRight = NaN(NUM_CELLS, length(T_PRIMARY));
yLim = NaN(NUM_CELLS, 2); %used to normalize SDF to maximum

tSacc2Left = NaN(NUM_CELLS,1); %time of second saccade re. array
tSacc2Right = NaN(NUM_CELLS,1);

for cc = 1:NUM_CELLS
  kk = ismember(behavData.Task_Session, unitData.Task_Session(cc));
  
  RTPkk = double(behavData.Sacc_RT{kk}); %RT of primary saccade
  RTPkk(RTPkk > 900) = NaN; %hard limit on primary RT
  RTSkk = double(behavData.Sacc2_RT{kk}) - RTPkk; %RT of second saccade
  RTSkk(RTSkk < 0) = NaN; %trials with no secondary saccade
  
  %compute spike density function and align on primary response
  sdfKK = compute_spike_density_fxn(spikesSAT{cc});
  sdfKK = align_signal_on_response(sdfKK, RTPkk); 
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData.Task_TrialRemoveSAT{cc}, behavData.Task_NumTrials(kk));
  %index by condition
  idxFast = (behavData.Task_SATCondition{kk} == 3) & ~idxIso;
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  idxErr = (behavData.Task_ErrChoice{kk} & ~behavData.Task_ErrTime{kk});
  
  idxLeft = ismember(behavData.Task_TgtOctant{kk}, [4,5,6]);
  idxRight = ismember(behavData.Task_TgtOctant{kk}, [8,1,2]);
  
  tSacc2Left(cc) =  nanmedian(RTSkk(idxFast & idxErr & idxLeft));
  tSacc2Right(cc) = nanmedian(RTSkk(idxFast & idxErr & idxRight));
  
  sdfCorrLeft(cc,:) =  nanmean(sdfKK(idxFast & idxCorr & idxLeft, T_PRIMARY));
  sdfCorrRight(cc,:) = nanmean(sdfKK(idxFast & idxCorr & idxRight, T_PRIMARY));
  sdfErrLeft(cc,:) =   nanmean(sdfKK(idxFast & idxErr & idxLeft, T_PRIMARY));
  sdfErrRight(cc,:) =  nanmean(sdfKK(idxFast & idxErr & idxRight, T_PRIMARY));
  
  tmp = [sdfCorrLeft(cc,:) sdfCorrRight(cc,:) sdfErrLeft(cc,:) sdfErrRight(cc,:)];
  yLim(cc,:) = [min(tmp) max(tmp)];
  
  if (PLOT_INDIVIDUAL_NEURONS)
  %% Plotting - Individual neurons
  figure()
  
  %Subplot -- Target Left
  subplot(1,2,1); hold on
  
  plot([0 0], yLim, 'k-', 'LineWidth',1.0)
  plot(tSacc2Left(cc)*ones(1,2), yLim, 'k--')

  plot(T_PRIMARY-3500, sdfCorrLeft, '-', 'Color',[0 .7 0], 'LineWidth',1.25);
  plot(T_PRIMARY-3500, sdfErrLeft, ':', 'Color',[0 .7 0], 'LineWidth',1.25);

  plot(unitData.ChoiceErrorSignal_Time(cc,3)*ones(1,2), yLim, '-.', 'Color',[0 .7 0], 'LineWidth',1.0)
  plot(unitData.ChoiceErrorSignal_Time(cc,4)*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
  
  xlim([T_PRIMARY(1) T_PRIMARY(end)]-3500)
  xticks((T_PRIMARY(1) : 200 : T_PRIMARY(end)) - 3500)
  
  ylabel('Activity (sp/sec)')
  xlabel('Time from response (ms)')
  print_session_unit(gca , unitData(cc,:), behavData(kk,:), 'horizontal')
  
  pause(0.1)
  
  %Subplot -- Target Right
  subplot(1,2,2); hold on
  
  plot([0 0], yLim, 'k-', 'LineWidth',1.0)
  plot(tSacc2Right(cc)*ones(1,2), yLim, 'k--')

  plot(T_PRIMARY-3500, sdfCorrRight, '-', 'Color',[0 .7 0], 'LineWidth',1.25);
  plot(T_PRIMARY-3500, sdfErrRight, ':', 'Color',[0 .7 0], 'LineWidth',1.25);

  plot(unitData.ChoiceErrorSignal_Time(cc,3)*ones(1,2), yLim, '-.', 'Color',[0 .7 0], 'LineWidth',1.0)
  plot(unitData.ChoiceErrorSignal_Time(cc,4)*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
  
  xlim([T_PRIMARY(1) T_PRIMARY(end)]-3500)
  xticks((T_PRIMARY(1) : 200 : T_PRIMARY(end)) - 3500)
  
  xlabel('Time from response (ms)')
  legend({'','2ndSacc','Corr','Err','Start','End'}, 'Location','northoutside', 'Orientation','horizontal')
  yticklabels([])
  ppretty([9,2.5])
  
  pause(0.1)
  
  print(['C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\__SEF_SAT\Data\Figs_ChoiceErrorSignal\ContraIpsi\', ...
    unitData.aArea{cc},'-',unitData.Properties.RowNames{cc},'.tif'], '-dtiff')
  pause(0.1); close()
  end %if: PLOT_INDIVIDUAL_NEURONS
  
end%for:cells(cc)

%prepare for plot of average across neurons
sdfCorrLeft = sdfCorrLeft ./ yLim(:,2);
sdfCorrRight = sdfCorrRight ./ yLim(:,2);
sdfErrLeft = sdfErrLeft ./ yLim(:,2);
sdfErrRight = sdfErrRight ./ yLim(:,2);


%% Plotting -- Across all neurons
figure();

%Subplot -- Target Left
subplot(1,2,1); hold on
plot([0 0], [0 1], 'k-', 'LineWidth',1.0)
plot(mean(tSacc2Left)*ones(1,2), [0 1], 'k--')

shaded_error_bar(T_PRIMARY-3500, mean(sdfCorrLeft), std(sdfCorrLeft)/sqrt(NUM_CELLS), {'-', 'Color',[0 .7 0], 'LineWidth',1.25})
shaded_error_bar(T_PRIMARY-3500, mean(sdfErrLeft),  std(sdfErrLeft)/sqrt(NUM_CELLS), {':', 'Color',[0 .7 0], 'LineWidth',1.25})

xlim([T_PRIMARY(1) T_PRIMARY(end)] - 3500)
xticks((T_PRIMARY(1) : 200 : T_PRIMARY(end)) - 3500)

ylabel('Activity (sp/sec)')
xlabel('Time from response (ms)')

%Subplot -- Target Right
subplot(1,2,2); hold on
plot([0 0], [0 1], 'k-', 'LineWidth',1.0)
plot(mean(tSacc2Right)*ones(1,2), [0 1], 'k--')

shaded_error_bar(T_PRIMARY-3500, mean(sdfCorrRight), std(sdfCorrRight)/sqrt(NUM_CELLS), {'-', 'Color',[0 .7 0], 'LineWidth',1.25})
shaded_error_bar(T_PRIMARY-3500, mean(sdfErrRight),  std(sdfErrRight)/sqrt(NUM_CELLS), {':', 'Color',[0 .7 0], 'LineWidth',1.25})

xlim([T_PRIMARY(1) T_PRIMARY(end)]-3500)
xticks((T_PRIMARY(1) : 200 : T_PRIMARY(end)) - 3500)

xlabel('Time from response (ms)')
legend({'','2ndSacc','','Corr','','Err'}, 'Location','northoutside', 'Orientation','horizontal')
yticklabels([])

ppretty([9,2.5])


end%fxn:plotSDFChoiceErr_ContraIpsi()
