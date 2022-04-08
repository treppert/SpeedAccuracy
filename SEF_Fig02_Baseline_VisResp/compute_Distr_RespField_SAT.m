function [ ] = compute_Distr_RespField_SAT( unitData )
%compute_Distr_RespField_SAT Summary of this function goes here
%   Detailed explanation goes here

idxArea = ismember(unitData.aArea, {'SEF'});
idxVisUnit = (unitData.Grade_Vis >= 3);

idxDa = (idxArea & idxVisUnit & ismember(unitData.aMonkey, {'D'}));
idxEu = (idxArea & idxVisUnit & ismember(unitData.aMonkey, {'E'}));
unitData_Da = unitData(idxDa,:);
unitData_Eu = unitData(idxEu,:);
NUM_UNIT_DA = sum(idxDa);
NUM_UNIT_EU = sum(idxEu);

%collect RF octant across neurons -- Da
RespField_Da = cell(NUM_UNIT_DA,1);
for uu = 1:NUM_UNIT_DA
  RF_uu = unitData_Da.RF{uu};
  if ismember(9, RF_uu) %RF is omni-directional
    RespField_Da{uu} = (1 : 8);
  else
    RespField_Da{uu} = RF_uu;
  end
end % for : unit(uu)


%collect RF octant across neurons -- Eu
RespField_Eu = cell(NUM_UNIT_EU,1);
for uu = 1:NUM_UNIT_EU
  RF_uu = unitData_Eu.RF{uu};
  if ismember(9, RF_uu) %RF is omni-directional
    RespField_Eu{uu} = (1 : 8);
  else
    RespField_Eu{uu} = RF_uu;
  end
end % for : unit(uu)

%combine RF across all units
RF_Da_All = [ RespField_Da{1:NUM_UNIT_DA} ];
RF_Eu_All = [ RespField_Eu{1:NUM_UNIT_EU} ];

%convert octant to angle for plotting
RF_Da_All = convert_tgt_octant_to_angle( RF_Da_All );
RF_Eu_All = convert_tgt_octant_to_angle( RF_Eu_All );


%% Plotting
PLOT_STEP = pi/8;
figure(); polaraxes(); hold on
polarhistogram( RF_Da_All, PLOT_STEP*(-1/2 : 1 : 2*pi/PLOT_STEP-1), 'Normalization','probability' , 'FaceColor', 'b')
polarhistogram( RF_Eu_All, PLOT_STEP*(-1/2 : 1 : 2*pi/PLOT_STEP-1), 'Normalization','probability' , 'FaceColor', 'm')
thetaticks(0:45:315) %tick in degrees
% rlim([0 20]); rticks(0:10:20)
legend({'Da','Eu'}, 'Location','southeast')
ppretty([3,3])

end % fxn : compute_Distr_RespField_SAT()

