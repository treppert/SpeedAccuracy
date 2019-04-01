function [ ] = computeBasicPerformanceXSessionSAT(binfo, moves, movesPP, varargin)
%computeBasicPerformanceXSessionSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

[binfo, moves, movesPP] = utilIsolateMonkeyBehavior(binfo, moves, movesPP, args.monkey);
NUM_SESSION = length(binfo);

%% Initializations

dlineAcc = NaN(1,NUM_SESSION);
dlineFast = NaN(1,NUM_SESSION);

RTAcc = NaN(1,NUM_SESSION);
RTFast = NaN(1,NUM_SESSION);

PerrChcAcc = NaN(1,NUM_SESSION);
PerrChcFast = NaN(1,NUM_SESSION);

PerrTimeAcc = NaN(1,NUM_SESSION);
PerrTimeFast = NaN(1,NUM_SESSION);

isiAcc = NaN(1,NUM_SESSION);
isiFast = NaN(1,NUM_SESSION);

%% Collect data

for kk = 1:NUM_SESSION
  
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc);
  idxErrChc = binfo(kk).err_dir & ~binfo(kk).err_time;
  idxErrTime = binfo(kk).err_time & ~binfo(kk).err_dir;
  
  dlineAcc(kk) = nanmedian(binfo(kk).deadline(idxAcc));
  dlineFast(kk) = median(binfo(kk).deadline(idxFast));
  
  RTAcc(kk) = median(moves(kk).resptime(idxAcc & idxCorr));
  RTFast(kk) = median(moves(kk).resptime(idxFast & idxCorr));
  
  PerrChcAcc(kk) = sum(idxAcc & idxErrChc) / sum(idxAcc);
  PerrChcFast(kk) = sum(idxFast & idxErrChc) / sum(idxFast);
  
  PerrTimeAcc(kk) = sum(idxAcc & idxErrTime) / sum(idxAcc);
  PerrTimeFast(kk) = sum(idxFast & idxErrTime) / sum(idxFast);
  
  ISIkk = double(movesPP(kk).resptime) - (double(moves(kk).resptime) + double(moves(kk).duration));
  idxNoPP = (movesPP(kk).resptime == 0);
  
  isiAcc(kk) = median(ISIkk(idxAcc & idxErrChc & ~idxNoPP));
  isiFast(kk) = median(ISIkk(idxFast & idxErrChc & ~idxNoPP));
  
end%for:session(kk)

%% Print mean +/- SE
fprintf('Response deadline Acc: %g +/- %g\n', mean(dlineAcc), std(dlineAcc)/sqrt(NUM_SESSION))
fprintf('Response deadline Fast: %g +/- %g\n\n', mean(dlineFast), std(dlineFast)/sqrt(NUM_SESSION))

fprintf('RT Acc: %g +/- %g\n', mean(RTAcc), std(RTAcc)/sqrt(NUM_SESSION))
fprintf('RT Fast: %g +/- %g\n', mean(RTFast), std(RTFast)/sqrt(NUM_SESSION))

fprintf('ISI Acc: %g +/- %g\n', mean(isiAcc), std(isiAcc)/sqrt(NUM_SESSION))
fprintf('ISI Fast: %g +/- %g\n', mean(isiFast), std(isiFast)/sqrt(NUM_SESSION))

fprintf('P[ChcErr] Acc: %g +/- %g\n', mean(PerrChcAcc), std(PerrChcAcc)/sqrt(NUM_SESSION))
fprintf('P[ChcErr] Fast: %g +/- %g\n', mean(PerrChcFast), std(PerrChcFast)/sqrt(NUM_SESSION))

fprintf('P[TimeErr] Acc: %g +/- %g\n', mean(PerrTimeAcc), std(PerrTimeAcc)/sqrt(NUM_SESSION))
fprintf('P[TimeErr] Fast: %g +/- %g\n', mean(PerrTimeFast), std(PerrTimeFast)/sqrt(NUM_SESSION))

%% Perform tests
%independent variables
RT = [RTAcc, RTFast]';
ISI = [isiAcc, isiFast]';
PerrChc = [PerrChcAcc, PerrChcFast]';
PerrTime = [PerrTimeAcc, PerrTimeFast]';

%two factors
condition = [ones(1,NUM_SESSION), 2*ones(1,NUM_SESSION)]';
taskType = repmat([binfo.taskType],1,2)';

[~,ANtbl] = anovan(RT, {condition taskType}, 'model','interaction', 'varnames',{'Condition','Task Type'}, 'display','off');
[~,ANtbl] = anovan(ISI, {condition taskType}, 'model','interaction', 'varnames',{'Condition','Task Type'}, 'display','off');
[~,ANtbl] = anovan(PerrChc, {condition taskType}, 'model','interaction', 'varnames',{'Condition','Task Type'}, 'display','off');
[~,ANtbl] = anovan(PerrTime, {condition taskType}, 'model','interaction', 'varnames',{'Condition','Task Type'}, 'display','off');

end%fxn:computeBasicPerformanceXSessionSAT()
