function [] = plot_dRT_vs_RT( info , moves )

NUM_SESSION = length(info);

MIN_PER_BIN = 5;

ERR_LIM_ACC = (-250 : 50 : 350);
NUM_BIN_ACC = length(ERR_LIM_ACC) - 1;
RT_PLOT_ACC = ERR_LIM_ACC(1:end-1) + diff(ERR_LIM_ACC)/2;

ERR_LIM_FAST = (-250 : 50 : 150);
NUM_BIN_FAST = length(ERR_LIM_FAST) - 1;
RT_PLOT_FAST = ERR_LIM_FAST(1:end-1) + diff(ERR_LIM_FAST)/2;

dRT_Acc = NaN(NUM_SESSION,NUM_BIN_ACC);
dRT_Fast = NaN(NUM_SESSION,NUM_BIN_FAST);

for kk = 1:NUM_SESSION
  
  RT = moves(kk).resptime;
  dRT = diff(RT); dRT = [dRT, NaN];
  errRT = RT - info(kk).tgt_dline;
  
  idx_acc = (info(kk).condition == 1);
  idx_fast = (info(kk).condition == 3);
  
%   subplot(5,4,2*kk-1)
%   scatter(errRT(idx_acc), dRT(idx_acc), 25, 'r', 'filled', 'MarkerFaceAlpha',0.5)
%   xlim([-250 500]); ylim([-1000 1000])
%   subplot(5,4,2*kk)
%   scatter(errRT(idx_fast), dRT(idx_fast), 25, [0 .7 0], 'filled', 'MarkerFaceAlpha',0.5)
%   xlim([-250 750]); ylim([-1000 1000])
  
  for jj = 1:NUM_BIN_ACC
    idx_jj = ((errRT > ERR_LIM_ACC(jj)) & (errRT < ERR_LIM_ACC(jj+1)));
    if (sum(idx_jj & idx_acc) >= MIN_PER_BIN)
      dRT_Acc(kk,jj) = mean(dRT(idx_jj & idx_acc));
    end
  end%for:errRT-bins-ACC(jj)
  
  for jj = 1:NUM_BIN_FAST
    idx_jj = ((errRT > ERR_LIM_FAST(jj)) & (errRT < ERR_LIM_FAST(jj+1)));
    if (sum(idx_jj & idx_fast) >= MIN_PER_BIN)
      dRT_Fast(kk,jj) = mean(dRT(idx_jj & idx_fast));
    end
  end%for:errRT-bins-ACC(jj)
  
end%for:sessions(kk)

figure(); hold on

plot(RT_PLOT_ACC, dRT_Acc, '-', 'Color',[1 .5 .5], 'LineWidth',1.0)
plot(RT_PLOT_FAST, dRT_Fast, '-', 'Color',[.3 .7 .3], 'LineWidth',1.0)

plot(RT_PLOT_ACC, nanmean(dRT_Acc), 'r-', 'LineWidth',2.0)
plot(RT_PLOT_FAST, nanmean(dRT_Fast), '-', 'Color',[0 .7 0], 'LineWidth',2.0)

ppretty()

end%function:plot_dRT_vs_RT()
