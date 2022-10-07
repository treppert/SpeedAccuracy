%Fig2.m -- Figure 2 header file
MONKEY = {'D','E'};
AREA = {'SEF','FEF','SC'};
BASELINE = [-600,+50];
VISRESP  = [+50,+400];
EFFECT_DIR = 1; % [1 = F>A]  [2 = A>F]

idxArea = ismember(unitData.Area, AREA);
idxMonkey = ismember(unitData.Monkey, MONKEY);
idxVisUnit = ismember(unitData.Grade_Vis, [+3,+4]);
idxEffectBL = ismember(unitData.SAT_Effect(:,1), EFFECT_DIR); %significant SAT effect on baseline
idxEffectVR = ismember(unitData.SAT_Effect(:,2), EFFECT_DIR); %significant SAT effect on visual response
% idxTest = (idxArea & idxMonkey & idxVisUnit & (idxEffectBL | idxEffectVR));
idxTest = (idxArea & idxMonkey & idxVisUnit & idxEffectVR);
unitTest = unitData(idxTest,:);

% Fig2AD_Plot_SDF_Re_Array(behavData, unitData, 'area',AREA, 'monkey',MONKEY, 'fig','A')

% Fig2BE_SpkCt_X_Trial(behavData, unitTest, 'interval',BASELINE) %Fig. 2B
% Fig2BE_SpkCt_X_Trial(behavData, unitTest, 'interval',VISRESP)  %Fig. 2E

Fig2_SpkCt_After_X_Before(behavData, unitTest)


%% Analysis of pupil diameter
% Fig2C_plotPupilData_SAT(behavData, pupilData)

%% Preliminary analyses
% plot_Raster_X_Trial(unitTest, behavData)

%Compute SAT effect significance at the single-neuron level
% effectSAT = compute_spkCt_X_Condition(behavData, unitTest);
% unitData.SAT_Effect(idxTest,:) = effectSAT;

%% Additional analyses
% Target discrimination
% plot_Distr_TST_SAT(unitData, 'area',AREA, 'monkey',MONKEY)

clear idx*
