function [ ] = plotChcErrRateXRT( binfo , moves , varargin )
%plotChcErrRateXRT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

[binfo, moves] = utilIsolateMonkeyBehavior(binfo, moves, cell(1,length(binfo)), args.monkey);
NUM_SESSION = length(binfo);

BINLIM_RT_ACC = [(-250 : 50 : 0), (30 : 30 : 300)];   RT_PLOT_ACC = BINLIM_RT_ACC(1:end-1) + diff(BINLIM_RT_ACC)/2;
BINLIM_RT_FAST = [(-200 : 20 : 0), (50 : 50 : 450)];  RT_PLOT_FAST = BINLIM_RT_FAST(1:end-1) + diff(BINLIM_RT_FAST)/2;
NUM_BIN_ACC = length(RT_PLOT_ACC);
NUM_BIN_FAST = length(RT_PLOT_FAST);

MIN_TRIALS_PER_BIN = 5; %min number of trials per bin
MIN_SESSIONS_PER_BIN = 3; %min number of sessions over which we average

chcErrRateAcc = NaN(NUM_SESSION,NUM_BIN_ACC);
chcErrRateFast = NaN(NUM_SESSION,NUM_BIN_FAST);

for kk = 1:NUM_SESSION
  %RT from deadline
  rtKK = double(moves(kk).resptime) - double(binfo(kk).deadline);
  
  %index by condition
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  %index by trial outcome
  idxErrChc = binfo(kk).err_dir;
  idxErrTime = binfo(kk).err_time;
  
  for ii = 1:NUM_BIN_ACC %loop over Time Err bins -- Accurate
    idxII = ((rtKK > BINLIM_RT_ACC(ii)) & (rtKK <= BINLIM_RT_ACC(ii+1)));
    
    if (sum(idxAcc & idxII) >= MIN_TRIALS_PER_BIN) %make sure we have enough trials
      chcErrRateAcc(kk,ii) = sum(idxAcc & idxII & idxErrChc) / sum(idxAcc & idxII);
    end
  end%for:bin-RT-Acc
  
  for ii = 1:NUM_BIN_FAST %loop over Time Err bins -- Accurate
    idxII = ((rtKK > BINLIM_RT_FAST(ii)) & (rtKK <= BINLIM_RT_FAST(ii+1)));
    
    if (sum(idxFast & idxII) >= MIN_TRIALS_PER_BIN) %make sure we have enough trials
      chcErrRateFast(kk,ii) = sum(idxFast & idxII & idxErrChc) / sum(idxFast & idxII);
    end
  end%for:bin-RT-Fast
  
end%for:session(kk)


%% Plotting
NUM_SE_ACC = sum(~isnan(chcErrRateAcc),1);
NUM_SE_FAST = sum(~isnan(chcErrRateFast),1);

mu_ERAcc = nanmean(chcErrRateAcc);   SE_ERAcc = nanstd(chcErrRateAcc) ./ sqrt(NUM_SE_ACC);
mu_ERFast = nanmean(chcErrRateFast); SE_ERFast = nanstd(chcErrRateFast) ./ sqrt(NUM_SE_FAST);

figure(); hold on
plot([0 0], [0 .9], 'k:')
errorbar(RT_PLOT_ACC, mu_ERAcc, SE_ERAcc, 'r-', 'CapSize',0, 'LineWidth',0.75)
errorbar(RT_PLOT_FAST, mu_ERFast, SE_ERFast, '-', 'Color',[0 .7 0], 'CapSize',0, 'LineWidth',0.75)
xlabel('Response time from deadline (ms)')
ylabel('Choice error rate'); ytickformat('%2.1f')
ppretty([4,6])

end%fxn:plotChcErrRateXRT()

