function [ ] = Fig3C_Distr_tErrorChoice_SAT( behavData , unitData )
%plot_Distr_ChcErrSignal_Time_SAT Plot cumulative distribution of time of error
%encoding and time of second saccade, relative to time of primary saccade.
%   Detailed explanation goes here
% 

idxSEF = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'E'});
idxErrUnit = (unitData.Grade_Err == 1);
idxKeep = (idxSEF & idxMonkey & idxErrUnit);

%get start time of choice error signal
tSignal_Acc = unitData.ErrorSignal_Time(idxKeep,3);
tSignal_Fast = unitData.ErrorSignal_Time(idxKeep,1);

%identify sessions with neurons that signal choice error
sess_ChcErr = unique(unitData.Task_Session(idxKeep));
numSession = length(sess_ChcErr);

behavData = behavData(sess_ChcErr,:);

%time of second saccade re. time of primary saccade
tSS_Acc = [];
tSS_Fast = [];
%inter-saccade interval (ISI) -- take into account primary sacc. duration
isiAcc = NaN(numSession,1);
isiFast = NaN(numSession,1);

for kk = 1:numSession
  
  %get time of second saccade re. primary saccade
  t_SecondSacc_kk = behavData.Sacc2_RT{kk} - behavData.Sacc_RT{kk};
  isi_kk = behavData.Sacc2_RT{kk} - (behavData.Sacc_RT{kk} + behavData.Sacc_Duration{kk});
  
  %index by condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  %index by trial outcome
  idxErr = (behavData.Task_ErrChoice{kk} & ~behavData.Task_ErrTime{kk});
  %index by second saccade endpoint
  idxTgt = (behavData.Sacc2_Endpoint{kk} == 1);
  idxDistr = (behavData.Sacc2_Endpoint{kk} == 2);
  
  %combine for easy indexing
  idxAcc = (idxAcc & idxErr & (idxTgt | idxDistr));
  idxFast = (idxFast & idxErr & (idxTgt | idxDistr));
  
  tSS_Acc = cat(1, tSS_Acc, t_SecondSacc_kk(idxAcc));
  tSS_Fast = cat(1, tSS_Fast, t_SecondSacc_kk(idxFast));
  
  isiAcc(kk) = median(isi_kk(idxAcc));
  isiFast(kk) = median(isi_kk(idxFast));
  
end % for : session(kk)

%% Plotting
figure(); hold on
plot([0 0], [0 1], 'k:')

cdfplotTR(tSignal_Acc, 'Color','r', 'LineStyle',':') %time of error signal
cdfplotTR(tSignal_Fast, 'Color',[0 .7 0], 'LineStyle',':')
cdfplotTR(tSS_Acc, 'Color','r')  %time of second saccade
cdfplotTR(tSS_Fast, 'Color',[0 .7 0])

xlabel('Time from primary saccade (ms)'); xlim([-200 500])
ylabel('Cum. probability'); ytickformat('%2.1f')
ppretty([4.8,3.0])

%barplot
figure(); hold on
bar(mean([isiAcc isiFast]))
errorbar(mean([isiAcc isiFast]), std([isiAcc isiFast]/sqrt(numSession)), 'Color','k')
ylim([250 290])
ppretty([2,4])

end % fxn : plot_Distr_ChcErrSignal_Time_SAT ()

