function [ ] = plotTErrChc_X_TErrRT( unitInfo , unitStats )
%plotTErrChc_X_TErrRT Summary of this function goes here
%   Detailed explanation goes here

idxSEF = ismember(unitInfo.area, {'SEF'});
idxDa = ismember(unitInfo.monkey, {'D'});
idxEu = ismember(unitInfo.monkey, {'E'});

idxErr = (unitInfo.errGrade >= 2);
idxRew = (abs(unitInfo.rewGrade) >= 2);

idxKeep = (idxSEF & (idxDa | idxEu) & (idxErr | idxRew));

unitInfo = unitInfo(idxKeep,:);
unitStats = unitStats(idxKeep,:);

idxErrOnly = (idxErr & ~idxRew);
idxRewOnly = (idxRew & ~idxErr);
idxBoth = (idxErr & idxRew);

idxBothErrDa = (idxSEF & idxDa & (idxErr & idxRew));
idxBothErrEu = (idxSEF & idxEu & (idxErr & idxRew));

%collect signal latencies
tChcErr_Fast = unitStats.ChoiceErrorSignal_Time(:,3);
tRewErr_Acc  = unitStats.TimingErrorSignal_Time(:,1);

%collect SDF's


%% Plotting

figure(); hold on
scatter(tChcErr, tRTErr, 30, 'k', 'filled')
ppretty([4.8,3])

end%fxn:plotTErrChc_X_TErrRT()

