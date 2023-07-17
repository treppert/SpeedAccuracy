% Fig6.m -- Figure 6 header file

%% Specify trials with poor isolation from each recording session
%cell array -- trial with poor isolation quality (Unit-Data-SAT.xlsx)
trialRemove = cell(16,1); %16 recording sessions
for kk = 1:16; trialRemove{kk} = [1 1]; end
trialRemove{5} = [495 800];
trialRemove{7} = [1 330];
trialRemove{11} = [1029 1200];%SEF   [150 275];%C
trialRemove{12} = [1 150];%SEF     [525 625];%SC
trialRemove{13} = [1776 1849];
trialRemove{16} = [1 100];

%% Signal correlation
% computeSigCorr_X_Session %sig corr values for export to Excel
% plot_SignalCorr_SAT %scatter plots for individual pairs of neurons

%% Noise correlation
% computeNoiseCorr_X_Session %noise corr values for export to Excel
% plot_NoiseCorr_X_Direction %plot noise corr vs direction vs epoch
