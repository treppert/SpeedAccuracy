function [ ] = plot_ISI_X_Sacc2Endpt( behavData )
%plot_ISI_X_Sacc2Endpt Summary of this function goes here
%   Detailed explanation goes here

%isolate appropriate recording sessions
kkKeep = (ismember(behavData.Monkey, {'D','E'}) & behavData.Task_RecordedSEF);
NUM_SESS = sum(kkKeep);   behavData = behavData(kkKeep, :);

%initializations
ISI_Sacc2T = NaN(NUM_SESS,2); % Fast | Accurate
ISI_Sacc2D = NaN(NUM_SESS,2);

for kk = 1:NUM_SESS
  ISI_kk = behavData.Sacc2_RT{kk} - (behavData.Sacc_RT{kk} + behavData.Sacc_Duration{kk});
  
  %index by task condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  %index by trial outcome
  idxErr = (behavData.Task_ErrChoice{kk} & ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  
  %index by second saccade endpoint
  idxTgt = (behavData.Sacc2_Endpoint{kk} == 1);
  idxDistr = (behavData.Sacc2_Endpoint{kk} == 2);
  idxFix = (behavData.Sacc2_Endpoint{kk} == 3);
  
  ISI_FastT = ISI_kk(idxFast & idxErr & idxTgt);
  ISI_FastD = ISI_kk(idxFast & idxErr & (idxDistr | idxFix));
  ISI_AccT  = ISI_kk(idxAcc & idxErr & idxTgt);
  ISI_AccD  = ISI_kk(idxAcc & idxErr & (idxDistr | idxFix));
  
  %save average ISI per condition per saccade endpoint
  ISI_Sacc2T(kk,:) = [ mean(ISI_FastT) , mean(ISI_AccT) ];
  ISI_Sacc2D(kk,:) = [ mean(ISI_FastD) , mean(ISI_AccD) ];
  
end %for : session (kk)

muPlot = [mean(ISI_Sacc2T) , mean(ISI_Sacc2D)];
sePlot = [std(ISI_Sacc2T) , std(ISI_Sacc2D)] / sqrt(NUM_SESS);
figure(); hold on
bar(muPlot, 'FaceColor','w')
errorbar(muPlot, sePlot, 'Color','k', 'CapSize',0)
ylabel('Inter-saccade interval (ms)')
xticks(1:4); xticklabels({'Fast','Acc','Fast','Acc'})
ppretty([3,3])

%stats
fprintf('Fast: '); ttestFull(ISI_Sacc2T(:,1), ISI_Sacc2D(:,1)) %Fast
fprintf('Acc: '); ttestFull(ISI_Sacc2T(:,2), ISI_Sacc2D(:,2)) %Accurate

end % fxn : plot_ISI_X_Sacc2Endpt()

