function [ varargout ] = computeBlineSpkCtXcondSAT( binfo , ninfo , nstats , spikes , varargin )
%computeBlineSpkCtXcondSAT Summary of this function goes here
%   Not currently including cells for which Acc > Fast.

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxVis = ([ninfo.visGrade] >= 2);   idxMove = ([ninfo.moveGrade] >= 2);
idxErr = ([ninfo.errGrade] >= 2);   idxRew = (abs([ninfo.rewGrade]) >= 2);
idxEff = ([ninfo.taskType] == 2);

idxKeep = (idxArea & idxMonkey);

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);
NUM_CELLS = length(spikes);

T_BASE  = 3500 + [-600, 20];

spkCtAcc = cell(1,NUM_CELLS); %baseline spike counts per trial
spkCtFast = cell(1,NUM_CELLS);

meanAcc = NaN(1,NUM_CELLS); %mean spike counts for plotting
meanFast = NaN(1,NUM_CELLS);

pVal = NaN(1,NUM_CELLS); %p-value from Mann-Whitney U test of effect of condition

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);

  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc);
  %index by condition
  trialAcc = find((binfo(kk).condition == 1) & idxCorr & ~idxIso);
  trialFast = find((binfo(kk).condition == 3) & idxCorr & ~idxIso);
  
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
  
  %Mann-Whitney U test for the difference between conditions (independent samples)
  ccNS = ninfo(cc).unitNum; %index nstats correctly
  [pVal(cc),hVal,tmp] = ranksum(spkCtFast{cc}, spkCtAcc{cc}, 'alpha',0.06);
  if (hVal == 1)
    if (tmp.zval < 0) %Acc > Fast
      nstats(ccNS).blineEffect = -1;
    else %Fast > Acc
      nstats(ccNS).blineEffect = 1;
    end
  else%no SAT effect on baseline
    nstats(ccNS).blineEffect = 0;
  end
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = nstats;
end

%% Plotting
nstats = nstats(idxKeep);
ccFgA = ([nstats.blineEffect] == 1);
ccAgF = ([nstats.blineEffect] == -1);
ccNgN = ([nstats.blineEffect] == 0);

figure(); hold on %histogram of p-values of Mann-Whitney U test
histogram(-log(pVal(ccNgN)), 'FaceColor',[.4 .4 .4], 'BinWidth',1)
histogram(-log(pVal(ccFgA)), 'FaceColor',[0 .7 0], 'BinWidth',1)
histogram(-log(pVal(ccAgF)), 'FaceColor','r', 'BinWidth',1)
plot(-log(.05)*ones(1,2), [0 5], 'k--', 'LineWidth',1.25)
plot(-log(.01)*ones(1,2), [0 5], 'k--', 'LineWidth',1.25)
plot(-log(.001)*ones(1,2), [0 5], 'k--', 'LineWidth',1.25)
xlabel('-log(p)')
ylabel('Number of neurons')
% xlim([0 40])
ppretty([3.2,2])

end%fxn:computeBlineSpkCtXcondSAT()
