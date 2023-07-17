function [ scAcc , scFast , varargout ] = computeSpikeCount_SAT( unitTest , behavTest , outcome , varargin )
%computeSpikeCount_SAT This function computes spike counts across the four
%main within-trial time windows (baseline, visual response, post-saccade,
%post-reward), separately for Fast and Accurate conditions.
%   Input
%   outcome - 'Correct' 'ErrChoice' 'ErrTime' 'ErrChoiceOnly' 'ErrTimeOnly'
% 
%   Output
%   scAcc(9x4)  - single neuron spike count (direction X epoch) - Accurate
%   scFast(9x4) - single neuron spike count (direction X epoch) - Fast
%   stsc - *single-trial* spike count (condition X direction X epoch)
% 

MIN_TRIAL_COUNT = 5;
nDir = 8;
nEpoch = 4; % Baseline | Post-array | Peri-saccade | Peri-reward
nTrial = behavTest.NumTrials;

TWIN.BL = [-300 -200]; %[-300,-100]; % baseline (re array)
TWIN.VR = [ +50 +150]; %[+50, +250]; % post-array (re array)
TWIN.PS = [ -50  +50]; %[0,   +200]; % peri-saccade (re saccade)
TWIN.PR = [ -50  +50]; %[0,   +200]; % peri-reward (re reward)

%% Check for valid input
nRow = size(unitTest,1);
if (nRow ~= 1); error('Input to computeSpikeCount_SAT() should be a single unit'); end

%% Compute spike counts by epoch
sc_uu = computeSpikeCount(unitTest, behavTest, TWIN);

%% Index by isolation quality
if (nargin > 3) %if desired, specify trials with poor isolation
  idxIso = removeTrials_Isolation(varargin{1}, nTrial);
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
  idxAccDir =  (idxAcc & idxOutcome & idxDir);
  idxFastDir = (idxFast & idxOutcome & idxDir);

  if (sum(idxAccDir) >= MIN_TRIAL_COUNT)
    stsc.Acc{dd} = sc_uu(idxAccDir,:); %single-trial counts
    scAcc(dd,:)  = mean(sc_uu(idxAccDir,:)); %mean counts
  else %not enough trials for this direction
    stsc.Acc{dd} = NaN(1,nEpoch);
  end
  if (sum(idxFastDir) >= MIN_TRIAL_COUNT)
    stsc.Fast{dd} = sc_uu(idxFastDir,:);
    scFast(dd,:) = mean(sc_uu(idxFastDir,:));
  else %not enough trials for this direction
    stsc.Fast{dd} = NaN(1,nEpoch);
  end
end % for : direction (dd)
scAcc(nDir+1,:)  = scAcc(1,:); %close the circle for plotting
scFast(nDir+1,:) = scFast(1,:);

if (nargout > 2) %if desired, return single-trial counts
  varargout{1} = stsc;
end

end % fxn : computeSpikeCount_SAT()


function [ spikeCount ] = computeSpikeCount( unitTest , behavTest , tWin )
%computeSpikeCount This function computes trial-by-trial spike counts
%for the SAT data set, separately for Fast and Accurate conditions.
% 
%   Input
%   unitTest -- Physiology data for a single unit
%   behavTest -- Behavioral data for single session
%   tWin  -- Time windows for computing counts
% 
%   Output
%   spikeCount -- Spike counts for epochs [BL,VR,PS,PR]
% 

spikeCount = NaN(behavTest.NumTrials,4); %[BL,VR,PS,PR]

%load raw spike times
spikeTimes = load_spikes_SAT(unitTest.Unit);

%align spike times to array appearance
spikeTimes = cellfun(@(x) x-3500, spikeTimes, 'UniformOutput',false);

%compute baseline spike counts
spikeCount(:,1) = cellfun(@(x) sum((x > tWin.BL(1)) & (x < tWin.BL(2))), spikeTimes);
%compute visual response spike counts
spikeCount(:,2) = cellfun(@(x) sum((x > tWin.VR(1)) & (x < tWin.VR(2))), spikeTimes);

%align spike times to saccade
RT = num2cell(behavTest.Sacc_RT{1});
spikeTimes = cellfun(@(x,y) x-y, spikeTimes, RT, 'UniformOutput',false);

%compute post-saccade spike counts
spikeCount(:,3) = cellfun(@(x) sum((x > tWin.PS(1)) & (x < tWin.PS(2))), spikeTimes);

%align spike times to reward
tRew = behavTest.RewTime;
spikeTimes = cellfun(@(x) x-tRew, spikeTimes, 'UniformOutput',false);

%compute post-reward spike counts
spikeCount(:,4) = cellfun(@(x) sum((x > tWin.PR(1)) & (x < tWin.PR(2))), spikeTimes);

end % fxn : computeSpikeCount()
