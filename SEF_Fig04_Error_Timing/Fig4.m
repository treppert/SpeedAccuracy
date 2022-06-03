%% Fig4.m -- Figure 4 header file
MONKEY = {'D'};

%% Behavior: RT and hazard rate
% Fig1D_Behav_X_Trial() %Fig. 4A
% plot_tSacc2_SAT(behavData , 'monkey',MONKEY)
plot_tSacc2_X_RTerr(behavData , 'monkey',MONKEY)

% % These fits were computed with plot_hazard_RTerr()
% pFitMean_Da = [1.595e-6, 1.013e-3, .1588];
% pFitMean_Eu = [3.426e-6, 1.810e-3, .2254];
% hfFit_Da = fittype('S * (1.595e-6*x.^2 + 1.013e-3*x + .1588)', 'independent',{'x'}, 'coefficients',{'S'});
% hfFit_Eu = fittype('S * (3.426e-6*x.^2 + 1.810e-3*x + .2254)', 'independent',{'x'}, 'coefficients',{'S'});
% 
% % Quadratic fit to hazard rate data computed with plot_hazard_RTerr()
% [~,pScale_Da] = plot_hazard_RTerr(behavData, 'monkey',{'D'}, 'hfFit',hfFit_Da);
% [~,pScale_Eu] = plot_hazard_RTerr(behavData, 'monkey',{'E'}, 'hfFit',hfFit_Eu);
% 
% parmFitDa = struct('fit',pFitMean_Da, 'scale',pScale_Da);
% parmFitEu = struct('fit',pFitMean_Eu, 'scale',pScale_Eu);
% clear hfFit_* pFitMean_* pScale_*

% % plotHazardRate(behavData(1:16,:)) *TODO - Debug

%% Physiology
% Notes
% Run plot_SDF_ErrTime.m to compute spike density functions for all neurons
% signaling timing errors.
% Save SDF (sdfAC, sdfAE, sdfFC, sdfFE) in table unitData.
% 
% Run compute_RTerr_Quantiles.m to compute quantiles of RT error.
% Save RT error quantiles in table behavData.
% 

idxArea = ismember(unitData.Area, {'SEF'});
idxMonkey = ismember(unitData.Monkey, {'D','E'});
idxFunction = ismember(unitData.Grade_TErr, [-1,+1]);
idxKeep = (idxArea & idxMonkey & idxFunction);

unitTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

% sigTE = Fig4X_Barplot_TESignalMag(unitTest, sdfAC, sdfAE);
% Fig4C_ProbActive_ErrorTime( unitData )

clear idx* MONKEY
