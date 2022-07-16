function [spkCorr] = computeSpkCorr_X_Outcome()
% see getCrossAreaPairs() sub function
% 
% computeSpkCorr_X_Outcome: Create spike count correlation data set
%   for pairs of units recorded from same session for cross areas.
% 
% crossPairs = getAllCrossPairs-no-filtering
% 
% FOR-each-crossPair in crossPairs DO
%   trialNos4SatConds = getTrialNosForAllSatConds(removeTrialNos-
%                             for-pair-if-present-on-any-unit-in-pair)
%   nTrials4SatConds = countTrials4SatConds(trialNos4SatConds)
% 
%   satCondWithMinTrials = whichSatCondIs(nTrials4SubSample)
%   satConds2SubSample = whichSatCondIs(>nTrials4SubSample)
% 
%   FOR-each-satCond in allSatConds DO
%       trialsNos4SatCond = getFrom(trialNos4SatConds,satCond)
%       nTrials4SatCond = count(trialsNos4SatCond)
% 
%       [X_unitSpkCountByTrial, Y_unitSpkCountByTrial] = getSpkCounts(X_unitAlignedTimes,Y_unitAlignedTimes,timWin)
%       [X_unitSpkCountMean,X_unitSpkCountStd] = getSpkCountStats(X_unitAlignedSpikes)
%       [Y_unitSpkCountMean,Y_unitSpkCountStd] = getSpkCountStats(Y_unitAlignedSpikes)
%       [cpRsc,cpPairPval] = corr(X_unitSpkCountByTrial, Y_unitSpkCountByTrial)
% 
%   LOOP-FOR-eachSatCond
% 
% LOOP-FOR-each-crossPair
% 
% Note 2020-JUN-11: nTrialsThreshold is set to '0' to include E20130829001
% for getting some additional pairs. 
% 
% 
% Expects the following files in specified location:
% 1. Info about all possible cell pairs:
%        'dataProcessed/satSefPaper/dataset/SAT_SEF_PAIR_CellInfoDB.mat'
% 2. Trial types of all sessions (Accurate, Fast, Correct,...):
%        'dataProcessed/satSefPaper/dataset/SAT_SEF_TrialTypesDB.mat'
% 3. Event times for all trials and all sessions:
%         'dataProcessed/satSefPaper/dataset/SAT_SEF_TrialEventTimesDB.mat'
%

%% File refs for data to compute Rsc
datasetDir = 'C:\Users\thoma\Dropbox\Speed Accuracy\Data\SpkCorr';

% specify files with data to compute Rsc
pairsFile = fullfile(datasetDir,'PAIR_CellInfoDB.mat');
trialTypesFile = fullfile(datasetDir,'SAT_SEF_TrialTypesDB.mat');
trialEventTimesFile = fullfile(datasetDir,'SAT_SEF_TrialEventTimesDB.mat');

alignNames = {'Baseline','Visual','PostSaccade','PostReward'};
alignEvents = {'CueOn','CueOn','SaccadePrimary','RewardTime'};
alignTimeWin = {[-600 100],[-200 400],[-100 500],[-200 700]};

conditions = {'AccurateCorrect'; 'AccurateErrorChoice'; 'AccurateErrorTiming'; ...
    'FastCorrect'; 'FastErrorChoice'; 'FastErrorTiming'};

staticWinsAlignTs(1).Baseline = [-150 0];
staticWinsAlignTs(1).Visual = [0 150];
staticWinsAlignTs(1).PostSaccade = [0 150];
staticWinsAlignTs(1).PostReward = [0 150];

% minimum number of trials for all conditions, if not, then ignore pair  
MIN_NTRIAL = 10;

%% Prep for parallel processing
parPool = gcp('nocreate');
nThreads = parPool.NumWorkers;

%%  Load data needed to compute Rsc
crossPairs = getCrossAreaPairs(pairsFile);
sessionTrialTypes = getSessionTrialTypes(trialTypesFile);
sessionEventTimes = getSessionEventTimes(trialEventTimesFile);

N_PAIRS = size(crossPairs,1);
fprintf('Computing Rsc for %i pairs\n', N_PAIRS)
spkCorr = table();

tic
%     pctRunOnAll warning off;
parfor (cp = 1:N_PAIRS,nThreads)%nCrossPairs
  crossPair = crossPairs(cp,:);
  sess = crossPair.X_Session{1};
  trialTypes = sessionTrialTypes(ismember(sessionTrialTypes.session,sess),:);
  trRem = getTrialNosToRemove(crossPair);
  [trialNos4SatConds, nTrials4SatConds] = ...
      getTrialNosForAllSatConds(trialTypes,trRem,conditions);
  
  %check no. of trials
  nTrials4SubSample = min(struct2array(nTrials4SatConds));
  if (nTrials4SubSample < MIN_NTRIAL); continue; end
  
  % get spike times
  xSpkTimes = load_spikes_SAT(crossPair.X_Index, 'user','thoma');
  ySpkTimes = load_spikes_SAT(crossPair.Y_Index, 'user','thoma');
  evntTimes = sessionEventTimes(ismember(sessionEventTimes.session,sess),:);
  
  tempCorr = struct();
  for sc = 1:numel(conditions)
    condition = conditions{sc};
    selTrials = trialNos4SatConds.(condition);
    selTrialsSorted = selTrials; % no sorting
    for evId = 1:numel(alignEvents)
      alignedName = alignNames{evId};
      alignedEvent = alignEvents{evId};
      alignedTimeWin = alignTimeWin{evId};
      alignTime = evntTimes.CueOn{1};
      if ~strcmp(alignedEvent,'CueOn')
          alignTime = alignTime + double(evntTimes.(alignedEvent){1}(:));
      end  
      alignTime = alignTime(selTrialsSorted);
      XAligned = SpikeUtils.alignSpikeTimes(xSpkTimes(selTrialsSorted),alignTime, alignedTimeWin);
      YAligned = SpikeUtils.alignSpikeTimes(ySpkTimes(selTrialsSorted),alignTime, alignedTimeWin);
      tempRast = SpikeUtils.rasters(XAligned,alignedTimeWin);
      XRasters = tempRast.rasters;
      tempRast = SpikeUtils.rasters(YAligned,alignedTimeWin);
      YRasters = tempRast.rasters;
      rasterBins = tempRast.rasterBins;                               
      
      staticWin = staticWinsAlignTs(1).(alignedName);
      fieldSuffix = num2str(range(staticWin),'_%dms'); 
      xSpkCounts = cellfun(@(r,x,w) sum(x(:,r>=w(1) & r<=w(2)),2),...
          {rasterBins},{XRasters},{staticWin},'UniformOutput',false);
      xMeanFrWin = mean(xSpkCounts{1})*1000/range(staticWin);
      ySpkCounts = cellfun(@(r,x,w) sum(x(:,r>=w(1) & r<=w(2)),2),...
          {rasterBins},{YRasters},{staticWin},'UniformOutput',false);
      yMeanFrWin = mean(ySpkCounts{1})*1000/range(staticWin);
      [rho_pval] = getSpikeCountCorr(xSpkCounts{1},ySpkCounts{1},'Pearson');

      %% Output
      % add crosspair info
      cN = getPairColNmes();
      cpTemp = table2struct(crossPair,'ToScalar',true);
      for c = 1:numel(cN)
          tempCorr(evId,sc).(cN{c}) = cpTemp.(cN{c});
      end

      tempCorr(evId,sc).condition = condition;
      tempCorr(evId,sc).alignedName = alignedName;
      tempCorr(evId,sc).alignedEvent = alignedEvent;
      tempCorr(evId,sc).alignedTimeWin = {alignedTimeWin};
      tempCorr(evId,sc).alignTime = alignTime;
      tempCorr(evId,sc).trialNosByCondition = selTrialsSorted;
      tempCorr(evId,sc).nTrials = numel(selTrialsSorted);

      tempCorr(evId,sc).(['xSpkCount_win' fieldSuffix]) = xSpkCounts;
      tempCorr(evId,sc).(['ySpkCount_win' fieldSuffix]) = ySpkCounts;
      tempCorr(evId,sc).(['xMeanFr_spkPerSec_win' fieldSuffix]) = xMeanFrWin;
      tempCorr(evId,sc).(['yMeanFr_spkPerSec_win' fieldSuffix]) = yMeanFrWin;

      tempCorr(evId,sc).rho_pval_win = {staticWin};                    
      tempCorr(evId,sc).rhoRaw = rho_pval(1);
      tempCorr(evId,sc).pvalRaw = rho_pval(2);
      tempCorr(evId,sc).signifRaw_05 = rho_pval(2) < 0.05;  

    end % for : align event (evId)

  end % for : task condition (sc)

  try
  tempCorr = tempCorr(:);
  for jj=1:numel(tempCorr)
    spkCorr = [spkCorr; struct2table(tempCorr(jj),'AsArray',true)]; 
  end
  catch me
    me
  end

end

toc

end % fxn : createSpkCorrWithSubSampling()

function [cellPairs] = getCrossAreaPairs(pairsFile)

allCellPairs = load(pairsFile);
allCellPairs = allCellPairs.pairInfoDB;
allCellPairs = allCellPairs(ismember([allCellPairs.X_Monkey],{'D','E'}),:);

idxCrossAreaSEF = (ismember(allCellPairs.X_Area,'SEF') & ismember(allCellPairs.Y_Area,{'FEF','SC'}));
idxCrossArea = idxCrossAreaSEF;
cellPairs = allCellPairs(idxCrossArea,:);

assert(isequal(cellPairs.X_Session, cellPairs.Y_Session), ...
  'Error: X-Unit sessions and Y-Unit sessions do not match');
fprintf('Done getCrossAreaPairs()\n')

end % util : getCrossAreaPairs()

function [sessionTrialTypes] = getSessionTrialTypes(trialTypesFile)
    sessionTrialTypes = load(trialTypesFile);
    sessionTrialTypes = sessionTrialTypes.TrialTypesDB;
    fprintf('Done getSessionTrialTypes()\n')
end

function [sessionEventTimes] = getSessionEventTimes(trialEventTimesFile)
    sessionEventTimes = load(trialEventTimesFile);
    sessionEventTimes = sessionEventTimes.TrialEventTimesDB;
    fprintf('Done getSessionEventTimes()\n')
end

function [trRem] = getTrialNosToRemove(crossPair)
    trRem = [crossPair.X_TrialRemoveSAT{1};crossPair.Y_TrialRemoveSAT{1}];
    if ~isempty(trRem)
        temp = [];
        for ii = 1:size(trRem,1)
            temp = [temp [trRem(ii,1):trRem(ii,2)]];
        end
        trRem = unique(temp(:));
    end
    %fprintf('Done getTrialNosToRemove()\n')
end

function [trialNos4SatConds,nTrials4SatConds] = getTrialNosForAllSatConds(trialTypes,trRem,conditions)
   trialNos4SatConds = struct();
   nTrials4SatConds = struct();
   for c = 1:numel(conditions)
       condition = conditions{c};
       temp = trialTypes.(condition){1};
       temp(trRem) = 0;
       temp = find(temp);       
       trialNos4SatConds.(condition) = temp;
   end
   % remove trials common to *ErrorChoice and *ErrorTiming
   % May not need this since they already seem to be mutually exclusive
   commonTrialNos = intersect(trialNos4SatConds.AccurateErrorChoice,trialNos4SatConds.AccurateErrorTiming);
   trialNos4SatConds.AccurateErrorChoice = setdiff(trialNos4SatConds.AccurateErrorChoice,commonTrialNos);
   trialNos4SatConds.AccurateErrorTiming = setdiff(trialNos4SatConds.AccurateErrorTiming,commonTrialNos);
   commonTrialNos = intersect(trialNos4SatConds.FastErrorChoice,trialNos4SatConds.FastErrorTiming);
   trialNos4SatConds.FastErrorChoice = setdiff(trialNos4SatConds.FastErrorChoice,commonTrialNos);
   trialNos4SatConds.FastErrorTiming = setdiff(trialNos4SatConds.FastErrorTiming,commonTrialNos);
   % nTrialsFor sat conds
   for c = 1:numel(conditions)
       condition = conditions{c};
       nTrials4SatConds.(condition) = numel(trialNos4SatConds.(condition));
   end   
   %fprintf('Done getTrialNosForAllSatConds()\n')   
end

function [colNames] = getPairColNmes()

colNames = {
    'Pair_UID'
    'X_Monkey'
    'X_SessionIndex'
    'X_Session'
    'X_Index'
    'Y_Index'
    'X_Area'
    'Y_Area'
    'X_Grade_Vis'
    'Y_Grade_Vis'
    'X_Grade_Err'
    'Y_Grade_Err'
    'X_isErrGrade'
    'Y_isErrGrade'
    'X_Grade_TErr'
    'Y_Grade_TErr'
    'X_isRewGrade'
    'Y_isRewGrade'
    };

end
