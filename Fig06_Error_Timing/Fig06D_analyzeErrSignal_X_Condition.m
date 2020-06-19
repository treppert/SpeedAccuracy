function [ ] = Fig06D_analyzeErrSignal_X_Condition( unitInfo , unitStats )
%Fig06D_analyzeErrSignal_X_Condition 
%   Detailed explanation goes here
% 

idxArea = ismember(unitInfo.area, {'SEF'});
idxMonkey = ismember(unitInfo.monkey, {'D','E'});
idxRewUnit = (abs(unitInfo.rewGrade) >= 2);
unitTest = (idxArea & idxMonkey & idxRewUnit);

NUM_CELLS = sum(unitTest);
unitStats = unitStats(unitTest,:);

%gather signal latency
lat_Acc = unitStats.TimingErrorSignal_Time(:,1);
lat_Fast = unitStats.TimingErrorSignal_Time(:,3);
%gather signal magnitude
mag_Acc = abs(unitStats.TimingErrorSignal_Magnitude(:,1));
mag_Fast = abs(unitStats.TimingErrorSignal_Magnitude(:,2));

%only keep neurons that signaled during both conditions
idxNaN = isnan(lat_Fast);
lat_Acc(idxNaN) = [];    mag_Acc(idxNaN) = [];
lat_Fast(idxNaN) = [];   mag_Fast(idxNaN) = [];
NUM_CELLS = NUM_CELLS - sum(idxNaN);

%calculate mean and s.e.m.
mu_lat_Acc = mean(lat_Acc);     se_lat_Acc = std(lat_Acc) / sqrt(NUM_CELLS);
mu_lat_Fast = mean(lat_Fast);   se_lat_Fast = std(lat_Fast) / sqrt(NUM_CELLS);
mu_mag_Acc = mean(mag_Acc);     se_mag_Acc = std(mag_Acc) / sqrt(NUM_CELLS);
mu_mag_Fast = mean(mag_Fast);   se_mag_Fast = std(mag_Fast) / sqrt(NUM_CELLS);

%% Plotting - Barplot
figure()

subplot(1,2,1); hold on %Latency
bar(1, mu_lat_Acc, 0.8, 'FaceColor','r', 'LineWidth',0.25)
bar(2, mu_lat_Fast, 0.8, 'FaceColor',[0 .7 0], 'LineWidth',0.25)
errorbar((1:2), [mu_lat_Acc mu_lat_Fast], [se_lat_Acc se_lat_Fast], 'Color','k', 'CapSize',0)

subplot(1,2,2); hold on %Magnitude
bar(1, mu_mag_Acc, 0.8, 'FaceColor','r', 'LineWidth',0.25)
bar(2, mu_mag_Fast, 0.8, 'FaceColor',[0 .7 0], 'LineWidth',0.25)
errorbar((1:2), [mu_mag_Acc mu_mag_Fast], [se_mag_Acc se_mag_Fast], 'Color','k', 'CapSize',0)

ppretty([3,3], 'XMinorTick','off')

%% Stats - t-test
fprintf('Signal latency:\n')
ttestTom(lat_Acc, lat_Fast, 'paired')
fprintf('Signal magnitude:\n')
ttestTom(mag_Acc, mag_Fast, 'paired')

end % fxn : Fig06D_analyzeErrSignal_X_Condition ()

