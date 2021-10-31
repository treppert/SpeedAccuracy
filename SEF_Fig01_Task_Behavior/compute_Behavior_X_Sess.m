function [ ] = compute_Behavior_X_Sess( behavData )
%compute_Behavior_X_Sess Summary of this function goes here
%   Detailed explanation goes here

%isolate sessions from MONKEY
MONKEY = {'D','E'};         sessKeep = ismember(behavData.Monkey, MONKEY);
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
  
  idxAcc = (behavData.Task_SATCondition{kk} == 1) & ~isnan(behavData.Task_Deadline{kk});
  idxFast = (behavData.Task_SATCondition{kk} == 3) & ~isnan(behavData.Task_Deadline{kk});
  
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrNoSacc{kk});
  idxErrChc = behavData.Task_ErrChoice{kk} & ~behavData.Task_ErrTime{kk};
  idxErrTime = behavData.Task_ErrTime{kk} & ~behavData.Task_ErrChoice{kk};
  
  %deadline
  dlineAcc(kk) = median(behavData.Task_Deadline{kk}(idxAcc));
  dlineFast(kk) = median(behavData.Task_Deadline{kk}(idxFast));
  
  %response time
  RTAcc(kk) = median(behavData.Sacc_RT{kk}(idxAcc & idxCorr));
  RTFast(kk) = median(behavData.Sacc_RT{kk}(idxFast & idxCorr));
  
  %prob. choice error
  PerrChcAcc(kk) = sum(idxAcc & idxErrChc) / sum(idxAcc);
  PerrChcFast(kk) = sum(idxFast & idxErrChc) / sum(idxFast);
  
  %prob. timing error
  PerrTimeAcc(kk) = sum(idxAcc & idxErrTime) / sum(idxAcc);
  PerrTimeFast(kk) = sum(idxFast & idxErrTime) / sum(idxFast);
  
  %inter-saccade interval
  ISIkk = double(behavData.Sacc2_RT{kk}) - (double(behavData.Sacc_RT{kk}) + double(behavData.Sacc_Duration{kk}));
  idxNoPP = (behavData.Sacc_RT{kk} == 0);
  
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
