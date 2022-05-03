function [ ] = Fig3C_Distr_tErrorChoice_SAT( unitData )
%Fig3C_Distr_tErrorChoice_SAT Plot cumulative distribution of time of error
%encoding relative to time of primary saccade.
%   Detailed explanation goes here
% 

tSig_Fast = unitData.SignalCE_Time_P(:,1);
tSig_Acc = unitData.SignalCE_Time_P(:,3);

%plot distribution
figure(); hold on
plot([0 0], [0 1], 'k:')
cdfplotTR(tSig_Acc, 'Color','r', 'LineStyle',':') %time of error signal
cdfplotTR(tSig_Fast, 'Color',[0 .7 0], 'LineStyle',':')
xlabel('Time from primary saccade (ms)')
ylabel('Cumulative probability'); ytickformat('%2.1f')
ppretty([3.2,2])

%stats -- signal time
ttestFull(tSig_Acc, tSig_Fast, 'barplot', ...
  'xticklabels',{'Acc','Fast'}, 'ylabel','Error signal latency (ms)')

end % fxn : Fig3C_Distr_tErrorChoice_SAT ()

