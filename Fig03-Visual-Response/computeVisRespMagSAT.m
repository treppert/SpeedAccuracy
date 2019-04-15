function [ VRmagAcc , VRmagFast ] = computeVisRespMagSAT( sdfVRAcc, sdfVRFast, nstats , offset )
%computeVisRespMagSAT Summary of this function goes here
%   sdfVRAcc - Single-trial visual response SDFs in the Accurate condition
%   sdfVRFast - Single-trial visual response SDFs in the Fast condition

T_AVERAGE = 100; %amount of time (ms) used to estimate magnitude

%use trials for both Target In and Distractor In to compute latency
sdfVRAcc = [sdfVRAcc.Tin ; sdfVRAcc.Din];
sdfVRFast = [sdfVRFast.Tin ; sdfVRFast.Din];

%compute the mean spike density function for each condition
sdfVRAcc = mean(sdfVRAcc(:,offset+1:end));
sdfVRFast = mean(sdfVRFast(:,offset+1:end));

%load mean baseline activity
blineAcc = nstats.blineAccMEAN;
blineFast = nstats.blineFastMEAN;

%load VR latency
latAcc = nstats.VRlatAcc;
latFast = nstats.VRlatFast;

%subtract off baseline activity
sdfVRAcc = sdfVRAcc - blineAcc;
sdfVRFast = sdfVRFast - blineFast;

%compute average of the SDF during T_AVERAGE post-response onset
VRmagAcc = mean(sdfVRAcc(latAcc:latAcc+T_AVERAGE-1));
VRmagFast = mean(sdfVRFast(latFast:latFast+T_AVERAGE-1));

end%computeVisRespMagSAT()

