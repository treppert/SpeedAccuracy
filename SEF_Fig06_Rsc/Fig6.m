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
% computeSpkCorr_X_Trial

%trial-to-trial analysis
% spkCorrA2F = computeSpkCorr_SAT('direction','A2F');
% spkCorrF2A = computeSpkCorr_SAT('direction','F2A');
% Fig6X_SpkCorr_X_Trial(spkCorrA2F, spkCorrF2A, unitData)

%% Post-hoc analysis
% RHO_TYPE = {'Positive','Negative'};
% Fig6B_SpkCorr_PostResponse(rscTest, MONKEY, RHO_TYPE, NEURON_TYPE)

% plot_rsc_X_Epoch( spkCorr )
% plot_rsc_X_FR( spkCorr )

% % spkCorr = organize_rscTable(spkCorr);

%% Specify trials with poor isolation from each recording session
%cell array -- trial with poor isolation quality (Unit-Data-SAT.xlsx)
trialRemove = cell(16,1);
trialRemove{5} = [495 800];
trialRemove{7} = [1 330];
trialRemove{11} = [150 275];
trialRemove{12} = [525 625];
trialRemove{13} = [1776 1849];
trialRemove{16} = [1 100];

%% Signal correlation
% plot_SignalCorr_SAT %scatter plots for individual pairs of neurons
% computeSigCorr_X_Session %sig corr values for export to Excel

%% Noise correlation
% plot_NoiseCorr_SAT %plot noise corr vs direction vs epoch
% computeNoiseCorr_X_Session %noise corr values for export to Excel

%% Correlation
plot_Correlation_X_Epoch
% plot_Correlation_SAT
