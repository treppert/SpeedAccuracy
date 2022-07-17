%% Fig4.m -- Figure 4 header file
% Sessions including neurons signaling timing errors:
% [3 4 5 6 8 9 12 14 15 16]

AREA = {'SEF'};
MONKEY = {'D','E'};
UNIT_PLOT = 60;

NBIN_TE = 1; %binning by timing error
NBIN_dRT = 1; %binning by change in RT
MIN_ISI = 1000;

idxArea = ismember(unitData.Area, AREA);
idxMonkey = ismember(unitData.Monkey, MONKEY);
idxFunction = ismember(unitData.Grade_TErr, [-1,+1]);
% unitTest = unitData(idxArea & idxMonkey & idxFunction,:);
unitTest = unitData(UNIT_PLOT,:);

[sdfTE,tSigTE] = compute_SDF_ErrTime(unitTest, behavData, ...
  'nBin_TE',NBIN_TE, 'nBin_dRT',NBIN_dRT, 'minISI',MIN_ISI);
plot_SDF_ErrTime(sdfTE, unitTest, 'nBin_TE',NBIN_TE, 'nBin_dRT',NBIN_dRT, ...
  'tSig_TE',tSigTE)
% plot_Raster_ErrTime(unitTest, behavData, 'minISI',MIN_ISI)

% Fig1D_Behav_X_Trial_Simple(behavData, 'monkey',MONKEY) %Figure 4A
% plot_tSacc2_X_RTerr(behavData , 'monkey',MONKEY)
% plot_dRT_X_RTerr(behavData, 'monkey',MONKEY)
% plot_RT_X_TrialOutcome(behavData, 'monkey',MONKEY)

% Fig4C_ProbActive_ErrorTime( unitTest )
% plot_tSacc2_ErrTime(behavData , 'monkey',MONKEY)

% sigTE = compute_TESignal_X_dRT(sdfTE, unitTest, 'nBin_TE',NBIN_TE, 'nBin_dRT',NBIN_dRT, 'monkey',{'E'});

% Fig4X_Barplot_TESignalMag(unitTest, sdfAC, sdfAE);
% Fig4X_ErrorSignal_X_Hazard(unitTest, sdfAC, sdfAE)
