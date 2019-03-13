function [ varargout ] = computeBlineSpkCtXcondSAT( binfo , ninfo , spikes , varargin )
%computeBlineSpkCtXcondSAT Summary of this function goes here
%   Not currently including cells for which Acc > Fast.

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idx_area = ismember({ninfo.area}, args.area);
idx_monkey = ismember({ninfo.monkey}, args.monkey);

ninfo = ninfo(idx_area & idx_monkey);
spikes = spikes(idx_area & idx_monkey);

NUM_CELLS = length(spikes);
T_BASE  = 3500 + [-700, -1];

spkCtAcc = cell(1,NUM_CELLS); %baseline spike counts
spkCtFast = cell(1,NUM_CELLS);
hVal = NaN(1,NUM_CELLS); %stats
pVal = NaN(1,NUM_CELLS);

meanAcc = NaN(1,NUM_CELLS); %mean spike counts for plotting
meanFast = NaN(1,NUM_CELLS);

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);

  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  trialAcc = find((binfo(kk).condition == 1) & ~idxIso);
  trialFast = find((binfo(kk).condition == 3) & ~idxIso);
  
  numTrialAcc = length(trialAcc);
  numTrialFast = length(trialFast);
  
  spkCtAcc{cc} = NaN(1,numTrialAcc);
  for jj = 1:numTrialAcc
    spkTime_jj = spikes(cc).SAT{trialAcc(jj)};
    spkCtAcc{cc}(jj) = sum((spkTime_jj > T_BASE(1)) & (spkTime_jj < T_BASE(2)));
  end%for:trial(jj)
  meanAcc(cc) = mean(spkCtAcc{cc});
  
  spkCtFast{cc} = NaN(1,numTrialFast);
  for jj = 1:numTrialFast
    spkTime_jj = spikes(cc).SAT{trialFast(jj)};
    spkCtFast{cc}(jj) = sum((spkTime_jj > T_BASE(1)) & (spkTime_jj < T_BASE(2)));
  end%for:trial(jj)
  meanFast(cc) = mean(spkCtFast{cc});
  
  %compute stats for individual cells
  [hVal(cc),pVal(cc),~,tmp] = ttest2(spkCtFast{cc}, spkCtAcc{cc});
  if (hVal(cc) && (tmp.tstat < 0)); hVal(cc) = -1; end %not including cells Acc > Fast
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = struct('Acc',spkCtAcc, 'Fast',spkCtFast);
  if (nargout > 1)
    varargout{2} = struct('hVal',hVal, 'pVal',pVal);
  end
end

end%fxn:computeBlineSpkCtXcondSAT()

