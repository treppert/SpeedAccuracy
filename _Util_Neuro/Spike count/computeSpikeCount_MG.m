function [ spkCt ] = computeSpikeCount_MG( unitTest , behavTestMG )
%computeSpikeCount_MG This function computes spike counts for the four
%main within-trial time windows (baseline, visual response, post-saccade,
%post-reward), separately for the memory-guided (MG) saccade task. For this
%data set, the MG task was used to classify neurons as [Vis]<->[Move].
% 
%   Input
%   unitTest  -- Data for a single neuron
%   behavTestMG -- Data for corresponding MG recording session
% 
%   Output
%   spkCt(8x4)  -- Mean spike count X direction X epoch
% 

if (size(unitTest,1)  ~= 1); error('Input to computeSpikeCount_Search() should be a single unit'); end
if (size(behavTestMG,1) ~= 1); error('Input to computeSpikeCount_Search() should be a single behavioral session'); end

nDir = 8;
nEpoch = 4; % Baseline | Post-array | Peri-saccade | Peri-reward

MIN_TRIAL_COUNT = 5; %min count X direction X condition
tWin.BL = [-300 -200];
tWin.VR = [ +50 +150];
tWin.PS = [ -50  +50];
tWin.PR = [ -50  +50];

%Compute single-trial spike counts for each epoch
scSingleTrial = computeSpikeCount_SAT(unitTest, behavTestMG, tWin, 'task','MG');

%Index by recording (isolation) quality and trial outcome
idxIso = removeTrials_Isolation(unitTest.isoMG{1}, behavTestMG.NumTrials);
idxCorrect = behavTestMG.Correct{1} & ~idxIso;

%% Compute mean spike count X target direction
spkCt = NaN(nDir,nEpoch);

for dd = 1:nDir
  idxDir = idxCorrect & (behavTestMG.TgtOctant{1} == dd);

  if (sum(idxDir) >= MIN_TRIAL_COUNT)
    spkCt(dd,:)  = mean(scSingleTrial(idxDir,:)); %mean count
  end

end % for : direction (dd)

end % fxn : computeSpikeCount_MG()
