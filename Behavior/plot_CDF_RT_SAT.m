function [  ] = plot_CDF_RT_SAT( behavData )
%plot_rtDistr_SAT Summary of this function goes here
%   Detailed explanation goes here

%isolate sessions from monkey of choice
kkKeep = (ismember(behavData.Monkey, {'E'}) & behavData.Task_RecordedSEF);
behavData = behavData(kkKeep, :);
NUM_SESS = sum(kkKeep);

rt_Acc = cell(NUM_SESS,2); % Correct , Timing error
rt_Fast = rt_Acc;

%% Collect RT on single trial
for kk = 1:NUM_SESS
  
  %index by trial outcome
  idxCorr = (behavData.Task_Correct{kk});
  idxErrTime = (behavData.Task_ErrTime{kk});
  
  %index by condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  
  rt_Acc{kk,1} = behavData.Sacc_RT{kk}(idxAcc & idxCorr);
  rt_Fast{kk,1} = behavData.Sacc_RT{kk}(idxFast & idxCorr);
  
  rt_Acc{kk,2} = behavData.Sacc_RT{kk}(idxAcc & idxErrTime);
  rt_Fast{kk,2} = behavData.Sacc_RT{kk}(idxFast & idxErrTime);
  
end%for:sessions(kk)

%% Compute RT distribution on single trial
BIN_LIM = ( 100 : 50 : 1000 );
NUM_BIN = length(BIN_LIM) - 1;
RT_BIN = BIN_LIM(1:NUM_BIN) + diff(BIN_LIM)/2;

RT_Acc = NaN(2*NUM_SESS,NUM_BIN); %Correct ; Timing error
RT_Fast = RT_Acc;

for kk = 1:NUM_SESS
  h_Fig = figure('visible','off'); hold on
  
  h_AccCorr =  histogram(rt_Acc{kk,1},  'BinEdges',BIN_LIM, 'normalization','probability');
  h_FastCorr = histogram(rt_Fast{kk,1}, 'BinEdges',BIN_LIM, 'normalization','probability');
  RT_Acc(kk,:) = cumsum(h_AccCorr.Values);
  RT_Fast(kk,:) = cumsum(h_FastCorr.Values);
  
  h_AccErr =  histogram(rt_Acc{kk,2},  'BinEdges',BIN_LIM, 'normalization','probability');
  h_FastErr = histogram(rt_Fast{kk,2}, 'BinEdges',BIN_LIM, 'normalization','probability');
  RT_Acc(kk+NUM_SESS,:) = cumsum(h_AccErr.Values);
  RT_Fast(kk+NUM_SESS,:) = cumsum(h_FastErr.Values);
  
  close(h_Fig)
end%for:sessions(kk)

%% Plotting
figure(); hold on

idxCorr = (1:NUM_SESS);
idxErr = (NUM_SESS+1:2*NUM_SESS);

shaded_error_bar(RT_BIN, mean(RT_Fast(idxCorr,:)), std(RT_Fast(idxCorr,:))/sqrt(NUM_SESS), {'Color',[0 .7 0]})
shaded_error_bar(RT_BIN, mean(RT_Acc(idxCorr,:)), std(RT_Acc(idxCorr,:))/sqrt(NUM_SESS), {'Color','r'})
shaded_error_bar(RT_BIN, mean(RT_Fast(idxErr,:)), std(RT_Fast(idxErr,:))/sqrt(NUM_SESS), {':','Color',[0 .7 0]})
shaded_error_bar(RT_BIN, mean(RT_Acc(idxErr,:)), std(RT_Acc(idxErr,:))/sqrt(NUM_SESS), {':','Color','r'})

xlim([100 800])
xlabel('Response time (ms)')
ylabel('Cumulative distribution function')
ppretty([4.8,3])

end %fxn:plot_rtDistr_SAT()
