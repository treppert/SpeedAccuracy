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
pScale_Da = ones(9,1); %TODO - update with correct values
pScale_Eu = ones(7,1); %TODO - update
pScale_All = [pScale_Da; pScale_Eu];
pScale = pScale_All(iSession);

% Create inline function to transform RT to instantaneous hazard rate
hTransform = @(rt,pQuad,pScale) 'pScale * (pQuad(1)*rt.^2 + pQuad(2)*rt + pQuad(3))';

% Transforation RT to hazard rate h(t)
haz = hTransform(RT, pQuad, pScale);

end %fxn : transform_RT2hazard()
