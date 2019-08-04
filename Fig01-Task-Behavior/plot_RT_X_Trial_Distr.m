function [  ] = plot_RT_X_Trial_Distr( binfo , moves , varargin )
%plot_RT_X_Trial_Distr Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

MIN_NUM_TRIAL = 5; %single-session min number per RT bin

[binfo, moves] = utilIsolateMonkeyBehavior(binfo, moves, zeros(1,length(binfo)), args.monkey);
N_SESS = length(binfo);

rtStartAcc = cell(1,N_SESS);   rtEndAcc = cell(1,N_SESS);
rtStartFast = cell(1,N_SESS);  rtEndFast = cell(1,N_SESS);

dlineAcc = NaN(1,N_SESS);
dlineFast = NaN(1,N_SESS);

trialSwitch = identify_condition_switch(binfo);

%% Collect RT on single-trial

for kk = 1:N_SESS
  
  jjA2F = trialSwitch(kk).A2F;
  jjF2A = trialSwitch(kk).F2A;
  
  rtStartAcc{kk} = moves(kk).resptime(jjF2A);   rtEndAcc{kk} = moves(kk).resptime(jjA2F - 1);
  rtStartFast{kk} = moves(kk).resptime(jjA2F);  rtEndFast{kk} = moves(kk).resptime(jjF2A - 1);
  
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  dlineAcc(kk) = nanmedian(binfo(kk).deadline(idxAcc));
  dlineFast(kk) = nanmedian(binfo(kk).deadline(idxFast));
  
end%for:sessions(kk)

%% Compute RT distributions

RT_BIN = ( 100 : 50 : 1000 );
N_BIN = length(RT_BIN) - 1;

cumStart_Acc = NaN(N_SESS,N_BIN);  cumEnd_Acc = NaN(N_SESS,N_BIN);
cumStart_Fast = NaN(N_SESS,N_BIN); cumEnd_Fast = NaN(N_SESS,N_BIN);

for kk = 1:N_SESS
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
shaded_error_bar(RT_PLOT, mean(cumStart_Acc), std(cumStart_Acc)/sqrt(N_SESS), {'Color',[1 .5 .5]})
shaded_error_bar(RT_PLOT, mean(cumEnd_Acc), std(cumEnd_Acc)/sqrt(N_SESS), {'Color','r'})
xlim([200 800]); ytickformat('%2.1f')

subplot(1,2,1); hold on %Fast condition
plot(mean(dlineFast)*ones(1,2), [0 1], 'k:')
shaded_error_bar(RT_PLOT, mean(cumStart_Fast), std(cumStart_Fast)/sqrt(N_SESS), {'Color',[0 .4 0]})
shaded_error_bar(RT_PLOT, mean(cumEnd_Fast), std(cumEnd_Fast)/sqrt(N_SESS), {'Color',[0 .8 0]})
xlim([200 600]); ytickformat('%2.1f')
xlabel('Response time (ms)'); ylabel('Cumulative probability')

ppretty([9,2])

end%function:plot_RT_X_Trial_Distr()

