function [ ] = plot_SpkCt_X_Sacc2Endpt( behavData , unitData , spikesSAT )
%plot_SpkCt_X_Sacc2Endpt Summary of this function goes here
%   Detailed explanation goes here

%initializations
NUM_UNIT = size(unitData,1);
spkCt_Sacc2T = NaN(NUM_UNIT,2); % Fast | Accurate
spkCt_Sacc2D = NaN(NUM_UNIT,2);

for uu = 1:NUM_UNIT
  fprintf('%s \n', unitData.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  RT_kk = double(behavData.Sacc_RT{kk});
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by task condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  %index by trial outcome
  idxErr = (behavData.Task_ErrChoice{kk} & ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  
  %index by second saccade endpoint
  idxTgt = (behavData.Sacc2_Endpoint{kk} == 1);
  idxDistr = (behavData.Sacc2_Endpoint{kk} == 2);
  idxFix = (behavData.Sacc2_Endpoint{kk} == 3);
  
  %index by saccade direction re. RF
  Octant_Sacc2 = behavData.Sacc2_Octant{kk};
  RF = unitData.RF{uu};
  
  if ( isempty(RF) || (ismember(9,RF)) ) %average over all possible directions
    idxRF = true(behavData.Task_NumTrials(kk),1);
  else %average only trials with saccade into RF
    idxRF = ismember(Octant_Sacc2, RF);
  end
  
  idxFastT = (idxFast & idxErr & idxTgt & idxRF & ~idxIso);
  idxFastD = (idxFast & idxErr & (idxDistr | idxFix) & idxRF & ~idxIso);
  idxAccT  = (idxAcc & idxErr & idxTgt & idxRF & ~idxIso);
  idxAccD  = (idxAcc & idxErr & (idxDistr | idxFix) & idxRF & ~idxIso);
  
  %get times of error-related modulation for this neuron
  RT_Fast = median(RT_kk(idxFast & idxErr & idxRF));
  RT_Acc = median(RT_kk(idxAcc & idxErr & idxRF));
  tFast = 3500 + RT_Fast + unitData.ErrorSignal_Time(uu,1:2);
  tAcc = 3500 + RT_Acc + unitData.ErrorSignal_Time(uu,3:4);
  
  %compute spike count
  spkCt_FastT_jj = cellfun(@(x) sum((x >= tFast(1)) & (x <= tFast(2))), spikesSAT{uu}(idxFastT))';
  spkCt_FastD_jj = cellfun(@(x) sum((x >= tFast(1)) & (x <= tFast(2))), spikesSAT{uu}(idxFastD))';
  spkCt_AccT_jj = cellfun(@(x) sum((x >= tAcc(1)) & (x <= tAcc(2))), spikesSAT{uu}(idxAccT))';
  spkCt_AccD_jj = cellfun(@(x) sum((x >= tAcc(1)) & (x <= tAcc(2))), spikesSAT{uu}(idxAccD))';
  
  spkCt_Sacc2T(uu,:) = [mean(spkCt_FastT_jj) mean(spkCt_AccT_jj)];
  spkCt_Sacc2D(uu,:) = [mean(spkCt_FastD_jj) mean(spkCt_AccD_jj)];
  
end %for : cells (jj)

figure(); hold on
title('Sacc2Tgt vs. Sacc2Distr', 'FontSize',9)
histogram(spkCt_Sacc2T(:,1) - spkCt_Sacc2D(:,1), 'FaceColor',[0 .7 0], 'BinEdges',-10:2:10)
histogram(spkCt_Sacc2T(:,2) - spkCt_Sacc2D(:,2), 'FaceColor','r', 'BinEdges',-10:2:10)
xlabel('Spike count difference')
ylabel('No. of neurons')
ppretty([3,3])

clearvars -except behavData spikesSAT unitData
end % fxn : plot_SpkCt_X_Sacc2Endpt()

