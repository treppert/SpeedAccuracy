function [ ] = plotTErrChc_X_TErrRT( unitData , unitData )
%plotTErrChc_X_TErrRT Summary of this function goes here
%   Detailed explanation goes here

idxArea = ismember(unitData.aArea, {'SEF'});
idxDa = ismember(unitData.aMonkey, {'D'});
idxEu = ismember(unitData.aMonkey, {'E'});

idxErr = (unitData.Basic_ErrGrade >= 2);
idxRew = (abs(unitData.Basic_RewGrade) >= 2 & ~isnan([unitData.TimingErrorSignal_Time(2)]));

idxBothErrDa = (idxArea & idxDa & (idxErr & idxRew));
idxBothErrEu = (idxArea & idxEu & (idxErr & idxRew));

%compute median time of error signaling for each monkey
tmedChcErrDa = median([unitData(idxErr & idxDa).A_ChcErr_tErr_Fast]);
tmedChcErrEu = median([unitData(idxErr & idxEu).A_ChcErr_tErr_Fast]);
tmedRTErrDa = median([unitData(idxRew & idxDa).A_Reward_tErrStart_Acc]);
tmedRTErrEu = median([unitData(idxRew & idxEu).A_Reward_tErrStart_Acc]);

%collect latencies for neurons with both types of modulation
tChcErrDa = [unitData(idxBothErrDa).A_ChcErr_tErr_Fast];% - tmedChcErrDa;
tChcErrEu = [unitData(idxBothErrEu).A_ChcErr_tErr_Fast];% - tmedChcErrEu;
tRTErrDa = [unitData(idxBothErrDa).A_Reward_tErrStart_Acc];% - tmedRTErrDa;
tRTErrEu = [unitData(idxBothErrEu).A_Reward_tErrStart_Acc];% - tmedRTErrEu;

%combine corrected latencies across monkeys
tChcErr = [tChcErrDa , tChcErrEu];
tRTErr  = [tRTErrDa , tRTErrEu];


%% Plotting

figure(); hold on
scatter(tChcErr, tRTErr, 30, 'k', 'filled')
ppretty([4.8,3])

end%fxn:plotTErrChc_X_TErrRT()

