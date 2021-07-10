function [ ] = compute_Behavior_X_Sess( behavData )
%compute_Behavior_X_Sess Summary of this function goes here
%   Detailed explanation goes here

%isolate sessions from MONKEY
MONKEY = {'D','E'};         sessKeep = ismember(behavData.monkey, MONKEY);
NUM_SESS = sum(sessKeep);   behavData = behavData(sessKeep, :);   behavData = behavData(sessKeep, :);   behavData = behavData(sessKeep, :);

%% Initializations

dlineAcc = NaN(1,NUM_SESS);    RTAcc = NaN(1,NUM_SESS);
dlineFast = NaN(1,NUM_SESS);   RTFast = NaN(1,NUM_SESS);

PerrChcAcc = NaN(1,NUM_SESS);  PerrTimeAcc = NaN(1,NUM_SESS);
PerrChcFast = NaN(1,NUM_SESS); PerrTimeFast = NaN(1,NUM_SESS);

isiAcc = NaN(1,NUM_SESS);
isiFast = NaN(1,NUM_SESS);

%% Collect data

for kk = 1:NUM_SESS
  
  idxAcc = (behavData.condition{kk} == 1) & ~isnan(behavData.deadline{kk});
  idxFast = (behavData.condition{kk} == 3) & ~isnan(behavData.deadline{kk});
  
  idxCorr = ~(behavData.err_dir{kk} | behavData.err_time{kk} | behavData.err_nosacc{kk});
  idxErrChc = behavData.err_dir{kk} & ~behavData.err_time{kk};
  idxErrTime = behavData.err_time{kk} & ~behavData.err_dir{kk};
  
  %deadline
  dlineAcc(kk) = median(behavData.deadline{kk}(idxAcc));
  dlineFast(kk) = median(behavData.deadline{kk}(idxFast));
  
  %response time
  RTAcc(kk) = median(behavData.RT{kk}(idxAcc & idxCorr));
  RTFast(kk) = median(behavData.RT{kk}(idxFast & idxCorr));
  
  %prob. choice error
  PerrChcAcc(kk) = sum(idxAcc & idxErrChc) / sum(idxAcc);
  PerrChcFast(kk) = sum(idxFast & idxErrChc) / sum(idxFast);
  
  %prob. timing error
  PerrTimeAcc(kk) = sum(idxAcc & idxErrTime) / sum(idxAcc);
  PerrTimeFast(kk) = sum(idxFast & idxErrTime) / sum(idxFast);
  
  %inter-saccade interval
  ISIkk = double(behavData.RT_SS{kk}) - (double(behavData.RT{kk}) + double(behavData.duration{kk}));
  idxNoPP = (behavData.resptime{kk} == 0);
  
  isiAcc(kk) = median(ISIkk(idxAcc & idxErrChc & ~idxNoPP));
  isiFast(kk) = median(ISIkk(idxFast & idxErrChc & ~idxNoPP));
  
end%for:session(kk)

%% Print mean +/- SE
fprintf('Response deadline Acc: %g +/- %g\n', mean(dlineAcc), std(dlineAcc)/sqrt(NUM_SESS))
fprintf('Response deadline Fast: %g +/- %g\n\n', mean(dlineFast), std(dlineFast)/sqrt(NUM_SESS))

fprintf('RT Acc: %g +/- %g\n', mean(RTAcc), std(RTAcc)/sqrt(NUM_SESS))
fprintf('RT Fast: %g +/- %g\n', mean(RTFast), std(RTFast)/sqrt(NUM_SESS))

fprintf('ISI Acc: %g +/- %g\n', mean(isiAcc), std(isiAcc)/sqrt(NUM_SESS))
fprintf('ISI Fast: %g +/- %g\n', mean(isiFast), std(isiFast)/sqrt(NUM_SESS))

fprintf('P[ChcErr] Acc: %g +/- %g\n', mean(PerrChcAcc), std(PerrChcAcc)/sqrt(NUM_SESS))
fprintf('P[ChcErr] Fast: %g +/- %g\n', mean(PerrChcFast), std(PerrChcFast)/sqrt(NUM_SESS))

fprintf('P[TimeErr] Acc: %g +/- %g\n', mean(PerrTimeAcc), std(PerrTimeAcc)/sqrt(NUM_SESS))
fprintf('P[TimeErr] Fast: %g +/- %g\n', mean(PerrTimeFast), std(PerrTimeFast)/sqrt(NUM_SESS))

fprintf('\n')

end%fxn:compute_Behavior_X_Sess()
