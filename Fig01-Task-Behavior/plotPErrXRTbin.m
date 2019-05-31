function [ ] = plotPErrXRTbin( binfo , moves )
%[  ] = plotPErrXRTbin(  )
%   Detailed explanation goes here

NUM_SESSION = length(moves);
MIN_NUM_SESSION = 3;
MIN_PER_BIN = 10; %number of movements per RT bin

%set up the RT bins to average data
BIN_LIM = 150 : 100 : 850;
NUM_BIN = length(BIN_LIM) - 1;
RT_PLOT  = BIN_LIM(1:NUM_BIN) + diff(BIN_LIM)/2;

%initializations
PerrAcc = NaN(NUM_SESSION,NUM_BIN);
PerrFast = NaN(NUM_SESSION,NUM_BIN);
dlineAcc = NaN(1,NUM_SESSION);
dlineFast = NaN(1,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  RTkk = double(moves(kk).resptime);
  
  %index by trial outcome
  idxErr = (binfo(kk).err_dir);
  %index by condition
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  
  %get mean response deadline per condition
  dlineAcc(kk) = nanmean(binfo(kk).deadline(idxAcc));
  dlineFast(kk) = nanmean(binfo(kk).deadline(idxFast));
  
  for jj = 1:NUM_BIN %loop over RT bins
    
    %get trials with appropriate RT
    idxJJ = (RTkk > BIN_LIM(jj)) & (RTkk < BIN_LIM(jj+1));
    
    %calculate percent correct for this RT bin
    if (sum(idxJJ & idxFast) >= MIN_PER_BIN)
      PerrFast(kk,jj) = sum((idxJJ & idxFast & idxErr) / sum(idxJJ & idxFast));
    end
    
    if (sum(idxJJ & idxAcc) >= MIN_PER_BIN)
      PerrAcc(kk,jj) = sum((idxJJ & idxAcc & idxErr) / sum(idxJJ & idxAcc));
    end
    
  end%for:RT_bins(jj)
  
end%for:session(kk)

%% Plot across all sessions

%remove data points with less than the required number of sessions
bin_nan_acc = (sum(~isnan(PerrAcc),1) < MIN_NUM_SESSION);
bin_nan_fast = (sum(~isnan(PerrFast),1) < MIN_NUM_SESSION);
PerrAcc(:,bin_nan_acc) = NaN;
PerrFast(:,bin_nan_fast) = NaN;

NUM_SEM_ACC = sum(~isnan(PerrAcc),1);
NUM_SEM_FAST = sum(~isnan(PerrFast),1);

%prepare to plot response deadlines
SEdlineAcc = std(dlineAcc)/sqrt(NUM_SESSION);
SEdlineFast = std(dlineFast)/sqrt(NUM_SESSION);
xDlineAcc = [mean(dlineAcc)-SEdlineAcc , mean(dlineAcc)+SEdlineAcc];
xDlineFast = [mean(dlineFast)-SEdlineFast , mean(dlineFast)+SEdlineFast];

figure(); hold on
% plot(RT_PLOT, PerrFast, 'color',[0 .7 0])
errorbar_no_caps(RT_PLOT, nanmean(PerrAcc), 'err',nanstd(PerrAcc)./sqrt(NUM_SEM_ACC), 'color','r')
errorbar_no_caps(RT_PLOT, nanmean(PerrFast), 'err',nanstd(PerrFast)./sqrt(NUM_SEM_FAST), 'color',[0 .7 0])
plot(xDlineFast(1)*ones(1,2), [.1 .5], ':', 'Color',[0 .7 0])
plot(xDlineFast(2)*ones(1,2), [.1 .5], ':', 'Color',[0 .7 0])
plot(xDlineAcc(1)*ones(1,2), [.1 .5], 'r:')
plot(xDlineAcc(2)*ones(1,2), [.1 .5], 'r:')
ppretty([6.4,4])


end%function:plotPErrXRTbin()
