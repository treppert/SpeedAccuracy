function [  ] = plot_RT_after_switch( info , moves )
%plot_param_re_switch Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(info);

RT_A2F = cell(1,NUM_SESSION);
RT_F2A = cell(1,NUM_SESSION);

dline_A2F = NaN(1,NUM_SESSION);
dline_F2A = NaN(1,NUM_SESSION);

trial_switch = identify_condition_switch(info);

%% Collect RT on single-trial

for kk = 1:NUM_SESSION
  
  RT_A2F{kk} = moves(kk).resptime(trial_switch(kk).A2F);
  RT_F2A{kk} = moves(kk).resptime(trial_switch(kk).F2A);
  
  dline_A2F(kk) = nanmean(info(kk).tgt_dline(trial_switch(kk).A2F));
  dline_F2A(kk) = nanmean(info(kk).tgt_dline(trial_switch(kk).F2A));
  
end%for:sessions(kk)

%% Compute RT distribution on single-trial

BIN_LIM = ( 200 : 40 : 1000 );
NUM_BIN = length(BIN_LIM) - 1;
RT_BIN = BIN_LIM(1:NUM_BIN) + diff(BIN_LIM)/2;

RT_A2F_avg = NaN(NUM_SESSION,NUM_BIN);
RT_F2A_avg = NaN(NUM_SESSION,NUM_BIN);

for kk = 1:NUM_SESSION
  
  figure(); set(gcf, 'visible','off')
  
  h_A2F = histogram(RT_A2F{kk}, 'BinEdges',BIN_LIM, 'normalization','probability');
  RT_A2F_avg(kk,:) = h_A2F.Values;
  
  h_F2A = histogram(RT_F2A{kk}, 'BinEdges',BIN_LIM, 'normalization','probability');
  RT_F2A_avg(kk,:) = h_F2A.Values;
  
  close(gcf)
  
end%for:sessions(kk)

%% Plotting

figure(); hold on

shaded_error_bar(RT_BIN, mean(RT_F2A_avg), std(RT_F2A_avg)/sqrt(NUM_SESSION), {'Color',[.4 .4 .4]})
plot(mean(dline_F2A)*ones(1,2), [0 .10], 'k--', 'LineWidth',1.5)

xlim([200 1000])
ppretty()

end%function:plot_param_re_switch()

