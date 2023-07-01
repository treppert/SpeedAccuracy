function [ scAcc , scFast , varargout ] = computeSpikeCount_SAT( unitTest , behavTest , outcome , varargin )
%computeSpikeCount_SAT This function computes spike counts across the four
%main within-trial time windows (baseline, visual response, post-saccade,
%post-reward), separately for Fast and Accurate conditions.
%   Input
%   outcome - 'Correct' 'ErrChoice' 'ErrTime' 'ErrChoiceOnly' 'ErrTimeOnly'
% 
%   Output
%   scAcc(8x4)  - single neuron spike count (direction X epoch) - Accurate
%   scFast(8x4) - single neuron spike count (direction X epoch) - Fast
%   stsc - *single-trial* spike count (condition X direction X epoch)
% 

nDir = 8;
nEpoch = 4; % Baseline | Visual response | Post-saccade | Post-reward
nTrial = behavTest.NumTrials;

%% Compute spike counts by epoch
sc_uu = computeSpikeCount(unitTest, behavTest);

%% Index by isolation quality
if (nargin > 3) %if desired, specify trials with poor isolation
  idxIso = varargin{1};
else
  idxIso = removeTrials_Isolation(unitTest.isoSAT{1}, nTrial);
end

%% Index spike counts by trial condition and outcome
%index by condition
idxAcc = ((behavTest.Condition{1} == 1) & ~idxIso);
idxFast = ((behavTest.Condition{1} == 3) & ~idxIso);
%index by trial outcome
idxOutcome = behavTest.(outcome){1};

%% Sort spike counts by condition and direction
scAcc = NaN(nDir+1,nEpoch); %mean spike counts
scFast = scAcc;
stsc.Acc = cell(nDir,1); %single-trial spike counts
stsc.Fast = stsc.Acc;
for dd = 1:nDir
  idxDir = (behavTest.Sacc_Octant{1} == dd);
  stsc.Acc{dd} = sc_uu(idxAcc & idxOutcome & idxDir,:); %single-trial counts
  stsc.Fast{dd} = sc_uu(idxFast & idxOutcome & idxDir,:);
  scAcc(dd,:)  = mean(sc_uu(idxAcc & idxOutcome & idxDir,:)); %mean counts
  scFast(dd,:) = mean(sc_uu(idxFast & idxOutcome & idxDir,:));
end % for : direction (dd)
scAcc(nDir+1,:)  = scAcc(1,:); %close the circle for plotting
scFast(nDir+1,:) = scFast(1,:);

if (nargout > 2) %if desired, return single-trial counts
  varargout{1} = stsc;
end

end % fxn : computeSpikeCount_SAT()


function [ spikeCount ] = computeSpikeCount( unitTest , behavTest )
%computeSpikeCount This function computes trial-by-trial spike counts
%for the SAT data set, separately for Fast and Accurate conditions.
% 
%   Input
%   unitData_ -- Physiology data for a single unit
%   behavData_ -- Behavioral data for single session
% 
%   Output
%   spikeCount -- Spike counts for epochs [BL,VR,PS,PR]
% 

spikeCount = NaN(behavTest.NumTrials,4); %[BL,VR,PS,PR]

tWin_BL = [-300,-100]; % baseline (re array)
tWin_VR = [+50, +250]; % visual response (re array)
tWin_PS = [0,   +200]; % post-saccade (re saccade)
tWin_PR = [0,   +200]; % post-reward (re reward)

%load raw spike times
spikeTimes = load_spikes_SAT(unitTest.Unit);

%align spike times to array appearance
spikeTimes = cellfun(@(x) x-3500, spikeTimes, 'UniformOutput',false);

%compute baseline spike counts
spikeCount(:,1) = cellfun(@(x) sum((x > tWin_BL(1)) & (x < tWin_BL(2))), spikeTimes);
%compute visual response spike counts
spikeCount(:,2) = cellfun(@(x) sum((x > tWin_VR(1)) & (x < tWin_VR(2))), spikeTimes);

%align spike times to saccade
RT = num2cell(behavTest.Sacc_RT{1});
spikeTimes = cellfun(@(x,y) x-y, spikeTimes, RT, 'UniformOutput',false);

%compute post-saccade spike counts
spikeCount(:,3) = cellfun(@(x) sum((x > tWin_PS(1)) & (x < tWin_PS(2))), spikeTimes);

%align spike times to reward
tRew = behavTest.RewTime;
spikeTimes = cellfun(@(x) x-tRew, spikeTimes, 'UniformOutput',false);

%compute post-reward spike counts
spikeCount(:,4) = cellfun(@(x) sum((x > tWin_PR(1)) & (x < tWin_PR(2))), spikeTimes);

end % fxn : computeSpikeCount()
