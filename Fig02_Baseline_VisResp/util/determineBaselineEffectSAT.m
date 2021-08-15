function [ varargout ] = determineBaselineEffectSAT( behavData , unitData , spikesSAT , varargin )
%determineBaselineEffectSAT This function tests for a significant effect of
%SAT condition on baseline discharge rate for single neurons. That actual
%test is the (non-parametric) Mann-Whitney U-test.
% 

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember(unitData.area, args.area);
idxMonkey = ismember(unitData.monkey, args.monkey);
idxKeep = (idxArea & idxMonkey);

NUM_CELLS = sum(idxKeep);
unitData = unitData(idxKeep,:);
spikesSAT = spikesSAT(idxKeep,:);

T_BASE  = 3500 + [-600, 20];

for cc = 1:NUM_CELLS
  kk = ismember(behavData.session, unitData.sess(cc));
  ccNS = unitData.unitNum(cc); %index nstats correctly
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData.trRemSAT{cc}, behavData.num_trials(kk));
  %index by trial outcome
  idxCorr = ~(behavData.err_dir{kk} | behavData.err_time{kk} | behavData.err_nosacc{kk} | behavData.err_hold{kk});
  %index by condition
  trialAcc = find((behavData.condition{kk} == 1) & idxCorr & ~idxIso);
  trialFast = find((behavData.condition{kk} == 3) & idxCorr & ~idxIso);
  
  nTrialAcc = length(trialAcc);
  nTrialFast = length(trialFast);
  
  spkCtAcc = NaN(1,nTrialAcc);
  for jj = 1:nTrialAcc
    spkTime_jj = spikesSAT{cc}{trialAcc(jj)};
    spkCtAcc(jj) = sum((spkTime_jj > T_BASE(1)) & (spkTime_jj < T_BASE(2)));
  end%for:trialAccurate(jj)
  
  spkCtFast = NaN(1,nTrialFast);
  for jj = 1:nTrialFast
    spkTime_jj = spikesSAT{cc}{trialFast(jj)};
    spkCtFast(jj) = sum((spkTime_jj > T_BASE(1)) & (spkTime_jj < T_BASE(2)));
  end%for:trialFast(jj)
  
  %Mann-Whitney U test for the difference between conditions (independent samples)
  [~,hSig,tmp] = ranksum(spkCtFast, spkCtAcc, 'alpha',0.05);
  if (hSig == 1)
    if (tmp.zval < 0) %Acc > Fast
      unitData.blineEffect(ccNS) = int8(-1);
    else %Fast > Acc
      unitData.blineEffect(ccNS) = int8(1);
    end
  else%no SAT effect on baseline
    unitData.blineEffect(ccNS) = int8(0);
  end
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = unitData;
end

%% Output
% unitData = unitData(idxKeep);
nFgA = sum((unitData.blineEffect ==  1));
nAgF = sum((unitData.blineEffect == -1));

fprintf('Number of neurons with Fast > Acc: %d/%d\n', nFgA, NUM_CELLS)
fprintf('Number of neurons with Acc > Fast: %d/%d\n', nAgF, NUM_CELLS)

end%fxn:determineBaselineEffectSAT()
