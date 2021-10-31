function [ tAcc , tFast ] = computeTimeRPE( sdfAccST , sdfFastST , offset )
%computeTimeRPE Summary of this function goes here
%   Detailed explanation goes here
% 

MIN_LAT = 0; %min acceptable latency (re. RT)

sdfAccCorr = sdfAccST.Corr.Reward(:,offset+MIN_LAT+1:end);
sdfAccErr = sdfAccST.Err.Reward(:,offset+MIN_LAT+1:end);
sdfFastCorr = sdfFastST.Corr.Reward(:,offset+MIN_LAT+1:end);
sdfFastErr = sdfFastST.Err.Reward(:,offset+MIN_LAT+1:end);

dsdfBaseAcc = mean(sdfAccST.Err.Baseline) - mean(sdfAccST.Corr.Baseline);
dsdfBaseFast = mean(sdfFastST.Err.Baseline) - mean(sdfFastST.Corr.Baseline);

[tAccStart,tAccEnd] = computeTErr(sdfAccCorr, sdfAccErr, dsdfBaseAcc);
[tFastStart,tFastEnd] = computeTErr(sdfFastCorr, sdfFastErr, dsdfBaseFast);

%output as structs
tAcc.Start = tAccStart + MIN_LAT;     tAcc.End = tAccEnd + MIN_LAT;
tFast.Start = tFastStart + MIN_LAT;   tFast.End = tFastEnd + MIN_LAT;

end%calcTimeErrSignal()


function [ tStart , tEnd , varargout ] = computeTErr( sdfCorr , sdfErr , dSDFbase )

DEBUG = false;
MIN_NUM_TRIAL = 5; %min # of error trials (otherwise do not test)

%initializations
MIN_DUR = 50; %minimum duration (ms) of target selection
ALLOWANCE = 5; %number of missed timepoints allowed within MIN_DUR 
ALPHA = 0.01; %significance cutoff for Mann-Whitney U-test
FILT_HALFWIN = 2; %half-width of averaging window to smooth SDF

%compute threshold for check on magnitude of error signal
D_MIN = mean(dSDFbase) + 2 * std(dSDFbase);

NUM_SAMP = size(sdfCorr,2);

Nerr = size(sdfErr,1);
if (Nerr < MIN_NUM_TRIAL)
  fprintf('*** Not enough error trials to compute error signal timing\n')
  tStart = NaN; tEnd = NaN; return
end

%% Mann-Whitney U-test for significant difference (Error/Correct)
sampH1MW = false(1,NUM_SAMP);
sampPMW = NaN(1,NUM_SAMP); %p-value associated with each test
for ii = FILT_HALFWIN+1:NUM_SAMP-FILT_HALFWIN
  
  idxII = ((ii - FILT_HALFWIN) : (ii + FILT_HALFWIN)); %small averaging window
  
  sdfCorrII = mean(sdfCorr(:,idxII), 2); %compute avg values over small window
  sdfErrII = mean(sdfErr(:,idxII), 2);
  
  %Mann-Whitney U-test
  [sampPMW(ii),sampH1MW(ii)] = ranksum(sdfCorrII, sdfErrII, 'alpha',ALPHA, 'tail','both');
  
end%for:sample(ii)

%% Baseline-relative test on magnitude of difference (Error-Correct)
dSDF = mean(sdfErr) - mean(sdfCorr);
sampH1mag = (abs(dSDF) >= D_MIN);

%% Search for MIN_DUR consecutive time points that reject the null *AND* satisfy minimum magnitude
sampH1 = find(sampH1MW & sampH1mag);   nCand = length(sampH1) - MIN_DUR;
dsampH1 = diff(sampH1);

tStart = NaN;
for ii = 1:nCand %loop over candidate timepoints
  
  runLengthII = sum(dsampH1(ii:ii+MIN_DUR-1));
  
  if (runLengthII <= (MIN_DUR+ALLOWANCE))
    %found a run of MIN_DURATION at level ALPHA with MAGNITUDE requirement
    tStart = sampH1(ii);
    break
  end
  
end%for:sample(ii)

%now that we have the start, find the finish
if isnan(tStart)
  tEnd = NaN;
else
  idxEnd = find(dsampH1(ii:end) >= 10, 1, 'first');
  if ~isempty(idxEnd)
    tEnd = sampH1(ii+idxEnd-1);
  else
    tEnd = sampH1(end);
  end
end

if (nargout > 1) %output vector of timestamps with sig. diff.
  varargout{1} = sampH1;
end

if (DEBUG)
  figure()
  
  subplot(2,1,1); hold on %check on significance
  plot(mean(sdfCorr), 'k-')
  plot(mean(sdfErr), 'k--')
  yLim = [min(mean(sdfCorr)) max(mean(sdfErr))];
  plot(find(sampH1MW), yLim(1), 'b.', 'MarkerSize',20)
  plot(tStart*ones(1,2), yLim, 'k:', 'LineWidth',1.5)
  plot(tEnd*ones(1,2), yLim, 'k:', 'LineWidth',1.5)
  yyaxis right; plot(-log(sampPMW), 'r-') %plot p-value of Mann-Whitney vs. time
  plot(repmat([0 NUM_SAMP], 3,1)', (ones(2,1)*(-log([.001 .01 .05]))), 'r:') %plot p-value thresholds
  
  subplot(2,1,2); hold on %check on magnitude
  dSDF = mean(sdfErr)-mean(sdfCorr);
  plot([0 NUM_SAMP], D_MIN*ones(1,2), 'k--')
  plot(abs(dSDF), 'k-', 'LineWidth',1.25)
  yLim = [min(abs(dSDF)), max(abs(dSDF))];
  plot(find(sampH1mag), yLim(1), 'c.', 'MarkerSize',20)
  plot(tStart*ones(1,2), yLim, 'k:', 'LineWidth',1.5)
  plot(tEnd*ones(1,2), yLim, 'k:', 'LineWidth',1.5)
  
  ppretty([6.4,6]); pause()
end%if:(DEBUG)

end%util:computeTimeRPE()
