function [  ] = plot_PDF_dRT_SAT( behavData )
%plot_PDF_dRT_SAT Summary of this function goes here
%   Detailed explanation goes here

%isolate sessions from monkey of choice
kkKeep = (ismember(behavData.Monkey, {'D','E'}) & behavData.Task_RecordedSEF);
behavData = behavData(kkKeep, :);
NUM_SESS = sum(kkKeep);

dRT_Acc = cell(NUM_SESS,2); % Correct , Timing error
dRT_Fast = dRT_Acc;

%% Collect dRT across sessions
for kk = 1:NUM_SESS
  RTkk = transpose(behavData.Sacc_RT{kk});
  
  %index by trial outcome
  idxCorr = (behavData.Task_Correct{kk});
  idxErr = behavData.Task_ErrTime{kk} & ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrNoSacc{kk});
  
  %index by condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  
  trialAC = find(idxAcc & idxCorr); trialAC(end) = [];
  trialFC = find(idxFast & idxCorr); trialFC(end) = [];
  trialAE = find(idxAcc & idxErr); trialAE(end) = [];
  trialFE = find(idxFast & idxErr); trialFE(end) = [];
  
  dRT_Acc{kk,1}  = RTkk(trialAC+1) - RTkk(trialAC); %dRT after correct
  dRT_Fast{kk,1} = RTkk(trialFC+1) - RTkk(trialFC);
  
  dRT_Acc{kk,2}  = RTkk(trialAE+1) - RTkk(trialAE); %dRT after timing error
  dRT_Fast{kk,2} = RTkk(trialFE+1) - RTkk(trialFE);
  
end%for:sessions(kk)

%% Plotting
figure()
BIN_EDGES = (-500 : 50 : 500);

subplot(2,2,1); title('Fast - Correct', 'FontSize',9); hold on %Fast correct
histogram([dRT_Fast{1:end,1}], 'BinEdges',BIN_EDGES, 'FaceColor',[0 .7 0])
ylabel('Frequency')

subplot(2,2,2); title('Accurate - Correct', 'FontSize',9); hold on %Accurate correct
histogram([dRT_Acc{1:end,1}], 'BinEdges',BIN_EDGES, 'FaceColor','r')

subplot(2,2,3); title('Fast - Error', 'FontSize',9); hold on %Fast error
histogram([dRT_Fast{1:end,2}], 'BinEdges',BIN_EDGES, 'FaceColor',[0 .7 0])
xlabel('Change in RT (ms)')
ylabel('Frequency')

subplot(2,2,4); title('Accurate - Error', 'FontSize',9); hold on %Accurate error
histogram([dRT_Acc{1:end,2}], 'BinEdges',BIN_EDGES, 'FaceColor','r')
xlabel('Change in RT (ms)')


% xticks(1:4); xticklabels({'F','A','F','A'})
ppretty([7,4])

end %fxn:plot_dRT_SAT()
