%% Fig6.m -- Figure 6 header file

MONKEY = {'D','E'};
AREA = {'SEF','FEF','SC'};
RHO_TYPE = {'Positive','Negative'};

idxArea = ismember(unitData.Area, AREA);
idxMonkey = ismember(unitData.Monkey, MONKEY);
idxSession = ismember(unitData.SessionIndex, [1,10]);
unitTest = unitData(idxArea & idxMonkey & ~idxSession,:);

% [pairInfoDB, pairSummary] = createSatSefCellPairsInfoDB( unitTest );
% spkCorr = createSpikeCorrWithSubSampling();

%index y-area(s) of interest (FEF, SC, or both)
yArea = {'FEF','SC'};
idxYArea = ismember(spkCorr.Y_Area, yArea);

%select data fields of interest
rscColName = 'rhoRaw'; % static spike count correlation
useCols = {'X_Index', 'Y_Index', ...
    'X_Area',  'Y_Area', ...
    'X_Grade_Vis', 'Y_Grade_Vis', ...
    'X_Grade_Err', 'Y_Grade_Err', ...
    'X_isErrGrade', 'Y_isErrGrade', ...
    'X_Grade_TErr', 'Y_Grade_TErr', ...
    'X_isRewGrade', 'Y_isRewGrade', ...
    'condition', ...
    'alignedName', 'alignedEvent', 'alignedTimeWin', ...
    rscColName};

rscTest = spkCorr(idxYArea,useCols);

% spkCorr__ = Fig6B_SpkCorr_PostResponse( rscTest , MONKEY , RHO_TYPE );
spkCorrVsEpoch( rscTest , rscColName )

clearvars -except MONKEY AREA pairInfoDB pairSummary spkCorr* unitData behavData *InfoDB *Summary
