function [ varargout ] = plotChcErrRate_X_RTbin( binfo , moves , varargin )
%plotChcErrRate_X_RTbin Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

[binfo, moves] = utilIsolateMonkeyBehavior(binfo, moves, cell(1,length(binfo)), args.monkey);
NUM_SESSION = length(binfo);

% BINLIM_RT_ACC = [(-250 : 50 : 0), (30 : 30 : 300)];
BINLIM_RT_ACC = (0 : 30 : 300);
RT_PLOT_ACC = BINLIM_RT_ACC(1:end-1) + diff(BINLIM_RT_ACC)/2;     NUM_BIN_ACC = length(RT_PLOT_ACC);
% BINLIM_RT_FAST = [(-200 : 20 : 0), (50 : 50 : 450)];
BINLIM_RT_FAST = (-200 : 20 : 0);
RT_PLOT_FAST = BINLIM_RT_FAST(1:end-1) + diff(BINLIM_RT_FAST)/2;  NUM_BIN_FAST = length(RT_PLOT_FAST);

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
plot([0 0], [.1 .3], 'k:')
errorbar(RT_PLOT_ACC, mu_ERAcc, SE_ERAcc, 'r-', 'CapSize',0, 'LineWidth',0.75)
errorbar(RT_PLOT_FAST, mu_ERFast, SE_ERFast, '-', 'Color',[0 .7 0], 'CapSize',0, 'LineWidth',0.75)
xlabel('Response time from deadline (ms)')
ylabel('Choice error rate'); %ytickformat('%3.2f')
ppretty([4.8,3])

%% Stats
%prepare session averages for Pearson correlation analysis
errRateFC = reshape(chcErrRateFast', 10*NUM_SESSION,1);
errRateAC = reshape(chcErrRateAcc', 10*NUM_SESSION,1);
RTFC = repmat(RT_PLOT_FAST, 1,NUM_SESSION)';
RTAC = repmat(RT_PLOT_ACC, 1,NUM_SESSION)';
% errRateFE = reshape(chcErrRateFast(:,11:19), 9*NUM_SESSION,1);
% errRateAE = reshape(chcErrRateAcc(:,1:5), 5*NUM_SESSION,1);
% RTFE = repmat(RT_PLOT_FAST(11:19), 1,14)';
% RTAE = repmat(RT_PLOT_ACC(1:5), 1,14)';

%remove all NaNs
inan = isnan(errRateFC);  RTFC(inan) = [];  errRateFC(inan) = [];
inan = isnan(errRateAC);  RTAC(inan) = [];  errRateAC(inan) = [];
% inan = isnan(errRateFE);  RTFE(inan) = [];  errRateFE(inan) = [];
% inan = isnan(errRateAE);  RTAE(inan) = [];  errRateAE(inan) = [];

[pvalFC,rhoFC] = corr(RTFC, errRateFC, 'Type','Pearson');
[pvalAC,rhoAC] = corr(RTAC, errRateAC, 'Type','Pearson');
% [pvalFE,rhoFE] = corr(RTFE, errRateFE, 'Type','Pearson');
% [pvalAE,rhoAE] = corr(RTAE, errRateAE, 'Type','Pearson');

stats = struct('Fast',[pvalFC, rhoFC], 'Acc',[pvalAC, rhoAC]);
% stats = struct('FastTCorr',[pvalFC, rhoFC], 'FastTErr',[pvalFE, rhoFE], ...
%   'AccTCorr',[pvalAC, rhoAC], 'AccTErr',[pvalAE, rhoAE]);
if (nargout > 0)
  varargout{1} = stats;
end

%fit line to the data
fitFast = fit(RTFC, errRateFC, 'poly1');
fitAcc = fit(RTAC, errRateAC, 'poly1');
plot([-180,-20], fitFast([-180,-20]), '-', 'Color',[.4 .7 .4])
plot([25,275], fitAcc([75,275]), '-', 'Color',[1 .5 .5])

end%fxn:plotChcErrRate_X_RTbin()

