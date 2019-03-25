function [ nstats ] = testVisRespMagSATeffect( binfo , moves , ninfo , nstats , spikes , varargin )
%testVisRespMagSATeffect Summary of this function goes here
%   Test for a significant difference in VR magnitude (relative to
%   baseline) across conditions Fast and Accurate.
% 

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxVis = ismember({ninfo.visType}, {'sustained'});

ninfo = ninfo(idxArea & idxMonkey & idxVis);
spikes = spikes(idxArea & idxMonkey & idxVis); NUM_CELLS = length(spikes);

T_BASE = [-90, 9] + 3500; %baseline interval spike ct to be subtracted
DUR_TEST = 100; %duration over which to test (time-locked to VR onset)
% MIN_DIFF_AVG_CT = 0.25; %min diff (Acc vs. Fast) in average spike ct

%pull visual response latencies
VRlatAcc = [nstats.VRlatAcc];
VRlatFast = [nstats.VRlatFast];

%initializations
relSpkCtAcc = cell(1,NUM_CELLS); %relative to baseline
relSpkCtFast = cell(1,NUM_CELLS);
meanCtAcc = NaN(1,NUM_CELLS);
meanCtFast = NaN(1,NUM_CELLS);

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  ccNS = ninfo(cc).unitNum; %index nstats correctly
  
  %determine testing intervals (time-locked to VR)
  tTestAcc = VRlatAcc(ccNS) + [0, DUR_TEST-1] + 3500;
  tTestFast = VRlatFast(ccNS) + [0, DUR_TEST-1] + 3500;

  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc);
  %index by response dir re. response field
  idxRF = ismember(moves(kk).octant, ninfo(cc).visField);
  %index by condition
  trialAcc = find((binfo(kk).condition == 1) & ~idxIso & idxCorr & idxRF);
  trialFast = find((binfo(kk).condition == 3) & ~idxIso & idxCorr & idxRF);
  
  numTrialAcc = length(trialAcc);
  numTrialFast = length(trialFast);
  
  relSpkCtAcc{cc} = NaN(1,numTrialAcc);
  for jj = 1:numTrialAcc
    spkTime_jj = spikes(cc).SAT{trialAcc(jj)};
    spkCtAccBasejj = sum((spkTime_jj > T_BASE(1)) & (spkTime_jj < T_BASE(2))); %baseline spk ct
    spkCtAccVRjj = sum((spkTime_jj > tTestAcc(1)) & (spkTime_jj < tTestAcc(2))); %VR spk ct
    relSpkCtAcc{cc}(jj) = spkCtAccVRjj - spkCtAccBasejj; %difference (relative) spk ct
  end%for:trial(jj)
  meanCtAcc(cc) = mean(relSpkCtAcc{cc});
  
  relSpkCtFast{cc} = NaN(1,numTrialFast);
  for jj = 1:numTrialFast
    spkTime_jj = spikes(cc).SAT{trialFast(jj)};
    spkCtFastBasejj = sum((spkTime_jj > T_BASE(1)) & (spkTime_jj < T_BASE(2)));
    spkCtFastVRjj = sum((spkTime_jj > tTestFast(1)) & (spkTime_jj < tTestFast(2)));
    relSpkCtFast{cc}(jj) = spkCtFastVRjj - spkCtFastBasejj;
  end%for:trial(jj)
  meanCtFast(cc) = mean(relSpkCtFast{cc});
  
  %compute stats for individual cells
  [hVal,~,~,tmp] = ttest2(relSpkCtFast{cc}, relSpkCtAcc{cc}, 'Alpha',0.05, 'Tail','both');
  if (hVal)
    if (tmp.tstat < 0) %Acc > Fast
      nstats(ccNS).VReffect = -1;
    else %Fast > Acc
      nstats(ccNS).VReffect = 1;
    end
  else%no SAT effect on VR
    nstats(ccNS).VReffect = 0;
  end
  
end%for:cells(cc)

end%util:testVisRespMagSATeffect()
