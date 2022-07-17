function [ ] = Fig5_SDF_ErrTime_Accurate( behavData , unitData , varargin )
%Fig5_SDF_ErrTime_Accurate() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'unitID=',[]}});

if isempty(args.unitID)
  error('Please specify unit to plot')
end

PVAL_MW = .05;
TAIL_MW = 'both';

NUM_UNIT = 1;
unitTest = unitData(args.unitID,:);

OFFSET_PRE = 200;
tPlot = 3500 + (-OFFSET_PRE : 800); %plot time vector
NUM_SAMP = length(tPlot);

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
  
  RT_P = behavData.Sacc_RT{kk}; %RT of primary saccade
  RTerr = behavData.Sacc_RTerr{kk};
  tRew = RT_P + behavData.Task_TimeReward(kk); %time of reward - fixed re. saccade
  
  %compute spike density function and align appropriately
  spikes_uu = load_spikes_SAT(unitTest.Index(uu), 'user','thoma');
  sdfA = compute_spike_density_fxn(spikes_uu);  %sdf from Array
  sdfP = align_signal_on_response(sdfA, RT_P); %sdf from Primary
  sdfR = align_signal_on_response(sdfA, tRew); %sdf from Reward
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitTest.TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  idxErr = (behavData.Task_ErrTime{kk} & ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  %index by saccade octant re. response field (RF)
  Octant_Sacc1 = behavData.Sacc_Octant{kk};
  idxRF  = ismember(Octant_Sacc1, RFuu);
  
  %combine indexing
  idxAC = (idxAcc & idxCorr);
  idxAE = (idxAcc & idxErr );
    
  %% Compute mean SDF for response into RF
  sdfAC = NaN(NUM_SAMP,3); %re. array | primary | reward
  sdfAE = sdfAC;
  
  %Accurate correct
  sdfAC(:,1) = mean(sdfA(idxAC, tPlot));
  sdfAC(:,2) = nanmean(sdfP(idxAC, tPlot));
  sdfAC(:,3) = nanmean(sdfR(idxAC, tPlot));
  
  %Accurate timing error
  sdfAE(:,1) = mean(sdfA(idxAE, tPlot));
  sdfAE(:,2) = nanmean(sdfP(idxAE, tPlot));
  sdfAE(:,3) = nanmean(sdfR(idxAE, tPlot));

  [~, vecSig] = calc_tErrorSignal_SAT(sdfR(idxAC,tPlot), sdfR(idxAE,tPlot), ...
    'pvalMW',PVAL_MW, 'tailMW',TAIL_MW);
  
  subplot(1,3,[2 3]); hold on %Accurate re. reward
  plot(tPlot-3500, sdfAC(:,3), 'r')
  plot(tPlot-3500, sdfAE(:,3), ':', 'Color',[0.6 0 0], 'LineWidth',1.25)
  scatter(vecSig-OFFSET_PRE, 3, 10, [.1 .2 1], 'filled')
  xlabel('Time from reward (ms)'); xlim(tPlot([1,NUM_SAMP])-3500)
  xticks(-400 : 100 : 800)

  drawnow

  %set y-limits
  ylim2 = get(gca, 'ylim');
  subplot(1,3,1); ylim1 = get(gca, 'ylim');
  yLim = [0 max([ylim1 ylim2])];
  ylim(yLim); subplot(1,3,[2 3]); ylim(yLim)
  
end% for : unit (uu)

end % fxn : Fig5_SDF_ErrTime_Accurate()
