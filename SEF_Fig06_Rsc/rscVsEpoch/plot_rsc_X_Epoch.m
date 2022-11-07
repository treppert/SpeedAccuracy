% function [ ] = plot_rsc_X_Epoch( spkCorr )

CLASS = {'All','Visual','ChoiceErr','TimingErr'}; %SEF functional class

%index by SEF neuron functional class
idxClass = cell(4,1);
idxFEF = ismember(spkCorr.Y_Area, {'FEF'});
idxSC = ismember(spkCorr.Y_Area, {'SC'});
idxYArea = (idxFEF);
idxClass{2} = (abs(spkCorr.X_Grade_Vis) > 2) & idxYArea;
idxClass{3} = ismember(spkCorr.X_Grade_Err, [-1,+1,+4]) & idxYArea;
idxClass{4} = ismember(spkCorr.X_Grade_TErr, [-1,+1,+4]) & idxYArea;
idxClass{1} = (idxClass{2} | idxClass{3} | idxClass{4});

%index by SAT condition and trial outcome
idxAC  = ismember(spkCorr.condition, {'AccurateCorrect'});
idxAEC = ismember(spkCorr.condition, {'AccurateErrorChoice'});
idxAET = ismember(spkCorr.condition, {'AccurateErrorTiming'});
idxFC  = ismember(spkCorr.condition, {'FastCorrect'});
idxFEC = ismember(spkCorr.condition, {'FastErrorChoice'});
idxFET = ismember(spkCorr.condition, {'FastErrorTiming'});

%initialize
rmu_Acc = cell(4,1);  %mean rsc
rse_Acc = rmu_Acc;    %se rsc
rmu_Fast = rmu_Acc;
rse_Fast = rmu_Acc;
fPos_Acc = rmu_Acc;   %fraction positive rsc
fPos_Fast = rmu_Acc;
rPos_Acc = rmu_Acc;   %positive rsc? (binary)
rPos_Fast = rmu_Acc;

for c = 1:4 %loop over functional class
  
  nClass = sum(idxClass{c}) / 24; %24 = 6(conditionXoutcome) * 4(epoch)
  
  %signed value spike count correlation
  r_AC = spkCorr.rhoRaw(idxClass{c} & idxAC); %Accurate correct
  r_AC = transpose(reshape(r_AC,4,nClass));
  
  r_AEC = spkCorr.rhoRaw(idxClass{c} & idxAEC); %Accurate error choice
  r_AEC = transpose(reshape(r_AEC,4,nClass));
  
  r_AET = spkCorr.rhoRaw(idxClass{c} & idxAET); %Accurate error timing
  r_AET = transpose(reshape(r_AET,4,nClass));
  
  r_FC = spkCorr.rhoRaw(idxClass{c} & idxFC); %Fast correct
  r_FC = transpose(reshape(r_FC,4,nClass));
  
  r_FEC = spkCorr.rhoRaw(idxClass{c} & idxFEC); %Fast error choice
  r_FEC = transpose(reshape(r_FEC,4,nClass));
  
  r_FET = spkCorr.rhoRaw(idxClass{c} & idxFET); %Fast error timing
  r_FET = transpose(reshape(r_FET,4,nClass));
  
  %compute mean and SEM across pairs
  %NOTE - For FET, there is 1 SC neuron (Eu) with zero spikes
  rmu_Acc{c}  = [ mean(r_AC) ; mean(r_AEC) ; mean(r_AET) ];
  rmu_Fast{c} = [ mean(r_FC) ; mean(r_FEC) ; nanmean(r_FET) ];
  rse_Acc{c}  = [ std(r_AC) ; std(r_AEC) ; std(r_AET) ] / sqrt(nClass);
  rse_Fast{c} = [ std(r_FC) ; std(r_FEC) ; nanstd(r_FET) ] / sqrt(nClass);
  
  %compute fraction of (+) and (-) correlations
  fPos_Acc{c}  = [ sum(r_AC > 0) ; sum(r_AEC > 0) ; sum(r_AET > 0) ] / nClass;
  fPos_Fast{c} = [ sum(r_FC > 0) ; sum(r_FEC > 0) ; sum(r_FET > 0) ] / nClass;

  %record sign of mean correlation across epochs
  rPos_Acc{c}  = [ sign(mean(r_AC,2)) , sign(mean(r_AEC,2)) , sign(mean(r_AET,2)) ];
  rPos_Fast{c} = [ sign(mean(r_FC,2)) , sign(mean(r_FEC,2)) , sign(mean(r_FET,2)) ];

end % for : class (c)

%% Stats - P(r > 0) - chi-square test for independence
cTest = 1;
nClass = size(rPos_Acc{cTest},1);
rsc = [ reshape(rPos_Acc{cTest}, 3*nClass,1) ; reshape(rPos_Fast{cTest}, 3*nClass,1) ];
condition = [ ones(3*nClass,1) ; 2*ones(3*nClass,1) ];
outcome = repmat([ones(nClass,1) ; 2*ones(nClass,1) ; 3*ones(nClass,1)], 2,1);

%chi-square test
[tbl,chi2stat,pval] = crosstab(condition, outcome, rsc);
chi2_A2F = struct('tbl',tbl, 'chi2stat',chi2stat, 'pval',pval);
% display(chi2_A2F.tbl)

%% Stats - 3-way ANOVA - |r| - All pairs
%Three-way ANOVA with factors ConditionXOutcomeXEpoch - All SEF neurons
idxStats = idxClass{1};
anovaTbl = table();
anovaTbl.rhoRaw = spkCorr.rhoRaw(idxStats);
anovaTbl.Outcome = regexprep(spkCorr.condition(idxStats),{'Fast','Accurate'},{'',''});
anovaTbl.SATCondition = regexprep(spkCorr.condition(idxStats),{'Correct','Error.*'},{'',''});
anovaTbl.Epoch = spkCorr.alignedName(idxStats);
statsAnova = satAnova(anovaTbl);

return
%% Plotting - Fraction of positive correlations
GREEN = [0 .7 0];
MARKERSIZE = 5.0;
YLIM = [0.3 .7001];
XLIM = [0.8 4.2001];

if (true)
figure()
for c = 1:4
  iAcc  = 2*(c-1) + 1;
  iFast = 2*(c-1) + 2;
  
  subplot(4,2,iAcc); hold on
  plot([1 4], [0.5 0.5], 'k--')
  plot(fPos_Acc{c}(1,:), 'rd-', 'MarkerSize',MARKERSIZE)
  plot(fPos_Acc{c}(2,:), 'rd--', 'MarkerSize',MARKERSIZE)
  plot(fPos_Acc{c}(3,:), 'rd:', 'MarkerSize',MARKERSIZE)
  ylim(YLIM); xlim(XLIM); xticks([])
  
  subplot(4,2,iFast); hold on
  plot([1 4], [0.5 0.5], 'k--')
  plot(fPos_Fast{c}(1,:), 'd-', 'Color',GREEN, 'MarkerSize',MARKERSIZE)
  plot(fPos_Fast{c}(2,:), 'd--', 'Color',GREEN, 'MarkerSize',MARKERSIZE)
  plot(fPos_Fast{c}(3,:), 'd:', 'Color',GREEN, 'MarkerSize',MARKERSIZE)
  ylim(YLIM); xlim(XLIM); xticks([]); yticks([])
end

subplot(4,2,7); xticks(1:4); xticklabels({'BL','VR','PS','PR'}); ylabel('P(r > 0)')
subplot(4,2,8); xticks(1:4); xticklabels({'BL','VR','PS','PR'})

drawnow
ppretty([4.8,5])
end

%% Plotting - Strength of absolute correlations
BARWIDTH = 0.25;
YLIM = [-0.04 0.0601];
XTICKS = [1 2 3 4];
XSHIFT = 0.05;

if (true)
figure()
for c = 1:4
  iAcc  = 2*(c-1) + 1;
  iFast = 2*(c-1) + 2;
  
  subplot(4,2,iAcc); hold on
  bar(rmu_Acc{c}(1,:), 'FaceColor','r', 'BarWidth',BARWIDTH)
  errorbar(XTICKS, rmu_Acc{c}(1,:), rse_Acc{c}(1,:), 'Color','k', 'LineStyle','-', 'CapSize',0)
  errorbar(XTICKS-XSHIFT, rmu_Acc{c}(2,:), rse_Acc{c}(2,:), 'Color','k', 'LineStyle','--', 'CapSize',0)
  errorbar(XTICKS+XSHIFT, rmu_Acc{c}(3,:), rse_Acc{c}(3,:), 'Color','k', 'LineStyle',':', 'CapSize',0)
  ylim(YLIM); ytickformat('%3.2f'); xlim(XLIM); xticks([])
  
  subplot(4,2,iFast); hold on
  bar(rmu_Fast{c}(1,:), 'FaceColor',GREEN, 'BarWidth',BARWIDTH)
  errorbar(XTICKS, rmu_Fast{c}(1,:), rse_Fast{c}(1,:), 'Color','k', 'LineStyle','-', 'CapSize',0)
  errorbar(XTICKS-XSHIFT, rmu_Fast{c}(2,:), rse_Fast{c}(2,:), 'Color','k', 'LineStyle','--', 'CapSize',0)
  errorbar(XTICKS+XSHIFT, rmu_Fast{c}(3,:), rse_Fast{c}(3,:), 'Color','k', 'LineStyle',':', 'CapSize',0)
  ylim(YLIM); ytickformat('%3.2f'); xlim(XLIM); xticks([]); yticks([])
end

subplot(4,2,7); xticks(XTICKS); xticklabels({'BL','VR','PS','PR'}); ylabel('|r|')
subplot(4,2,8); xticks(XTICKS); xticklabels({'BL','VR','PS','PR'})

drawnow
ppretty([4.8,5])
end

clearvars -except behavData unitData spkCorr stats*
% end % fxn : plot_rsc_X_Epoch()
