%% Header file -- RT and hazard rate

% These fits were computed with plot_hazard_RTerr()
pFitMean_Da = [1.595e-6, 1.013e-3, .1588];
pFitMean_Eu = [3.426e-6, 1.810e-3, .2254];
hfFit_Da = fittype('S * (1.595e-6*x.^2 + 1.013e-3*x + .1588)', 'independent',{'x'}, 'coefficients',{'S'});
hfFit_Eu = fittype('S * (3.426e-6*x.^2 + 1.810e-3*x + .2254)', 'independent',{'x'}, 'coefficients',{'S'});

% Quadratic fit to hazard rate data computed with plot_hazard_RTerr()
[~,pScale_Da] = plot_hazard_RTerr(behavData, 'monkey',{'D'}, 'hfFit',hfFit_Da);
[~,pScale_Eu] = plot_hazard_RTerr(behavData, 'monkey',{'E'}, 'hfFit',hfFit_Eu);

parmFitDa = struct('fit',pFitMean_Da, 'scale',pScale_Da);
parmFitEu = struct('fit',pFitMean_Eu, 'scale',pScale_Eu);
clear hfFit_* pFitMean_* pScale_*

clear idx*
