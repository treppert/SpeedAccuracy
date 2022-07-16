%Fig1.m -- Figure 1 header file
MONKEY = {'D','E'};

%compute mean task-related parameters per session
T = compute_Behavior_X_Session(behavData, 'monkey',MONKEY);
T_Combined = grpstats(T, 'Condition', {'mean','sem'}, 'DataVars',{'RT','Deadline', ...
  'pErrChc','pErrTime','pErrBoth'}); %monkeys combined
T_Split = grpstats(T, {'Condition','Monkey'}, {'mean','sem'}, 'DataVars',{'RT','Deadline', ...
  'pErrChc','pErrTime','pErrBoth'}); %monkeys split

idxDa = ismember(T.Monkey, {'D'});
idxEu = ismember(T.Monkey, {'E'});
idxAcc  = ismember(T.Condition, {'Acc'}) & idxEu;
idxFast = ismember(T.Condition, {'Fast'}) & idxEu;
% ttestFull(T.RT(idxAcc), T.RT(idxFast), 'ylabel','RT', 'xticklabels',{'Acc','Fast'})
% ttestFull(T.pErrChc(idxAcc), T.pErrChc(idxFast), 'ylabel','pErrChc', 'xticklabels',{'Acc','Fast'})
% ttestFull(T.pErrTime(idxAcc), T.pErrTime(idxFast), 'ylabel','pErrTime', 'xticklabels',{'Acc','Fast'})

% Fig1C_ErrRate_X_RT(behavData, 'monkey',MONKEY)

% plot_Behav_X_Trial(behavData, 'monkey',MONKEY) %Fig. 1D
