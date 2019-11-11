function [ ] = plot_Distr_ChcErrSignal_Time_SAT( unitInfo , unitStats , behavInfo , primarySacc , secondSacc )
%plot_Distr_ChcErrSignal_Time_SAT Plot cumulative distribution of time of error
%encoding and time of second saccade, relative to time of primary saccade.
%   Detailed explanation goes here
% 

idxSEF = ismember(unitInfo.area, {'SEF'});
idxMonkey = ismember(unitInfo.monkey, {'D','E'});
idxErrUnit = (idxSEF & idxMonkey & (unitInfo.errGrade >= 2));

%get start time of choice error signal
tSignal_Acc = unitStats.ChoiceErrorSignal_Time(idxErrUnit, 1);
tSignal_Fast = unitStats.ChoiceErrorSignal_Time(idxErrUnit, 3);

%identify sessions with neurons that signal choice error
sess_ChcErr = unique(unitInfo.sess(idxErrUnit));
numSession = length(sess_ChcErr);

behavInfo = behavInfo(sess_ChcErr,:);
primarySacc = primarySacc(sess_ChcErr,:);
secondSacc = secondSacc(sess_ChcErr,:);

%get time of second saccade re. time of primary saccade
tSS_Acc = [];
tSS_Fast = [];

for kk = 1:numSession
  
  %get time of second saccade re. primary saccade
  %NOTE: this is not the inter-saccade interval, which takes into account
  %   primary saccade duration
  t_SecondSacc = secondSacc.resptime{kk} - primarySacc.resptime{kk};
  
  %index by condition
  idxAcc = (behavInfo.condition{kk} == 1);
  idxFast = (behavInfo.condition{kk} == 3);
  %index by trial outcome
  idxErr = (behavInfo.err_dir{kk} & ~behavInfo.err_time{kk});
  %index by second saccade endpoint
  idxTgt = (secondSacc.endpt{kk} == 1);
  idxDistr = (secondSacc.endpt{kk} == 2);
  
  %combine for easy indexing
  idxAcc = (idxAcc & idxErr & (idxTgt | idxDistr));
  idxFast = (idxFast & idxErr & (idxTgt | idxDistr));
  
  tSS_Acc = cat(2, tSS_Acc, t_SecondSacc(idxAcc));
  tSS_Fast = cat(2, tSS_Fast, t_SecondSacc(idxFast));
  
end%for:cells(cc)

%% Plotting
figure(); hold on
plot([0 0], [0 1], 'k:')

cdfplotTR(tSignal_Acc, 'Color','r', 'LineStyle',':') %time of error signal
cdfplotTR(tSignal_Fast, 'Color',[0 .7 0], 'LineStyle',':')
cdfplotTR(tSS_Acc, 'Color','r')  %time of second saccade
cdfplotTR(tSS_Fast, 'Color',[0 .7 0])

xlabel('Time from primary saccade (ms)'); %xlim([-100 500])
ylabel('Cum. probability'); ytickformat('%2.1f')
ppretty([4.8,3.0])

end % fxn : plot_Distr_ChcErrSignal_Time_SAT ()

