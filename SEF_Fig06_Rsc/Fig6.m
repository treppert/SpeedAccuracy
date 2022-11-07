% Fig6.m -- Figure 6 header file

%% Create pair information DB
% idxArea = ismember(unitData.Area, {'SEF','FEF','SC'});
% idxMonkey = ismember(unitData.Monkey, {'D','E'});
% idxSession = ismember(unitData.SessionIndex, [1,10]);
% unitTest = unitData(idxArea & idxMonkey & ~idxSession,:);
% [pairInfoDB, pairSummary] = createSatSefCellPairsInfoDB( unitTest );
% (!)Note - Follow this up by filtering out non-task-relevant neurons

%% Compute spike count correlation
% spkCorr = computeSpkCorr_SAT_SubSample(); %sub-sampling for bar plots
% spkCorr = computeSpkCorr_X_Outcome(); %no sub-sampling

%trial-to-trial analysis
% spkCorrA2F = computeSpkCorr_SAT('direction','A2F');
% spkCorrF2A = computeSpkCorr_SAT('direction','F2A');
% Fig6X_SpkCorr_X_Trial(spkCorrA2F, spkCorrF2A)

%% Indexing
%index by y-area(s) of interest (FEF, SC, or both)
% idxYArea = ismember(spkCorr.Y_Area, {'FEF','SC'});
%index by monkey
% idxMonkey = ismember(spkCorr.X_Monkey, {'D','E'});

%% Post-hoc analysis
% RHO_TYPE = {'Positive','Negative'};
% Fig6B_SpkCorr_PostResponse(rscTest, MONKEY, RHO_TYPE, NEURON_TYPE)

plot_rsc_X_Epoch( spkCorr )
plot_rsc_X_FR( spkCorr )

clear idx*

% % spkCorr = organize_rscTable(spkCorr);
