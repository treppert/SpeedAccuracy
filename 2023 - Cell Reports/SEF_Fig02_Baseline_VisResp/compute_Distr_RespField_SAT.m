function [ ] = compute_Distr_RespField_SAT( unitData )
%compute_Distr_RespField_SAT Summary of this function goes here
%   Detailed explanation goes here

idxArea     = ismember(unitData.Area, {'SEF'});
idxVisUnit  = ismember(unitData.Grade_Vis, [-3,-4,+3,+4]);

idxDa = (idxArea & idxVisUnit & ismember(unitData.Monkey, {'D'}));
idxEu = (idxArea & idxVisUnit & ismember(unitData.Monkey, {'E'}));
unitData_Da = unitData(idxDa,:);
unitData_Eu = unitData(idxEu,:);

%collect RF octants across neurons
RespField_Da = unitData_Da.RF;
RespField_Eu = unitData_Eu.RF;

%combine RF octant counts across all units
RF_Da_All = [ RespField_Da{1:end} ];
RF_Eu_All = [ RespField_Eu{1:end} ];

%convert octant to angle for plotting
RF_Da_All = convert_tgt_octant_to_angle( RF_Da_All );
RF_Eu_All = convert_tgt_octant_to_angle( RF_Eu_All );


%% Plotting
NORMALIZATION = 'count';
PLOT_STEP = pi/8;

figure()
subplot(1,2,1, polaraxes); hold on; title('Da')
polarhistogram( RF_Da_All, PLOT_STEP*(-1/2 : 1 : 2*pi/PLOT_STEP-1), 'Normalization',NORMALIZATION, 'FaceColor', 'b')
thetaticks(0:45:315) %tick in degrees

subplot(1,2,2, polaraxes); hold on; title('Eu')
polarhistogram( RF_Eu_All, PLOT_STEP*(-1/2 : 1 : 2*pi/PLOT_STEP-1), 'Normalization',NORMALIZATION, 'FaceColor', 'm')
thetaticks(0:45:315) %tick in degrees

ppretty([5,3])

end % fxn : compute_Distr_RespField_SAT()

