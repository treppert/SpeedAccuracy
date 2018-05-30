function [ ] = plot_pcent_corr_vs_RT_2( moves , info )
%[  ] = plot_pcent_corr_vs_RT( moves , info )
%   Detailed explanation goes here

MIN_PER_BIN = 8; %number of movements per RT bin

%set up the RT bins to average data
BIN_LIM = 200 : 50 : 850;
NUM_BIN = length(BIN_LIM) - 1;
RT_PLOT  = BIN_LIM(1:NUM_BIN) + diff(BIN_LIM)/2;

%mark trials with errors in direction
% info = determine_errors_SAT(info);

NUM_SESSION = length(moves);
MIN_NUM_SESSION = 3;

%% Get binned percent correct
Pcorr_acc = NaN(NUM_SESSION,NUM_BIN);
Pcorr_fast = NaN(NUM_SESSION,NUM_BIN);

for kk = 1:NUM_SESSION
  
  resptime = double(moves(kk).resptime);
  idx_err = info(kk).err_dir;
  
  idx_acc = (info(kk).condition == 1);
  idx_fast = (info(kk).condition == 3);
  
  for jj = 1:NUM_BIN
    
    %get trials with appropriate RT
    idx_jj = (resptime > BIN_LIM(jj)) & (resptime < BIN_LIM(jj+1));
    
    %calculate percent correct for this RT bin
    if (sum(idx_jj & idx_fast) >= MIN_PER_BIN)
      Pcorr_fast(kk,jj) = 1.0 - (sum(idx_err(idx_jj & idx_fast)) / sum(idx_jj & idx_fast));
    end
    
    if (sum(idx_jj & idx_acc) >= MIN_PER_BIN)
      Pcorr_acc(kk,jj) = 1.0 - (sum(idx_err(idx_jj & idx_acc)) / sum(idx_jj & idx_acc));
    end
    
  end%for:RT_bins(jj)
  
end%for:session(kk)

%% Plot across all sessions

bin_nan_acc = (sum(~isnan(Pcorr_acc),1) < MIN_NUM_SESSION);
bin_nan_fast = (sum(~isnan(Pcorr_fast),1) < MIN_NUM_SESSION);

Pcorr_acc(:,bin_nan_acc) = NaN;
Pcorr_fast(:,bin_nan_fast) = NaN;

NUM_SEM_ACC = sum(~isnan(Pcorr_acc),1);
NUM_SEM_FAST = sum(~isnan(Pcorr_fast),1);

figure(); hold on
shaded_error_bar(RT_PLOT, nanmean(Pcorr_acc), nanstd(Pcorr_acc)./sqrt(NUM_SEM_ACC), {'r-', 'LineWidth',1.5})
shaded_error_bar(RT_PLOT, nanmean(Pcorr_fast), nanstd(Pcorr_fast)./sqrt(NUM_SEM_FAST), {'-', 'Color',[0 .7 0], 'LineWidth',1.5})
ppretty('image_size',[4.8,3])

% figure(); hold on
% plot(RT_PLOT, Pcorr_acc, 'r.-', 'LineWidth',1.5)
% xlim([200 850])
% ppretty('image_size',[4.8,3])

% figure(); hold on
% plot(RT_PLOT, Pcorr_fast, '.-', 'Color',[0 .7 0], 'LineWidth',1.5)
% xlim([200 850])
% ppretty('image_size',[4.8,3])

end%function:plot_prob_error_vs_rxntime_SAT()
