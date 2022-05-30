function [ haz ] = transform_RT2hazard( RT , iSession )
%UNTITLED Summary of this function goes here

% Fit to mean relationship between RT and hazard (Accurate condition)
if (iSession < 10)
  pQuad = [1.595e-6, 1.013e-3, .1588]; %Da
else
  pQuad = [3.426e-6, 1.810e-3, .2254]; %Eu
end
% hfFit_Da = fittype('S * (1.595e-6*x.^2 + 1.013e-3*x + .1588)', 'independent',{'x'}, 'coefficients',{'S'});
% hfFit_Eu = fittype('S * (3.426e-6*x.^2 + 1.810e-3*x + .2254)', 'independent',{'x'}, 'coefficients',{'S'});

% Fit to single-session data with scaling factor -- Allow for variability
% across recording sessions
pScale_Da = [1.7436, 1.3636, 1.0670, 0.7963, 1.2014, 0.6759, 0.7740, 0.8387, 0.5455];
pScale_Eu = [1.4213, 0.9540, 1.5354, 0.6588, 0.9437, 0.6250, 0.8612];
pScale_All = [pScale_Da; pScale_Eu];
pScale = pScale_All(iSession);

% Create inline function to transform RT to instantaneous hazard rate
hTransform = @(rt,pQuad,pScale) 'pScale * (pQuad(1)*rt.^2 + pQuad(2)*rt + pQuad(3))';

% Transforation RT to hazard rate h(t)
haz = hTransform(RT, pQuad, pScale);

end %fxn : transform_RT2hazard()
