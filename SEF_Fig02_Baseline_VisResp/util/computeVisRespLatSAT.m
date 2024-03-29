function [ VRlatAcc , VRlatFast ] = computeVisRespLatSAT(sdfVRAcc, sdfVRFast, unitData, offset)
%computeVisRespLatSAT Summary of this function goes here
%   Detailed explanation goes here
%   sdfVRAcc - Single-trial visual response SDFs in the Accurate condition
%   sdfVRFast - Single-trial visual response SDFs in the Fast condition
% 

MIN_LATENCY = 20; %minimum acceptable latency from stimulus appearance
MIN_DURATION = 50; %minimum duration (ms) of the response
CUTOFF = [3, 6]; %number of SDs above mean baseline firing rate

%compute threshold/cutoff values based on baseline activity
cutoffAcc = unitData.Baseline_Mean(1) + CUTOFF * unitData.Baseline_SD(1);
cutoffFast = unitData.Baseline_Mean(2) + CUTOFF * unitData.Baseline_SD(2);

%use trials for both Target In and Distractor In to compute latency
sdfVRAcc = [sdfVRAcc.Tin ; sdfVRAcc.Din];
sdfVRFast = [sdfVRFast.Tin ; sdfVRFast.Din];

%compute the mean spike density function for each condition
sdfVRAcc = mean(sdfVRAcc);
sdfVRFast = mean(sdfVRFast);

%only consider time points beyond MIN_LATENCY
sdfVRAcc = sdfVRAcc(offset+MIN_LATENCY+1:end);
sdfVRFast = sdfVRFast(offset+MIN_LATENCY+1:end);

VRlatAcc = computeLatency(sdfVRAcc, cutoffAcc, MIN_DURATION) + MIN_LATENCY;
VRlatFast = computeLatency(sdfVRFast, cutoffFast, MIN_DURATION) + MIN_LATENCY;

if isnan(VRlatAcc)
  fprintf('*** VRlatAcc is NaN, so setting equal to VRlatFast\n')
  VRlatAcc = VRlatFast;
elseif isnan(VRlatFast)
  fprintf('*** VRlatFast is NaN, so setting equal to VRlatAcc\n')
  VRlatFast = VRlatAcc;
end

end%computeVisRespLatSAT()

function [ latVR ] = computeLatency( sdfVR , cutoff , MIN_DURATION )

DEBUG = false;

%find all points above cutoff
tSuper = find(sdfVR > cutoff(2));
dtSuper = diff(tSuper);

nCandidate = length(tSuper) - MIN_DURATION;

if (DEBUG)
  figure(); hold on
  plot(sdfVR)
  plot([0,length(sdfVR)], cutoff(1)*ones(1,2), 'k--')
  plot([0,length(sdfVR)], cutoff(2)*ones(1,2), 'k--')
  pause()
end

latVR = NaN; %initialization

for ii = 1:nCandidate %loop over candidate timepoints
  
  runLengthII = sum(dtSuper(ii:ii+MIN_DURATION-1));
  
  %found a run of MIN_DURATION above top threshold
  if (runLengthII == MIN_DURATION)
    
    %tag the start of the run as the vis resp latency
    latVR = tSuper(ii);
    
    %now walk back to bottom cutoff
    tSub = find(sdfVR < cutoff(1));
    
    %find last index before crossing bottom threshold
    idxVRNew = find(tSub < latVR, 1, 'last');
    
    %only change current estimate if we found the low threshold
    if ~isempty(idxVRNew)
      latVR = tSub(idxVRNew);
    else
      fprintf('Could not find a sample below bottom cutoff\n')
    end
    
    break
    
  end%if:found-run-MIN_DURATION
  
end%for:sample(ii)

end%util:computeLatency()
