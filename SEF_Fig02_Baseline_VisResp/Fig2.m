%Fig2.m -- Figure 2 header file
% BASELINE = [-600,+50];
% VISRESP  = [+50,+400];

idxArea = ismember(unitData.Area, {'SEF','FEF','SC'});
idxMonkey = ismember(unitData.Monkey, {'D','E'});
idxVisUnit = ismember(unitData.Grade_Vis, [+3,+4]);
idxEffectBL = ismember(unitData.SAT_Effect(:,1), +1); %Baseline effect ([+1 = F>A]  [2 = A>F])
idxEffectVR = ismember(unitData.SAT_Effect(:,2), +1); %Visual response effect
idxTest = (idxArea & idxMonkey & idxVisUnit & idxEffectVR);
unitTest = unitData(idxTest,:);    clear idx*

% Fig2AD_Plot_SDF_Re_Array(behavData, unitData, 'area',{'SEF'}, 'monkey',{'D','E'}, 'fig','A')
% Fig2BE_SpkCt_X_Trial(behavData, unitTest, 'interval',BASELINE) %Fig. 2B
% Fig2BE_SpkCt_X_Trial(behavData, unitTest, 'interval',VISRESP)  %Fig. 2E

% Fig2F_SpkCt_After_X_Before(behavData, unitTest)
%Note: Get spkCorr_ from Fig6.m (pairs SEF-SC and SEF-FEF)
% Fig2X_SingleTrialChange_Simultaneous
% Fig2X_SingleTrialChange_NDim


%% Preliminary analyses
% plot_Raster_X_Trial(unitTest, behavData)

%Compute SAT effect significance at the single-neuron level
% effectSAT = compute_spkCt_X_Condition(behavData, unitTest);
% unitData.SAT_Effect(idxTest,:) = effectSAT;


%% Additional analyses
% RF distribution
compute_Distr_RespField_SAT(unitData)

% Target discrimination
% plot_Distr_TST_SAT(unitData, 'area',{'SEF'}, 'monkey',{'D','E'})

% Pupil diameter
% Fig2C_plotPupilData_SAT(behavData, pupilData)
