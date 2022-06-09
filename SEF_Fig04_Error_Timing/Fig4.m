%% Fig4.m -- Figure 4 header file
% Sessions including neurons signaling timing errors:
% [3 4 5 6 8 9 12 14 15 16]
% 

MONKEY = {'D','E'};  AREA = {'SEF'};
idxArea = ismember(unitData.Area, AREA);
idxMonkey = ismember(unitData.Monkey, MONKEY);
idxFunction = ismember(unitData.Grade_TErr, [-1,+1]);
unitTest = unitData(idxArea & idxMonkey & idxFunction,:);

% Fig4A_ErrRate_X_Trial(behavData, 'monkey',MONKEY)
% plot_tSacc2_X_RTerr(behavData , 'monkey',MONKEY)
% plot_dRT_X_RTerr(behavData, 'monkey',MONKEY)

NBIN_TE = 1;
NBIN_dRT = 5;

[sdfTE,tSigTE] = compute_SDF_ErrTime(unitTest, behavData, ...
  'nBin_TE',NBIN_TE, 'nBin_dRT',NBIN_dRT, 'minISI',600);

% plot_SDF_ErrTime(sdfTE, unitTest, 'nBin_TE',NBIN_TE, 'nBin_dRT',NBIN_dRT, ...
%   'tSig_TE',tSigTE, 'significant')
% Fig4B_Raster_ErrTime(unitTest, behavData, 'minISI',1000)

% Fig4C_ProbActive_ErrorTime( unitTest )
% plot_tSacc2_ErrTime(behavData , 'monkey',MONKEY)

sigTE = compute_TESignal_X_dRT(sdfTE, unitTest, 'nBin_TE',NBIN_TE, 'nBin_dRT',NBIN_dRT);

% Fig4X_Barplot_TESignalMag(unitTest, sdfAC, sdfAE);
% Fig4X_ErrorSignal_X_Hazard(unitTest, sdfAC, sdfAE)

%% RT and hazard rate

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

clear idx* MONKEY AREA
