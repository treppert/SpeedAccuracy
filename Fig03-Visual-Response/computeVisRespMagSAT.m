function [ VRmagAcc , VRmagFast ] = computeVisRespMagSAT( sdfVRAcc, sdfVRFast, latAcc, latFast, nstats )
%computeVisRespMagSAT Summary of this function goes here
%   sdfVRAcc - Single-trial visual response SDFs in the Accurate condition
%   sdfVRFast - Single-trial visual response SDFs in the Fast condition

T_AVERAGE = 100; %amount of time (ms) used to estimate magnitude

%compute the mean spike density function for each condition
sdfVRAcc = mean(sdfVRAcc);
sdfVRFast = mean(sdfVRFast);

%load mean baseline activity
blineAcc = nstats.blineAccMEAN;
blineFast = nstats.blineFastMEAN;

%subtract off baseline activity
sdfVRAcc = sdfVRAcc - blineAcc;
sdfVRFast = sdfVRFast - blineFast;

%compute average of the SDF during T_AVERAGE post-response onset
VRmagAcc = mean(sdfVRAcc(latAcc:latAcc+T_AVERAGE-1));
VRmagFast = mean(sdfVRFast(latFast:latFast+T_AVERAGE-1));

end%computeVisRespMagSAT()

