function [ varargout ] = plot_PDF_RTerr_SAT( behavData )
%plot_PDF_RTerr_SAT Summary of this function goes here
%   Detailed explanation goes here

%isolate sessions from monkey of choice
kkKeep = (ismember(behavData.Monkey, {'D','E'}));% & behavData.Task_RecordedSEF);
behavData = behavData(kkKeep, :);
NUM_SESS = sum(kkKeep);

errRT_Acc = cell(NUM_SESS,1);
errRT_Fast = errRT_Acc;
errRT = errRT_Acc;

%% Collect dRT across sessions
for kk = 1:NUM_SESS
  RTkk = behavData.Sacc_RT{kk};
  
  %index by trial outcome
  idxErr = behavData.Task_ErrTime{kk} & ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrNoSacc{kk});
  
  %index by condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  
  %get deadline for each condition
  dlineAcc =  nanmedian(behavData.Task_Deadline{kk}(idxAcc));
  dlineFast = nanmedian(behavData.Task_Deadline{kk}(idxFast));
  
  errRT_Acc{kk}  = transpose(RTkk(idxAcc & idxErr) - dlineAcc);
  errRT_Fast{kk} = transpose(RTkk(idxFast & idxErr) - dlineFast);
  
  errRT{kk} = NaN(behavData.Task_NumTrials(kk),1);
  errRT{kk}(idxAcc)  = RTkk(idxAcc) - dlineAcc;
  errRT{kk}(idxFast) = RTkk(idxFast) - dlineFast;
  
end%for:sessions(kk)

if (nargout > 0); varargout{1} = errRT; end

%% Plotting
figure()

subplot(1,2,1); title('Fast', 'FontSize',9); hold on %Fast error
histogram([errRT_Fast{1:end}], 'BinEdges',(-100:20:400), 'FaceColor',[0 .7 0])
xlabel('Error in RT (ms)')
ylabel('Frequency')

subplot(1,2,2); title('Accurate', 'FontSize',9); hold on %Accurate error
histogram([errRT_Acc{1:end}], 'BinEdges',(-400:20:100), 'FaceColor','r')
xlabel('Error in RT (ms)')


% xticks(1:4); xticklabels({'F','A','F','A'})
ppretty([7,2])

end % fxn : plot_errRT_SAT()
