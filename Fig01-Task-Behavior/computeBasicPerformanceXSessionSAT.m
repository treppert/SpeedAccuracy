function [ ] = computeBasicPerformanceXSessionSAT(binfo, moves, varargin)
%computeBasicPerformanceXSessionSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

MIN_NUM_TRIALS = 500;

idxMonkey = ismember({binfo.monkey}, args.monkey);
idxNumTrials = ([binfo.num_trials] > MIN_NUM_TRIALS);

binfo = binfo(idxMonkey & idxNumTrials); NUM_SESSION = length(binfo);
moves = moves(idxMonkey & idxNumTrials);

if ((length(args.monkey) == 1) && ismember(args.monkey, {'D','E'})) %remove sessions with no SEF
  binfo(1) = []; NUM_SESSION = NUM_SESSION - 1;
  moves(1) = [];
end

dlineAcc = NaN(1,NUM_SESSION);
dlineFast = NaN(1,NUM_SESSION);

RTAcc = NaN(1,NUM_SESSION);
RTFast = NaN(1,NUM_SESSION);

PerrChcAcc = NaN(1,NUM_SESSION);
PerrChcFast = NaN(1,NUM_SESSION);

PerrTimeAcc = NaN(1,NUM_SESSION);
PerrTimeFast = NaN(1,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc);
  idxErrChc = binfo(kk).err_dir & ~binfo(kk).err_time;
  idxErrTime = binfo(kk).err_time & ~binfo(kk).err_dir;
  
  dlineAcc(kk) = nanmedian(binfo(kk).tgt_dline(idxAcc));
  dlineFast(kk) = median(binfo(kk).tgt_dline(idxFast));
  
  RTAcc(kk) = median(moves(kk).resptime(idxAcc & idxCorr));
  RTFast(kk) = median(moves(kk).resptime(idxFast & idxCorr));
  
  PerrChcAcc(kk) = sum(idxAcc & idxErrChc) / sum(idxAcc);
  PerrChcFast(kk) = sum(idxFast & idxErrChc) / sum(idxFast);
  
  PerrTimeAcc(kk) = sum(idxAcc & idxErrTime) / sum(idxAcc);
  PerrTimeFast(kk) = sum(idxFast & idxErrTime) / sum(idxFast);
  
end%for:session(kk)

[~,pvalRT,~,tmpRT] = ttest(RTAcc-RTFast);
dofRT = tmpRT.df; tstatRT = tmpRT.tstat;

[~,pvalPErrChc,~,tmpPErrChc] = ttest(PerrChcFast-PerrChcAcc);
dofPErrChc = tmpPErrChc.df; tstatPErrChc = tmpPErrChc.tstat;

[~,pvalPErrTime,~,tmpPErrTime] = ttest(PerrTimeAcc-PerrTimeFast);
dofPErrTime = tmpPErrTime.df; tstatPErrTime = tmpPErrTime.tstat;

fprintf('Response deadline Acc: %g +/- %g\n', mean(dlineAcc), std(dlineAcc)/sqrt(NUM_SESSION))
fprintf('Response deadline Fast: %g +/- %g\n\n', mean(dlineFast), std(dlineFast)/sqrt(NUM_SESSION))

fprintf('RT Acc: %g +/- %g\n', mean(RTAcc), std(RTAcc)/sqrt(NUM_SESSION))
fprintf('RT Fast: %g +/- %g\n', mean(RTFast), std(RTFast)/sqrt(NUM_SESSION))
fprintf('pval = %g   t(%d) = %g\n\n', pvalRT, dofRT, tstatRT)

fprintf('P[ChcErr] Acc: %g +/- %g\n', mean(PerrChcAcc), std(PerrChcAcc)/sqrt(NUM_SESSION))
fprintf('P[ChcErr] Fast: %g +/- %g\n', mean(PerrChcFast), std(PerrChcFast)/sqrt(NUM_SESSION))
fprintf('pval = %g   t(%d) = %g\n\n', pvalPErrChc, dofPErrChc, tstatPErrChc)

fprintf('P[TimeErr] Acc: %g +/- %g\n', mean(PerrTimeAcc), std(PerrTimeAcc)/sqrt(NUM_SESSION))
fprintf('P[TimeErr] Fast: %g +/- %g\n', mean(PerrTimeFast), std(PerrTimeFast)/sqrt(NUM_SESSION))
fprintf('pval = %g   t(%d) = %g\n\n', pvalPErrTime, dofPErrTime, tstatPErrTime)

end%fxn:computeBasicPerformanceXSessionSAT()
