function [ scAcc , scFast , varargout ] = computeSpikeCount_Search( unitTest , behavTest , varargin )
%computeSpikeCount_Search This function computes spike counts for the four
%main within-trial time windows (baseline, visual response, post-saccade,
%post-reward), separately for Fast and Accurate conditions.
% 
%   Input
%   unitTest  -- Data for a single neuron
%   behavTest -- Data for corresponding behavioral recording session
%   Outcome   -- 'Correct' 'ErrChoice' 'ErrTime' 'ErrChoiceOnly' 'ErrTimeOnly'
% 
%   Output
%   scAcc(8x4)  -- Mean spike count X direction X epoch -- Accurate
%   scFast(8x4) -- Mean spike count X direction X epoch -- Fast
%   stsc      -- Single-trial spike count X condition X direction X epoch
% 

args = getopt(varargin, {{'Outcome=','Correct'}});

if (size(unitTest,1)  ~= 1); error('Input to computeSpikeCount_Search() should be a single unit'); end
if (size(behavTest,1) ~= 1); error('Input to computeSpikeCount_Search() should be a single behavioral session'); end

nDir = 8;
nEpoch = 4; % Baseline | Post-array | Peri-saccade | Peri-reward

MIN_TRIAL_COUNT = 5; %min count X direction X condition
tWin.BL = [-300 -200]; %[-300,-100]; % baseline (re array)
tWin.VR = [ +50 +150]; %[+50, +250]; % post-array (re array)
tWin.PS = [ -50  +50]; %[0,   +200]; % peri-saccade (re saccade)
tWin.PR = [ -50  +50]; %[0,   +200]; % peri-reward (re reward)

%% Compute single-trial spike counts for each epoch
scSingleTrial = computeSpikeCount_SAT(unitTest, behavTest, tWin, 'task','Search');

%% Prepare to index spike counts by trial condition and outcome
%index by recording (isolation) quality
idxIso = removeTrials_Isolation(unitTest.isoSAT{1}, behavTest.NumTrials);
%index by condition
idxAcc = ((behavTest.Condition{1} == 1) & ~idxIso);
idxFast = ((behavTest.Condition{1} == 3) & ~idxIso);
%index by trial outcome
idxOutcome = behavTest.(args.Outcome){1};

%% Sort spike counts by condition and direction
scAcc = NaN(nDir,nEpoch); %mean spike counts
scFast = scAcc;
stsc.Acc = cell(nDir,1); %single-trial spike counts
stsc.Fast = stsc.Acc;

for dd = 1:nDir
  %index by target direction
  idxDir  = (behavTest.Sacc_Octant{1} == dd);
  idxDirAcc  = (idxAcc  & idxOutcome & idxDir);
  idxDirFast = (idxFast & idxOutcome & idxDir);

  %Accurate condition
  if (sum(idxDirAcc) >= MIN_TRIAL_COUNT)
    stsc.Acc{dd} = scSingleTrial(idxDirAcc,:); %save single-trial counts
    scAcc(dd,:)  = mean(scSingleTrial(idxDirAcc,:)); %mean count
  else %not enough trials for this direction
    stsc.Acc{dd} = NaN(1,nEpoch);
  end

  %Fast condition
  if (sum(idxDirFast) >= MIN_TRIAL_COUNT)
    stsc.Fast{dd} = scSingleTrial(idxDirFast,:);
    scFast(dd,:) = mean(scSingleTrial(idxDirFast,:));
  else
    stsc.Fast{dd} = NaN(1,nEpoch);
  end

end % for : direction (dd)

if (nargout > 2) %if desired, return single-trial counts
  varargout{1} = stsc;
end

end % fxn : computeSpikeCount_Search()
