function [ tLim , vecSig ] = calc_tErrorSignal_SAT( sdfCorr , sdfErr , varargin )
%calc_tErrorSignal_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'minDur=',200}, {'pvalMW=',.05}, {'tailMW=','both'}});

%make sure SDF is organized with samples along horizontal dimension and
%trials along vertical dimension
vertSDF = size(sdfCorr,1);
horzSDF = size(sdfCorr,2);
if (horzSDF < vertSDF)
  sdfCorr = transpose(sdfCorr);
  sdfErr  = transpose(sdfErr);
end

MIN_DURATION = args.minDur; %min duration (ms) of error signal
MAX_SKIP = 20; %max skip (ms) within error signal window
MIN_REL_MAGNITUDE = 0.2; %minimum effect size relative to max firing rate

FILT_HALFWIN = 2; %half-width of averaging window to smooth SDF
FILT_STEPSIZE = 1; %step size between MW tests

%remove trials with NaN samples
inanCorr = isnan(sdfCorr(:,1));   sdfCorr(inanCorr,:) = [];
inanErr  = isnan(sdfErr(:,1));    sdfErr(inanErr,:) = [];

%% Compute start time and check effect size
%Mann-Whitney U-test for significant difference (Error/Correct)
NUM_SAMP = size(sdfCorr,2);
pVal = NaN(NUM_SAMP,2); %re. start | end
for ii = FILT_HALFWIN+1 : FILT_STEPSIZE : NUM_SAMP-FILT_HALFWIN
  idx_ii = ((ii - FILT_HALFWIN) : (ii + FILT_HALFWIN)); %averaging window
  
  sdfCorr_ii = mean(sdfCorr(:,idx_ii),2); %compute avg values over small window
  sdfErr_ii = mean(sdfErr(:,idx_ii),2);
  
  pVal(ii,1) = ranksum(sdfCorr_ii, sdfErr_ii, 'tail',args.tailMW); %Mann-Whitney U-test
end % for:sample(jj)

%Check the effect size relative to max FR on correct trials
iiNoEffect = checkEffectSize(sdfCorr ,sdfErr ,MIN_REL_MAGNITUDE);
pVal(iiNoEffect,1) = 1.0;

%Search for MIN_DUR consecutive time points
tLim(1) = checkMinDuration(pVal(:,1), args.pvalMW, MIN_DURATION, MAX_SKIP);

%% Compute end time and check effect size
sdfCorr = fliplr(sdfCorr); %start search from last timepoint
sdfErr = fliplr(sdfErr);

%Mann-Whitney U-test for significant difference (Error/Correct)
for ii = FILT_HALFWIN+1 : FILT_STEPSIZE : NUM_SAMP-FILT_HALFWIN
  idx_ii = ((ii - FILT_HALFWIN) : (ii + FILT_HALFWIN)); %averaging window
  
  sdfCorr_ii = mean(sdfCorr(:,idx_ii),2); %compute avg values over small window
  sdfErr_ii = mean(sdfErr(:,idx_ii),2);
  
  pVal(ii,2) = ranksum(sdfCorr_ii, sdfErr_ii, 'tail',args.tailMW); %Mann-Whitney U-test
end % for:sample(jj)

%Check the effect size relative to max FR on correct trials
iiNoEffect = checkEffectSize(sdfCorr ,sdfErr ,MIN_REL_MAGNITUDE);
pVal(iiNoEffect,2) = 1.0;

%Search for MIN_DUR consecutive time points
tLim(2) = checkMinDuration(pVal(:,2), args.pvalMW, MIN_DURATION, MAX_SKIP);

%% Save output as time points for plotting
vecSig = find(pVal(:,1) < args.pvalMW);

end % function : calc_tErrorSignal_SAT()

function [ iiNoEffect ] = checkEffectSize( sdfCorr , sdfErr , MIN_REL_MAGNITUDE )
%   Note: We use nanmean() to calculate mean SDF because recordings were
%   only made to 2.5 sec after array onset, cutting into the reward window
% 

meanSDF_Corr = nanmean(sdfCorr);
meanSDF_Err  = nanmean(sdfErr);

relDiff_SDF = abs(meanSDF_Err - meanSDF_Corr) / max(meanSDF_Corr);

iiNoEffect = (relDiff_SDF < MIN_REL_MAGNITUDE);

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