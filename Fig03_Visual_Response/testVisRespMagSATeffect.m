function [ varargout ] = testVisRespMagSATeffect( bInfo , uInfo , uStats , spikes , varargin )
%testVisRespMagSATeffect Summary of this function goes here
%   Test for a significant difference in VR magnitude (relative to
%   baseline) across conditions Fast and Accurate.
% 

args = getopt(varargin, {{'area=','SC'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember(uInfo.area, args.area);
idxMonkey = ismember(uInfo.monkey, args.monkey);
idxVis = (uInfo.visGrade >= 2);
idxKeep = (idxArea & idxMonkey & idxVis);

uInfo = uInfo(idxKeep,:);
spikes = spikes(idxKeep);

NUM_CELLS = length(spikes);
T_BASE = [-90, 9] + 3500; %baseline interval spike ct to be subtracted
T_TEST = 100; %duration over which to test (time-locked to VR onset)

%pull visual response latencies
VR_Latency = uStats.VisualResponse_Latency;

%initializations
relSpkCtAcc = cell(1,NUM_CELLS); %relative to baseline
relSpkCtFast = cell(1,NUM_CELLS);

for cc = 1:NUM_CELLS
  kk = ismember(bInfo.session, uInfo.sess{cc});
  ccNS = uInfo.unitNum(cc); %index nstats correctly
  
  %determine testing intervals (time-locked to VR onset)
  tTest = VR_Latency(ccNS) + [0, T_TEST-1] + 3500;

  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(uInfo.trRemSAT{cc}, bInfo.num_trials(kk));
  %index by trial outcome
  idxCorr = ~(bInfo.err_dir{kk} | bInfo.err_time{kk} | bInfo.err_hold{kk} | bInfo.err_nosacc{kk});
  %index by response dir re. response field
%   idxRF = ismember(moves(kk).octant, ninfo(cc).visField);
  %index by condition
  trialAcc = find((bInfo.condition{kk} == 1) & ~idxIso & idxCorr);
  trialFast = find((bInfo.condition{kk} == 3) & ~idxIso & idxCorr);
  
  numTrialAcc = length(trialAcc);
  numTrialFast = length(trialFast);
  
  relSpkCtAcc{cc} = NaN(1,numTrialAcc);
  for jj = 1:numTrialAcc
    %retrieve spikes for Accurate condition
    spkTime_jj = spikes{cc}{trialAcc(jj)};
    %compute baseline spike count for comparison
    spkCtAccBasejj = sum((spkTime_jj > T_BASE(1)) & (spkTime_jj < T_BASE(2)));
    %compute raw visual response spike count
    spkCtAccVRjj = sum((spkTime_jj > tTest(1)) & (spkTime_jj < tTest(2)));
    %compute relative VR spike count (VR - baseline)
    relSpkCtAcc{cc}(jj) = spkCtAccVRjj - spkCtAccBasejj;
  end%for:trial(jj)
  
  relSpkCtFast{cc} = NaN(1,numTrialFast);
  for jj = 1:numTrialFast
    spkTime_jj = spikes{cc}{trialFast(jj)};
    spkCtFastBasejj = sum((spkTime_jj > T_BASE(1)) & (spkTime_jj < T_BASE(2)));
    spkCtFastVRjj = sum((spkTime_jj > tTest(1)) & (spkTime_jj < tTest(2)));
    relSpkCtFast{cc}(jj) = spkCtFastVRjj - spkCtFastBasejj;
  end%for:trial(jj)
  
  %test for a difference in VR spike counts (Fast vs. Acc)
  [hVal,~,~,tmp] = ttest2(relSpkCtFast{cc}, relSpkCtAcc{cc}, 'Alpha',0.05, 'Tail','both');
  if (hVal)
    if (tmp.tstat < 0) %Acc > Fast
      uStats.VisualResponse_SAT_Effect(ccNS) = -1;
    else %Fast > Acc
      uStats.VisualResponse_SAT_Effect(ccNS) = 1;
    end
  else%no SAT effect on VR
    uStats.VisualResponse_SAT_Effect(ccNS) = 0;
  end
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = uStats;
end

end%util:testVisRespMagSATeffect()
