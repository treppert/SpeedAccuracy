function [  ] = Fig06B_Plot_RT_X_Trial_Distr( behavData )
%Fig06B_Plot_RT_X_Trial_Distr Summary of this function goes here
%   Detailed explanation goes here

MIN_NUM_TRIAL = 5; %single-session min number per RT bin

%isolate sessions from MONKEY
MONKEY = {'D','E'};         sessKeep = ismember(behavData.Monkey, MONKEY);
NUM_SESS = sum(sessKeep);   behavData = behavData(sessKeep, :);

rtStartAcc = cell(1,NUM_SESS);   rtEndAcc = cell(1,NUM_SESS);
rtStartFast = cell(1,NUM_SESS);  rtEndFast = cell(1,NUM_SESS);

dlineAcc = NaN(1,NUM_SESS);
dlineFast = NaN(1,NUM_SESS);

trialSwitch = identify_condition_switch(behavData);

%% Collect RT on single-trial

for kk = 1:NUM_SESS
  
  jjA2F = trialSwitch.A2F{kk};
  jjF2A = trialSwitch.F2A{kk};
  
  rtStartAcc{kk} = behavData.Sacc_RT{kk}(jjF2A);   rtEndAcc{kk} = behavData.Sacc_RT{kk}(jjA2F - 1);
  rtStartFast{kk} = behavData.Sacc_RT{kk}(jjA2F);  rtEndFast{kk} = behavData.Sacc_RT{kk}(jjF2A - 1);
  
  idxAcc = (behavData.Task_Condition{kk} == 1);
  idxFast = (behavData.Task_Condition{kk} == 3);
  dlineAcc(kk) = nanmedian(behavData.Task_Deadline{kk}(idxAcc));
  dlineFast(kk) = nanmedian(behavData.Task_Deadline{kk}(idxFast));
  
end%for:sessions(kk)

%% Compute RT distributions

RT_BIN = ( 100 : 50 : 1000 );
N_BIN = length(RT_BIN) - 1;

cumStart_Acc = NaN(NUM_SESS,N_BIN);  cumEnd_Acc = NaN(NUM_SESS,N_BIN);
cumStart_Fast = NaN(NUM_SESS,N_BIN); cumEnd_Fast = NaN(NUM_SESS,N_BIN);

for kk = 1:NUM_SESS
  N_Acc = length(rtStartAcc{kk});
  N_Fast = length(rtStartFast{kk});
  
  if (N_Acc >= MIN_NUM_TRIAL)
    for ii = 1:N_BIN
      cumStart_Acc(kk,ii) = sum(rtStartAcc{kk} <= RT_BIN(ii)) / N_Acc ;
      cumEnd_Acc(kk,ii) = sum(rtEndAcc{kk} <= RT_BIN(ii)) / N_Acc ;
    end%for:RT-bin(ii)
  end%if:enough-trials-Acc
  
  if (N_Fast >= MIN_NUM_TRIAL)
    for ii = 1:N_BIN
      cumStart_Fast(kk,ii) = sum(rtStartFast{kk} <= RT_BIN(ii)) / N_Fast ;
      cumEnd_Fast(kk,ii) = sum(rtEndFast{kk} <= RT_BIN(ii)) / N_Fast ;
    end%for:RT-bin(ii)
  end%if:enough-trials-Fast
  
end%for:sessions(kk)

%% Plotting
RT_PLOT = RT_BIN(1:N_BIN) + diff(RT_BIN)/2;

figure()

subplot(1,2,2); hold on %Accurate condition
plot(mean(dlineAcc)*ones(1,2), [0 1], 'k:')
shaded_error_bar(RT_PLOT, mean(cumStart_Acc), std(cumStart_Acc)/sqrt(NUM_SESS), {'Color',[1 .5 .5]})
shaded_error_bar(RT_PLOT, mean(cumEnd_Acc), std(cumEnd_Acc)/sqrt(NUM_SESS), {'Color','r'})
xlim([200 800]); ytickformat('%2.1f')

subplot(1,2,1); hold on %Fast condition
plot(mean(dlineFast)*ones(1,2), [0 1], 'k:')
shaded_error_bar(RT_PLOT, mean(cumStart_Fast), std(cumStart_Fast)/sqrt(NUM_SESS), {'Color',[0 .4 0]})
shaded_error_bar(RT_PLOT, mean(cumEnd_Fast), std(cumEnd_Fast)/sqrt(NUM_SESS), {'Color',[0 .8 0]})
xlim([200 600]); ytickformat('%2.1f')
xlabel('Response time (ms)'); ylabel('Cumulative probability')

ppretty([9,2])

end%function:plot_RT_X_Trial_Distr()

