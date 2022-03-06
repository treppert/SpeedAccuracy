% function [ ] = FigS5_ErrorTime_X_ErrorChoice( behavData , unitData , spikesSAT )
%FigS5_ErrorTime_X_ErrorChoice() Summary of this function goes here
%   Detailed explanation goes here

idxSEF = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});
idxCErrUnit = ismember(unitData.Grade_Err, 1);
idxTErrUnit = ismember(unitData.Grade_Rew, 2);

idxKeep = (idxSEF & idxMonkey & (idxCErrUnit | idxTErrUnit));

NUM_UNIT = sum(idxKeep);
unitDataTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

tCount_ChcErr = 3500 + (0:400);
tCount_TimeErr = 3500 + (100:500);

%initialization -- contrast ratio (A_err - A_corr) / (A_err + A_corr)
CR_Acc_TE = NaN(NUM_UNIT,1);
CR_Fast_CE = CR_Acc_TE;

for uu = 1:NUM_UNIT
  kk = ismember(behavData.Task_Session, unitDataTest.Task_Session(uu));
  RT_kk = behavData.Sacc_RT{kk};
  tRew_kk = RT_kk + behavData.Task_TimeReward{kk};
  
  %compute spike density function and align on primary response
  sdfA_kk = compute_spike_density_fxn(spikesTest{uu});  %sdf from Array
  sdfP_kk = align_signal_on_response(sdfA_kk, RT_kk); %sdf from Primary
  sdfR_kk = align_signal_on_response(sdfA_kk, round(tRew_kk)); %sdf from Reward
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitDataTest.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by screen clear on Fast trials
  idxClear = logical(behavData.Task_ClearDisplayFast{kk});
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  idxErrChc = (behavData.Task_ErrChoice{kk} & ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  idxErrTime = (behavData.Task_ErrTime{kk} & ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  %index by condition
  idxFast = (behavData.Task_SATCondition{kk} == 3 & ~idxIso & ~idxClear);
  idxAcc = (behavData.Task_SATCondition{kk} == 1 & ~idxIso);
  
  %index by saccade octant re. response field (RF)
  Octant_Sacc1 = behavData.Sacc_Octant{kk};
  RF = unitDataTest.RF{uu};
  
  if ( isempty(RF) || (ismember(9,RF)) ) %average over all possible directions
    idxRF = true(behavData.Task_NumTrials(kk),1);
  else %average only trials with saccade into RF
    idxRF = ismember(Octant_Sacc1, RF);
  end
  
  idxFC = (idxFast & idxCorr & idxRF);
  idxAC = (idxAcc  & idxCorr & idxRF);
  idxFE = (idxFast & idxErrChc & idxRF); %Fast choice error
  idxAE = (idxAcc & idxErrTime & idxRF); %Accurate timing error
  
  meanSDF_FC = nanmean(sdfP_kk(idxFC, tCount_ChcErr));
  meanSDF_FE = nanmean(sdfP_kk(idxFE, tCount_ChcErr));
  meanSDF_AC = nanmean(sdfR_kk(idxAC, tCount_TimeErr));
  meanSDF_AE = nanmean(sdfR_kk(idxAE, tCount_TimeErr));
  
  %compute contrast ratios
  muAC = mean(meanSDF_AC);  muAE = mean(meanSDF_AE);
  muFC = mean(meanSDF_FC);  muFE = mean(meanSDF_FE);
  CR_Acc_TE(uu)  = (muAE - muAC) / (muAE + muAC);
  CR_Fast_CE(uu) = (muFE - muFC) / (muFE + muFC);
  
end%for:cells(uu)

%split into three groups (only CE, only TE, and both)
idxCErrUnit = ismember(unitDataTest.Grade_Err, 1);
idxTErrUnit = ismember(unitDataTest.Grade_Rew, 2);
idxCE_Only = (idxCErrUnit & ~idxTErrUnit);
idxTE_Only = (~idxCErrUnit & idxTErrUnit);
idx_Both = (idxCErrUnit & idxTErrUnit);

%% Plotting - Contrast ratio

figure(); hold on
scatter(CR_Fast_CE(idxCE_Only), CR_Acc_TE(idxCE_Only), 30, [0 .7 0], 'filled')
scatter(CR_Fast_CE(idxTE_Only), CR_Acc_TE(idxTE_Only), 30, 'r', 'filled')
scatter(CR_Fast_CE(idx_Both), CR_Acc_TE(idx_Both), 30, 'k', 'filled')
line([0 0], [-.2 .6], 'Color','k', 'LineStyle',':')
line([-.2 .6], [0 0], 'Color','k', 'LineStyle',':')
xlabel('Contrast ratio - Choice error')
ylabel('Contrast ratio - Timing error')
ppretty([3.2,2])

clearvars -except behavData unitData spikesSAT
% end%fxn:FigS5_ErrorTime_X_ErrorChoice()


