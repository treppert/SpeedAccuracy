function [ tLim , vecSig ] = calc_tErrorSignal_SAT( sdfCorr , sdfErr , varargin )
%calc_tErrorSignal_SAT Summary of this function goes here
%   Detailed explanation goes here
% 

args = getopt(varargin, {{'pvalMW=',.05}, {'tailMW=','left'}});

MIN_DURATION = 200; %min duration (ms) of error signal
MAX_SKIP = 20; %max skip (ms) within error signal window
MIN_REL_MAGNITUDE = 0.1; %minimum effect size relative to max firing rate

FILT_HALFWIN = 2; %half-width of averaging window to smooth SDF
FILT_STEPSIZE = 1; %step size between MW tests

%remove trials with NaN samples
inanCorr = isnan(sdfCorr(:,1));   sdfCorr(inanCorr,:) = [];
inanErr  = isnan(sdfErr(:,1));    sdfErr(inanErr,:) = [];

%% Compute start time
%Mann-Whitney U-test for significant difference (Error/Correct)
NUM_SAMP = size(sdfCorr,2);
pVal = NaN(NUM_SAMP,2); %re. start | end
for jj = FILT_HALFWIN+1 : FILT_STEPSIZE : NUM_SAMP-FILT_HALFWIN
  idx_jj = ((jj - FILT_HALFWIN) : (jj + FILT_HALFWIN)); %averaging window
  
  sdfCorr_jj = mean(sdfCorr(:,idx_jj),2); %compute avg values over small window
  sdfErr_jj = mean(sdfErr(:,idx_jj),2);
  
  pVal(jj,1) = ranksum(sdfCorr_jj, sdfErr_jj, 'tail',args.tailMW); %Mann-Whitney U-test
end % for:sample(jj)

%Check the effect size relative to max FR on correct trials
jjNoEffect = checkEffectSize(sdfCorr ,sdfErr ,MIN_REL_MAGNITUDE);
pVal(jjNoEffect,1) = 1.0;

%Search for MIN_DUR consecutive time points
tLim(1) = checkMinDuration(pVal(:,1), args.pvalMW, MIN_DURATION, MAX_SKIP);

%% Compute end time
sdfCorr = fliplr(sdfCorr); %start search from last timepoint
sdfErr = fliplr(sdfErr);

%Mann-Whitney U-test for significant difference (Error/Correct)
for jj = FILT_HALFWIN+1 : FILT_STEPSIZE : NUM_SAMP-FILT_HALFWIN
  idx_jj = ((jj - FILT_HALFWIN) : (jj + FILT_HALFWIN)); %averaging window
  
  sdfCorr_jj = mean(sdfCorr(:,idx_jj),2); %compute avg values over small window
  sdfErr_jj = mean(sdfErr(:,idx_jj),2);
  
  pVal(jj,2) = ranksum(sdfCorr_jj, sdfErr_jj, 'tail',args.tailMW); %Mann-Whitney U-test
end % for:sample(jj)

%Check the effect size relative to max FR on correct trials
jjNoEffect = checkEffectSize(sdfCorr ,sdfErr ,MIN_REL_MAGNITUDE);
pVal(jjNoEffect,2) = 1.0;

%Search for MIN_DUR consecutive time points
tLim(2) = checkMinDuration(pVal(:,2), args.pvalMW, MIN_DURATION, MAX_SKIP);

%% Save output as time points for plotting
vecSig = find(pVal(:,1) < args.pvalMW);

end % function : calc_tErrorSignal_SAT()

function [ jjNoEffect ] = checkEffectSize( sdfCorr , sdfErr , MIN_REL_MAGNITUDE )

meanSDF_Corr = mean(sdfCorr);
meanSDF_Err  = mean(sdfErr);

relDiff_SDF = abs(meanSDF_Err - meanSDF_Corr) / max(meanSDF_Corr);

jjNoEffect = (relDiff_SDF < MIN_REL_MAGNITUDE);

end

function [ tSignal ] = checkMinDuration( pVal , pvalMW , MIN_DURATION , MAX_SKIP )

sampSig = find(pVal < pvalMW);
dsampSig = diff(sampSig);
nSig = length(sampSig);

tSignal = NaN; %set as NaN to start

for ii = 1 : nSig-MIN_DURATION %loop over candidate timepoints
  runLengthII = sum(dsampSig(ii:ii+MIN_DURATION-1));
  
  if (runLengthII <= (MIN_DURATION+MAX_SKIP))
    tSignal = sampSig(ii); break
  end
end % for : sample(ii)

end