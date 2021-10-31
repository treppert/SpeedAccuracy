function [ varargout ] = determineBaselineEffectSAT( behavData , unitData , spikesSAT , varargin )
%determineBaselineEffectSAT This function tests for a significant effect of
%SAT condition on baseline discharge rate for single neurons. That actual
%test is the (non-parametric) Mann-Whitney U-test.
% 

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember(unitData.aArea, args.area);
idxMonkey = ismember(unitData.aMonkey, args.monkey);
idxKeep = (idxArea & idxMonkey);

NUM_CELLS = sum(idxKeep);
unitData = unitData(idxKeep,:);
spikesSAT = spikesSAT(idxKeep,:);

T_BASE  = 3500 + [-600, 20];

for uu = 1:NUM_CELLS
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  uuNS = unitData.unitNum(uu); %index unitData correctly
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrNoSacc{kk} | behavData.Task_ErrHold{kk});
  %index by condition
  trialAcc = find((behavData.Task_Condition{kk} == 1) & idxCorr & ~idxIso);
  trialFast = find((behavData.Task_Condition{kk} == 3) & idxCorr & ~idxIso);
  
  nTrialAcc = length(trialAcc);
  nTrialFast = length(trialFast);
  
  spkCtAcc = NaN(1,nTrialAcc);
  for jj = 1:nTrialAcc
    spkTime_jj = spikesSAT{uu}{trialAcc(jj)};
    spkCtAcc(jj) = sum((spkTime_jj > T_BASE(1)) & (spkTime_jj < T_BASE(2)));
  end%for:trialAccurate(jj)
  
  spkCtFast = NaN(1,nTrialFast);
  for jj = 1:nTrialFast
    spkTime_jj = spikesSAT{uu}{trialFast(jj)};
    spkCtFast(jj) = sum((spkTime_jj > T_BASE(1)) & (spkTime_jj < T_BASE(2)));
  end%for:trialFast(jj)
  
  %Mann-Whitney U test for the difference between conditions (independent samples)
  [~,hSig,tmp] = ranksum(spkCtFast, spkCtAcc, 'alpha',0.05);
  if (hSig == 1)
    if (tmp.zval < 0) %Acc > Fast
      unitData.Baseline_SAT_Effect(uuNS) = int8(-1);
    else %Fast > Acc
      unitData.Baseline_SAT_Effect(uuNS) = int8(1);
    end
  else%no SAT effect on baseline
    unitData.Baseline_SAT_Effect(uuNS) = int8(0);
  end
end%for:cells(uu)

if (nargout > 0)
  varargout{1} = unitData;
end

%% Output
% unitData = unitData(idxKeep);
nFgA = sum((unitData.Baseline_SAT_Effect ==  1));
nAgF = sum((unitData.Baseline_SAT_Effect == -1));

fprintf('Number of neurons with Fast > Acc: %d/%d\n', nFgA, NUM_CELLS)
fprintf('Number of neurons with Acc > Fast: %d/%d\n', nAgF, NUM_CELLS)

end%fxn:determineBaselineEffectSAT()
