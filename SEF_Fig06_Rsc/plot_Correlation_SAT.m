%plot_Correlation_SAT.m

%load signal correlation values
rSignal.SC = readmatrix(ROOTDIR_SAT+"Correlation-SAT-Mat.xlsx", "Sheet","SEF-SC", "Range","D5:G49");
rSignal.FEF = readmatrix(ROOTDIR_SAT+"Correlation-SAT-Mat.xlsx", "Sheet","SEF-FEF", "Range","D5:G74");
rabsSignal.SC = abs(rSignal.SC);
rabsSignal.FEF = abs(rSignal.FEF);

%load noise correlation values
rNoise.SC = readmatrix(ROOTDIR_SAT+"Correlation-SAT-Mat.xlsx", "Sheet","SEF-SC", "Range","I5:P49");
rNoise.FEF = readmatrix(ROOTDIR_SAT+"Correlation-SAT-Mat.xlsx", "Sheet","SEF-FEF", "Range","I5:P74");
rabsNoise.SC = abs(rNoise.SC);
rabsNoise.FEF = abs(rNoise.FEF);

%compute mean and SD (signal corr)
rabsSignal.Mean.SC  = mean(rabsSignal.SC,1);
rabsSignal.Mean.FEF = mean(rabsSignal.FEF,1);
rabsSignal.SD.SC  = std(rabsSignal.SC,0,1);
rabsSignal.SD.FEF = std(rabsSignal.FEF,0,1);

%compute mean and SD (noise corr)
rabsNoise.Mean.SC  = mean(rabsNoise.SC,1);
rabsNoise.Mean.FEF = mean(rabsNoise.FEF,1);
rabsNoise.SD.SC  = std(rabsNoise.SC,0,1);
rabsNoise.SD.FEF = std(rabsNoise.FEF,0,1);

%compute fraction positive (signal corr)
frPosSignal.SC  = sum(rSignal.SC > 0, 1) / size(rSignal.SC,1);
frPosSignal.FEF = sum(rSignal.FEF > 0, 1) / size(rSignal.FEF,1);

%compute fraction positive (noise corr)
frPosNoise.SC  = sum(rNoise.SC > 0, 1) / size(rNoise.SC,1);
frPosNoise.FEF = sum(rNoise.FEF > 0, 1) / size(rNoise.FEF,1);

FACEALPHA = 0.5;
TXTFORMAT = "%2.1f";

%% Plot - Scatter - Signal correlation
if (false)
figure()
subplot(1,2,1); title("VR epoch"); hold on
scatter(rSignal.SC(:,1),  rSignal.SC(:,3), 20, "magenta", "filled", "o", "MarkerFaceAlpha",FACEALPHA)
scatter(rSignal.FEF(:,1), rSignal.FEF(:,3), 20, "blue", "filled", "o", "MarkerFaceAlpha",FACEALPHA)
plot([-1 +1], [-1 +1], 'k-', "LineWidth",0.5)
xlabel("Signal corr - Accurate"); xtickformat(TXTFORMAT)
ylabel("Signal corr - Fast"); ytickformat(TXTFORMAT)

subplot(1,2,2); title("PS epoch"); hold on
scatter(rSignal.SC(:,2),  rSignal.SC(:,4), 20, "magenta", "filled", "o", "MarkerFaceAlpha",FACEALPHA)
scatter(rSignal.FEF(:,2), rSignal.FEF(:,4), 20, "blue", "filled", "o", "MarkerFaceAlpha",FACEALPHA)
plot([-1 +1], [-1 +1], 'k-', "LineWidth",0.5)
xlabel("Signal corr - Accurate"); xtickformat(TXTFORMAT)
ytickformat(TXTFORMAT)
ppretty([5.4,2]); drawnow
end

%% Plot - Scatter - Noise correlation
if (false)
rNoiseSC_Acc  = mean(rNoise.SC(:,1:4),2);
rNoiseSC_Fast = mean(rNoise.SC(:,5:8),2);
rNoiseFEF_Acc  = mean(rNoise.FEF(:,1:4),2);
rNoiseFEF_Fast = mean(rNoise.FEF(:,5:8),2);

figure(); hold on
scatter(rNoiseSC_Acc,  rNoiseSC_Fast,  20, "magenta", "filled", "o", "MarkerFaceAlpha",FACEALPHA)
scatter(rNoiseFEF_Acc, rNoiseFEF_Fast, 20, "blue", "filled", "o", "MarkerFaceAlpha",FACEALPHA)
plot([-.2 +.4], [-.2 +.4], 'k-', "LineWidth",0.5)
xlabel("Noise corr - Accurate"); xtickformat(TXTFORMAT)
ylabel("Noise corr - Fast"); ytickformat(TXTFORMAT)
ppretty([2.4,2]); drawnow
end

%% Plot - Scatter - Signal vs noise correlation
if (false)
figure()
subplot(2,2,3); title("Accurate"); hold on
scatter(rSignal.SC(:,2),  rNoiseSC_Acc,  20, "magenta", "filled", "o", "MarkerFaceAlpha",FACEALPHA)
scatter(rSignal.FEF(:,2), rNoiseFEF_Acc, 20, "blue", "filled", "o", "MarkerFaceAlpha",FACEALPHA)
xlabel("Signal corr - PS"); xtickformat(TXTFORMAT)
ylabel("Noise corr"); ytickformat(TXTFORMAT)

subplot(2,2,4); title("Fast"); hold on
scatter(rSignal.SC(:,4),  rNoiseSC_Fast,  20, "magenta", "filled", "o", "MarkerFaceAlpha",FACEALPHA)
scatter(rSignal.FEF(:,4), rNoiseFEF_Fast, 20, "blue", "filled", "o", "MarkerFaceAlpha",FACEALPHA)
xlabel("Signal corr - PS"); xtickformat(TXTFORMAT)
ytickformat(TXTFORMAT)
ppretty([5.4,4.8]); drawnow
end

%% Plot - Fraction positive (signal correlation)
if (false)
figure()
subplot(1,2,1); title("SEF-SC"); hold on % SEF-SC
bar(frPosSignal.SC, 0.6, "c", "EdgeColor","none"); yline(0.5, 'k')
xticks(1:4); xticklabels({'VR','PS','VR','PS'})
ylabel('Frac. positive signal corr.'); ytickformat('%2.1f')

subplot(1,2,2); title("SEF-FEF"); hold on % SEF-FEF
bar(frPosSignal.FEF, 0.6, "c", "EdgeColor","none"); yline(0.5, 'k')
xticks(1:4); xticklabels({'VR','PS','VR','PS'})
ytickformat('%2.1f')

ppretty([5,1.2]); drawnow
end

%% Plot - Fraction positive (noise correlation)
if (false)
xAcc = 1:4;
xFast = 5:8;

figure()
subplot(1,2,1); title("SEF-SC"); hold on % SEF-SC
bar(frPosNoise.SC, 0.5, "m", "EdgeColor","none"); yline(0.5, 'k')
xticks(1:8); xticklabels({'BL','VR','PS','PR','BL','VR','PS','PR'})
ylabel('Frac. positive signal corr.'); ytickformat('%2.1f')

subplot(1,2,2); title("SEF-FEF"); hold on % SEF-FEF
bar(frPosNoise.FEF, 0.5, "m", "EdgeColor","none"); yline(0.5, 'k')
xticks(1:8); xticklabels({'BL','VR','PS','PR','BL','VR','PS','PR'})
ytickformat('%2.1f')

ppretty([5,1.2]); drawnow
end

%% Plot - Absolute value of signal correlation
if (false)
figure()
subplot(1,2,1); title("SEF-SC"); hold on % SEF-SC
bar(rabsSignal.Mean.SC, 0.6, "c", "EdgeColor","none")
errorbar(1:2, rabsSignal.Mean.SC(1:2), rabsSignal.SD.SC(1:2), "k", "CapSize",0) %Accurate
errorbar(3:4, rabsSignal.Mean.SC(3:4), rabsSignal.SD.SC(3:4), "k", "CapSize",0) %Fast
xticks(1:4); xticklabels({'VR','PS','VR','PS'})
ylabel('Absolute signal correlation'); ytickformat('%2.1f')

subplot(1,2,2); title("SEF-FEF"); hold on % SEF-FEF
bar(rabsSignal.Mean.FEF, 0.6, "c", "EdgeColor","none")
errorbar(1:2, rabsSignal.Mean.FEF(1:2), rabsSignal.SD.FEF(1:2), "k", "CapSize",0) %Accurate
errorbar(3:4, rabsSignal.Mean.FEF(3:4), rabsSignal.SD.FEF(3:4), "k", "CapSize",0) %Fast
xticks(1:4); xticklabels({'VR','PS','VR','PS'})
ytickformat('%2.1f')

subplot(1,2,1); ylim([0 0.7])
subplot(1,2,2); ylim([0 0.7])

ppretty([5,1.2]); drawnow
end
%% Plot - Absolute value of noise correlation
if (false)
xAcc = 1:4;
xFast = 5:8;

figure()
subplot(1,2,1); title("SEF-SC"); hold on % SEF-SC
bar(rabsNoise.Mean.SC, 0.5, "m", "EdgeColor","none")
errorbar(xAcc,  rabsNoise.Mean.SC(xAcc),  rabsNoise.SD.SC(xAcc), "k", "CapSize",0) %Accurate
errorbar(xFast, rabsNoise.Mean.SC(xFast), rabsNoise.SD.SC(xFast), "k", "CapSize",0) %Fast
xticks(1:8); xticklabels({'BL','VR','PS','PR','BL','VR','PS','PR'})
ylabel('Absolute noise correlation'); ytickformat('%2.1f')

subplot(1,2,2); title("SEF-FEF"); hold on % SEF-FEF
bar(rabsNoise.Mean.FEF, 0.5, "m", "EdgeColor","none")
errorbar(xAcc,  rabsNoise.Mean.FEF(xAcc),  rabsNoise.SD.FEF(xAcc), "k", "CapSize",0) %Accurate
errorbar(xFast, rabsNoise.Mean.FEF(xFast), rabsNoise.SD.FEF(xFast), "k", "CapSize",0) %Fast
xticks(1:8); xticklabels({'BL','VR','PS','PR','BL','VR','PS','PR'})
ytickformat('%2.1f')

subplot(1,2,1); ylim([0 0.3])
subplot(1,2,2); ylim([0 0.3])

ppretty([5,1.2]); drawnow
end
