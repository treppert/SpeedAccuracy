%% Fig6.m -- Figure 6 header file

%% Create pair information DB
idxArea = ismember(unitData.Area, {'SEF','FEF','SC'});
idxMonkey = ismember(unitData.Monkey, {'D','E'});
idxSession = ismember(unitData.SessionIndex, [1,10]);
unitTest = unitData(idxArea & idxMonkey & ~idxSession,:);
% [pairInfoDB, pairSummary] = createSatSefCellPairsInfoDB( unitTest );

%% Compute spike count correlation
% spkCorr = computeSpkCorr_SAT_SubSample();
% spkCorr = computeSpkCorr_SAT();

%% Indexing
%index by y-area(s) of interest (FEF, SC, or both)
idxYArea = ismember(spkCorr.Y_Area, {'FEF','SC'});
%index by SEF neuron function
idxVis = (abs(spkCorr.X_Grade_Vis) > 2);
idxErrChc = (abs(spkCorr.X_Grade_Err) == 1);
idxErrTime = (abs(spkCorr.X_Grade_TErr) == 1);
spkCorr.AllN = (idxVis | idxErrChc | idxErrTime);
spkCorr.VisualN = (idxVis & ~(idxErrChc | idxErrTime));
spkCorr.ErrChoiceN = idxErrChc;
spkCorr.ErrTimeN = idxErrTime;
%index by monkey
idxMonkey = ismember(spkCorr.monkey, MONKEY);

spkCorrTest = spkCorr(idxYArea & spkCorr.AllN & idxMonkey, :);

%% Post-hoc analysis
RHO_TYPE = {'Positive','Negative'};
NEURON_TYPE = {'AllN'};%{'AllN','VisualN','ErrChoiceN','ErrTimeN'};

Fig6X_SpkCorr_X_Trial(spkCorrTest)

%data fields of interest
useCols = {'Pair_UID', 'X_Monkey', ...
    'X_SessionIndex', 'X_Session', ...
    'X_Index', 'Y_Index', ...
    'X_Area',  'Y_Area', ...
    'X_Grade_Vis', 'Y_Grade_Vis', ...
    'X_Grade_Err', 'Y_Grade_Err', ...
    'X_isErrGrade', 'Y_isErrGrade', ...
    'X_Grade_TErr', 'Y_Grade_TErr', ...
    'X_isRewGrade', 'Y_isRewGrade', ...
    'condition', ...
    'alignedName', 'alignedEvent', 'alignedTimeWin', ...
    'xSpkCount_win_150ms', 'ySpkCount_win_150ms', ...
    'xMeanFr_spkPerSec_win_150ms', 'yMeanFr_spkPerSec_win_150ms', ...
    'rhoRaw', 'pvalRaw', 'signifRaw_05', ...
    'AllN', 'VisualN', 'ErrChoiceN', 'ErrTimeN', ...
    'rhoEstRaw_nTrials_40', 'rhoEstRaw_nTrials_80', ...
    'ci95_nTrials_40', 'ci95_nTrials_80', ...
    'rhoEstRaw_nTrials_40', 'rhoEstRaw_nTrials_80', ...
    'rhoEstSem_nTrials_40', 'rhoEstSem_nTrials_80'};

rscTest = spkCorr(idxYArea,useCols);
Fig6B_SpkCorr_PostResponse( rscTest , MONKEY , RHO_TYPE , NEURON_TYPE )
% spkCorrVsEpoch( rscTest , 'rhoRaw' , NEURON_TYPE )

clearvars -except MONKEY AREA pairInfoDB pairSummary spkCorr* unitData behavData *InfoDB *Summary
