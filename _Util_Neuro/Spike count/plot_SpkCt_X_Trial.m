function [ ] = plot_SpkCt_X_Trial( unitData , spikesSAT )
%plot_SpkCt_X_Trial Summary of this function goes here
%   Detailed explanation goes here

SAVEDIR = 'C:\Users\Thomas Reppert\Dropbox\__SEF_SAT_\Figs\SpikeCount-X-Trial\';
AREA = {'SEF'};
MONKEY = {'D','E'};

T_TEST = [-800 0] + 3500;

idxArea = ismember(unitData.aArea, AREA);
idxMonkey = ismember(unitData.aMonkey, MONKEY);

unitData = unitData(idxArea & idxMonkey, :);
spikesSAT = spikesSAT(idxArea & idxMonkey);

NUM_UNITS = size(unitData, 1);

for uu = 1:NUM_UNITS
  %unit-specific initialization
  unitID = [unitData.Properties.RowNames{uu}, '-', unitData.aArea{uu}];
  numTrials = length(spikesSAT{uu});
  
  %compute spike count for all trials
  sc_uu = cellfun(@(x) sum((x > T_TEST(1)) & (x < T_TEST(2))), spikesSAT{uu});
  
  
  %% Plotting
  figure(); hold on
  plot(sc_uu, 'Color','k', 'LineWidth',1.0)
  
  xlim([0 numTrials])
  ylabel('Baseline spike count')
  xlabel('Trial')
  
  title(unitID)
  ppretty([10,3])
  
  print([SAVEDIR, unitID,'.tif'], '-dtiff')
  pause(0.1); close(); pause(0.1)
  
end % for : units(uu)

end % util :: plot_SpkCt_X_Trial()

