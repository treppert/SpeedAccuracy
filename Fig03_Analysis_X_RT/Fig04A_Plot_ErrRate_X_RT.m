function [ ] = Fig04A_Plot_ErrRate_X_RT( behavData , pSacc )
%Fig04A_Plot_ErrRate_X_RT Summary of this function goes here
%   Inputs
%     behavData - behavDataSAT
%     pSacc - primarySaccade

MONKEY = {'D','E'};
MIN_NUM_TRIAL = 5; %min number of trials per bin

%isolate sessions from MONKEY
sessKeep = ismember(behavData.Monkey, MONKEY);
behavData = behavData(sessKeep, :);
pSacc = pSacc(sessKeep, :);
NUM_SESS = sum(sessKeep);

%initialize RT and error rate
RT_ACC = (0 : 30 : 300);   NBIN_ACC = length(RT_ACC) - 1;
RT_FAST = (-200 : 20 : 0); NBIN_FAST = length(RT_FAST) - 1;
chcErrRateAcc = NaN(NUM_SESS,NBIN_ACC);
chcErrRateFast = NaN(NUM_SESS,NBIN_FAST);

for kk = 1:NUM_SESS
  %RT from deadline
  rtKK = double(pSacc.resptime{kk}) - double(behavData.Task_Deadline{kk});
  
  %index by condition
  idxAcc = (behavData.Task_Condition{kk} == 1);
  idxFast = (behavData.Task_Condition{kk} == 3);
  %index by trial outcome
  idxErrChc = behavData.Task_ErrChoice{kk};
  
  for ii = 1:NBIN_ACC %loop over Time Err bins -- Accurate
    idxII = ((rtKK > RT_ACC(ii)) & (rtKK <= RT_ACC(ii+1)));
    
    if (sum(idxAcc & idxII) >= MIN_NUM_TRIAL) %make sure we have enough trials
      chcErrRateAcc(kk,ii) = sum(idxAcc & idxII & idxErrChc) / sum(idxAcc & idxII);
    end
  end%for:bin-RT-Acc
  
  for ii = 1:NBIN_FAST %loop over Time Err bins -- Accurate
    idxII = ((rtKK > RT_FAST(ii)) & (rtKK <= RT_FAST(ii+1)));
    
    if (sum(idxFast & idxII) >= MIN_NUM_TRIAL) %make sure we have enough trials
      chcErrRateFast(kk,ii) = sum(idxFast & idxII & idxErrChc) / sum(idxFast & idxII);
    end
  end%for:bin-RT-Fast
  
end%for:session(kk)


%% Plotting
RT_PLOT_ACC = RT_ACC(1:end-1) + diff(RT_ACC)/2;
RT_PLOT_FAST = RT_FAST(1:end-1) + diff(RT_FAST)/2;

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
errRateFC = reshape(chcErrRateFast', 10*NUM_SESS,1);
errRateAC = reshape(chcErrRateAcc', 10*NUM_SESS,1);
RTFC = repmat(RT_PLOT_FAST, 1,NUM_SESS)';
RTAC = repmat(RT_PLOT_ACC, 1,NUM_SESS)';

%remove all NaNs
inan = isnan(errRateFC);  RTFC(inan) = [];  errRateFC(inan) = [];
inan = isnan(errRateAC);  RTAC(inan) = [];  errRateAC(inan) = [];

[bfFC, rhoFC, pvalFC] = bf.corr(RTFC, errRateFC);
[bfAC, rhoAC, pvalAC] = bf.corr(RTAC, errRateAC);

fprintf('Accurate: R = %g  ||  p = %g || BF = %g\n', rhoAC, pvalAC, bfAC)
fprintf('Fast: R = %g  ||  p = %g || BF = %g\n', rhoFC, pvalFC, bfFC)

%fit line to the data
fitFast = fit(RTFC, errRateFC, 'poly1');
fitAcc = fit(RTAC, errRateAC, 'poly1');
plot([-180,-20], fitFast([-180,-20]), '-', 'Color',[.4 .7 .4])
plot([25,275], fitAcc([75,275]), '-', 'Color',[1 .5 .5])

end%fxn:plot_ErrRate_X_RT()

