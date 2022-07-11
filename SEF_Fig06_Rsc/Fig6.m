%% Fig6.m -- Figure 6 header file

MONKEY = {'D','E'};
AREA = {'SEF'};
idxArea = ismember(unitData.Area, AREA);
idxMonkey = ismember(unitData.Monkey, MONKEY);
idxFunction = ismember(unitData.Grade_TErr, [-1,+1]);
unitTest = unitData(idxArea & idxMonkey & idxFunction,:);

Fig4A_ErrRate_X_Trial(behavData, 'monkey',MONKEY)
% plot_RT_X_TrialOutcome(behavData, 'monkey',MONKEY)

clear idx*
