function [ ] = plot_ISI_X_RT( behavData , moves , movesPP , varargin )
%plot_ISI_X_RT Summary of this function goes here
%   Detailed explanation goes here
args = getopt(varargin, {{'monkey=',{'D','E'}}});

[behavData, moves, movesPP] = utilIsolateMonkeyBehavior(behavData, moves, movesPP, args.monkey);
NUM_SESS = length(behavData);


MIN_NUM_TRIAL = 5; %minimum number of saccades per RT bin

RT_ACC = (0 : 50 : 300);   NBIN_ACC = length(RT_ACC) - 1;
RT_FAST = (-200 : 25 : 0); NBIN_FAST = length(RT_FAST) - 1;

isiAcc = NaN(NUM_SESS,NBIN_ACC);
isiFast = NaN(NUM_SESS,NBIN_FAST);

for kk = 1:NUM_SESS
  
  %index by condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  %index by trial outcome
  idxErr = (behavData.Task_ErrChoice{kk});
  %skip trials with no recorded post-primary saccade
  idxNoPP = (movesPP(kk).resptime == 0);
  
  RTkk = double(moves(kk).resptime) - double(behavData.Task_Deadline{kk}); %RT FROM DEADLINE
  ISIkk = double(movesPP(kk).resptime) - (double(moves(kk).resptime) + double(moves(kk).duration));
  
  for ii = 1:NBIN_ACC %loop over RT bins (Acc)
    idxII = ((RTkk > RT_ACC(ii)) & (RTkk <= RT_ACC(ii+1)));
    if (sum(idxAcc & idxErr & ~idxNoPP & idxII) >= MIN_NUM_TRIAL)
      isiAcc(kk,ii) = nanmedian(ISIkk(idxAcc & idxErr & ~idxNoPP & idxII));
    end
  end%for:RT-bin-Acc
  
  for ii = 1:NBIN_FAST %loop over RT bins (Fast)
    idxII = ((RTkk > RT_FAST(ii)) & (RTkk <= RT_FAST(ii+1)));
    if (sum(idxFast & idxErr & ~idxNoPP & idxII) >= MIN_NUM_TRIAL)
      isiFast(kk,ii) = nanmedian(ISIkk(idxFast & idxErr & ~idxNoPP & idxII));
    end
  end%for:RT-bin-Fast
  
end%for:session(kk)

%% Plotting
MIN_NUM_SESS = 3; %min number of sessions to plot a data point

RTPLOT_FAST = RT_FAST(1:end-1) + diff(RT_FAST)/2;
RTPLOT_ACC = RT_ACC(1:end-1) + diff(RT_ACC)/2;

%remove data points with < MIN_NUM_SESS sessions
isiAcc(:,(sum(~isnan(isiAcc), 1) < MIN_NUM_SESS)) = NaN;
isiFast(:,(sum(~isnan(isiFast), 1) < MIN_NUM_SESS)) = NaN;

NSEM_ACC = sum(~isnan(isiAcc), 1);
NSEM_FAST = sum(~isnan(isiFast), 1);

figure(); hold on
plot([0 0], [250 300], 'k:', 'LineWidth',0.75)
errorbar(RTPLOT_FAST, nanmean(isiFast), nanstd(isiFast)./sqrt(NSEM_FAST), 'Color',[0 .7 0], 'CapSize',0)
errorbar(RTPLOT_ACC, nanmean(isiAcc), nanstd(isiAcc)./sqrt(NSEM_ACC), 'Color','r', 'CapSize',0)
ppretty([4.8,3])

end%fxn:plot_ISI_X_RT()

