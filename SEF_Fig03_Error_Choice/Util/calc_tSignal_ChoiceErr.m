function [ tSig ] = calc_tSignal_ChoiceErr( sdfCorr , sdfErr )
%calc_tSignal_ChoiceErr Summary of this function goes here
%   Detailed explanation goes here
% 

MIN_REL_MAGNITUDE = 0.1; %minimum effect size relative to max firing rate
NUM_SAMP = size(sdfCorr,2);
FILT_HALFWIN = 2; %half-width of averaging window to smooth SDF

%remove trials with NaN samples
inanCorr = isnan(sdfCorr(:,1));   sdfCorr(inanCorr,:) = [];
inanErr  = isnan(sdfErr(:,1));    sdfErr(inanErr,:) = [];

%% Mann-Whitney U-test for significant difference (Error/Correct)
pVal = NaN(NUM_SAMP,1); %p-value

for jj = FILT_HALFWIN+1:NUM_SAMP-FILT_HALFWIN
  idxJJ = ((jj - FILT_HALFWIN) : (jj + FILT_HALFWIN)); %averaging window
  sdfCorrJJ = mean(sdfCorr(:,idxJJ),2); %compute avg values over small window
  sdfErrJJ = mean(sdfErr(:,idxJJ),2);
  
  %Mann-Whitney U-test
  pVal(jj) = ranksum(sdfCorrJJ, sdfErrJJ, 'tail','both');
end%for:sample(jj)

%% Check the effect size relative to max FR
meanSDF_Corr = mean(sdfCorr);
meanSDF_Err  = mean(sdfErr);
maxFR = max([meanSDF_Corr meanSDF_Err],[],'all');

relDiff_SDF = abs(meanSDF_Err - meanSDF_Corr) / maxFR;
jjNoEffectSize = (relDiff_SDF < MIN_REL_MAGNITUDE);

pVal(jjNoEffectSize) = 1.0; %save as not significant

%% Save output as time points for plotting
tSig.p10 = find(pVal < .10);
tSig.p05 = find(pVal < .05);
tSig.p01 = find(pVal < .01);

end%function:calc_tSignal_ChoiceErr()
