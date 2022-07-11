function [spkCorr] = createSpikeCorrWithSubSampling()
% see getCrossAreaPairs() sub function
% 
% CREATESPIKECORRWITHSUBSAMPLING: Create spike count correlation data set
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
%        nTerials4SubSample = 40 or 80;
%        FOR-1-to-nSubSamples DO
%            subSampIdx = subsample(1:nTrials4SatCond,
%                nTrials4SubSample) 
%            estimatedRscVec(loop-count) =
%                corr(X_unitSpkCountByTrial(subSampIdx), 
%                Y_unitSpkCountByTrial(subSampIdx)) Pearson's
%        LOOP-FOR-nSubSamples
%        estimatedRsc4Cond = mean(estimatedRscVec)
%        confIntRsc4Cond = CI(estimatedRscVec,0.95)
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
%     warning('off');
%     datasetDir = 'dataProcessed/satSefPaper/dataset';
datasetDir = 'C:\Users\thoma\Dropbox\Speed Accuracy\Data\SpkCorr\dataset';

% specify files with data to compute Rsc
pairsFile = fullfile(datasetDir,'SAT_SEF_PAIR_CellInfoDB.mat');
trialTypesFile = fullfile(datasetDir,'SAT_SEF_TrialTypesDB.mat');
trialEventTimesFile = fullfile(datasetDir,'SAT_SEF_TrialEventTimesDB.mat');

alignNames = {'PostSaccade'}; % {'Baseline','Visual','PostSaccade','PostReward'};
alignEvents = {'SaccadePrimary'}; % {'CueOn','CueOn','SaccadePrimary','RewardTime'};
alignTimeWin = {[-100 500]}; % {[-600 100],[-200 400],[-100 500],[-200 700]};

conditions = {'AccurateCorrect'; 'AccurateErrorChoice'; 'AccurateErrorTiming'; ...
    'FastCorrect'; 'FastErrorChoice'; 'FastErrorTiming'};

staticWinsAlignTs(1).Baseline = [-150 0];
staticWinsAlignTs(1).Visual = [0 150];
staticWinsAlignTs(1).PostSaccade = [0 150];
staticWinsAlignTs(1).PostReward = [0 150];

% minimum number of trials for all conditions, if not, then ignore pair  
MIN_NTRIAL = 10;
% nSubSamples = 1000; % number of times to subsample
N_SUBSAMPLE = 1;

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
  sess = crossPair.X_sess{1};
  trialTypes = sessionTrialTypes(ismember(sessionTrialTypes.session,sess),:);
  trRem = getTrialNosToRemove(crossPair);
  [trialNos4SatConds, nTrials4SatConds] = ...
      getTrialNosForAllSatConds(trialTypes,trRem,conditions);
  
  %check no. of trials
  nTrials4SubSample = min(struct2array(nTrials4SatConds));
  if (nTrials4SubSample < MIN_NTRIAL); continue; end
  
  % get spike times
  xSpkTimes = load_spikes_SAT(crossPair.X_unitNum);
  ySpkTimes = load_spikes_SAT(crossPair.Y_unitNum);
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

      %% Do sub-sampling to estimate Rho and CI
      % Mean-trial-count for Fast-ErrorTiming ~ 40 (37.29)
      [rhoEst40,rhoEstSem40,~,ci95_nTrials_40,subSampleIdxs_40,rhoVecSubSamples_40] = ...
           getEstimatedRhoAndConfInterval(xSpkCounts{1}, ySpkCounts{1}, 40, N_SUBSAMPLE, [10 90]);
      % Mean-trial-count for Accurate-ErrorChoice ~ 80 (79.56)
      [rhoEst80,rhoEstSem80,~,ci95_nTrials_80,subSampleIdxs_80,rhoVecSubSamples_80] = ...
           getEstimatedRhoAndConfInterval(xSpkCounts{1}, ySpkCounts{1}, 80, N_SUBSAMPLE,[10 90]);

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

      tempCorr(evId,sc).subSamplIdxs_nTrials_40 = {subSampleIdxs_40};
      tempCorr(evId,sc).rhoVecSubSampl_nTrials_40 = {rhoVecSubSamples_40};                
      tempCorr(evId,sc).rhoEstRaw_nTrials_40 = rhoEst40;
      tempCorr(evId,sc).rhoEstSem_nTrials_40 = rhoEstSem40;
      tempCorr(evId,sc).ci95_nTrials_40 = {ci95_nTrials_40};
      tempCorr(evId,sc).rhoRawInCi95_nTrials_40 = ci95_nTrials_40(1) < rho_pval(1) & rho_pval(1) < ci95_nTrials_40(2);

      tempCorr(evId,sc).subSamplIdxs_nTrials_80 = {subSampleIdxs_80};
      tempCorr(evId,sc).rhoVecSubSampl_nTrials_80 = {rhoVecSubSamples_80};                
      tempCorr(evId,sc).rhoEstRaw_nTrials_80 = rhoEst80;
      tempCorr(evId,sc).rhoEstSem_nTrials_80 = rhoEstSem80;
      tempCorr(evId,sc).ci95_nTrials_80 = {ci95_nTrials_80};
      tempCorr(evId,sc).rhoRawInCi95_nTrials_80 = ci95_nTrials_80(1) < rho_pval(1) & rho_pval(1) < ci95_nTrials_80(2);

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
% outFile = 'rscSubSampl1K_PostSaccade_0_TrialsThresh.mat';
% save(outFile,'-v7.3','spkCorr')

end % fxn : createSpkCorrWithSubSampling()

function [rhoEst,rhoEstSem,percentileCI,normalCI,subSampleIdxs,rhoVecSubSamples] = ...
         getEstimatedRhoAndConfInterval(xSpkCounts,ySpkCounts,nTrials4SubSample,nSubSamples, prctileRange)
    % inline fx for subsampling see DATASAMPLE
    subSampleIdxs = arrayfun(@(x) single(datasample(1:numel(xSpkCounts),nTrials4SubSample,'Replace',true)'),(1:nSubSamples),'UniformOutput',false);
    rhoPvalSubSamples = cellfun(@(x) getSpikeCountCorr(xSpkCounts(x),ySpkCounts(x),'Pearson'),subSampleIdxs','UniformOutput',false);
    rhoPvalSubSamples = cell2mat(rhoPvalSubSamples);
    rhoVecSubSamples = single(rhoPvalSubSamples(:,1));
    % compute mean & sem
    % remove NaNs from computation
    rhoVecSubSamples(isnan(rhoVecSubSamples)) = [];
    rhoEst = mean(rhoVecSubSamples);
    rhoEstSem = std(rhoVecSubSamples)/sqrt(numel(rhoVecSubSamples));
    % compute t-statistic for 0.025, 0.975
    ts = tinv([0.025,0.975],nTrials4SubSample-1);
    normalCI = rhoEst + rhoEstSem*ts;
    percentileCI =  prctile(rhoVecSubSamples,prctileRange); 
    
    % change subSampleIdxs to nSubSamples by nTrials4SubSample
    subSampleIdxs = cell2mat(subSampleIdxs)';
end

function [cellPairs] = getCrossAreaPairs(pairsFile)

allCellPairs = load(pairsFile);
allCellPairs = allCellPairs.satSefPairCellInfoDB;
allCellPairs = allCellPairs(ismember([allCellPairs.X_monkey],{'D','E'}),:);

idxCrossAreaSEF = (ismember(allCellPairs.X_area,'SEF') & ismember(allCellPairs.Y_area,{'FEF','SC'}));
idxCrossArea = idxCrossAreaSEF;
cellPairs = allCellPairs(idxCrossArea,:);

assert(isequal(cellPairs.X_sess, cellPairs.Y_sess), ...
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
    trRem = [crossPair.X_trRemSAT{1};crossPair.Y_trRemSAT{1}];
    if ~isempty(trRem)
        temp = [];
        for ii = 1:size(trRem,1)
            temp = [temp [trRem(ii,1):trRem(ii,2)]]; %#ok<NBRAK,AGROW>
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

    % cellPairInfo fields to extract
    colNames = {
        'Pair_UID'
        'X_monkey'
        'X_sessNum'
        'X_sess'
        'X_unitNum'
        'Y_unitNum'
        'X_unit'
        'Y_unit'
        'X_area'
        'Y_area'
        'X_visGrade'
        'Y_visGrade'
        'X_visField'
        'Y_visField'
        'X_errGrade'
        'Y_errGrade'
        'X_isErrGrade'
        'Y_isErrGrade'
        'X_rewGrade'
        'Y_rewGrade'
        'X_isRewGrade'
        'Y_isRewGrade'
        };
end
