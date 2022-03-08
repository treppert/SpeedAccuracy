function [ ] = Fig3C_Distr_tErrorChoice_SAT( unitData )
%Fig3C_Distr_tErrorChoice_SAT Plot cumulative distribution of time of error
%encoding and time of second saccade, relative to time of primary saccade.
%   Detailed explanation goes here
% 

idxSEF = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});
idxErrUnit = ismember(unitData.Grade_Err, [-1,1]);
idxKeep = (idxSEF & idxMonkey & idxErrUnit);

tSig_Fast = unitData.ErrorSignal_Time(idxKeep,1);
tSig_Acc = unitData.ErrorSignal_Time(idxKeep,3);

%plot distribution
figure(); hold on
plot([0 0], [0 1], 'k:')
cdfplotTR(tSig_Acc, 'Color','r', 'LineStyle',':') %time of error signal
cdfplotTR(tSig_Fast, 'Color',[0 .7 0], 'LineStyle',':')
xlabel('Time from primary saccade (ms)')
ylabel('Cumulative probability'); ytickformat('%2.1f')
ppretty([3.2,2])

%stats -- signal time
fprintf('Signal Time:\n')
ttestTom(tSig_Acc, tSig_Fast, 'barplot')
ylabel('Error signal onset (ms)')

%stats -- signal magnitude
% mSig_Fast = abs( unitData.ErrorSignal_Mag(idxKeep,2) );
% mSig_Acc  = abs( unitData.ErrorSignal_Mag(idxKeep,1) );
% fprintf('\nSignal Magnitude:\n')
% ttestTom(mSig_Acc, mSig_Fast)
% ylabel('Error signal magnitude (sp)')

end % fxn : Fig3C_Distr_tErrorChoice_SAT ()

