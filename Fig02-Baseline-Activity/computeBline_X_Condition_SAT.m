function [ ] = computeBline_X_Condition_SAT( binfo , ninfo , spikes , varargin )
%computeBline_X_Condition_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxVis = ([ninfo.visGrade] >= 2);   idxMove = ([ninfo.moveGrade] >= 2);
idxKeep = (idxArea & idxMonkey & (idxVis | idxMove));

NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

T_BLINE = 3500 + [-600 20];

%initializations
spkCountAcc = NaN(1,NUM_CELLS);
spkCountFast = NaN(1,NUM_CELLS);
% zSpkCtAcc = NaN(NUM_CELLS,NBIN_ACC);
% zSpkCtFast = NaN(NUM_CELLS,NBIN_FAST);

for cc = 1:NUM_CELLS
  %compute spike count for all trials
  spkCtCC = cellfun(@(x) sum((x > T_BLINE(1)) & (x < T_BLINE(2))), spikes(cc).SAT);
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_time | binfo(kk).err_hold | binfo(kk).err_nosacc);
  %index by condition and RT limits
  idxAcc = ((binfo(kk).condition == 1) & idxCorr & ~idxIso);
  idxFast = ((binfo(kk).condition == 3) & idxCorr & ~idxIso);
  
  %compute trial-wise spike counts per task condition
  scAccCC = spkCtCC(idxAcc);
  scFastCC = spkCtCC(idxFast);
  
  %remove outliers
  if (nanmedian(scAccCC) >= 1) %make sure we have a minimum spike count
    idxCutAcc = estimate_spread(scAccCC, 3.5);      scAccCC(idxCutAcc) = [];
    idxCutFast = estimate_spread(scFastCC, 3.5);    scFastCC(idxCutFast) = [];
  end
  
  %z-score spike counts
  muSpkCt = mean([scAccCC scFastCC]);
  sdSpkCt = std([scAccCC scFastCC]);
  scAccCC = (scAccCC - muSpkCt) / sdSpkCt;
  scFastCC = (scFastCC - muSpkCt) / sdSpkCt;
    
  %save median spike counts
  spkCountAcc(cc) = mean(scAccCC);
  spkCountFast(cc) = mean(scFastCC);
  
end%for:cells(cc)

%split by search efficiency
ccMore = ([ninfo.taskType] == 1);   NUM_MORE = sum(ccMore);
ccLess = ([ninfo.taskType] == 2);   NUM_LESS = sum(ccLess);

scAccMore = spkCountAcc(ccMore);    scAccLess = spkCountAcc(ccLess);
scFastMore = spkCountFast(ccMore);  scFastLess = spkCountFast(ccLess);

%% Plotting

muAccMore = mean(scAccMore);    seAccMore = std(scAccMore) / sqrt(NUM_MORE);
muAccLess = mean(scAccLess);    seAccLess = std(scAccLess) / sqrt(NUM_LESS);
muFastMore = mean(scFastMore);    seFastMore = std(scFastMore) / sqrt(NUM_MORE);
muFastLess = mean(scFastLess);    seFastLess = std(scFastLess) / sqrt(NUM_LESS);

figure(); hold on
bar((1:4), [muAccMore muFastMore muAccLess muFastLess], 0.6, 'FaceColor',[.4 .4 .4], 'LineWidth',0.25)
errorbar((1:4), [muAccMore muFastMore muAccLess muFastLess], [seAccMore seFastMore seAccLess seFastLess], 'Color','k', 'CapSize',0)
ppretty([1.5,3])

end%fxn:computeBline_X_Condition_SAT()

