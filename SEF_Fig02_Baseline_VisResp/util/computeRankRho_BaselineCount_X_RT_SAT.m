function [ ] = computeRankRho_BaselineCount_X_RT_SAT( behavData , moves , unitData , spikes , varargin )
%computeRankRho_BaselineCount_X_RT_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

if ~any(ismember(args.monkey, {'Q','S'}))
  behavData = behavData(1:16);
end

idxArea = ismember(unitData.aArea, args.area);
idxMonkey = ismember(unitData.aMonkey, args.monkey);

idxVis = ([unitData.Basic_VisGrade] >= 2);   idxMove = (unitData.Basic_MovGrade >= 2);
idxErr = (unitData.Basic_ErrGrade >= 2);   idxRew = (abs(unitData.Basic_RewGrade) >= 2);
idxTaskRel = (idxVis | idxMove | idxErr | idxRew);

idxKeep = (idxArea & idxMonkey & idxTaskRel);

NUM_CELLS = sum(idxKeep);
unitData = unitData(idxKeep);
spikes = spikes(idxKeep);

RTLIM_ACC = [390 800];
RTLIM_FAST = [150 450];

T_BLINE = 3500 + [-600 20];

%initializations
rhoSpearmanAcc = NaN(1,NUM_CELLS);    pvalSpearmanAcc = NaN(1,NUM_CELLS);
rhoSpearmanFast = NaN(1,NUM_CELLS);   pvalSpearmanFast = NaN(1,NUM_CELLS);

for uu = 1:NUM_CELLS
  fprintf('Unit %s - %s\n', unitData.Task_Session(uu), unitData.aID{uu});
  
  %compute spike count for all trials
  spkCtCC = cellfun(@(x) sum((x > T_BLINE(1)) & (x < T_BLINE(2))), spikes(uu).SAT);
  
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  RTkk = double(moves(kk).resptime);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData(uu,:), behavData.Task_NumTrials{kk});
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrNoSacc{kk} | behavData.Task_ErrHold{kk});
  %index by condition and RT limits
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & idxCorr & ~idxIso & ~(RTkk < RTLIM_ACC(1) | RTkk > RTLIM_ACC(2) | isnan(RTkk)));
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & idxCorr & ~idxIso & ~(RTkk < RTLIM_FAST(1) | RTkk > RTLIM_FAST(2) | isnan(RTkk)));
  
  spkCountAcc = spkCtCC(idxAcc);    RTacc = RTkk(idxAcc);
  spkCountFast = spkCtCC(idxFast);  RTfast = RTkk(idxFast);
  
  %compute Spearman rank correlation coefficient
  [rAcc,pAcc] = corr(RTacc', spkCountAcc', 'Type','Spearman');
  [rFast,pFast] = corr(RTfast', spkCountFast', 'Type','Spearman');
  
  rhoSpearmanAcc(uu) = rAcc;      pvalSpearmanAcc(uu) = pAcc;
  rhoSpearmanFast(uu) = rFast;    pvalSpearmanFast(uu) = pFast;
  
end%for:cell(uu)

%separate neurons by level of search efficiency
idxMore = unitData.Task_LevelDifficulty == 1;  NUM_MORE = sum(idxMore);
idxLess = unitData.Task_LevelDifficulty == 2;  NUM_LESS = sum(idxLess);

%find units with a significant correlation
ALPHA = 0.06;
idxAccPos = (pvalSpearmanAcc <= ALPHA & rhoSpearmanAcc > 0);
idxAccNeg = (pvalSpearmanAcc <= ALPHA & rhoSpearmanAcc < 0);
idxFastPos = (pvalSpearmanFast <= ALPHA & rhoSpearmanFast > 0);
idxFastNeg = (pvalSpearmanFast <= ALPHA & rhoSpearmanFast < 0);

fprintf('More efficient:\n')
fprintf('Acc: (+) = %d  (-) = %d  / %d\n', sum(idxAccPos & idxMore), sum(idxAccNeg & idxMore), NUM_MORE)
fprintf('Fast: (+) = %d  (-) = %d  / %d\n', sum(idxFastPos & idxMore), sum(idxFastNeg & idxMore), NUM_MORE)
fprintf('Less efficient:\n')
fprintf('Acc: (+) = %d  (-) = %d  / %d\n', sum(idxAccPos & idxLess), sum(idxAccNeg & idxLess), NUM_LESS)
fprintf('Fast: (+) = %d  (-) = %d  / %d\n', sum(idxFastPos & idxLess), sum(idxFastNeg & idxLess), NUM_LESS)

end%fxn:computeRankRho_BaselineCount_X_RT_SAT()
