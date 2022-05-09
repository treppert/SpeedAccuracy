%Fig4.m -- Figure 4 header file
%**Note: Run plot_SDF_ErrTime.m to get sdfAC sdfAE sdfFC sdfFE errLim_Acc

idxArea = ismember(unitData.Area, {'SEF'});
idxMonkey = ismember(unitData.Monkey, {'D','E'});
idxFunction = ismember(unitData.Grade_TErr, [-1,1]);
idxKeep = (idxArea & idxMonkey & idxFunction);

unitTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

% Fig. 4A: Use Fig1D_Behav_X_Trial()

% sigTE = Fig4X_Barplot_TESignalMag(unitTest, sdfAC, sdfAE);
% Fig4C_ProbActive_ErrorTime( unitData )

[~,pHF_Scale] = plot_hazard_RTerr(behavData, 'monkey',MONKEY);
Fig4D_TESignal_X_TEMagnitude( unitTest , sdfAC , sdfAE , errLim_Acc , pHF_Scale )

clear idx*
