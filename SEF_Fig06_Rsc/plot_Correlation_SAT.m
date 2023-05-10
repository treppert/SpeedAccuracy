%plot_Correlation_SAT.m

% %load signal correlation values
% rSignal.SC = readmatrix(ROOTDIR_SAT+"Correlation-SAT-Mat.xlsx", "Sheet","SEF-SC", "Range","D5:G49");
% rSignal.FEF = readmatrix(ROOTDIR_SAT+"Correlation-SAT-Mat.xlsx", "Sheet","SEF-FEF", "Range","D5:G74");
% rabsSignal.SC = abs(rSignal.SC);
% rabsSignal.FEF = abs(rSignal.FEF);
% 
% %load noise correlation values
% rNoise.SC = readmatrix(ROOTDIR_SAT+"Correlation-SAT-Mat.xlsx", "Sheet","SEF-SC", "Range","I5:P49");
% rNoise.FEF = readmatrix(ROOTDIR_SAT+"Correlation-SAT-Mat.xlsx", "Sheet","SEF-FEF", "Range","I5:P74");
% rabsNoise.SC = abs(rNoise.SC);
% rabsNoise.FEF = abs(rNoise.FEF);
% 
% %compute mean and SD (signal corr)
% rabsSignal.Mean.SC  = mean(rabsSignal.SC,1);
% rabsSignal.Mean.FEF = mean(rabsSignal.FEF,1);
% rabsSignal.SD.SC  = std(rabsSignal.SC,0,1);
% rabsSignal.SD.FEF = std(rabsSignal.FEF,0,1);
% 
% %compute mean and SD (noise corr)
% rabsNoise.Mean.SC  = mean(rabsNoise.SC,1);
% rabsNoise.Mean.FEF = mean(rabsNoise.FEF,1);
% rabsNoise.SD.SC  = std(rabsNoise.SC,0,1);
% rabsNoise.SD.FEF = std(rabsNoise.FEF,0,1);

%% Plotting - Absolute value of signal correlation
% figure()
% subplot(1,2,1); title("SEF-SC"); hold on % SEF-SC
% bar(rabsSignal.Mean.SC, 0.6, "c", "EdgeColor","k")
% errorbar(1:2, rabsSignal.Mean.SC(1:2), rabsSignal.SD.SC(1:2), "k", "CapSize",0) %Accurate
% errorbar(3:4, rabsSignal.Mean.SC(3:4), rabsSignal.SD.SC(3:4), "k", "CapSize",0) %Fast
% xticks(1:4); xticklabels({'VR','PS','VR','PS'})
% ylabel('Absolute signal correlation')
% 
% subplot(1,2,2); title("SEF-FEF"); hold on % SEF-FEF
% bar(rabsSignal.Mean.FEF, 0.6, "c", "EdgeColor","k")
% errorbar(1:2, rabsSignal.Mean.FEF(1:2), rabsSignal.SD.FEF(1:2), "k", "CapSize",0) %Accurate
% errorbar(3:4, rabsSignal.Mean.FEF(3:4), rabsSignal.SD.FEF(3:4), "k", "CapSize",0) %Fast
% xticks(1:4); xticklabels({'VR','PS','VR','PS'})
% 
% subplot(1,2,1); ylim([0 0.7])
% subplot(1,2,2); ylim([0 0.7])
% 
% ppretty([5,1.2])

%% Plotting - Absolute value of noise correlation
xAcc = 1:4;
xFast = 5:8;

figure()
subplot(1,2,1); title("SEF-SC"); hold on % SEF-SC
bar(rabsNoise.Mean.SC, 0.5, "m", "EdgeColor","k")
errorbar(xAcc,  rabsNoise.Mean.SC(xAcc),  rabsNoise.SD.SC(xAcc), "k", "CapSize",0) %Accurate
errorbar(xFast, rabsNoise.Mean.SC(xFast), rabsNoise.SD.SC(xFast), "k", "CapSize",0) %Fast
xticks(1:8); xticklabels({'VR','PS','VR','PS','VR','PS','VR','PS'})
ylabel('Absolute noise correlation')

subplot(1,2,2); title("SEF-FEF"); hold on % SEF-FEF
bar(rabsNoise.Mean.FEF, 0.5, "m", "EdgeColor","k")
errorbar(xAcc,  rabsNoise.Mean.FEF(xAcc),  rabsNoise.SD.FEF(xAcc), "k", "CapSize",0) %Accurate
errorbar(xFast, rabsNoise.Mean.FEF(xFast), rabsNoise.SD.FEF(xFast), "k", "CapSize",0) %Fast
xticks(1:8); xticklabels({'VR','PS','VR','PS','VR','PS','VR','PS'})

subplot(1,2,1); ylim([0 0.2])
subplot(1,2,2); ylim([0 0.2])

ppretty([5,1.2])
