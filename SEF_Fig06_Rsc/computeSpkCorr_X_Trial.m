% function [spkCorr] = computeSpkCorr_X_Trial()

%% File refs for data to compute Rsc
datasetDir = 'C:\Users\thoma\Dropbox\Speed Accuracy\Data\SpkCorr';

% specify files with data to compute Rsc
pairsFile = fullfile(datasetDir,'PAIR_CellInfoDB.mat');
trialEventTimesFile = fullfile(datasetDir,'SAT_SEF_TrialEventTimesDB.mat');

alignName = {'PostSaccade'}; %{'Baseline','Visual','PostSaccade','PostReward'}
alignEvent = {'SaccadePrimary'}; %'CueOn','CueOn','SaccadePrimary','RewardTime'
alignTimeWin = [-100 500];

trialIndex = (-4:+3);
trialSwitch = identify_condition_switch(behavData);
DIRECTION = 'F2A';

staticWinAlignTs = [0 200]; %PS=[0 200], BL=[-300 -100]

%% Prep for parallel processing
parPool = gcp('nocreate');
nThreads = parPool.NumWorkers;

%%  Load data needed to compute Rsc
crossPairs = getCrossAreaPairs(pairsFile);
sessionEventTimes = getSessionEventTimes(trialEventTimesFile);

N_PAIRS = size(crossPairs,1);
fprintf('Computing Rsc for %i pairs\n', N_PAIRS)
spkCorr = table();

parfor (cp = 1:N_PAIRS,nThreads) %pairs SEF-FEF/SC
  crossPair = crossPairs(cp,:);
  sess = crossPair.X_Session{1};

  %index by trial from condition switch
  kk = crossPair.X_SessionIndex;
  jjSwitch = trialSwitch.(DIRECTION){kk};

  % get spike times
  xSpkTimes = load_spikes_SAT(crossPair.X_Index, 'user','thoma');
  ySpkTimes = load_spikes_SAT(crossPair.Y_Index, 'user','thoma');
  evntTimes = sessionEventTimes(ismember(sessionEventTimes.session,sess),:);
  
  tmp_rsc = struct();
  for tt = 1:numel(trialIndex) %trial number re. switch

    jj = jjSwitch + trialIndex(tt);

    if ismember(alignEvent, 'SaccadePrimary')
      alignTime = evntTimes.CueOn{1} + double(evntTimes.SaccadePrimary{1}(:));
    elseif ismember(alignEvent, 'Baseline')
      alignTime = evntTimes.CueOn{1};
    end

    X_Aligned = SpikeUtils.alignSpikeTimes(xSpkTimes(jj), alignTime(jj), alignTimeWin);
    Y_Aligned = SpikeUtils.alignSpikeTimes(ySpkTimes(jj), alignTime(jj), alignTimeWin);

    tempRast = SpikeUtils.rasters(X_Aligned,alignTimeWin);
    XRasters = tempRast.rasters;

    tempRast = SpikeUtils.rasters(Y_Aligned,alignTimeWin);
    YRasters = tempRast.rasters;

    rasterBins = tempRast.rasterBins;                               
    
    %compute spike counts for SEF(X) and FEF/SC(Y) for this trial epoch
    staticWin = staticWinAlignTs;
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
        tmp_rsc(tt).(cN{c}) = cpTemp.(cN{c});
    end

    tmp_rsc(tt).trialIndex = trialIndex(tt);
    tmp_rsc(tt).alignedName = alignName;
    tmp_rsc(tt).trialNos = jj;
    tmp_rsc(tt).nTrials = numel(jj);

%     fieldSuffix = num2str(range(staticWin),'_%dms'); 
%     tmp_rsc(tt).(['xSpkCount_win' fieldSuffix]) = xSpkCounts;
%     tmp_rsc(tt).(['ySpkCount_win' fieldSuffix]) = ySpkCounts;

%     xMeanFrWin = mean(xSpkCounts{1})*1000/range(staticWin);
%     tmp_rsc(tt).(['xMeanFr_spkPerSec_win' fieldSuffix]) = xMeanFrWin;
%     yMeanFrWin = mean(ySpkCounts{1})*1000/range(staticWin);
%     tmp_rsc(tt).(['yMeanFr_spkPerSec_win' fieldSuffix]) = yMeanFrWin;

    tmp_rsc(tt).rho_pval_win = {staticWin};                    
    tmp_rsc(tt).rhoRaw = rho_pval(1);
    tmp_rsc(tt).pvalRaw = rho_pval(2);

  end % for : trial type (tt)

  try
  tmp_rsc = tmp_rsc(:);
  for ii=1:numel(tmp_rsc)
    spkCorr = [spkCorr; struct2table(tmp_rsc(ii),'AsArray',true)]; 
  end
  catch me
    me
  end

end

% end % fxn : computeSpkCorr_X_Trial ()

function [cellPairs] = getCrossAreaPairs(pairsFile)
allCellPairs = load(pairsFile);
allCellPairs = allCellPairs.pairInfoDB;
cellPairs = allCellPairs(ismember([allCellPairs.X_Monkey],{'D','E'}),:);
end % util : getCrossAreaPairs()

function [sessionEventTimes] = getSessionEventTimes(trialEventTimesFile)
sessionEventTimes = load(trialEventTimesFile);
sessionEventTimes = sessionEventTimes.TrialEventTimesDB;
fprintf('Done getSessionEventTimes()\n')
end % util : getSessionEventTimes()

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
