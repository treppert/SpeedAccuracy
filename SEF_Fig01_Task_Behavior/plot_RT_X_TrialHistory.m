function [  ] = plot_RT_X_TrialHistory( behavData , varargin )
%plot_RT_X_TrialHistory Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

%isolate sessions from monkey of choice
kkKeep = (ismember(behavData.Monkey, args.monkey) & behavData.Task_RecordedSEF);
behavData = behavData(kkKeep, :);
NUM_SESS = sum(kkKeep);

trialSwitch = identify_condition_switch( behavData );

drtAcc = cell(NUM_SESS,3); % correct | choice error | timing error
drtFast = drtAcc;

dRT_Acc = NaN(NUM_SESS,3); %mean values
dRT_Fast = dRT_Acc;

%% Collect dRT across sessions
for kk = 1:NUM_SESS
  RTkk = transpose(behavData.Sacc_RT{kk});
  
  %index by trial outcome
  idxCorr = (behavData.Task_Correct{kk});
  idxErrChc  = behavData.Task_ErrChoice{kk} & ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  idxErrTime = behavData.Task_ErrTime{kk} & ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  
  %index by condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  
  %exclude trials at task condition switch
  idxSwitch = false(behavData.Task_NumTrials(kk),1);
  idxSwitch(sort([trialSwitch.A2F{kk}; trialSwitch.F2A{kk}])) = true;
  
  trialAC = find(idxAcc & idxCorr & ~idxSwitch); trialAC(end) = [];
  trialFC = find(idxFast & idxCorr & ~idxSwitch); trialFC(end) = [];
  trialAEC = find(idxAcc & idxErrChc & ~idxSwitch); trialAEC(end) = [];
  trialFEC = find(idxFast & idxErrChc & ~idxSwitch); trialFEC(end) = [];
  trialAET = find(idxAcc & idxErrTime & ~idxSwitch); trialAET(end) = [];
  trialFET = find(idxFast & idxErrTime & ~idxSwitch); trialFET(end) = [];
  
  %compute change in RT from Trial {n-1} to {n} re. outcome of Trial {n-1}
  drtAcc{kk,1} = RTkk(trialAC+1)-RTkk(trialAC); %correct
  drtAcc{kk,2} = RTkk(trialAEC+1)-RTkk(trialAEC); %choice error
  drtAcc{kk,3} = RTkk(trialAET+1)-RTkk(trialAET); %timing error
  drtFast{kk,1} = RTkk(trialFC+1)-RTkk(trialFC); %correct
  drtFast{kk,2} = RTkk(trialFEC+1)-RTkk(trialFEC); %choice error
  drtFast{kk,3} = RTkk(trialFET+1)-RTkk(trialFET); %timing error
  
  %save mean values
  dRT_Acc(kk,1) = nanmedian(drtAcc{kk,1});
  dRT_Acc(kk,2) = nanmedian(drtAcc{kk,2});
  dRT_Acc(kk,3) = nanmedian(drtAcc{kk,3});
  dRT_Fast(kk,1) = nanmedian(drtFast{kk,1});
  dRT_Fast(kk,2) = nanmedian(drtFast{kk,2});
  dRT_Fast(kk,3) = nanmedian(drtFast{kk,3});
  
end%for:sessions(kk)

%concatenate RT data across sessions
drtAC = [drtAcc{1:NUM_SESS,1}]';
drtAEC = [drtAcc{1:NUM_SESS,2}]';
drtAET = [drtAcc{1:NUM_SESS,3}]';
drtFC = [drtFast{1:NUM_SESS,1}]';
drtFEC = [drtFast{1:NUM_SESS,2}]';
drtFET = [drtFast{1:NUM_SESS,3}]';

%% Plotting

figure(); hold on
bar([1:3,5:7], mean([dRT_Acc dRT_Fast]), 0.4, 'FaceColor','none', 'LineWidth',0.5)
errorbar([1:3,5:7], mean([dRT_Acc dRT_Fast]), std([dRT_Acc dRT_Fast])/sqrt(NUM_SESS), ...
  'Color','k', 'CapSize',0, 'LineStyle','none')
xticks([1:3,5:7]); xticklabels({'AC','AEC','AET','FC','FEC','FET'})
ylabel('Change in response time (ms)'); %ylim([200 600])
ppretty([2,2])

% anova1(dRT_Acc);
% anova1(dRT_Fast);

figure()
XLIM = [-600 600];
subplot(2,3,1); title('Correct'); hold on %Accurate - Correct
histogram(drtAC, 'FaceColor','r', 'BinWidth',50); xlim(XLIM)

subplot(2,3,2); title('Choice error'); hold on %Accurate - Choice Error
histogram(drtAEC, 'FaceColor','r', 'BinWidth',50); xlim(XLIM)

subplot(2,3,3); title('Timing error'); hold on %Accurate - Timing Error
histogram(drtAET, 'FaceColor','r', 'BinWidth',50); xlim(XLIM)

subplot(2,3,4); hold on %Fast - Correct
histogram(drtFC, 'FaceColor',[0 .7 0], 'BinWidth',50); xlim(XLIM)
xlabel('Change in response time (ms)'); ylabel('Frequency')

subplot(2,3,5); hold on %Fast - Choice Error
histogram(drtFEC, 'FaceColor',[0 .7 0], 'BinWidth',50); xlim(XLIM)

subplot(2,3,6); hold on %Fast - Timing Error
histogram(drtFET, 'FaceColor',[0 .7 0], 'BinWidth',50); xlim(XLIM)
ppretty([8,5])

end % fxn : plot_RT_X_TrialHistory()
