function [  ] = plotRTDistrSwitch( binfo , moves , varargin )
%plotRTDistrSwitch Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

[binfo, moves] = utilIsolateMonkeyBehavior(binfo, moves, args.monkey);
NUM_SESSION = length(binfo);

MIN_NUM_TRIALS = 8;
CONDITION = 'fast'; %'acc' or 'fast'

RT_Start = cell(1,NUM_SESSION);
RT_End = cell(1,NUM_SESSION);

trial_switch = identify_condition_switch(binfo);

%% Collect RT on single-trial

for kk = 1:NUM_SESSION
  
  jjSwitchA2F = trial_switch(kk).A2F;
  jjSwitchF2A = trial_switch(kk).F2A;
  
  num_A2F = length(jjSwitchA2F);
  num_F2A = length(jjSwitchF2A);
  
  if ((num_A2F < MIN_NUM_TRIALS) || (num_F2A < MIN_NUM_TRIALS))
    fprintf('Session %d -- Less than %d trials\n', kk, MIN_NUM_TRIALS)
    continue
  end
    
  %remove choice error trials
  jjErr = find(binfo(kk).err_dir);
  jjSwitchA2F = jjSwitchA2F(~ismember(jjSwitchA2F, jjErr));
  jjSwitchF2A = jjSwitchF2A(~ismember(jjSwitchF2A, jjErr));
  
  if strcmp(CONDITION, 'acc')
    
    RT_Start{kk} = moves(kk).resptime(jjSwitchF2A);
    RT_End{kk} = moves(kk).resptime(jjSwitchA2F - 1);
    
  elseif strcmp(CONDITION, 'fast')
    
    RT_Start{kk} = moves(kk).resptime(jjSwitchA2F);
    RT_End{kk} = moves(kk).resptime(jjSwitchF2A - 1);
    
  end
  
end%for:sessions(kk)

%% Compute RT distributions

BIN_LIM = ( 100 : 50 : 1000 );
NUM_BIN = length(BIN_LIM) - 1;
RT_BIN = BIN_LIM(1:NUM_BIN) + diff(BIN_LIM)/2;

RT_Start_avg = NaN(NUM_SESSION,NUM_BIN);
RT_End_avg = NaN(NUM_SESSION,NUM_BIN);

for kk = 1:NUM_SESSION
  if isempty(RT_Start{kk}); continue; end
  
  figure(); set(gcf, 'visible','off')
  
  h_Start = histogram(RT_Start{kk}, 'BinEdges',BIN_LIM, 'normalization','probability');
  RT_Start_avg(kk,:) = cumsum(h_Start.Values);
  
  h_End = histogram(RT_End{kk}, 'BinEdges',BIN_LIM, 'normalization','probability');
  RT_End_avg(kk,:) = cumsum(h_End.Values);
  
  close(gcf)
  
end%for:sessions(kk)

%% Plotting

%remove sessions with no data
kkNaN = isnan(RT_Start_avg(:,1));
RT_Start_avg(kkNaN,:) = [];
RT_End_avg(kkNaN,:) = [];
NUM_SEM = size(RT_Start_avg,1);

if strcmp(CONDITION, 'acc')
  XLIM = [100 1000];
  COLOR_PLOT = {[1 .5 .5], [1 0 0]};
elseif strcmp(CONDITION, 'fast')
  XLIM = [100 600];
  COLOR_PLOT = {[0 .4 0], [0 .8 0]};
end

figure(); hold on

shaded_error_bar(RT_BIN, mean(RT_Start_avg), std(RT_Start_avg)/sqrt(NUM_SEM), {'Color',COLOR_PLOT{1}})
shaded_error_bar(RT_BIN, mean(RT_End_avg), std(RT_End_avg)/sqrt(NUM_SEM), {'Color',COLOR_PLOT{2}})
ytickformat('%2.1f')
xlim(XLIM)

ppretty([6.4,4])

end%function:plotRTDistrSwitch()

