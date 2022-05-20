%Fig3.m -- Figure 3 header file
%**Note: Run plot_SDF_ErrChoice.m to get sdfAC sdfAE sdfFC sdfFE

idxArea = ismember(unitData.Area, {'SEF'});
idxMonkey = ismember(unitData.Monkey, {'D','E'});
idxFunction = ismember(unitData.Grade_Err, [-1,1]);
idxKeep = (idxArea & idxMonkey & idxFunction);

unitTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

% Fig3B_EndptSS_Distr(behavData, 'monkey',{'D'})

% Fig3C_Distr_tErrorChoice_SAT( unitTest )
% plot_tSacc2_SAT(behavData, 'monkey','D') %time of second saccade

Fig3D_Barplot_CESignal( unitTest )

% Fig3E_PrCorrective_X_ErrorSignal( behavData , unitTest , spikesTest )

clear idx*

% Fig. S3E-H
% Run script plot_SDF_X_Dir_RF_ErrChoice to calculate ratio rho for Fig.
% S3E. This script also plots individual neuron data (Figs. S3F-H).