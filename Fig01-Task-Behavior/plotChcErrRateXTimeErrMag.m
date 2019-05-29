function [ ] = plotChcErrRateXTimeErrMag( binfo , moves , varargin )
%plotChcErrRateXTimeErrMag Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

[binfo, moves] = utilIsolateMonkeyBehavior(binfo, moves, cell(1,length(binfo)), args.monkey);
NUM_SESSION = length(binfo);

BINLIM_TERR_ACC = (0 : 25 : 250);   TERR_PLOT_ACC = BINLIM_TERR_ACC(1:end-1) + diff(BINLIM_TERR_ACC)/2;
BINLIM_TERR_FAST = (0 : 50 : 500);  TERR_PLOT_FAST = BINLIM_TERR_FAST(1:end-1) + diff(BINLIM_TERR_FAST)/2;
NUM_BIN_ACC = length(TERR_PLOT_ACC);
NUM_BIN_FAST = length(TERR_PLOT_FAST);

MIN_TRIALS_PER_BIN = 5; %min number of trials per bin
MIN_SESSIONS_PER_BIN = 3; %min number of sessions over which we average

chcErrRateAcc = NaN(NUM_SESSION,NUM_BIN_ACC);
chcErrRateFast = NaN(NUM_SESSION,NUM_BIN_FAST);

for kk = 1:NUM_SESSION
  
  rtKK = double(moves(kk).resptime);
  TErrKK = abs(rtKK - double(binfo(kk).deadline));
  
  %index by condition
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  %index by trial outcome
  idxErrChc = binfo(kk).err_dir;
  idxErrTime = binfo(kk).err_time;
  
  for ii = 1:NUM_BIN_ACC %loop over Time Err bins -- Accurate
    idxII = ((TErrKK > BINLIM_TERR_ACC(ii)) & (TErrKK <= BINLIM_TERR_ACC(ii+1)));
    
    if (sum(idxAcc & idxErrTime & idxII) >= MIN_TRIALS_PER_BIN) %make sure we have enough trials
      chcErrRateAcc(kk,ii) = sum(idxAcc & idxErrTime & idxII & idxErrChc) / sum(idxAcc & idxErrTime & idxII);
    end
  end%for:bin-TErr-Acc
  
  for ii = 1:NUM_BIN_FAST %loop over Time Err bins -- Accurate
    idxII = ((TErrKK > BINLIM_TERR_FAST(ii)) & (TErrKK <= BINLIM_TERR_FAST(ii+1)));
    
    if (sum(idxFast & idxErrTime & idxII) >= MIN_TRIALS_PER_BIN) %make sure we have enough trials
      chcErrRateFast(kk,ii) = sum(idxFast & idxErrTime & idxII & idxErrChc) / sum(idxFast & idxErrTime & idxII);
    end
  end%for:bin-TErr-Fast
  
end%for:session(kk)


%% Plotting
NUM_SE_ACC = sum(~isnan(chcErrRateAcc),1);
NUM_SE_FAST = sum(~isnan(chcErrRateFast),1);

mu_ERAcc = nanmean(chcErrRateAcc);   SE_ERAcc = nanstd(chcErrRateAcc) ./ sqrt(NUM_SE_ACC);
mu_ERFast = nanmean(chcErrRateFast);   SE_ERFast = nanstd(chcErrRateFast) ./ sqrt(NUM_SE_FAST);

figure(); hold on
errorbar(TERR_PLOT_ACC, mu_ERAcc, SE_ERAcc, 'r-', 'CapSize',0, 'LineWidth',0.75)
errorbar(TERR_PLOT_FAST, mu_ERFast, SE_ERFast, '-', 'Color',[0 .7 0], 'CapSize',0, 'LineWidth',0.75)
xlabel('Timing error magnitude (ms)')
ylabel('Choice error rate')
ppretty([4,6])

end%fxn:plotChcErrRateXTimeErrMag()

