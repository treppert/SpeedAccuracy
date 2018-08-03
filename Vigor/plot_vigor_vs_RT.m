function [ ] = plot_vigor_vs_RT( moves , info )
%[  ] = plot_vigor_vs_RT( moves , info )
%   Detailed explanation goes here

MIN_PER_BIN = 10; %number of movements per RT bin

%set up the RT bins to average data
BIN_LIM = 150 : 50 : 850;
NUM_BIN = length(BIN_LIM) - 1;
RT_PLOT  = BIN_LIM(1:NUM_BIN) + diff(BIN_LIM)/2;

NUM_SESSION = length(moves);
MIN_NUM_SESSION = 3;

info = index_timing_errors_SAT(info, moves);

%% Get binned percent correct
vig_corr_A = NaN(NUM_SESSION,NUM_BIN);
vig_err_A = NaN(NUM_SESSION,NUM_BIN);
vig_corr_F = NaN(NUM_SESSION,NUM_BIN);
vig_err_F = NaN(NUM_SESSION,NUM_BIN);

for kk = 1:NUM_SESSION
  
  resptime = double(moves(kk).resptime);
  
  idx_errdir = info(kk).err_dir & ~info(kk).err_time;
  idx_corr = ~(info(kk).err_dir | info(kk).err_hold | info(kk).err_nosacc | info(kk).err_time);
  
  idx_acc = (info(kk).condition == 1);
  idx_fast = (info(kk).condition == 3);
  
  for jj = 1:NUM_BIN
    
    %get trials with appropriate RT
    idx_jj = (resptime > BIN_LIM(jj)) & (resptime < BIN_LIM(jj+1));
    
    if (sum(idx_jj & idx_corr & idx_acc) >= MIN_PER_BIN)
      vig_corr_A(kk,jj) = nanmean(moves(kk).vigor(idx_jj & idx_corr & idx_acc));
    end
    
    if (sum(idx_jj & idx_corr & idx_fast) >= MIN_PER_BIN)
      vig_corr_F(kk,jj) = nanmean(moves(kk).vigor(idx_jj & idx_corr & idx_fast));
    end
    
    if (sum(idx_jj & idx_errdir & idx_acc) >= MIN_PER_BIN)
      vig_err_A(kk,jj) = nanmean(moves(kk).vigor(idx_jj & idx_errdir & idx_acc));
    end
    
    if (sum(idx_jj & idx_errdir & idx_fast) >= MIN_PER_BIN)
      vig_err_F(kk,jj) = nanmean(moves(kk).vigor(idx_jj & idx_errdir & idx_fast));
    end
    
  end%for:RT_bins(jj)
  
end%for:session(kk)

%% Plot across all sessions

bin_nan_corr_A = (sum(~isnan(vig_corr_A),1) < MIN_NUM_SESSION);
bin_nan_corr_F = (sum(~isnan(vig_corr_F),1) < MIN_NUM_SESSION);
bin_nan_err_A = (sum(~isnan(vig_err_A),1) < MIN_NUM_SESSION);
bin_nan_err_F = (sum(~isnan(vig_err_F),1) < MIN_NUM_SESSION);

vig_corr_A(:,bin_nan_corr_A) = NaN;
vig_corr_F(:,bin_nan_corr_F) = NaN;
vig_err_A(:,bin_nan_err_A) = NaN;
vig_err_F(:,bin_nan_err_F) = NaN;

NUM_SEM_CORR_A = sum(~isnan(vig_corr_A),1);
NUM_SEM_CORR_F = sum(~isnan(vig_corr_F),1);
NUM_SEM_ERR_A = sum(~isnan(vig_err_A),1);
NUM_SEM_ERR_F = sum(~isnan(vig_err_F),1);

figure(); hold on
shaded_error_bar(RT_PLOT, nanmean(vig_corr_A), nanstd(vig_corr_A)./sqrt(NUM_SEM_CORR_A), {'r-'})
shaded_error_bar(RT_PLOT, nanmean(vig_corr_F), nanstd(vig_corr_F)./sqrt(NUM_SEM_CORR_F), {'-', 'Color',[0 .7 0]})
shaded_error_bar(RT_PLOT, nanmean(vig_err_A), nanstd(vig_err_A)./sqrt(NUM_SEM_CORR_A), {'r--', 'LineWidth',1.5})
shaded_error_bar(RT_PLOT, nanmean(vig_err_F), nanstd(vig_err_F)./sqrt(NUM_SEM_CORR_F), {'--', 'Color',[0 .7 0], 'LineWidth',1.5})
ppretty('image_size',[4.8,3])

% pause(0.25)
% 
% figure(); hold on
% errorbar_no_caps(RT_PLOT, nanmean(vig_corr_A), 'err',nanstd(vig_corr_A)./sqrt(NUM_SEM_CORR_A), 'color','r')
% errorbar_no_caps(RT_PLOT, nanmean(vig_corr_F), 'err',nanstd(vig_corr_F)./sqrt(NUM_SEM_CORR_F), 'color',[0 .7 0])
% errorbar_no_caps(RT_PLOT, nanmean(vig_err_A), 'err',nanstd(vig_err_A)./sqrt(NUM_SEM_ERR_A), 'color','r', 'linewidth',1.5)
% errorbar_no_caps(RT_PLOT, nanmean(vig_err_F), 'err',nanstd(vig_err_F)./sqrt(NUM_SEM_ERR_F), 'color',[0 .7 0], 'linewidth',1.5)
% ppretty('image_size',[4.8,3])

% figure(); hold on
% plot(RT_PLOT, vig_corr_A, 'r.-', 'LineWidth',1.5)
% xlim([200 850])
% ppretty('image_size',[4.8,3])

% figure(); hold on
% plot(RT_PLOT, vig_corr_F, '.-', 'Color',[0 .7 0], 'LineWidth',1.5)
% xlim([200 850])
% ppretty('image_size',[4.8,3])

end%function:plot_vigor_vs_RT()
