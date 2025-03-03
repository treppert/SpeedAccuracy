%% Fig4.m -- Figure 4 header file
% Sessions including neurons signaling timing errors:
% [3 4 5 6 8 9 12 14 15 16]

AREA = {'SEF'};
MONKEY = {'D','E'};

NBIN_TE = 1; %binning by timing error
NBIN_dRT = 4; %binning by change in RT
MIN_ISI = 1000;

idxArea = ismember(unitData.Area, AREA);
idxMonkey = ismember(unitData.Monkey, MONKEY);
idxFunction = ismember(unitData.Grade_TErr, [-1,+1]);

unitTest = unitData(idxArea & idxMonkey & idxFunction,:);
% UNIT_PLOT = 60; unitTest = unitData(UNIT_PLOT,:); %Fig. 4E

%Figure 4E
[sdfTE,tSigTE] = compute_SDF_ErrTime(unitTest, behavData, 'nBin_dRT',NBIN_dRT, 'minISI',MIN_ISI);
% plot_SDF_ErrTime(sdfTE, tSigTE, unitTest, 'nBin_dRT',NBIN_dRT) %Fig. 4E
% plot_Raster_ErrTime(unitTest, behavData, 'minISI',MIN_ISI) %Fig. 4E
%Figure 4F
sigTE = Fig4F_TESignal_X_dRT(sdfTE, unitTest, 'nBin_TE',NBIN_TE, 'nBin_dRT',NBIN_dRT, 'monkey',MONKEY);

%Figure 4A
% plot_Behav_X_Trial(behavData, 'monkey',MONKEY)
%Figures 4B,C
% plot_RT_X_TrialOutcome(behavData, 'monkey',MONKEY)
%Figure 4D
% Fig4D_ProbActive_ErrorTime(unitTest) %Figure 4D
% plot_tSacc2_ErrTime(behavData , 'monkey',MONKEY)


%Response to reviews
% plot_dRT_X_RTerr(behavData, 'monkey',MONKEY)
% plot_ISI_X_RTerr(behavData , 'monkey',MONKEY)

clear idx*
