function [  ] = plot_SDF_ErrChoice( behavData , unitData , varargin )
%plot_SDF_X_Dir_RF_ErrChoice() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=',{'SEF'}}, {'monkey=',{'D','E'}}, {'uID=',[]}});

COMPUTE_TIMING = true;

if isempty(args.uID)
  idxArea = ismember(unitData.Area, args.area);
  idxMonkey = ismember(unitData.Monkey, args.monkey);
  idxFunction = ismember(unitData.Grade_Err, [-1,+1]);
  idxKeep = (idxArea & idxMonkey & idxFunction);
else % plot unit specified
  idxKeep = false(size(unitData,1),1);
  idxKeep(args.uID) = true;
end

NUM_UNIT = sum(idxKeep);
unitTest = unitData(idxKeep,:);

TLIM_PLOT = [-500,+500];
TVEC_PLOT = 3500 + (TLIM_PLOT(1) : TLIM_PLOT(2));
NSAMP_PLOT = length(TVEC_PLOT);

%store average SDF
sdfFC = cell(NUM_UNIT,1); %Fast correct
sdfAC = sdfFC; %Accurate correct
sdfFE = sdfFC; %Fast error
sdfAE = sdfFC; %Accurate error

for uu = 1:NUM_UNIT
  fprintf('%s \n', unitTest.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitTest.Session(uu));
  
  RT_P = behavData.Sacc_RT{kk}; %Primary saccade RT
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
  idxErr  = behavData.Task_ErrChoiceOnly{kk};
  
  %combine indexing
  idxAC = (idxAcc & idxCorr);    idxAE = (idxAcc & idxErr);
  idxFC = (idxFast & idxCorr);   idxFE = (idxFast & idxErr);
  
  %set "ISI" of correct trials as median ISI of error trials
  isiAE = ISI(idxAE);   medISI_AE = round(nanmedian(isiAE));
  isiFE = ISI(idxFE);   medISI_FE = round(nanmedian(isiFE));
  RT_S(idxAC) = RT_P(idxAC) + medISI_AE;
  RT_S(idxFC) = RT_P(idxFC) + medISI_FE;
  
  %compute spike density function and align appropriately
  spikes_uu = load_spikes_SAT(unitTest.Index(uu));
  sdfA = compute_spike_density_fxn(spikes_uu);  %sdf from Array
  sdfP = align_signal_on_response(sdfA, RT_P); %sdf from Primary
  sdfS = align_signal_on_response(sdfA, RT_S); %sdf from Second
  
  %% Compute mean SDF
  sdfFC{uu} = NaN(NSAMP_PLOT,3); % re. array | re. primary | re. second
  sdfFE{uu} = sdfFC{uu};
  sdfAC{uu} = sdfFC{uu};
  sdfAE{uu} = sdfFC{uu};
  
  %Correct trials - Fast
  sdfFC{uu}(:,1) = mean(sdfA(idxFC, TVEC_PLOT));
  sdfFC{uu}(:,2) = nanmean(sdfP(idxFC, TVEC_PLOT));
  sdfFC{uu}(:,3) = nanmean(sdfS(idxFC, TVEC_PLOT));
  %Correct trials - Accurate
  sdfAC{uu}(:,1) = mean(sdfA(idxAC, TVEC_PLOT));
  sdfAC{uu}(:,2) = nanmean(sdfP(idxAC, TVEC_PLOT));
  sdfAC{uu}(:,3) = nanmean(sdfS(idxAC, TVEC_PLOT));
  
  %Error trials - Fast
  sdfFE{uu}(:,1) = mean(sdfA(idxFE, TVEC_PLOT));
  sdfFE{uu}(:,2) = nanmean(sdfP(idxFE, TVEC_PLOT));
  sdfFE{uu}(:,3) = nanmean(sdfS(idxFE, TVEC_PLOT));
  %Error trials - Accurate
  sdfAE{uu}(:,1) = mean(sdfA(idxAE, TVEC_PLOT));
  sdfAE{uu}(:,2) = nanmean(sdfP(idxAE, TVEC_PLOT));
  sdfAE{uu}(:,3) = nanmean(sdfS(idxAE, TVEC_PLOT));
  
  %% Compute time of error signaling
  if (COMPUTE_TIMING)
    [~, vecSig_Fast_P] = calc_tErrorSignal_SAT(sdfP(idxFC, TVEC_PLOT), sdfP(idxFE, TVEC_PLOT)); %re. P
    [~, vecSig_Fast_S] = calc_tErrorSignal_SAT(sdfS(idxFC, TVEC_PLOT), sdfS(idxFE, TVEC_PLOT)); %re. S
    [~, vecSig_Acc_P]  = calc_tErrorSignal_SAT(sdfP(idxAC, TVEC_PLOT), sdfP(idxAE, TVEC_PLOT));
    [~, vecSig_Acc_S]  = calc_tErrorSignal_SAT(sdfS(idxAC, TVEC_PLOT), sdfS(idxAE, TVEC_PLOT));
  end
  
  %% Plotting
  GREEN = [0 .7 0];
  SIGDOT_SIZE = 10;
  yLim = [0, max([sdfAC{uu} sdfFC{uu} sdfAE{uu} sdfFE{uu}],[],'all')];
  xLim = TVEC_PLOT([1,NSAMP_PLOT]) - 3500;

  subplot(2,3,1); hold on %Fast re. array
  title([unitTest.Properties.RowNames{uu},'-',unitTest.Area{uu}], 'FontSize',9)
  plot(TVEC_PLOT-3500, sdfFC{uu}(:,1), 'Color',GREEN, 'LineWidth',1.25)
  plot(TVEC_PLOT-3500, sdfFE{uu}(:,1), ':', 'Color',GREEN, 'LineWidth',1.25)
  xlim(xLim); ylim(yLim);

  subplot(2,3,2); hold on %Fast re. primary
  plot(TVEC_PLOT-3500, sdfFC{uu}(:,2), 'Color',GREEN, 'LineWidth',1.25)
  plot(TVEC_PLOT-3500, sdfFE{uu}(:,2), ':', 'Color',GREEN, 'LineWidth',1.25)
  if (COMPUTE_TIMING); scatter(TLIM_PLOT(1)+vecSig_Fast_P, yLim(2)/25, SIGDOT_SIZE, 'k'); end
  xlim(xLim); ylim(yLim); set(gca, 'YColor','none')

  subplot(2,3,3); hold on %Fast re. second
  plot(TVEC_PLOT-3500, sdfFC{uu}(:,3), 'Color',GREEN, 'LineWidth',1.25)
  plot(TVEC_PLOT-3500, sdfFE{uu}(:,3), ':', 'Color',GREEN, 'LineWidth',1.25)
  if (COMPUTE_TIMING); scatter(TLIM_PLOT(1)+vecSig_Fast_S, yLim(2)/25, SIGDOT_SIZE, 'k'); end
  xlim(xLim); ylim(yLim); set(gca, 'YColor','none')

  subplot(2,3,4); hold on %Accurate re. array
  plot(TVEC_PLOT-3500, sdfAC{uu}(:,1), 'r', 'LineWidth',1.25)
  plot(TVEC_PLOT-3500, sdfAE{uu}(:,1), 'r:', 'LineWidth',1.25)
  ylabel('Activity (sp/sec)')
  xlabel('Time from array (ms)')
  xlim(xLim); ylim(yLim)

  subplot(2,3,5); hold on %Accurate re. primary
  plot(TVEC_PLOT-3500, sdfAC{uu}(:,2), 'r', 'LineWidth',1.25)
  plot(TVEC_PLOT-3500, sdfAE{uu}(:,2), 'r:', 'LineWidth',1.25)
  if (COMPUTE_TIMING); scatter(TLIM_PLOT(1)+vecSig_Acc_P, yLim(2)/25, SIGDOT_SIZE, 'k'); end
  xlabel('Time from primary saccade (ms)')
  xlim(xLim); ylim(yLim); set(gca, 'YColor','none')

  subplot(2,3,6); hold on %Accurate re. second
  plot(TVEC_PLOT-3500, sdfAC{uu}(:,3), 'r', 'LineWidth',1.25)
  plot(TVEC_PLOT-3500, sdfAE{uu}(:,3), 'r:', 'LineWidth',1.25)
  if (COMPUTE_TIMING); scatter(TLIM_PLOT(1)+vecSig_Acc_S, yLim(2)/25, SIGDOT_SIZE, 'k'); end
  xlabel('Time from second saccade (ms)')
  xlim(xLim); ylim(yLim); set(gca, 'YColor','none')

  ppretty([8,2.4])
  drawnow

end % for : unit(uu)

end % fxn : plot_SDF_ErrChoice()
