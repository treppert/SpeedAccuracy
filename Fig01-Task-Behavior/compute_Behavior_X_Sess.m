function [ ] = compute_Behavior_X_Sess(binfo, moves, movesPP, varargin)
%compute_Behavior_X_Sess Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});
SAVEDIR = 'C:\Users\Thomas Reppert\Dropbox\SAT\Stats\';

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

numCorrect = NaN(1,NUM_SESSION);

%% Collect data

for kk = 1:NUM_SESSION
  
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc);
  idxErrChc = binfo(kk).err_dir & ~binfo(kk).err_time;
  idxErrTime = binfo(kk).err_time & ~binfo(kk).err_dir;
  
  numCorrect(kk) = sum((idxAcc | idxFast) & idxCorr);
  
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
fprintf('Number of correct responses per session: %g +/- %g\n\n', mean(numCorrect), std(numCorrect)/sqrt(NUM_SESSION));

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

%% Split sessions by search efficiency
kkMore = ([binfo.taskType] == 1);
kkLess = ([binfo.taskType] == 2);

parmAcc = RTAcc;
parmFast = RTFast;

parm = struct('AccMore',parmAcc(kkMore), 'AccLess',parmAcc(kkLess), ...
  'FastMore',parmFast(kkMore), 'FastLess',parmFast(kkLess));
writeData_TwoWayANOVA(parm, 'C:\Users\Thomas Reppert\Dropbox\SAT\Stats\Behavior-RT.mat')

%two-way ANOVA in Matlab
parm = [RTAcc, RTFast]'; %[RTAcc, RTFast]';
Condition = [ones(1,NUM_SESSION), 2*ones(1,NUM_SESSION)]';
Efficiency = repmat([binfo.taskType],1,2)';
[~,~] = anovan(parm, {Condition Efficiency}, 'model','interaction', 'varnames',{'Condition','Efficiency'});

end%fxn:compute_Behavior_X_Sess()



function [ ] = writeData_TwoWayANOVA( param , writeFile )

N_MORE = length(param.AccMore);
N_LESS = length(param.AccLess);
N_SESS = N_MORE + N_LESS;

%dependent variable
DV_Parameter = [ param.AccMore param.AccLess param.FastMore param.FastLess ]';

%factors
F_Condition = [ ones(1,N_SESS) 2*ones(1,N_SESS) ]';
F_Efficiency = [ ones(1,N_MORE) 2*ones(1,N_LESS) ones(1,N_MORE) 2*ones(1,N_LESS) ]';

%write data
save(writeFile, 'DV_Parameter','F_Condition','F_Efficiency')

end%util:writeData()


