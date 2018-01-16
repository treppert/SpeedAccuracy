function [  ] = plot_RT_distr_switch( info , moves , monkey )
%plot_param_re_switch Summary of this function goes here
%   Detailed explanation goes here

MIN_NUM_TRIALS = 10;
NUM_SESSION = length(info);

RT_AccStart = cell(1,NUM_SESSION);
RT_AccEnd = cell(1,NUM_SESSION);

RT_dline = NaN(1,NUM_SESSION);

trial_switch = identify_condition_switch(info, monkey);

%% Collect RT on single-trial

for kk = 1:NUM_SESSION
  
  num_A2F = length(trial_switch(kk).A2F);
  num_F2A = length(trial_switch(kk).F2A);
  
  if ((num_A2F < MIN_NUM_TRIALS) || (num_F2A < MIN_NUM_TRIALS)); continue; end
  
  RT_AccStart{kk} = moves(kk).resptime(trial_switch(kk).F2A);
  RT_AccEnd{kk} = moves(kk).resptime(trial_switch(kk).A2F-1);
  
  RT_dline(kk) = nanmean(info(kk).tgt_dline(info(kk).condition == 1));
  
end%for:sessions(kk)

%% Compute RT distribution on single-trial

BIN_LIM = ( 120 : 40 : 1000 );
NUM_BIN = length(BIN_LIM) - 1;
RT_BIN = BIN_LIM(1:NUM_BIN) + diff(BIN_LIM)/2;

RT_AccStart_avg = NaN(NUM_SESSION,NUM_BIN);
RT_AccEnd_avg = NaN(NUM_SESSION,NUM_BIN);

for kk = 1:NUM_SESSION
  if isempty(RT_AccStart{kk}); continue; end
  
  figure(); set(gcf, 'visible','off')
  
  h_Start = histogram(RT_AccStart{kk}, 'BinEdges',BIN_LIM, 'normalization','probability');
  RT_AccStart_avg(kk,:) = cumsum(h_Start.Values);
  
  h_End = histogram(RT_AccEnd{kk}, 'BinEdges',BIN_LIM, 'normalization','probability');
  RT_AccEnd_avg(kk,:) = cumsum(h_End.Values);
  
  close(gcf)
  
end%for:sessions(kk)

%% Plotting

%remove sessions with no data
kk_nan = isnan(RT_AccStart_avg(:,1));
RT_AccStart_avg(kk_nan,:) = [];
RT_AccEnd_avg(kk_nan,:) = [];
NUM_SESSION = size(RT_AccStart_avg,1);

figure(); hold on

shaded_error_bar(RT_BIN, mean(RT_AccStart_avg), std(RT_AccStart_avg)/sqrt(NUM_SESSION), {'Color',[.4 .4 .4]})
shaded_error_bar(RT_BIN, mean(RT_AccEnd_avg), std(RT_AccEnd_avg)/sqrt(NUM_SESSION), {'Color','k'})
plot(nanmean(RT_dline)*ones(1,2), [0 1.0], 'k--', 'LineWidth',1.5)

xlim([100 1000])
ppretty()

end%function:plot_RT_distr_switch()

