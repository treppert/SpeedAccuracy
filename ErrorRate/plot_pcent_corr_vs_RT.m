function [ ] = plot_pcent_corr_vs_RT( moves , info )
%[  ] = plot_pcent_corr_vs_RT( moves , info )
%   Detailed explanation goes here

MIN_PER_BIN = 50; %number of movements per RT bin

%set up the RT bins to average data
BIN_LIM = 200 : 50 : 850;
NUM_BIN = length(BIN_LIM) - 1;
RT_PLOT  = BIN_LIM(1:NUM_BIN) + diff(BIN_LIM)/2;

%mark trials with errors in direction
% info = determine_errors_SAT(info);

%% Get binned percent correct
Pcorr_acc = NaN(1,NUM_BIN);
Pcorr_fast = NaN(1,NUM_BIN);

RT = double([moves.resptime]);
IDX_ERR = [info.err_dir];

idx_acc = ([info.condition] == 1);
idx_fast = ([info.condition] == 3);

for jj = 1:NUM_BIN
  
  %get trials with appropriate RT
  idx_jj = (RT > BIN_LIM(jj)) & (RT < BIN_LIM(jj+1));
  
  %calculate percent correct for this RT bin
  if (sum(idx_jj & idx_fast) >= MIN_PER_BIN)
    Pcorr_fast(jj) = 1.0 - (sum(IDX_ERR(idx_jj & idx_fast)) / sum(idx_jj & idx_fast));
  end
  
  if (sum(idx_jj & idx_acc) >= MIN_PER_BIN)
    Pcorr_acc(jj) = 1.0 - (sum(IDX_ERR(idx_jj & idx_acc)) / sum(idx_jj & idx_acc));
  end
  
end%for:RT_bins(jj)

%% Plot across all sessions

figure(); hold on
plot(RT_PLOT, Pcorr_acc, 'r.-', 'LineWidth',1.55)
plot(RT_PLOT, Pcorr_fast, '.-', 'Color',[0 .7 0], 'LineWidth',1.55)
ppretty()


end%function:plot_prob_error_vs_rxntime_SAT()
