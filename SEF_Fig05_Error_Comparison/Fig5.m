%% Fig5.m -- Figure 5 header file

%Figure 5 - Spike density function
UNIT_PLOT = 97;
plot_SDF_X_RF_ErrChoice_Simple(behavData, unitData, 'unitID',UNIT_PLOT)
pause(0.1)
plot_SDF_X_RF_ErrTime_Simple(behavData, unitData, 'unitID',UNIT_PLOT)

%Figure S5 - Error signal magnitude
MONKEY = {'D','E'};
AREA = {'SEF'};
idxArea = ismember(unitData.Area, AREA);
idxMonkey = ismember(unitData.Monkey, MONKEY);
idxCE = ismember(unitData.Grade_Err, [-1,+1]); %signals choice error
idxTE = ismember(unitData.Grade_TErr, [-1,+1]); % signals timing error

idxBE = (idxCE & idxTE); %signals both types of error
idxCEO = idxCE & ~idxTE; %signals choice errors only
idxTEO = idxTE & ~idxCE; %signals timing errors only

unitTest = unitData(idxArea & idxMonkey & idxFunction,:);

