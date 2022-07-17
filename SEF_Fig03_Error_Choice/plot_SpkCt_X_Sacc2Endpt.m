function [ ] = plot_SpkCt_X_Sacc2Endpt( behavData , unitData )
%plot_SpkCt_X_Sacc2Endpt Summary of this function goes here
%   Detailed explanation goes here

%initializations
NUM_UNIT = size(unitData,1);
spkCt_Sacc2T = NaN(NUM_UNIT,2); % Fast | Accurate
spkCt_Sacc2D = NaN(NUM_UNIT,2);

for uu = 1:NUM_UNIT
  fprintf('%s \n', unitData.Properties.RowNames{uu})
  kk = ismember(behavData.Task_Session, unitData.Session(uu));
  RT_kk = double(behavData.Sacc_RT{kk});
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitData.TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by task condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1) & ~idxIso;
  idxFast = (behavData.Task_SATCondition{kk} == 3) & ~idxIso;
  %index by trial outcome
  idxErr = behavData.Task_ErrChoiceOnly{kk};
  
  %index by second saccade endpoint
  idxTgt = (behavData.Sacc2_Endpoint{kk} == 1);
  idxDistr = (behavData.Sacc2_Endpoint{kk} == 2);
  idxFix = (behavData.Sacc2_Endpoint{kk} == 3);
  
  %index by saccade direction re. RF
  Octant_Sacc2 = behavData.Sacc2_Octant{kk};
  RF = unitData.RF{uu};
  idxRF = ismember(Octant_Sacc2, RF);
  
  idxFastT = (idxFast & idxErr & idxTgt & idxRF);
  idxFastD = (idxFast & idxErr & (idxDistr | idxFix) & idxRF);
  idxAccT  = (idxAcc & idxErr & idxTgt & idxRF);
  idxAccD  = (idxAcc & idxErr & (idxDistr | idxFix) & idxRF);
  
  %get times of error-related modulation for this neuron
  RT_Fast = median(RT_kk(idxFast & idxErr & idxRF));
  RT_Acc = median(RT_kk(idxAcc & idxErr & idxRF));
  tFast = 3500 + RT_Fast + unitData.SignalCE_Time_P(uu,1:2);
  tAcc = 3500 + RT_Acc + unitData.SignalCE_Time_P(uu,3:4);
  
  %compute spike count
  spikes_uu = load_spikes_SAT(unitData.Index(uu));
  spkCt_FastT_jj = cellfun(@(x) sum((x >= tFast(1)) & (x <= tFast(2))), spikes_uu(idxFastT))';
  spkCt_FastD_jj = cellfun(@(x) sum((x >= tFast(1)) & (x <= tFast(2))), spikes_uu(idxFastD))';
  spkCt_AccT_jj = cellfun(@(x) sum((x >= tAcc(1)) & (x <= tAcc(2))), spikes_uu(idxAccT))';
  spkCt_AccD_jj = cellfun(@(x) sum((x >= tAcc(1)) & (x <= tAcc(2))), spikes_uu(idxAccD))';
  
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

