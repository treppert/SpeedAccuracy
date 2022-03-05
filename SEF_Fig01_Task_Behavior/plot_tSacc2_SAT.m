function [  ] = plot_tSacc2_SAT( behavData )
%plot_tSacc2_SAT Summary of this function goes here
%   Detailed explanation goes here

%isolate sessions from monkey of choice
kkKeep = (ismember(behavData.Monkey, {'D','E'}) & behavData.Task_RecordedSEF);
behavData = behavData(kkKeep, :);
NUM_SESS = sum(kkKeep);

tSacc2_Acc = cell(NUM_SESS,1);
tSacc2_Fast = tSacc2_Acc;

tMedSacc2_Acc = NaN(NUM_SESS,1); %median time of second saccade
tMedSacc2_Fast = tMedSacc2_Acc;

%% Collect time of second saccade across sessions
for kk = 1:NUM_SESS
  
  RT2_kk = behavData.Sacc2_RT{kk} - behavData.Sacc_RT{kk};
  
  %index by trial outcome -- choice errors
  idxErr = behavData.Task_ErrChoice{kk} & ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrNoSacc{kk});
  
  %index by second saccade endpoint
  idxTgt = (behavData.Sacc2_Endpoint{kk} == 1);
  idxDistr = (behavData.Sacc2_Endpoint{kk} == 2);
  
  %index by condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  
  tSacc2_Acc{kk}  = transpose(RT2_kk(idxAcc & idxErr & (idxTgt | idxDistr))); %transpose for concatenation
  tSacc2_Fast{kk} = transpose(RT2_kk(idxFast & idxErr & (idxTgt | idxDistr)));
  
  tMedSacc2_Acc(kk) = median(RT2_kk(idxAcc & idxErr & (idxTgt | idxDistr)));
  tMedSacc2_Fast(kk) = median(RT2_kk(idxFast & idxErr & (idxTgt | idxDistr)));
  
end % for : session(kk)

%concatenate single-trial data across sessions
tSacc2_Acc = [ tSacc2_Acc{1:NUM_SESS} ];
tSacc2_Fast = [ tSacc2_Fast{1:NUM_SESS} ];

%plot -- distribution
figure(); hold on
cdfplotTR(tSacc2_Acc, 'Color','r')  %time of second saccade
cdfplotTR(tSacc2_Fast, 'Color',[0 .7 0])
xlabel('Time from primary saccade (ms)'); xlim([-200 500])
ylabel('Cumulative probability'); ytickformat('%2.1f')
ppretty([3.2,2])

%plot -- average
ttestTom(tMedSacc2_Acc, tMedSacc2_Fast, 'barplot')
ylim([280 320]); ylabel('Time of second saccade (ms)')

end % fxn : plot_tSacc2_SAT()
