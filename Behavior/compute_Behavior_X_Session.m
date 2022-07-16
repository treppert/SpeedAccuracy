function [ T ] = compute_Behavior_X_Session( behavData , varargin )
%compute_Behavior_X_Session Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

%isolate sessions from MONKEY
idxMonkey = ismember(behavData.Monkey, args.monkey);
kkTest = (idxMonkey & behavData.Task_RecordedSEF);
behavTest = behavData(kkTest,:);
NUM_SESS = sum(kkTest);


%% Initializations
dlineAcc = NaN(NUM_SESS,1);
dlineFast = dlineAcc;
RTAcc = dlineAcc;
RTFast = dlineAcc;

PerrChcAcc = NaN(NUM_SESS,1);
PerrTimeAcc = PerrChcAcc;
PerrBothAcc = PerrChcAcc;
PerrChcFast = PerrChcAcc;
PerrTimeFast = PerrChcAcc;
PerrBothFast = PerrChcAcc;


%% Collect data
for kk = 1:NUM_SESS
  
  idxAcc = (behavTest.Task_SATCondition{kk} == 1);
  idxFast = (behavTest.Task_SATCondition{kk} == 3);
  
  idxCorr = behavTest.Task_Correct{kk};
  idxErrChc = behavTest.Task_ErrChoice{kk};
  idxErrTime = behavTest.Task_ErrTime{kk};
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
  
  %prob. both errors
  PerrBothAcc(kk) = sum(idxAcc & idxErrBoth) / sum(idxAcc);
  PerrBothFast(kk) = sum(idxFast & idxErrBoth) / sum(idxFast);

end%for:session(kk)


%% Output
Deadline = [dlineAcc; dlineFast];
RT = [RTAcc; RTFast];
pErrChc = [PerrChcAcc; PerrChcFast];
pErrTime = [PerrTimeAcc; PerrTimeFast];
pErrBoth = [PerrBothAcc; PerrBothFast];
Condition = [repmat({'Acc'},NUM_SESS,1); repmat({'Fast'},NUM_SESS,1)];
Difficulty = repmat(behavTest.Difficulty, 2,1);
Monkey = repmat(behavTest.Monkey, 2,1);

T = table(Condition, Monkey, Difficulty, RT, Deadline, pErrChc, pErrTime, pErrBoth);

end % fxn : compute_Behavior_X_Session()
