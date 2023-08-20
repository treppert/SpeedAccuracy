% Fig6.m -- Figure 6 header file
% Note - To get trials with poor unit isolation for a particular neuron,
% access unitData.mat.

%% Processing of SAT-Local \ Correlation analysis \ Correlation-SAT-Mat.xlsx
% Note - This file contains signal and noise correlations derived from
% session-wise analysis completed in Data \ Correlation-Data-SAT.xlsx.

% plot_Correlation_SAT
% This script computes several different types of plots featured in the
% response to reviewers, including: (a) scatterplots of signal and noise
% correlations in the Fast vs Accurate condition (each dot represents a
% single pair SEF-SC or SEF-FEF); (b) barplot of signal correlation vs
% condition for the VR and PS epochs; and (c) barplot of noise correlation
% vs epoch for each task condition


%% Prepare for post-processing of pairwise correlations
% Load pairDataALL.mat

XAREA = 'SEF';
YAREA = 'SC';

pairData = pairDataALL.Eu;
% pairData = [pairDataALL.Da ; pairDataALL.Eu];

%index pair data
idxXArea = ismember(pairData.XArea, XAREA);
idxYArea = ismember(pairData.YArea, YAREA);
idxXFxn  = ismember(pairData.X_VR, +1);
idxYFxn  = ismember(pairData.Y_VR, +1);

% pairData = pairData(idxXArea & idxYArea & idxXFxn & idxYFxn, :);
pairData = pairData(idxXArea & idxYArea, :);
nPair = size(pairData,1);

% %retrieve RF information
% for pp = 1:nPair
%   uX = pairData.XUnit(pp);
%   uY = pairData.YUnit(pp);
%   pairData.X_VRF(pp) = unitData.VRF(uX);
%   pairData.Y_VRF(pp) = unitData.VRF(uY);
% 
%   %determine whether RFs overlap
%   if any(ismember(pairData.X_VRF{pp}, pairData.Y_VRF{pp}))
%     pairData.RFoverlap(pp) = true;
%   else
%     pairData.RFoverlap(pp) = false;
%   end
% end
% 
% %index by RF overlap
% idxOverlap = pairData.RFoverlap;
% pairData(~idxOverlap, :) = [];
% nPair = size(pairData,1);

%% Compute signal and noise correlations
% computeCorrelation_X_FxnClass

% plot_SignalCorr_SAT_Fig6B
% plot_NoiseCorr_SAT_Fig6B


%% Prior analysis of SAT correlations
% Compute signal correlation by session
% computeSigCorr_X_Session %sig corr values for export to Excel
% plot_SignalCorr_SAT %scatter plots for individual pairs of neurons

% Compute noise correlation by session
% computeNoiseCorr_X_Session %noise corr values for export to Excel
