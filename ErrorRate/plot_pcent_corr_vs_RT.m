function [ ] = plot_pcent_corr_vs_RT( moves , info )
%[  ] = plot_pcent_corr_vs_RT( moves , info )
%   Detailed explanation goes here

%set up the RT bins to average data
BIN_LIM = 200 : 50 : 850;
NUM_BIN = length(BIN_LIM) - 1;
RT_PLOT  = BIN_LIM(1:NUM_BIN) + diff(BIN_LIM)/2;

%mark trials with errors in direction
info = determine_errors_SAT(info);


%% Get binned percent correct
Pcorr = NaN(1,NUM_BIN);

RT = [moves.resptime];
IDX_ERR = [info.err_dir];

for jj = 1:NUM_BIN
  
  %get trials with appropriate RT
  idx_jj = (RT > BIN_LIM(jj)) & (RT < BIN_LIM(jj+1));
  
  %calculate percent correct for this RT bin
  Pcorr(jj) = 1.0 - (sum(IDX_ERR(idx_jj)) / sum(idx_jj));
  
end%for:RT_bins(jj)

%% Plot across all sessions

figure(); hold on
plot(RT_PLOT, Pcorr, 'kd-', 'LineWidth',1.25)
ppretty()


end%function:plot_prob_error_vs_rxntime_SAT()
