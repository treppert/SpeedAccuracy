function [  ] = plot_RT_distr_switch( info , moves , monkey )
%plot_param_re_switch Summary of this function goes here
%   Detailed explanation goes here

CONDITION = 'fast'; %'acc' or 'fast'
PLOT_TYPE = 'cdf'; %'pdf' or 'cdf'

MIN_NUM_TRIALS = 10;
NUM_SESSION = length(info);

RT_Start = cell(1,NUM_SESSION);
RT_End = cell(1,NUM_SESSION);

RT_dline = NaN(1,NUM_SESSION);

trial_switch = identify_condition_switch(info, monkey);

%% Collect RT on single-trial

for kk = 1:NUM_SESSION
  
  num_A2F = length(trial_switch(kk).A2F);
  num_F2A = length(trial_switch(kk).F2A);
  
  if ((num_A2F < MIN_NUM_TRIALS) || (num_F2A < MIN_NUM_TRIALS)); continue; end
  
  if strcmp(CONDITION, 'acc')
    
    RT_Start{kk} = moves(kk).resptime(trial_switch(kk).F2A);
    RT_End{kk} = moves(kk).resptime(trial_switch(kk).A2F-1);
    
    RT_dline(kk) = nanmean(info(kk).tgt_dline(info(kk).condition == 1));
    
  elseif strcmp(CONDITION, 'fast')
    
    RT_Start{kk} = moves(kk).resptime(trial_switch(kk).A2F);
    RT_End{kk} = moves(kk).resptime(trial_switch(kk).F2A-1);
    
    RT_dline(kk) = nanmean(info(kk).tgt_dline(info(kk).condition == 3));
    
  end
  
end%for:sessions(kk)

%% Compute RT distribution on single-trial

BIN_LIM = ( 100 : 50 : 1000 );
NUM_BIN = length(BIN_LIM) - 1;
RT_BIN = BIN_LIM(1:NUM_BIN) + diff(BIN_LIM)/2;

RT_Start_avg = NaN(NUM_SESSION,NUM_BIN);
RT_End_avg = NaN(NUM_SESSION,NUM_BIN);

for kk = 1:NUM_SESSION
  if isempty(RT_Start{kk}); continue; end
  
  figure(); set(gcf, 'visible','off')
  
  h_Start = histogram(RT_Start{kk}, 'BinEdges',BIN_LIM, 'normalization','probability');
  if strcmp(PLOT_TYPE, 'pdf')
    RT_Start_avg(kk,:) = h_Start.Values;
  elseif strcmp(PLOT_TYPE, 'cdf')
    RT_Start_avg(kk,:) = cumsum(h_Start.Values);
  end
  
  h_End = histogram(RT_End{kk}, 'BinEdges',BIN_LIM, 'normalization','probability');
  if strcmp(PLOT_TYPE, 'pdf')
    RT_End_avg(kk,:) = h_End.Values;
  elseif strcmp(PLOT_TYPE, 'cdf')
    RT_End_avg(kk,:) = cumsum(h_End.Values);
  end
  
  close(gcf)
  
end%for:sessions(kk)

%% Plotting

%remove sessions with no data
kk_nan = isnan(RT_Start_avg(:,1));
RT_Start_avg(kk_nan,:) = [];
RT_End_avg(kk_nan,:) = [];
NUM_SESSION = size(RT_Start_avg,1);

figure(); hold on

shaded_error_bar(RT_BIN, mean(RT_Start_avg), std(RT_Start_avg)/sqrt(NUM_SESSION), {'Color',[.4 .4 .4]})
shaded_error_bar(RT_BIN, mean(RT_End_avg), std(RT_End_avg)/sqrt(NUM_SESSION), {'Color','k'})
plot(nanmean(RT_dline)*ones(1,2), [0 0.15], 'k--', 'LineWidth',1.5)
ytickformat('%2.1f')

if strcmp(CONDITION, 'acc')
  xlim([100 1000])
elseif strcmp(CONDITION, 'fast')
  xlim([100 1000])
end

ppretty()

end%function:plot_RT_distr_switch()

