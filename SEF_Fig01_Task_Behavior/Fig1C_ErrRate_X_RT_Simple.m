function [ ] = Fig1C_ErrRate_X_RT_Simple( behavData , varargin )
%Fig1C_ErrRate_X_RT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

%isolate sessions from MONKEY
sessKeep = (ismember(behavData.Monkey, args.monkey) & behavData.Task_RecordedSEF);
NUM_SESS = sum(sessKeep);   behavData = behavData(sessKeep, :);

%% Compute RT/ER and split on Task Condition
ER_Acc = NaN(1,NUM_SESS);   RT_Acc = NaN(1,NUM_SESS);
ER_Fast = NaN(1,NUM_SESS);  RT_Fast = NaN(1,NUM_SESS);

for kk = 1:NUM_SESS
  
  %index by condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1) & ~isnan(behavData.Task_Deadline{kk});
  idxFast = (behavData.Task_SATCondition{kk} == 3) & ~isnan(behavData.Task_Deadline{kk});
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrNoSacc{kk});
  idxErr = (behavData.Task_ErrChoice{kk});
  
  RT_Acc(kk) = median(behavData.Sacc_RT{kk}(idxAcc & idxCorr));
  RT_Fast(kk) = median(behavData.Sacc_RT{kk}(idxFast & idxCorr));
  ER_Acc(kk) = sum(idxAcc & idxErr) / sum(idxAcc);
  ER_Fast(kk) = sum(idxFast & idxErr) / sum(idxFast);
  
end%for:session(kk)


%% Statistics
[~,pER,~,tER] = ttest(ER_Acc, ER_Fast) %paired t-test -- error rate
[~,pRT,~,tRT] = ttest(RT_Acc, RT_Fast) %paired t-test -- response time

%% Plotting
BLUE = [0 0 1];

muER = [mean(ER_Fast) mean(ER_Acc)];    seER = [std(ER_Fast) std(ER_Acc)] / sqrt(NUM_SESS);
muRT = [mean(RT_Fast) mean(RT_Acc)];    seRT = [std(RT_Fast) std(RT_Acc)] / sqrt(NUM_SESS);

figure(); hold on
errorbarxy(muRT, muER, seRT, seER, {'k-','k','k'})
ppretty([1.8,1.2]); set(gca, 'YColor',BLUE)


figure()

subplot(1,2,1); hold on; set(gca, 'YColor',BLUE)
errorbar(muRT, seRT, 'CapSize',0, 'LineWidth',1, 'Color','k')
xlim([0.9 2.1]); xticks([1 2]); xticklabels({'Fast','Accurate'})

subplot(1,2,2); hold on; set(gca, 'YColor',BLUE)
errorbar(muER, seER, 'CapSize',0, 'LineWidth',1, 'Color','k')
xlim([0.9 2.1]); xticks([1 2]); xticklabels({'Fast','Accurate'})

ppretty([4,1.2])

end % fxn : Fig1C_ErrRate_X_RT_Simple()
