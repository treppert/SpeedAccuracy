%% Fig6.m -- Figure 6 header file

%% Create pair information DB
% idxArea = ismember(unitData.Area, {'SEF','FEF','SC'});
% idxMonkey = ismember(unitData.Monkey, {'D','E'});
% idxSession = ismember(unitData.SessionIndex, [1,10]);
% unitTest = unitData(idxArea & idxMonkey & ~idxSession,:);
% [pairInfoDB, pairSummary] = createSatSefCellPairsInfoDB( unitTest );

%% Compute spike count correlation
% spkCorr = computeSpkCorr_SAT_SubSample(); %sub-sampling for bar plots
% spkCorr = computeSpkCorr_X_Outcome(); %no sub-sampling
% spkCorr = computeSpkCorr_SAT(); %trial-to-trial analysis

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
idxMonkey = ismember(spkCorr.X_Monkey, {'D','E'});

rscTest = spkCorr(idxYArea & spkCorr.AllN & idxMonkey, :);

%% Post-hoc analysis
RHO_TYPE = {'Positive','Negative'};
NEURON_TYPE = {'AllN'};%{'AllN','VisualN','ErrChoiceN','ErrTimeN'};

% Fig6X_SpkCorr_X_Trial(rscTest)
% Fig6B_SpkCorr_PostResponse(rscTest, MONKEY, RHO_TYPE, NEURON_TYPE)
spkCorrVsEpoch(rscTest, 'rhoRaw', NEURON_TYPE)

clearvars -except MONKEY AREA pairInfoDB pairSummary spkCorr* unitData behavData *InfoDB *Summary
