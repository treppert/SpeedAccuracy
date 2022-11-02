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
trialTypesFile = fullfile(datasetDir,'SAT_SEF_TrialTypesDB.mat'); %computeTrialTypesDB.m
trialEventTimesFile = fullfile(datasetDir,'SAT_SEF_TrialEventTimesDB.mat');

alignNames = {'Baseline','Visual','PostSaccade','PostReward'};
alignEvents = {'CueOn','CueOn','SaccadePrimary','RewardTime'};
alignTimeWin = {[-600 100],[-200 400],[-100 500],[-200 700]};

trialType = {'AccurateCorrect'; 'AccurateErrorChoice'; 'AccurateErrorTiming'; ...
             'FastCorrect'; 'FastErrorChoice'; 'FastErrorTiming'};

staticWinsAlignTs(1).Baseline = [-300 -100]; %[-150 0];
staticWinsAlignTs(1).Visual = [50 250]; %[0 150];
staticWinsAlignTs(1).PostSaccade = [0 200]; %[0 150];
staticWinsAlignTs(1).PostReward = [0 200]; %[0 150];

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

parfor (cp = 1:N_PAIRS,nThreads) %pairs SEF-FEF/SC
  crossPair = crossPairs(cp,:);
  sess = crossPair.X_Session{1};
  trialTypes = sessionTrialTypes(ismember(sessionTrialTypes.session,sess),:);
  trialNos4SatConds = getTrialNosForSatConds(trialTypes,trialType);
  
  % get spike times
  xSpkTimes = load_spikes_SAT(crossPair.X_Index, 'user','thoma');
  ySpkTimes = load_spikes_SAT(crossPair.Y_Index, 'user','thoma');
  evntTimes = sessionEventTimes(ismember(sessionEventTimes.session,sess),:);
  
  tmp_rsc = struct();
  for tt = 1:numel(trialType) %trial condition/outcome combination
    jj = trialNos4SatConds.(trialType{tt}); %jj == trial numbers for this trial type

    for ep = 1:numel(alignEvents) %trial epoch

      alignedEvent = alignEvents{ep};
      alignedTimeWin = alignTimeWin{ep};

      alignTime = evntTimes.CueOn{1};
      if ~strcmp(alignedEvent,'CueOn')
          alignTime = alignTime + double(evntTimes.(alignedEvent){1}(:));
      end

      X_Aligned = SpikeUtils.alignSpikeTimes(xSpkTimes(jj), alignTime(jj), alignedTimeWin);
      Y_Aligned = SpikeUtils.alignSpikeTimes(ySpkTimes(jj), alignTime(jj), alignedTimeWin);

      tempRast = SpikeUtils.rasters(X_Aligned,alignedTimeWin);
      XRasters = tempRast.rasters;

      tempRast = SpikeUtils.rasters(Y_Aligned,alignedTimeWin);
      YRasters = tempRast.rasters;

      rasterBins = tempRast.rasterBins;                               
      
      %compute spike counts for SEF(X) and FEF/SC(Y) for this trial epoch
      staticWin = staticWinsAlignTs(1).(alignNames{ep});
      xSpkCounts = cellfun(@(r,x,w) sum(x(:,r>=w(1) & r<=w(2)),2),...
          {rasterBins},{XRasters},{staticWin},'UniformOutput',false);
      ySpkCounts = cellfun(@(r,x,w) sum(x(:,r>=w(1) & r<=w(2)),2),...
          {rasterBins},{YRasters},{staticWin},'UniformOutput',false);

      %compute spike count correlation from spike counts
      [rho_pval] = getSpikeCountCorr(xSpkCounts{1},ySpkCounts{1},'Pearson');

      %% Save data for output
      % add crosspair info
      cN = getPairColNmes();
      cpTemp = table2struct(crossPair,'ToScalar',true);
      for c = 1:numel(cN)
          tmp_rsc(ep,tt).(cN{c}) = cpTemp.(cN{c});
      end

      tmp_rsc(ep,tt).condition = trialType{tt};
      tmp_rsc(ep,tt).alignedName = alignNames{ep};
      tmp_rsc(ep,tt).alignedEvent = alignedEvent;
      tmp_rsc(ep,tt).alignedTimeWin = {alignedTimeWin};
      tmp_rsc(ep,tt).alignTime = alignTime(jj);
      tmp_rsc(ep,tt).trialNosByCondition = jj;
      tmp_rsc(ep,tt).nTrials = numel(jj);

      fieldSuffix = num2str(range(staticWin),'_%dms'); 
      tmp_rsc(ep,tt).(['xSpkCount_win' fieldSuffix]) = xSpkCounts;
      tmp_rsc(ep,tt).(['ySpkCount_win' fieldSuffix]) = ySpkCounts;

      xMeanFrWin = mean(xSpkCounts{1})*1000/range(staticWin);
      tmp_rsc(ep,tt).(['xMeanFr_spkPerSec_win' fieldSuffix]) = xMeanFrWin;

      yMeanFrWin = mean(ySpkCounts{1})*1000/range(staticWin);
      tmp_rsc(ep,tt).(['yMeanFr_spkPerSec_win' fieldSuffix]) = yMeanFrWin;

      tmp_rsc(ep,tt).rho_pval_win = {staticWin};                    
      tmp_rsc(ep,tt).rhoRaw = rho_pval(1);
      tmp_rsc(ep,tt).pvalRaw = rho_pval(2);
      tmp_rsc(ep,tt).signifRaw_05 = rho_pval(2) < 0.05;  

    end % for : trial epoch (ep)

  end % for : task condition (sc)

  try
  tmp_rsc = tmp_rsc(:);
  for ii=1:numel(tmp_rsc)
    spkCorr = [spkCorr; struct2table(tmp_rsc(ii),'AsArray',true)]; 
  end
  catch me
    me
  end

end

end % fxn : createSpkCorrWithSubSampling()

function [cellPairs] = getCrossAreaPairs(pairsFile)
allCellPairs = load(pairsFile);
allCellPairs = allCellPairs.pairInfoDB;
cellPairs = allCellPairs(ismember([allCellPairs.X_Monkey],{'D','E'}),:);
end % util : getCrossAreaPairs()

function [sessionTrialTypes] = getSessionTrialTypes(trialTypesFile)
sessionTrialTypes = load(trialTypesFile);
sessionTrialTypes = sessionTrialTypes.TrialTypesDB;
fprintf('Done getSessionTrialTypes()\n')
end % util : getSessionTrialTypes()

function [sessionEventTimes] = getSessionEventTimes(trialEventTimesFile)
sessionEventTimes = load(trialEventTimesFile);
sessionEventTimes = sessionEventTimes.TrialEventTimesDB;
fprintf('Done getSessionEventTimes()\n')
end % util : getSessionEventTimes()

function [trialNos4SatConds] = getTrialNosForSatConds(trialTypes, conditions)
 trialNos4SatConds = struct();
 for c = 1:numel(conditions)
     temp = find(trialTypes.(conditions{c}){1});
     trialNos4SatConds.(conditions{c}) = temp;
 end
end % util : getTrialNosForSatConds()

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
    'X_RF'
    'Y_RF'
    'X_Grade_Err'
    'X_Grade_TErr'
    };

end
