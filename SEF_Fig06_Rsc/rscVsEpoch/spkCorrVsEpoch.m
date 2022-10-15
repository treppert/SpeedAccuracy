function [ ] = spkCorrVsEpoch( rsc_Acc , rsc_Fast )
% spkCorrVsEpoch.m
% Collect absolute static spike count correlation (r_sc) for pairs from
%         pairAreas (SEF-FEF, SEF-SC) filter by functional
%         neuronTypes
% For different 
%         outcomes (Correct, ErrorChoice, ErrorTiming) by
%         mainConditions (Fast, Accurate) by
%         epochs (Baseline, Visual, PostSaccade, PostReward)
% 
% Compute ANOVA withs factors EPOCH (4 levels) and CONDITION (2 levels)
%

%index by SEF neuron functional class
idxVis = (abs(rsc_Acc.X_Grade_Vis) > 2);
idxCErr = (abs(rsc_Acc.X_Grade_CErr) == 1);
idxTErr = (abs(rsc_Acc.X_Grade_TErr) == 1);
idxAll = (idxVis | idxCErr | idxTErr);

%prepare signed and absolute value spike count correlation
r_AccCorr = rsc_Acc.rhoCorr;          rabs_AccCorr = abs(r_AccCorr);
r_AccErrChc = rsc_Acc.rhoErrChc;      rabs_AccErrChc = abs(r_AccErrChc);
r_AccErrTime = rsc_Acc.rhoErrTime;    rabs_AccErrTime = abs(r_AccErrTime);
r_FastCorr = rsc_Fast.rhoCorr;        rabs_FastCorr = abs(r_FastCorr);
r_FastErrChc = rsc_Fast.rhoErrChc;    rabs_FastErrChc = abs(r_FastErrChc);
%r_FastErrTime = rsc_Fast.rhoErrTime;  rabs_FastErrTime = abs(r_FastErrTime);

%compute mean across pairs
rmu_Vis_Acc =  [ mean(rabs_AccCorr(idxVis,:));  mean(rabs_AccErrChc(idxVis,:));  mean(rabs_AccErrTime(idxVis,:)) ];
rmu_Vis_Fast = [ mean(rabs_FastCorr(idxVis,:)); mean(rabs_FastErrChc(idxVis,:)) ];
rmu_CErr_Acc =  [ mean(rabs_AccCorr(idxCErr,:));  mean(rabs_AccErrChc(idxCErr,:));  mean(rabs_AccErrTime(idxCErr,:)) ];
rmu_CErr_Fast = [ mean(rabs_FastCorr(idxCErr,:)); mean(rabs_FastErrChc(idxCErr,:)) ];
rmu_TErr_Acc =  [ mean(rabs_AccCorr(idxTErr,:));  mean(rabs_AccErrChc(idxTErr,:));  mean(rabs_AccErrTime(idxTErr,:)) ];
rmu_TErr_Fast = [ mean(rabs_FastCorr(idxTErr,:)); mean(rabs_FastErrChc(idxTErr,:)) ];
rmu_All_Acc =  [ mean(rabs_AccCorr(idxAll,:));  mean(rabs_AccErrChc(idxAll,:));  mean(rabs_AccErrTime(idxAll,:)) ];
rmu_All_Fast = [ mean(rabs_FastCorr(idxAll,:)); mean(rabs_FastErrChc(idxAll,:)) ];
%compute sem across pairs
rse_Vis_Acc =  [ std(rabs_AccCorr(idxVis,:));  std(rabs_AccErrChc(idxVis,:));  std(rabs_AccErrTime(idxVis,:)) ] / sqrt(sum(idxVis));
rse_Vis_Fast = [ std(rabs_FastCorr(idxVis,:)); std(rabs_FastErrChc(idxVis,:)) ] / sqrt(sum(idxVis));
rse_CErr_Acc =  [ std(rabs_AccCorr(idxCErr,:));  std(rabs_AccErrChc(idxCErr,:));  std(rabs_AccErrTime(idxCErr,:)) ] / sqrt(sum(idxCErr));
rse_CErr_Fast = [ std(rabs_FastCorr(idxCErr,:)); std(rabs_FastErrChc(idxCErr,:)) ] / sqrt(sum(idxCErr));
rse_TErr_Acc =  [ std(rabs_AccCorr(idxTErr,:));  std(rabs_AccErrChc(idxTErr,:));  std(rabs_AccErrTime(idxTErr,:)) ] / sqrt(sum(idxTErr));
rse_TErr_Fast = [ std(rabs_FastCorr(idxTErr,:)); std(rabs_FastErrChc(idxTErr,:)) ] / sqrt(sum(idxTErr));
rse_All_Acc =  [ std(rabs_AccCorr(idxAll,:));  std(rabs_AccErrChc(idxAll,:));  std(rabs_AccErrTime(idxAll,:)) ] / sqrt(sum(idxAll));
rse_All_Fast = [ std(rabs_FastCorr(idxAll,:)); std(rabs_FastErrChc(idxAll,:)) ] / sqrt(sum(idxAll));

%report number of positive and negative correlations
npos_Vis_Acc =  [sum(r_AccCorr(idxVis,:) > 0);  sum(r_AccErrChc(idxVis,:) > 0); sum(r_AccErrTime(idxVis,:) > 0)] / sum(idxVis);
npos_Vis_Fast = [sum(r_FastCorr(idxVis,:) > 0); sum(r_FastErrChc(idxVis,:) > 0)] / sum(idxVis);
npos_CErr_Acc =  [sum(r_AccCorr(idxCErr,:) > 0);  sum(r_AccErrChc(idxCErr,:) > 0); sum(r_AccErrTime(idxCErr,:) > 0)] / sum(idxCErr);
npos_CErr_Fast = [sum(r_FastCorr(idxCErr,:) > 0); sum(r_FastErrChc(idxCErr,:) > 0)] / sum(idxCErr);
npos_TErr_Acc =  [sum(r_AccCorr(idxTErr,:) > 0);  sum(r_AccErrChc(idxTErr,:) > 0); sum(r_AccErrTime(idxTErr,:) > 0)] / sum(idxTErr);
npos_TErr_Fast = [sum(r_FastCorr(idxTErr,:) > 0); sum(r_FastErrChc(idxTErr,:) > 0)] / sum(idxTErr);
npos_All_Acc =  [sum(r_AccCorr(idxAll,:) > 0);  sum(r_AccErrChc(idxAll,:) > 0); sum(r_AccErrTime(idxAll,:) > 0)] / sum(idxAll);
npos_All_Fast = [sum(r_FastCorr(idxAll,:) > 0); sum(r_FastErrChc(idxAll,:) > 0)] / sum(idxAll);

%% Plotting
GREEN = [0 .7 0];
BARWIDTH = 0.3;

figure() %fraction of positive/negative correlations

subplot(4,2,1); hold on %vis neurons
plot(npos_Vis_Acc', 'd-')
legend({'Correct','Choice error','Timing error'})

subplot(4,2,2); hold on
plot(npos_Vis_Fast', 'd-')

subplot(4,2,3); hold on %choice error neurons
plot(npos_CErr_Acc', 'd-')

subplot(4,2,4); hold on
plot(npos_CErr_Fast', 'd-')

subplot(4,2,5); hold on %timing error neurons
plot(npos_TErr_Acc', 'd-')

subplot(4,2,6); hold on
plot(npos_TErr_Fast', 'd-')

subplot(4,2,7); hold on %all neurons
plot(npos_All_Acc', 'd-')

subplot(4,2,8); hold on
plot(npos_All_Fast', 'd-')


for jj = 1:8
  subplot(4,2,jj); ylim([.3 .6]); xticks([])
end

drawnow
ppretty([4.8,4])


figure() % strength of absolute correlations

subplot(4,2,1); hold on %vis neurons
errorbar(rmu_Vis_Acc', rse_Vis_Acc', 'vertical', 'LineStyle','-', 'CapSize',0)
bar(rmu_Vis_Acc(1,:), 'FaceColor','r', 'BarWidth',BARWIDTH)
legend({'Correct','Choice error','Timing error'})

subplot(4,2,2); hold on
errorbar(rmu_Vis_Fast', rse_Vis_Fast', 'vertical', 'LineStyle','-', 'CapSize',0)
bar(rmu_Vis_Fast(1,:), 'FaceColor',GREEN, 'BarWidth',BARWIDTH)

subplot(4,2,3); hold on %choice error neurons
errorbar(rmu_CErr_Acc', rse_CErr_Acc', 'vertical', 'LineStyle','-', 'CapSize',0)
bar(rmu_CErr_Acc(1,:), 'FaceColor','r', 'BarWidth',BARWIDTH)

subplot(4,2,4); hold on
errorbar(rmu_CErr_Fast', rse_CErr_Fast', 'vertical', 'LineStyle','-', 'CapSize',0)
bar(rmu_CErr_Fast(1,:), 'FaceColor',GREEN, 'BarWidth',BARWIDTH)

subplot(4,2,5); hold on %timing error neurons
errorbar(rmu_TErr_Acc', rse_TErr_Acc', 'vertical', 'LineStyle','-', 'CapSize',0)
bar(rmu_TErr_Acc(1,:), 'FaceColor','r', 'BarWidth',BARWIDTH)

subplot(4,2,6); hold on
errorbar(rmu_TErr_Fast', rse_TErr_Fast', 'vertical', 'LineStyle','-', 'CapSize',0)
bar(rmu_TErr_Fast(1,:), 'FaceColor',GREEN, 'BarWidth',BARWIDTH)

subplot(4,2,7); hold on %all neurons
errorbar(rmu_All_Acc', rse_All_Acc', 'vertical', 'LineStyle','-', 'CapSize',0)
bar(rmu_All_Acc(1,:), 'FaceColor','r', 'BarWidth',BARWIDTH)

subplot(4,2,8); hold on
errorbar(rmu_All_Fast', rse_All_Fast', 'vertical', 'LineStyle','-', 'CapSize',0)
bar(rmu_All_Fast(1,:), 'FaceColor',GREEN, 'BarWidth',BARWIDTH)

for jj = 1:8
  subplot(4,2,jj); xticks([]); ytickformat('%3.2f')
end

drawnow
ppretty([4.8,4])


end % fxn : spkCorrVsEpoch()
