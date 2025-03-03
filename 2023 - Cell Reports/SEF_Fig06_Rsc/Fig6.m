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

XAREA = 'FEF';
YAREA = 'SEF';

% pairData = pairDataALL.Eu;
pairData = [pairDataALL.Da ; pairDataALL.Eu];

%index pair data
idxXArea = ismember(pairData.XArea, XAREA);
idxYArea = ismember(pairData.YArea, YAREA);
idxXFxn  = ismember(pairData.X_VR, +1);
idxYFxn  = ismember(pairData.Y_VR, +1);

pairData = pairData(idxXArea & idxYArea & idxXFxn & idxYFxn, :);
% pairData = pairData(idxXArea & idxYArea, :);
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

%% Figure 6A
%retrieve signal correlations and p-values from pairData
sigAC = pairData.sigAC; nAC = length(sigAC);
sigFC = pairData.sigFC; nFC = length(sigFC);
psigAC = pairData.psig(:,1);
psigFC = pairData.psig(:,3);

iposAC = (sigAC < 0);   iposFC = (sigFC > 0); %indexes of positive correlations
inegAC = (sigAC > 0);   inegFC = (sigFC < 0); %indexes of negative correlations
nposAC = sum(iposAC);   nposFC = sum(iposFC); %counts
nnegAC = sum(inegAC);   nnegFC = sum(inegFC);
fposAC = nposAC / nAC;  fposFC = nposFC / nFC; %fractions
fnegAC = nnegAC / nAC;  fnegFC = nnegFC / nFC;

pvalposAC = psigAC(iposAC); %significance (p-values) of positive correlations
pvalnegAC = psigAC(inegAC); %significance (p-values) of negative correlations
pvalposFC = psigFC(iposFC);
pvalnegFC = psigFC(inegFC);
nsigposAC = sum(pvalposAC < .05);   nsigposFC = sum(pvalposFC < .05); %counts of significance
nsignegAC = sum(pvalnegAC < .05);   nsignegFC = sum(pvalnegFC < .05);
fsigposAC = nsigposAC / nposAC;   fsigposFC = nsigposFC / nposFC; %fractions of significance
fsignegAC = nsignegAC / nnegAC;   fsignegFC = nsignegFC / nnegFC;

%% Prior analysis of SAT correlations
% Compute signal correlation by session
% computeSigCorr_X_Session %sig corr values for export to Excel
% plot_SignalCorr_SAT %scatter plots for individual pairs of neurons

% Compute noise correlation by session
% computeNoiseCorr_X_Session %noise corr values for export to Excel
