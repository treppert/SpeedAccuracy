%compute_Behavior_X_Sess Summary of this function goes here
%   Detailed explanation goes here

%isolate sessions from MONKEY
kkKeep = ismember(behavData.Monkey, {'E'}) & behavData.Task_RecordedSEF;
behavTest = behavData(kkKeep, :);
NUM_SESS = sum(kkKeep);

%% Initializations
dlineAcc = NaN(NUM_SESS,1);    RTAcc = NaN(NUM_SESS,1);
dlineFast = NaN(NUM_SESS,1);   RTFast = NaN(NUM_SESS,1);

PerrChcAcc = NaN(NUM_SESS,1);  PerrTimeAcc = NaN(NUM_SESS,1);
PerrChcFast = NaN(NUM_SESS,1); PerrTimeFast = NaN(NUM_SESS,1);

%% Collect data
for kk = 1:NUM_SESS
  
  idxAcc = (behavTest.Task_SATCondition{kk} == 1);
  idxFast = (behavTest.Task_SATCondition{kk} == 3);
  
  idxCorr = behavTest.Task_Correct{kk};
  idxErrChc = behavTest.Task_ErrChoice{kk} & ~behavTest.Task_ErrTime{kk};
  idxErrTime = behavTest.Task_ErrTime{kk} & ~(behavTest.Task_ErrChoice{kk} | behavTest.Task_ErrHold{kk});
  idxErrBoth = (behavTest.Task_ErrChoice{kk} & behavTest.Task_ErrTime{kk});
  
  %deadline
  dlineAcc(kk) = median(behavTest.Task_Deadline{kk}(idxAcc));
  dlineFast(kk) = median(behavTest.Task_Deadline{kk}(idxFast));
  
  %response time
  RTAcc(kk) = median(behavTest.Sacc_RT{kk}(idxAcc & idxCorr));
  RTFast(kk) = median(behavTest.Sacc_RT{kk}(idxFast & idxCorr));
  
  %prob. choice error
  PerrChcAcc(kk) = sum(idxAcc & idxErrChc) / sum(idxAcc);
  PerrChcFast(kk) = sum(idxFast & idxErrChc) / sum(idxFast);
  
  %prob. timing error
  PerrTimeAcc(kk) = sum(idxAcc & idxErrTime) / sum(idxAcc);
  PerrTimeFast(kk) = sum(idxFast & idxErrTime) / sum(idxFast);
  
end%for:session(kk)

clear isi* RT* idx* Idx* dline* kkKeep *kk NUM_SESS