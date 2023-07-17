function [ spikeCount ] = computeSpikeCount_SAT( unitTest , behavTest , tWin , varargin )
%computeSpikeCount This function computes trial-by-trial spike counts
%for the SAT data set, separately for Fast and Accurate conditions.
% 
%   Input
%   unitTest -- Physiology data for single unit
%   behavTest -- Behavioral data for single session
%   tWin  -- Time windows for computing counts [BL,VR,PS,PR]
% 
%   Output
%   spikeCount -- Spike counts for epochs [BL,VR,PS,PR]
% 

args = getopt(varargin, {{'task=','Search'}});

if (size(unitTest,1) ~= 1); error('Input to computeSpikeCount_SAT() should be a single unit'); end

spikeCount = NaN(behavTest.NumTrials,4); %[BL,VR,PS,PR]

%load raw spike times
spikeTimes = load_spikes_SAT(unitTest.Unit, 'task',args.task);

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

end % fxn : computeSpikeCount_SAT()
