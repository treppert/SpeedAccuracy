%Fig2.m -- Figure 2 header file
MONKEY = {'D','E'};
AREA = {'SC'};

BASELINE = [-600 50];
VISRESP  = [50 400];
SIGN_EFFECT = +1; % [+1 = F>A]  [-1 = A>F]

idxArea = ismember(unitData.Area, AREA);
idxMonkey = ismember(unitData.Monkey, MONKEY);
idxVisUnit = (abs(unitData.Grade_Vis) >= 3);
idxEffectBL = ismember(unitData.SAT_Effect(:,1), SIGN_EFFECT); %significant SAT effect on baseline
idxEffectVR = ismember(unitData.SAT_Effect(:,2), SIGN_EFFECT); %significant SAT effect on visual response
idxTest = (idxArea & idxMonkey & idxVisUnit & (idxEffectBL | idxEffectVR));
unitTest = unitData(idxTest,:);

% Fig2AD_Plot_SDF_Re_Array(behavData, unitData, 'area',AREA, 'monkey',MONKEY, 'fig','A')

% Fig2BE_SpkCt_X_Trial(behavData, unitTest, 'interval',BASELINE) %Fig. 2B
% Fig2BE_SpkCt_X_Trial(behavData, unitTest, 'interval',VISRESP)  %Fig. 2E

Fig2_SpkCt_After_X_Before(behavData, unitTest)

% Fig2C_plotPupilData_SAT(behavData, pupilData)

% Target discrimination
% plot_Distr_TST_SAT(unitData, 'area',AREA, 'monkey',MONKEY)

clear idx*

%% Compute SAT effect significance at the single-neuron level
% idxArea = ismember(unitData.Area, AREA);
% idxMonkey = ismember(unitData.Monkey, MONKEY);
% idxVisUnit = (unitData.Grade_Vis >= 3);
% idxMark = (idxArea & idxMonkey & idxVisUnit);
% 
% [pvalBL,diffBL] = compute_spkCt_X_Condition(behavData, unitData, 'interval',BASELINE, ...
%   'monkey',MONKEY, 'area',AREA);
% [pvalVR,diffVR] = compute_spkCt_X_Condition(behavData, unitData, 'interval',VISRESP, ...
%   'monkey',MONKEY, 'area',AREA);
% 
% effect_BL = zeros(sum(idxMark),1);
% effect_VR = zeros(sum(idxMark),1);
% idxBL_FgA = ((pvalBL <= .05) & (diffBL > 0)); effect_BL(idxBL_FgA) = +1;
% idxBL_AgF = ((pvalBL <= .05) & (diffBL < 0)); effect_BL(idxBL_AgF) = -1;
% idxVR_FgA = ((pvalVR <= .05) & (diffVR > 0)); effect_VR(idxVR_FgA) = +1;
% idxVR_AgF = ((pvalVR <= .05) & (diffVR < 0)); effect_VR(idxVR_AgF) = -1;
% 
% unitData.SAT_Effect(idxMark, :) = [effect_BL effect_VR];
% clear idx*
