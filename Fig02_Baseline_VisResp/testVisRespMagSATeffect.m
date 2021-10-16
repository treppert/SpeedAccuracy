function [ unitData ] = testVisRespMagSATeffect( behavData , moves , unitData , unitData , spikes , varargin )
%testVisRespMagSATeffect Summary of this function goes here
%   Test for a significant difference in VR magnitude (relative to
%   baseline) across conditions Fast and Accurate.
% 

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember(unitData.aArea, args.area);
idxMonkey = ismember(unitData.aMonkey, args.monkey);

idxVis = ([unitData.Basic_VisGrade] >= 2);
idxKeep = (idxArea & idxMonkey & idxVis);

unitData = unitData(idxKeep);
spikes = spikes(idxKeep);

NUM_CELLS = length(spikes);
T_BASE = [-90, 9] + 3500; %baseline interval spike ct to be subtracted
T_TEST = 100; %duration over which to test (time-locked to VR onset)

%pull visual response latencies
VRlatAcc = [unitData.VRlatAcc];
VRlatFast = [unitData.VRlatFast];

%initializations
relSpkCtAcc = cell(1,NUM_CELLS); %relative to baseline
relSpkCtFast = cell(1,NUM_CELLS);

for uu = 1:NUM_CELLS
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  uuNS = unitData.aIndex(uu); %index unitData correctly
  
  %determine testing intervals (time-locked to VR onset)
  tTestAcc = VRlatAcc(uuNS) + [0, T_TEST-1] + 3500;
  tTestFast = VRlatFast(uuNS) + [0, T_TEST-1] + 3500;

  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData(uu,:), behavData.Task_NumTrials{kk});
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrNoSacc{kk});
  %index by response dir re. response field
%   idxRF = ismember(moves(kk).octant, unitData.Basic_VisField{uu});
  %index by condition
  trialAcc = find((behavData.Task_SATCondition{kk} == 1) & ~idxIso & idxCorr);
  trialFast = find((behavData.Task_SATCondition{kk} == 3) & ~idxIso & idxCorr);
  
  numTrialAcc = length(trialAcc);
  numTrialFast = length(trialFast);
  
  relSpkCtAcc{uu} = NaN(1,numTrialAcc);
  for jj = 1:numTrialAcc
    %retrieve spikes for Accurate condition
    spkTime_jj = spikes(uu).SAT{trialAcc(jj)};
    %compute baseline spike count for comparison
    spkCtAccBasejj = sum((spkTime_jj > T_BASE(1)) & (spkTime_jj < T_BASE(2)));
    %compute raw visual response spike count
    spkCtAccVRjj = sum((spkTime_jj > tTestAcc(1)) & (spkTime_jj < tTestAcc(2)));
    %compute relative VR spike count (VR - baseline)
    relSpkCtAcc{uu}(jj) = spkCtAccVRjj - spkCtAccBasejj;
  end%for:trial(jj)
  
  relSpkCtFast{uu} = NaN(1,numTrialFast);
  for jj = 1:numTrialFast
    spkTime_jj = spikes(uu).SAT{trialFast(jj)};
    spkCtFastBasejj = sum((spkTime_jj > T_BASE(1)) & (spkTime_jj < T_BASE(2)));
    spkCtFastVRjj = sum((spkTime_jj > tTestFast(1)) & (spkTime_jj < tTestFast(2)));
    relSpkCtFast{uu}(jj) = spkCtFastVRjj - spkCtFastBasejj;
  end%for:trial(jj)
  
  %test for a difference in VR spike counts (Fast vs. Acc)
  [hVal,~,~,tmp] = ttest2(relSpkCtFast{uu}, relSpkCtAcc{uu}, 'Alpha',0.05, 'Tail','both');
  if (hVal)
    if (tmp.tstat < 0) %Acc > Fast
      unitData(uuNS).VReffect = -1;
    else %Fast > Acc
      unitData(uuNS).VReffect = 1;
    end
  else%no SAT effect on VR
    unitData(uuNS).VReffect = 0;
  end
  
end%for:cells(uu)

end%util:testVisRespMagSATeffect()
