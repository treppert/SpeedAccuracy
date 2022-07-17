function [ ] = Fig5_SDF_ErrChoice_Fast( behavData , unitData , varargin )
%Fig5_SDF_ErrChoice_Fast() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'unitID=',[]}});

if isempty(args.unitID)
  error('Please specify unit to plot')
end

PVAL_MW = .05;
TAIL_MW = 'both';

NUM_UNIT = 1;
unitTest = unitData(args.unitID,:);

tLim_Plot = [-100,+400];
tPlot = 3500 + (tLim_Plot(1) : tLim_Plot(2));
nSamp_Plot = length(tPlot);

tLim_Test = [-100,+500];
tTest = 3500 + (tLim_Test(1) : tLim_Test(2));

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
  
  %combine indexing
  idxAC = (idxAcc & idxCorr);    idxAE = (idxAcc & idxErr);
  idxFC = (idxFast & idxCorr);   idxFE = (idxFast & idxErr);
  
  %set "ISI" of correct trials as median ISI of error trials
  isiAE = ISI(idxAE);   medISI_AE = round(nanmedian(isiAE));
  isiFE = ISI(idxFE);   medISI_FE = round(nanmedian(isiFE));
  RT_S(idxAC) = RT_P(idxAC) + medISI_AE;
  RT_S(idxFC) = RT_P(idxFC) + medISI_FE;
  
  %compute spike density function and align appropriately
  spikes_uu = load_spikes_SAT(unitTest.Index(uu), 'user','thoma');
  sdfA = compute_spike_density_fxn(spikes_uu);  %sdf from Array
  sdfP = align_signal_on_response(sdfA, RT_P); %sdf from Primary
  sdfS = align_signal_on_response(sdfA, RT_S); %sdf from Second
  
  %% Compute mean SDF for response into RF
  sdfFC = NaN(nSamp_Plot,3); % re. array | re. primary | re. second
  sdfFE = sdfFC;
  
  %Correct trials - Fast
  sdfFC(:,1) = mean(sdfA(idxFC, tPlot));
  sdfFC(:,2) = nanmean(sdfP(idxFC, tPlot));
  sdfFC(:,3) = nanmean(sdfS(idxFC, tPlot));
  
  %Error trials - Fast
  sdfFE(:,1) = mean(sdfA(idxFE, tPlot));
  sdfFE(:,2) = nanmean(sdfP(idxFE, tPlot));
  sdfFE(:,3) = nanmean(sdfS(idxFE, tPlot));
  
  %Compute time of signaling: primary saccade into RF
  [~, vecSig_1] = calc_tErrorSignal_SAT(sdfP(idxFC, tTest), sdfP(idxFE, tTest), ...
     'pvalMW',PVAL_MW, 'tailMW',TAIL_MW);
  
  %% Plot: Mean SDF for response into RF
  xLim = tPlot([1,nSamp_Plot]) - 3500;

  subplot(1,3,1); hold on %Fast re. primary
  ylabel(unitTest.Row{uu})
  plot(tPlot-3500, sdfFC(:,2), 'Color',[0 .7 0], 'LineWidth',1.25)
  plot(tPlot-3500, sdfFE(:,2), ':', 'Color',[0 .7 0], 'LineWidth',1.25)
  scatter(tLim_Plot(1)+vecSig_1, 5, 10, 'k')
  xlim(xLim)

  drawnow

end % for : unit(uu)

end % fxn : Fig5_SDF_ErrChoice_Fast()
