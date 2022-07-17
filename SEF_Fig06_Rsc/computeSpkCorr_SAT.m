function [spkCorr] = computeSpkCorr_SAT( varargin )
% 
% computeSpkCorr_SAT: Create spike count correlation data set
%   for pairs of units recorded from same session for cross areas.
% 
% see getCrossAreaPairs() sub function
% crossPairs = getAllCrossPairs-no-filtering
% 
% FOR-each-crossPair in crossPairs DO
% 
%   FOR-each-satCond in allSatConds DO
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
% Expects the following files in specified location:
% 1. Info about all possible cell pairs:
%        'dataProcessed/satSefPaper/dataset/SAT_SEF_PAIR_CellInfoDB.mat'
% 2. Event times for all trials and all sessions:
%         'dataProcessed/satSefPaper/dataset/SAT_SEF_TrialEventTimesDB.mat'
%

args = getopt(varargin, {{'direction=','A2F'}});

%% File refs for data to compute Rsc
datasetDir = 'C:\Users\thoma\Dropbox\Speed Accuracy\Data';

% specify files with data to compute Rsc
pairsFile = fullfile(datasetDir,'SpkCorr\PAIR_CellInfoDB.mat');
trialEventTimesFile = fullfile(datasetDir,'SpkCorr\SAT_SEF_TrialEventTimesDB.mat');

DIRECTION = args.direction;
TRIAL_RE_SWITCH = ( -4 : 3 );
tmp = load([datasetDir, '\behavData.mat']);
trialSwitch = identify_condition_switch( tmp.behavData );

ALIGNED_EVENT = 'SaccadePrimary';
ALIGNED_TIMEWIN = [-100 500];
STATIC_WIN_ALIGN = [0 150];

%% Prep for parallel processing
parPool = gcp('nocreate');
nThreads = parPool.NumWorkers;

%%  Load data needed to compute Rsc
crossPairs = getCrossAreaPairs(pairsFile);
sessionEventTimes = getSessionEventTimes(trialEventTimesFile);

NUM_PAIRS = size(crossPairs,1);
fprintf('Computing Rsc for %i pairs\n', NUM_PAIRS)
spkCorr = table();

parfor (cp = 1:NUM_PAIRS, nThreads)
  
  crossPair = crossPairs(cp,:);
  sess = crossPair.X_Session{1};
  
  %index by trial from condition switch
  kk = crossPair.X_SessionIndex;
  jjSwitch = trialSwitch.(DIRECTION){kk};
  
  % get spike times
  xSpkTimes = load_spikes_SAT(crossPair.X_Index);
  ySpkTimes = load_spikes_SAT(crossPair.Y_Index);
  evntTimes = sessionEventTimes(ismember(sessionEventTimes.session,sess),:);
  
  rhoRawCP = NaN(numel(TRIAL_RE_SWITCH),1);
  pvalRawCP = rhoRawCP;
  
  for ii = 1:numel(TRIAL_RE_SWITCH) %loop over trial index re. switch
    
    jjCurrent = jjSwitch + TRIAL_RE_SWITCH(ii); %get all trials at this index re. switch
    
    alignTime = evntTimes.CueOn{1} + double(evntTimes.(ALIGNED_EVENT){1}(:));
    alignTime = alignTime(jjCurrent);
    
    XAligned = SpikeUtils.alignSpikeTimes(xSpkTimes(jjCurrent), alignTime, ALIGNED_TIMEWIN);
    YAligned = SpikeUtils.alignSpikeTimes(ySpkTimes(jjCurrent), alignTime, ALIGNED_TIMEWIN);
    tempRast = SpikeUtils.rasters(XAligned,ALIGNED_TIMEWIN);
    XRasters = tempRast.rasters;
    tempRast = SpikeUtils.rasters(YAligned,ALIGNED_TIMEWIN);
    YRasters = tempRast.rasters;
    rasterBins = tempRast.rasterBins;                               

    fieldSuffix = num2str(range(STATIC_WIN_ALIGN),'_%dms'); 
    xSpkCounts = cellfun(@(r,x,w) sum(x(:,r>=w(1) & r<=w(2)),2),...
        {rasterBins},{XRasters},{STATIC_WIN_ALIGN},'UniformOutput',false);
    xMeanFrWin = mean(xSpkCounts{1})*1000/range(STATIC_WIN_ALIGN);
    ySpkCounts = cellfun(@(r,x,w) sum(x(:,r>=w(1) & r<=w(2)),2),...
        {rasterBins},{YRasters},{STATIC_WIN_ALIGN},'UniformOutput',false);
    yMeanFrWin = mean(ySpkCounts{1})*1000/range(STATIC_WIN_ALIGN);
    [rho_pval] = getSpikeCountCorr(xSpkCounts{1},ySpkCounts{1},'Pearson');
    
    rhoRawCP(ii) = rho_pval(1);
    pvalRawCP(ii) = rho_pval(2);
    
  end % for : index re. switch (ii)

%% Output
tmpCorr = struct();

cN = getPairColNames(); % add crosspair info
cpTemp = table2struct(crossPair,'ToScalar',true);
for c = 1:numel(cN)
  tmpCorr.(cN{c}) = cpTemp.(cN{c});
end

tmpCorr.index = TRIAL_RE_SWITCH';
tmpCorr.trials = jjCurrent;

tmpCorr.(['xSpkCount_win' fieldSuffix]) = xSpkCounts;
tmpCorr.(['ySpkCount_win' fieldSuffix]) = ySpkCounts;
tmpCorr.(['xMeanFr_spkPerSec_win' fieldSuffix]) = xMeanFrWin;
tmpCorr.(['yMeanFr_spkPerSec_win' fieldSuffix]) = yMeanFrWin;

tmpCorr.rho_pval_win = {STATIC_WIN_ALIGN};                    
tmpCorr.rhoRaw = rhoRawCP;
tmpCorr.pvalRaw = pvalRawCP;

try
  tmpCorr = tmpCorr(:);
  for ii=1:numel(tmpCorr)
    spkCorr = [spkCorr; struct2table(tmpCorr(ii),'AsArray',true)]; 
  end
catch me
  me
end

end % parfor : currentPair (cp)

end % fxn : createSpkCorrWithSubSampling()

function [cellPairs] = getCrossAreaPairs(pairsFile)

allCellPairs = load(pairsFile);
allCellPairs = allCellPairs.pairInfoDB;
allCellPairs = allCellPairs(ismember([allCellPairs.X_Monkey],{'D','E'}),:);

idxCrossAreaSEF = (ismember(allCellPairs.X_Area,'SEF') & ismember(allCellPairs.Y_Area,{'FEF','SC'}));
cellPairs = allCellPairs(idxCrossAreaSEF,:);

assert(isequal(cellPairs.X_Session, cellPairs.Y_Session), ...
  'Error: X-Unit sessions and Y-Unit sessions do not match');
fprintf('Done getCrossAreaPairs()\n')

end % util : getCrossAreaPairs()

function [sessionEventTimes] = getSessionEventTimes(trialEventTimesFile)
    sessionEventTimes = load(trialEventTimesFile);
    sessionEventTimes = sessionEventTimes.TrialEventTimesDB;
    fprintf('Done getSessionEventTimes()\n')
end

function [colNames] = getPairColNames()

colNames = {'Pair_UID', ...
    'X_Monkey', 'X_SessionIndex', 'X_Session', ...
    'X_Index', 'Y_Index', ...
    'X_Area',  'Y_Area', ...
    'X_Grade_Vis', 'Y_Grade_Vis', ...
    'X_Grade_Err', 'X_isErrGrade', ...
    'X_Grade_TErr', 'X_isRewGrade'};

end
