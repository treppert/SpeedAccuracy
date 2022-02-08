function [  ] = plot_rtDistr_X_Switch_SAT( behavData )
%plot_rtDistr_X_Switch_SAT Summary of this function goes here
%   Detailed explanation goes here

PLOT_TYPE = 'cdf'; %'pdf' or 'cdf'
MIN_NUM_TRIALS = 10; %min number of switch trials

%isolate sessions from monkey of choice
kkKeep = (ismember(behavData.Monkey, {'E'}) & behavData.Task_RecordedSEF);
behavData = behavData(kkKeep, :);
NUM_SESS = sum(kkKeep);

RT_Start = cell(NUM_SESS,2); % Fast ; Accurate
RT_End =   cell(NUM_SESS,2);
RT_dline = NaN(NUM_SESS,2);

trialSwitch = identify_condition_switch( behavData );

%% Collect RT on single trial
for kk = 1:NUM_SESS
  
  num_A2F = length(trialSwitch.A2F{kk});
  num_F2A = length(trialSwitch.F2A{kk});
  
  if ((num_A2F < MIN_NUM_TRIALS) || (num_F2A < MIN_NUM_TRIALS)); continue; end
  
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  
  %Accurate condition
  RT_Start{kk,2} = behavData.Sacc_RT{kk}(trialSwitch.F2A{kk});
  RT_End{kk,2} = behavData.Sacc_RT{kk}(trialSwitch.A2F{kk}-1);
  RT_dline(kk,2) = nanmean(behavData.Task_Deadline{kk}(idxAcc));
  
  %Fast condition
  RT_Start{kk,1} = behavData.Sacc_RT{kk}(trialSwitch.A2F{kk});
  RT_End{kk,1} = behavData.Sacc_RT{kk}(trialSwitch.F2A{kk}-1);
  RT_dline(kk,1) = nanmean(behavData.Task_Deadline{kk}(idxFast));
  
end%for:sessions(kk)

%% Compute RT distribution on single trial
BIN_LIM = ( 100 : 50 : 1000 );
NUM_BIN = length(BIN_LIM) - 1;
RT_BIN = BIN_LIM(1:NUM_BIN) + diff(BIN_LIM)/2;

RT_Start_mean = NaN(2*NUM_SESS,NUM_BIN); % Fast ; Accurate
RT_End_mean = NaN(2*NUM_SESS,NUM_BIN);

for kk = 1:NUM_SESS
  if isempty(RT_Start{kk}); continue; end
  h_Fig = figure('visible','off'); hold on
  
  h_Start_Fast = histogram(RT_Start{kk,1}, 'BinEdges',BIN_LIM, 'normalization','probability');
  h_End_Fast =   histogram(RT_End{kk,1}, 'BinEdges',BIN_LIM, 'normalization','probability');
  h_Start_Acc =  histogram(RT_Start{kk,2}, 'BinEdges',BIN_LIM, 'normalization','probability');
  h_End_Acc =    histogram(RT_End{kk,2}, 'BinEdges',BIN_LIM, 'normalization','probability');
  if strcmp(PLOT_TYPE, 'pdf')
    RT_Start_mean(kk,:) = h_Start_Fast.Values; %Fast
    RT_End_mean(kk,:) = h_End_Fast.Values;
    RT_Start_mean(kk+NUM_SESS,:) = h_Start_Acc.Values; %Accurate
    RT_End_mean(kk+NUM_SESS,:) = h_End_Acc.Values;
  elseif strcmp(PLOT_TYPE, 'cdf')
    RT_Start_mean(kk,:) = cumsum(h_Start_Fast.Values); %Fast
    RT_End_mean(kk,:) = cumsum(h_End_Fast.Values);
    RT_Start_mean(kk+NUM_SESS,:) = cumsum(h_Start_Acc.Values); %Accurate
    RT_End_mean(kk+NUM_SESS,:) = cumsum(h_End_Acc.Values);
  end
  
  close(h_Fig)
end%for:sessions(kk)

%% Plotting
figure(); hold on

%Fast condition
shaded_error_bar(RT_BIN, nanmean(RT_Start_mean(1:NUM_SESS,:)), std(RT_Start_mean(1:NUM_SESS,:))/sqrt(NUM_SESS), {'Color',[0 .7 0]})
shaded_error_bar(RT_BIN, nanmean(RT_End_mean(1:NUM_SESS,:)), std(RT_End_mean(1:NUM_SESS,:))/sqrt(NUM_SESS), {'Color',[0 .7 0]})
plot(nanmean(RT_dline(:,1))*ones(1,2), [.02 .98], ':', 'Color',[0 .7 0], 'LineWidth',1.2)

%Accurate condition
shaded_error_bar(RT_BIN, nanmean(RT_Start_mean(NUM_SESS:end,:)), std(RT_Start_mean(NUM_SESS:end,:))/sqrt(NUM_SESS), {'Color','r'})
shaded_error_bar(RT_BIN, nanmean(RT_End_mean(NUM_SESS:end,:)), std(RT_End_mean(NUM_SESS:end,:))/sqrt(NUM_SESS), {'Color','r'})
plot(nanmean(RT_dline(:,2))*ones(1,2), [.02 .98], 'r:', 'LineWidth',1.2)

xlim([0 800])
xlabel('Response time (ms)')
ylabel('Cumulative distribution function')
ppretty([4.8,3])

end %fxn:plot_plot_rtDistr_X_Switch_SATrtDistr_X_SAT()
