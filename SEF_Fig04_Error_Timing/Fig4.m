%% Fig4.m -- Figure 4 header file
% Sessions including neurons signaling timing errors:
% [3 4 5 6 8 9 12 14 15 16]

MONKEY = {'D','E'};
AREA = {'SEF'};
idxArea = ismember(unitData.Area, AREA);
idxMonkey = ismember(unitData.Monkey, MONKEY);
idxFunction = ismember(unitData.Grade_TErr, [-1,+1]);
unitTest = unitData(idxArea & idxMonkey & idxFunction,:);

% Fig1D_Behav_X_Trial_Simple(behavData, 'monkey',MONKEY) %Figure 4A
% plot_tSacc2_X_RTerr(behavData , 'monkey',MONKEY)
% plot_dRT_X_RTerr(behavData, 'monkey',MONKEY)
% plot_RT_X_TrialOutcome(behavData, 'monkey',MONKEY)

% NBIN_TE = 1;
% NBIN_dRT = 4;

% [sdfTE,tSigTE] = compute_SDF_ErrTime(unitTest, behavData, ...
%   'nBin_TE',NBIN_TE, 'nBin_dRT',NBIN_dRT, 'minISI',800);

% plot_SDF_ErrTime(sdfTE, unitTest, 'nBin_TE',NBIN_TE, 'nBin_dRT',NBIN_dRT, ...
%   'tSig_TE',tSigTE, 'hide','print')
% Fig4B_Raster_ErrTime(unitTest, behavData, 'minISI',1000)

% Fig4C_ProbActive_ErrorTime( unitTest )
% plot_tSacc2_ErrTime(behavData , 'monkey',MONKEY)

% sigTE = compute_TESignal_X_dRT(sdfTE, unitTest, 'nBin_TE',NBIN_TE, 'nBin_dRT',NBIN_dRT, 'monkey',{'E'});

% Fig4X_Barplot_TESignalMag(unitTest, sdfAC, sdfAE);
% Fig4X_ErrorSignal_X_Hazard(unitTest, sdfAC, sdfAE)
