function [ scAcc , scFast , varargout ] = computeSpkCt_X_Epoch( unitTest , behavData , varargin )
%computeSpkCt_X_Epoch This function computes spike counts across the four
%main within-trial time windows (baseline, visual response, post-saccade,
%post-reward), separately for Fast and Accurate conditions.
%   Detailed explanation goes here

nDir = 8;
nEpoch = 4;
nTrial = behavData.NumTrials; %number of trials

%% Compute spike counts by epoch
sc_uu = computeSpikeCount_SAT(unitTest, behavData);

%% Index by isolation quality
if (nargin > 2) %if desired, specify trials with poor isolation
  idxIso = varargin{1};
else
  idxIso = removeTrials_Isolation(unitTest.TrialRemoveSAT{1}, nTrial);
end

%% Index spike counts by trial condition and outcome
%index by condition
idxAcc = ((behavData.Condition{1} == 1) & ~idxIso);
idxFast = ((behavData.Condition{1} == 3) & ~idxIso);
%index by trial outcome
idxCorr = behavData.Correct{1};

%% Sort spike counts by condition and direction
scAcc = NaN(nDir+1,nEpoch); %mean spike counts
scFast = scAcc;
stsc.Acc = cell(nDir,1); %single-trial spike counts
stsc.Fast = stsc.Acc;
for dd = 1:nDir
  idxDir = (behavData.Sacc_Octant{1} == dd);
  stsc.Acc{dd} = sc_uu(idxAcc & idxCorr & idxDir,:); %single-trial counts
  stsc.Fast{dd} = sc_uu(idxFast & idxCorr & idxDir,:);
  scAcc(dd,:)  = mean(sc_uu(idxAcc & idxCorr & idxDir,:)); %mean counts
  scFast(dd,:) = mean(sc_uu(idxFast & idxCorr & idxDir,:));
end % for : direction (dd)
scAcc(nDir+1,:)  = scAcc(1,:); %close the circle for plotting
scFast(nDir+1,:) = scFast(1,:);

if (nargout > 2) %if desired, return single-trial counts
  varargout{1} = stsc;
end

end % fxn : computeSpkCt_X_Epoch()
