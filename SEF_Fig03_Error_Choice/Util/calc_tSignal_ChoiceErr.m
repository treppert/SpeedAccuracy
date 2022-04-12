function [ tStart , vecSig ] = calc_tSignal_ChoiceErr( sdfCorr , sdfErr , varargin )
%calc_tSignal_ChoiceErr Summary of this function goes here
%   Detailed explanation goes here
% 

args = getopt(varargin, {{'pvalMW=',.05}, {'tailMW=','left'}, {'durMW=',250}});

MIN_DURATION = args.durMW; %min duration (ms) of error signal
MAX_SKIP = 20; %max skip (ms) within error signal window
MIN_REL_MAGNITUDE = 0.1; %minimum effect size relative to max firing rate

FILT_HALFWIN = 2; %half-width of averaging window to smooth SDF
FILT_STEPSIZE = 1; %step size between MW tests

%remove trials with NaN samples
inanCorr = isnan(sdfCorr(:,1));   sdfCorr(inanCorr,:) = [];
inanErr  = isnan(sdfErr(:,1));    sdfErr(inanErr,:) = [];

%% Mann-Whitney U-test for significant difference (Error/Correct)
NUM_SAMP = size(sdfCorr,2);
pVal = NaN(NUM_SAMP,1); %p-value
for jj = FILT_HALFWIN+1 : FILT_STEPSIZE : NUM_SAMP-FILT_HALFWIN
  idx_jj = ((jj - FILT_HALFWIN) : (jj + FILT_HALFWIN)); %averaging window
  
  sdfCorr_jj = mean(sdfCorr(:,idx_jj),2); %compute avg values over small window
  sdfErr_jj = mean(sdfErr(:,idx_jj),2);
  
  pVal(jj) = ranksum(sdfCorr_jj, sdfErr_jj, 'tail',args.tailMW); %Mann-Whitney U-test
end % for:sample(jj)

%% Check the effect size relative to max FR
meanSDF_Corr = mean(sdfCorr);
meanSDF_Err  = mean(sdfErr);

relDiff_SDF = abs(meanSDF_Err - meanSDF_Corr) / max(meanSDF_Corr);
jjNoEffectSize = (relDiff_SDF < MIN_REL_MAGNITUDE);

pVal(jjNoEffectSize) = 1.0; %save as not significant

%% Search for MIN_DUR consecutive time points
sampSig = find(pVal < args.pvalMW);
dsampSig = diff(sampSig);
nSig = length(sampSig);

tStart = NaN;
for ii = 1 : nSig-MIN_DURATION %loop over candidate timepoints
  runLengthII = sum(dsampSig(ii:ii+MIN_DURATION-1));
  
  if (runLengthII <= (MIN_DURATION+MAX_SKIP))
    tStart = sampSig(ii); break
  end
end % for : sample(ii)

%% Save output as time points for plotting
% tSig.p10 = find(pVal < .10);
% tSig.p05 = find(pVal < .05);
% tSig.p01 = find(pVal < .01);
vecSig = find(pVal < args.pvalMW);

end%function:calc_tSignal_ChoiceErr()
