function [ ] = plot_SpikeCountXTrial_SAT(uInfo , spikes)
%plot_SpikeCountXTrial_SAT Summary of this function goes here
%   Detailed explanation goes here

SAVEDIR = 'C:\Users\Thomas Reppert\Dropbox\__SEF_SAT_\Figs\SpikeCount-X-Trial\';
AREA = {'SEF','NSEFN'};
MONKEY = {'D','E'};

T_TEST = [-800 0] + 3500;

idxArea = ismember(uInfo.area, AREA);
idxMonkey = ismember(uInfo.monkey, MONKEY);

uInfo = uInfo(idxArea & idxMonkey, :);
spikes = spikes(idxArea & idxMonkey);

NUM_UNITS = size(uInfo, 1);

for uu = 1:NUM_UNITS
  %unit-specific initialization
  unitID = [uInfo.Properties.RowNames{uu}, '-', uInfo.area{uu}];
  numTrials = length(spikes{uu});
  
  %compute spike count for all trials
  sc_uu = cellfun(@(x) sum((x > T_TEST(1)) & (x < T_TEST(2))), spikes{uu});
  
  
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

end % util :: plot_SpikeCountXTrial_SAT()

