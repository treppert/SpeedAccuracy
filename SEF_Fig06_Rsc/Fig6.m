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

spkCorr__ = Fig6B_SpkCorr_PostResponse( spkCorr , MONKEY , RHO_TYPE );
% spkCorrVsEpoch

clearvars -except MONKEY AREA pairInfoDB pairSummary spkCorr* unitData behavData *InfoDB *Summary
