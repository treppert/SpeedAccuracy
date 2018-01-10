function [ varargout ] = barplot_avg_peakvel_SAT( moves_cell , info_cell )
%barplot_avg_peakvel_SAT Summary of this function goes here
%   Detailed explanation goes here

DISP_LIM = [4.75,6.5];

NUM_MONKEY = length(moves_cell);

peakvel_early = NaN(2,NUM_MONKEY); %mean;SEM
peakvel_late = NaN(2,NUM_MONKEY);

stats_ttest = new_struct({'p','h','stat'}, 'dim',[1,NUM_MONKEY]); %stats from paired t-test

for jj = 1:NUM_MONKEY
  
  moves = moves_cell{jj};
  info = info_cell{jj};
  
  NUM_SESSION = length(moves);
  
  pv_jj_early = NaN(1,NUM_SESSION);
  pv_jj_late = NaN(1,NUM_SESSION);
  
  for kk = 1:NUM_SESSION
    
    idx_fast = (info(kk).condition == 3);
    
    lim_RT_fast = quantile(moves(kk).resptime(idx_fast), [.25 .75]);
    
    %index by saccade RT
    idx_early = (idx_fast & (moves(kk).resptime < lim_RT_fast(1)));
    idx_late = (idx_fast & (moves(kk).resptime > lim_RT_fast(2)));
    
    %index by displacement
    idx_disp = ( (moves(kk).displacement > DISP_LIM(1)) & (moves(kk).displacement < DISP_LIM(2)) );
    
    pv_jj_early(kk) = nanmean(moves(kk).peakvel(idx_early & idx_disp), 2);
    pv_jj_late(kk)  = nanmean(moves(kk).peakvel(idx_late & idx_disp), 2);
    
  end%for:sessions(kk)
  
  peakvel_early(1,jj) = nanmean(pv_jj_early);
  peakvel_early(2,jj) = nanstd(pv_jj_early)/sqrt(NUM_SESSION);
  
  peakvel_late(1,jj) = nanmean(pv_jj_late);
  peakvel_late(2,jj) = nanstd(pv_jj_late)/sqrt(NUM_SESSION);
  
  [stats_ttest(jj).h, stats_ttest(jj).p, ~, stats_ttest(jj).stat] = ttest(pv_jj_early, pv_jj_late);
  
end%for:monkeys(jj)

if (nargout > 0)
  varargout{1} = stats_ttest;
end

%% Plotting

figure(); hold on

bar([1,3,5,7], peakvel_early(1,:), 'FaceColor',[0 .3 0], 'BarWidth',0.4)
errorbar_no_caps([1,3,5,7], peakvel_early(1,:), 'err',peakvel_early(2,:), 'linestyle','none')

bar([2,4,6,8], peakvel_late(1,:), 'FaceColor',[0 .7 0], 'BarWidth',0.4)
errorbar_no_caps([2,4,6,8], peakvel_late(1,:), 'err',peakvel_late(2,:), 'linestyle','none')

xlim([0 9]); xticks([])
ylim([300 500]); yticks(300:40:500)
ppretty('image_size',[2.5,3])


end%utility:barplot_avg_peakvel_SAT()

