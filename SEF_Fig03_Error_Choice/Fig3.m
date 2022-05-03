%Fig3.m -- Figure 3 header file

idxArea = ismember(unitData.Area, {'SEF'});
idxMonkey = ismember(unitData.Monkey, {'D','E'});
idxFunction = ismember(unitData.Grade_Err, [-1,1]);
idxKeep = (idxArea & idxMonkey & idxFunction);

unitTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

% Fig3B_EndptSS_Distr( behavData )

% Fig3C_Distr_tErrorChoice_SAT( unitTest )
% plot_tSacc2_SAT( behavData ) %time of second saccade

% Fig3D_Barplot_CESignal( unitTest )

% Fig3E_PrCorrective_X_ErrorSignal( behavData , unitTest , spikesTest )

clear idx*
