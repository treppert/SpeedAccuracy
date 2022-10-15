%% Fig3.m -- Figure 3 header file
%**Note: Run plot_SDF_ErrChoice.m to get sdfAC sdfAE sdfFC sdfFE
% 
AREA = {'SEF'};
MONKEY = {'D','E'};
UNIT_PLOT = 134;

% plot_SDF_ErrChoice(behavData, unitData, 'area',AREA, 'monkey',MONKEY, 'uID',UNIT_PLOT) %Fig. 3A
% plot_Raster_ErrChoice(behavData, unitData, 'area',AREA, 'monkey',MONKEY, 'uID',UNIT_PLOT) %Fig. 3A

idxArea = ismember(unitData.Area, AREA);
idxMonkey = ismember(unitData.Monkey, MONKEY);
idxFunction = ismember(unitData.Grade_Err, [-1,1]);
idxKeep = (idxArea & idxMonkey & idxFunction);
unitTest = unitData(idxKeep,:);
clear idx*

%Figures 3B, S3A
% Fig3B_EndptSS_Distr(behavData, 'monkey',MONKEY)

%Figures 3C, S3B,C,D
% Fig3C_Distr_tErrorChoice_SAT( unitTest )
% Fig3D_Barplot_CESignal( unitTest )

%Figures S3E-H
% Run script plot_SDF_X_Dir_RF_ErrChoice to calculate ratio rho for Fig.
% S3E. This script also plots individual neuron data (Figs. S3F-H).

%Response to reviews
plot_ISI_X_Sacc2Endpt(behavData)
% plot_SpkCt_X_Sacc2Endpt(behavData, unitTest)
