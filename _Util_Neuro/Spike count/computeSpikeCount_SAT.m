function [ spikeCount ] = computeSpikeCount_SAT( unitData_ , behavData_ )
%computeSpikeCount_SAT This function computes trial-by-trial spike counts
%for the SAT data set, separately for Fast and Accurate conditions.
% 
%   Inputs
%   unitData_ -- Physiology data for a single unit
%   behavData_ -- Behavioral data for single session
% 

spikeCount = NaN(behavData_.NumTrials,4); %[BL,VR,PS,PR]

tWin_BL = [-300,-100]; % baseline (re array)
tWin_VR = [+50, +250]; % visual response (re array)
tWin_PS = [0,   +200]; % post-saccade (re saccade)
tWin_PR = [0,   +200]; % post-reward (re reward)

%load raw spike times
spikeTimes = load_spikes_SAT(unitData_.Index);

%align spike times to array appearance
spikeTimes = cellfun(@(x) x-3500, spikeTimes, 'UniformOutput',false);

%compute baseline spike counts
spikeCount(:,1) = cellfun(@(x) sum((x > tWin_BL(1)) & (x < tWin_BL(2))), spikeTimes);
%compute visual response spike counts
spikeCount(:,2) = cellfun(@(x) sum((x > tWin_VR(1)) & (x < tWin_VR(2))), spikeTimes);

%align spike times to saccade
RT = num2cell(behavData_.Sacc_RT{1});
spikeTimes = cellfun(@(x,y) x-y, spikeTimes, RT, 'UniformOutput',false);

%compute post-saccade spike counts
spikeCount(:,3) = cellfun(@(x) sum((x > tWin_PS(1)) & (x < tWin_PS(2))), spikeTimes);

%align spike times to reward
tRew = behavData_.RewTime;
spikeTimes = cellfun(@(x) x-tRew, spikeTimes, 'UniformOutput',false);

%compute post-reward spike counts
spikeCount(:,4) = cellfun(@(x) sum((x > tWin_PR(1)) & (x < tWin_PR(2))), spikeTimes);

end % fxn : computeSpikeCount_SAT()
