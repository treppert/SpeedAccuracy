function [  ] = plot_RT_X_TrialOutcome( behavData , varargin )
%plot_RT_X_TrialOutcome Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

%isolate sessions from monkey of choice
kkKeep = (ismember(behavData.Monkey, args.monkey) & behavData.Task_RecordedSEF);
behavData = behavData(kkKeep, :);
NUM_SESS = sum(kkKeep);

trialSwitch = identify_condition_switch( behavData );

rtAC  = NaN(NUM_SESS,3); %correct
rtFC  = rtAC;
rtAET = rtAC; %timing error
rtFET = rtAC;
rtAEC = rtAC; %choice error
rtFEC = rtAC;
drtAcc  = rtAC; % correct | choice error | timing error
drtFast = rtAC;

%% Collect dRT across sessions
for kk = 1:NUM_SESS
  RTkk = behavData.Sacc_RT{kk};
  dRTkk = [diff(behavData.Sacc_RT{kk}); Inf]';
  
  %index by condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  idxErrChc  = behavData.Task_ErrChoiceOnly{kk};
  idxErrTime = behavData.Task_ErrTimeOnly{kk};
  
  %exclude trials at task condition switch
  idxSwitch = false(behavData.Task_NumTrials(kk),1);
  jjSwitch = [trialSwitch.A2F{kk}; trialSwitch.F2A{kk}];
  jjSwitch = sort([jjSwitch; (jjSwitch-1); (jjSwitch+1)]);
  idxSwitch(jjSwitch) = true;
  idxSwitch(end) = true; %leave out the last trial
  
  %combine indexing
  jjAC   = find(idxAcc  & idxCorr & ~idxSwitch); %correct
  jjFC   = find(idxFast & idxCorr & ~idxSwitch); %correct
  jjAEC  = find(idxAcc  & idxErrChc & ~idxSwitch); %choice error
  jjFEC  = find(idxFast & idxErrChc & ~idxSwitch); %choice error
  jjAET  = find(idxAcc  & idxErrTime & ~idxSwitch); %timing error
  jjFET  = find(idxFast & idxErrTime & ~idxSwitch); %timing error
  
  %compute average RT
  rtAC(kk,:) = median([RTkk(jjAC-1) , RTkk(jjAC) , RTkk(jjAC+1)]);
  rtFC(kk,:) = median([RTkk(jjFC-1) , RTkk(jjFC) , RTkk(jjFC+1)]);
  rtAEC(kk,:) = median([RTkk(jjAEC-1) , RTkk(jjAEC) , RTkk(jjAEC+1)]);
  rtFEC(kk,:) = median([RTkk(jjFEC-1) , RTkk(jjFEC) , RTkk(jjFEC+1)]);
  rtAET(kk,:) = median([RTkk(jjAET-1) , RTkk(jjAET) , RTkk(jjAET+1)]);
  rtFET(kk,:) = median([RTkk(jjFET-1) , RTkk(jjFET) , RTkk(jjFET+1)]);
  
  %compute mean change in RT
  drtAcc(kk,:)  = [median(dRTkk(jjAC)) , median(dRTkk(jjAEC)) , median(dRTkk(jjAET))];
  drtFast(kk,:) = [median(dRTkk(jjFC)) , median(dRTkk(jjFEC)) , median(dRTkk(jjFET))];

end % for : sessions(kk)

%% Plotting - Mean RT
figure()

subplot(3,1,1); hold on %correct
title('Correct')
bar(mean([rtAC rtFC]), 0.4, 'FaceColor','none', 'LineWidth',0.5)
errorbar(mean([rtAC rtFC]), std([rtAC rtFC])/sqrt(NUM_SESS), ...
  'Color','k', 'CapSize',0, 'LineStyle','none')
xticks(1:6); xticklabels({'n-1','n','n+1','n-1','n','n+1'})
xlabel('Accurate              Fast')

subplot(3,1,2); hold on %choice error
title('Choice error')
bar(mean([rtAEC rtFEC]), 0.4, 'FaceColor','none', 'LineWidth',0.5)
errorbar(mean([rtAEC rtFEC]), std([rtAEC rtFEC])/sqrt(NUM_SESS), ...
  'Color','k', 'CapSize',0, 'LineStyle','none')
xticks(1:6); xticklabels({'n-1','n','n+1','n-1','n','n+1'})
xlabel('Accurate              Fast')

subplot(3,1,3); hold on %timing error
title('Timing error')
bar(mean([rtAET rtFET]), 0.4, 'FaceColor','none', 'LineWidth',0.5)
errorbar(mean([rtAET rtFET]), std([rtAET rtFET])/sqrt(NUM_SESS), ...
  'Color','k', 'CapSize',0, 'LineStyle','none')
xticks(1:6); xticklabels({'n-1','n','n+1','n-1','n','n+1'})
xlabel('Accurate              Fast')
ylabel('RT (ms)')

ppretty([2,5])

% anova1(dRT_Acc);
% anova1(dRT_Fast);

%% Plotting - Change in RT trial {n+1} - trial {n}
figure(); hold on
title('Correct')
bar(mean([drtAcc drtFast]), 0.4, 'FaceColor','none', 'LineWidth',0.5)
errorbar(mean([drtAcc drtFast]), std([drtAcc drtFast])/sqrt(NUM_SESS), ...
  'Color','k', 'CapSize',0, 'LineStyle','none')
ppretty([1.8,1.8]); xticks([])




end % fxn : plot_RT_X_TrialHistory()
