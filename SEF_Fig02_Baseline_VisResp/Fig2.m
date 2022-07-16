%Fig2.m -- Figure 2 header file
MONKEY = {'D'};
AREA = {'SEF'};

BASELINE = [-600 50];
VISRESP  = [50 400];
EFFECT = 'FgA';

% Fig2AD_Plot_SDF_Re_Array(behavData, unitData, 'area',AREA, 'monkey',MONKEY, 'fig','A')

Fig2_plot_SpkCt_X_Trial(behavData, unitData, 'interval',BASELINE, 'monkey',MONKEY, ...
  'effect',EFFECT, 'area',AREA) %Fig. 2B
Fig2_plot_SpkCt_X_Trial(behavData, unitData, 'interval',VISRESP, 'monkey',MONKEY, ...
  'effect',EFFECT, 'area',AREA) %Fig. 2E

% Fig2C_plotPupilData_SAT(behavData, pupilData)

% Target discrimination
% plot_Distr_TST_SAT(unitData, 'area',AREA, 'monkey',MONKEY)


%% Compute SAT effect significance at the single-neuron level
return
idxArea = ismember(unitData.Area, AREA);
idxMonkey = ismember(unitData.Monkey, MONKEY);
idxVisUnit = (unitData.Grade_Vis >= 3);
idxMark = (idxArea & idxMonkey & idxVisUnit);

[pvalBL,diffBL] = compute_spkCt_X_Condition(behavData, unitData, 'interval',BASELINE, ...
  'monkey',MONKEY, 'area',AREA);
[pvalVR,diffVR] = compute_spkCt_X_Condition(behavData, unitData, 'interval',VISRESP, ...
  'monkey',MONKEY, 'area',AREA);

effect_BL = zeros(sum(idxMark),1);
effect_VR = zeros(sum(idxMark),1);
idxBL_FgA = ((pvalBL <= .05) & (diffBL > 0)); effect_BL(idxBL_FgA) = +1;
idxBL_AgF = ((pvalBL <= .05) & (diffBL < 0)); effect_BL(idxBL_AgF) = -1;
idxVR_FgA = ((pvalVR <= .05) & (diffVR > 0)); effect_VR(idxVR_FgA) = +1;
idxVR_AgF = ((pvalVR <= .05) & (diffVR < 0)); effect_VR(idxVR_AgF) = -1;

unitData.SAT_Effect(idxMark, :) = [effect_BL effect_VR];
clear idx*
