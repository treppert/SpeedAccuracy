function [ varargout ] = testBaselineSATEffect_X_Neuron( binfo , ninfo , nstats , spikes )
%testBaselineSATEffect_X_Neuron This function tests for a significant effect of
%SAT condition on baseline discharge rate for single neurons. That actual
%test is the (non-parametric) Mann-Whitney U-test.
% 

AREA = {'SEF'};
MONKEY = {'D','E','Q','S'};

idxArea = ismember(ninfo.area, AREA);
idxMonkey = ismember(ninfo.monkey, MONKEY);

idxVis = (ninfo.visGrade >= 2);   idxMove = (ninfo.moveGrade >= 2);
idxErr = (ninfo.errGrade >= 2);   idxRew = (abs(ninfo.rewGrade) >= 2);

idxKeep = (idxArea & idxMonkey & (idxVis | idxMove));
% idxKeep = (idxArea & idxMonkey & (idxMove));

NUM_CELLS = sum(idxKeep);
spikes = spikes(idxKeep);
ninfo = ninfo(idxKeep,:);

T_BASE  = 3500 + [-600, 20];

for cc = 1:NUM_CELLS
  
  kk = ismember(binfo.session, ninfo.sess{cc}); %cross-reference session number
  ccNS = ninfo.unitNum(cc); %index nstats correctly
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo.trRemSAT{cc}, binfo.num_trials(kk));
  %index by trial outcome
  idxCorr = ~(binfo.err_dir{kk} | binfo.err_time{kk} | binfo.err_nosacc{kk} | binfo.err_hold{kk});
  %index by condition
  trialAcc = find((binfo.condition{kk} == 1) & idxCorr & ~idxIso);
  trialFast = find((binfo.condition{kk} == 3) & idxCorr & ~idxIso);
  
  nTrialAcc = length(trialAcc);
  nTrialFast = length(trialFast);
  
  spkCtAcc = NaN(1,nTrialAcc);
  for jj = 1:nTrialAcc
    spkTime_jj = spikes{cc}{trialAcc(jj)};
    spkCtAcc(jj) = sum((spkTime_jj > T_BASE(1)) & (spkTime_jj < T_BASE(2)));
  end%for:trialAccurate(jj)
  
  spkCtFast = NaN(1,nTrialFast);
  for jj = 1:nTrialFast
    spkTime_jj = spikes{cc}{trialFast(jj)};
    spkCtFast(jj) = sum((spkTime_jj > T_BASE(1)) & (spkTime_jj < T_BASE(2)));
  end%for:trialFast(jj)
  
  %Mann-Whitney U test for the difference between conditions (independent samples)
  [~,hSig,tmp] = ranksum(spkCtFast, spkCtAcc, 'alpha',0.05);
  if (hSig == 1)
    if (tmp.zval < 0) %Acc > Fast
      nstats.blineEffect(ccNS) = -1;
    else %Fast > Acc
      nstats.blineEffect(ccNS) = 1;
    end
  else%no SAT effect on baseline
    nstats.blineEffect(ccNS) = 0;
  end
end%for:cells(cc)

if (nargout > 0) %if specify nstats as output, then update values
  varargout{1} = nstats;
end

%% Output
nstats = nstats(idxKeep,:);
nFgA = sum((nstats.blineEffect ==  1));
nAgF = sum((nstats.blineEffect == -1));
nNoEffect = NUM_CELLS - (nFgA + nAgF);

fprintf('Number of neurons with Fast > Acc: %d/%d = %d%%\n', nFgA, NUM_CELLS, 100*nFgA/NUM_CELLS)
fprintf('Number of neurons with Acc > Fast: %d/%d = %d%%\n', nAgF, NUM_CELLS, 100*nAgF/NUM_CELLS)
fprintf('Number of neurons with no effect: %d/%d = %d%%\n', nNoEffect, NUM_CELLS, 100*nNoEffect/NUM_CELLS)

end % fxn : testBaselineSATEffect_X_Neuron()
