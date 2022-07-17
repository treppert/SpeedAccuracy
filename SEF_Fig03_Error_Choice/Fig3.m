%% Fig3.m -- Figure 3 header file
%**Note: Run plot_SDF_ErrChoice.m to get sdfAC sdfAE sdfFC sdfFE
% 
AREA = {'SEF'};
MONKEY = {'D','E'};
UNIT_PLOT = 134;

plot_SDF_ErrChoice(behavData, unitData, 'area',AREA, 'monkey',MONKEY, 'uID',UNIT_PLOT) %Fig. 3A
plot_Raster_ErrChoice(behavData, unitData, 'area',AREA, 'monkey',MONKEY, 'uID',UNIT_PLOT) %Fig. 3A

idxArea = ismember(unitData.Area, AREA);
idxMonkey = ismember(unitData.Monkey, MONKEY);
idxFunction = ismember(unitData.Grade_Err, [-1,1]);
idxKeep = (idxArea & idxMonkey & idxFunction);
unitTest = unitData(idxKeep,:);

% Fig3B_EndptSS_Distr(behavData, 'monkey',MONKEY)

% Fig3C_Distr_tErrorChoice_SAT( unitTest )
% plot_tSacc2_SAT(behavData, 'monkey',MONKEY) %time of second saccade

% Fig3D_Barplot_CESignal( unitTest )

% Fig3E_PrCorrective_X_ErrorSignal( behavData , unitTest )

clear idx*

% Fig. S3E-H
% Run script plot_SDF_X_Dir_RF_ErrChoice to calculate ratio rho for Fig.
% S3E. This script also plots individual neuron data (Figs. S3F-H).
