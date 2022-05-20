%Fig4.m -- Figure 4 header file
%**Note: Run plot_SDF_ErrTime.m to get sdfAC sdfAE sdfFC sdfFE errLim_Acc

%% Behavior: RT and hazard rate
%Fig. 4A: Use Fig1D_Behav_X_Trial()

%These fits were computed with plot_hazard_RTerr()
% pFitMean_Da = [1.595e-6, 1.013e-3, .1588];
% pFitMean_Eu = [3.426e-6, 1.810e-3, .2254];
% hfFit_Da = fittype('S * (1.595e-6*x.^2 + 1.013e-3*x + .1588)', 'independent',{'x'}, 'coefficients',{'S'});
% hfFit_Eu = fittype('S * (3.426e-6*x.^2 + 1.810e-3*x + .2254)', 'independent',{'x'}, 'coefficients',{'S'});

%Quadratic fit to hazard rate data computed with plot_hazard_RTerr()
% [~,pScale_Da] = plot_hazard_RTerr(behavData, 'monkey',{'D'}, 'hfFit',hfFit_Da);
% [~,pScale_Eu] = plot_hazard_RTerr(behavData, 'monkey',{'E'}, 'hfFit',hfFit_Eu);

% parmFitDa = struct('fit',pFitMean_Da, 'scale',pScale_Da);
% parmFitEu = struct('fit',pFitMean_Eu, 'scale',pScale_Eu);

%% Physiology
idxArea = ismember(unitData.Area, {'SEF'});
idxMonkey = ismember(unitData.Monkey, {'D','E'});
idxFunction = ismember(unitData.Grade_TErr, [-1,+1]);
idxKeep = (idxArea & idxMonkey & idxFunction);

unitTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);

%compute mean spike density function for interval of interest
% plot_SDF_ErrTime

%compute limits to RT error
% compute_RTerr_Quantiles

% sigTE = Fig4X_Barplot_TESignalMag(unitTest, sdfAC, sdfAE);
% Fig4C_ProbActive_ErrorTime( unitData )

% Fig4D_TESignal_X_TEMagnitude(unitTest, sdfAC, sdfAE, errLim_Acc, pHF_Scale, 'sessHighlight',16)
for kk = 3:15
  Fig4X_ErrorSignal_X_Hazard(unitTest, parmFitDa, parmFitEu, 'sessHighlight',kk)
end

clear idx* MONKEY



% for uu = 1:25
%   unitData.sdfAC_TE{idxKeep(uu)} = sdfAC{uu};
%   unitData.sdfAE_TE{idxKeep(uu)} = sdfAE{uu};
%   unitData.sdfFC_TE{idxKeep(uu)} = sdfFC{uu};
%   unitData.sdfFE_TE{idxKeep(uu)} = sdfFE{uu};
% end
