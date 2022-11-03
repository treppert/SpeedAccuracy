% function [ ] = plot_rsc_X_Epoch( spkCorr )

CLASS = {'All','Visual','ChoiceErr','TimingErr'}; %SEF functional class

%index by SEF neuron functional class
idxClass = cell(4,1);
idxClass{2} = (abs(spkCorr.X_Grade_Vis) > 2);
idxClass{3} = ismember(spkCorr.X_Grade_Err, [-1,+1,+4]);
idxClass{4} = ismember(spkCorr.X_Grade_TErr, [-1,+1,+4]);
idxClass{1} = (idxClass{2} | idxClass{3} | idxClass{4});

%index by SAT condition and trial outcome
idxAC  = ismember(spkCorr.condition, {'AccurateCorrect'});
idxAEC = ismember(spkCorr.condition, {'AccurateErrorChoice'});
idxAET = ismember(spkCorr.condition, {'AccurateErrorTiming'});
idxFC  = ismember(spkCorr.condition, {'FastCorrect'});
idxFEC = ismember(spkCorr.condition, {'FastErrorChoice'});
idxFET = ismember(spkCorr.condition, {'FastErrorTiming'});

%initialize
rmu_Acc = cell(4,1);  %mean abs(rsc)
rse_Acc = rmu_Acc;    %se abs(rsc)
fPos_Acc = rmu_Acc;   %fraction positive rsc
rmu_Fast = rmu_Acc;
rse_Fast = rmu_Acc;
fPos_Fast = rmu_Acc;

for c = 1:4 %loop over functional class
  
  nClass = sum(idxClass{c}) / 24; %24 = 6(conditionXoutcome) * 4(epoch)
  
  %signed value spike count correlation
  r_AC = spkCorr.rhoRaw(idxClass{c} & idxAC , :); %Accurate correct
  r_AC = transpose(reshape(r_AC,4,nClass));
  
  r_AEC = spkCorr.rhoRaw(idxClass{c} & idxAEC , :); %Accurate error choice
  r_AEC = transpose(reshape(r_AEC,4,nClass));
  
  r_AET = spkCorr.rhoRaw(idxClass{c} & idxAET , :); %Accurate error timing
  r_AET = transpose(reshape(r_AET,4,nClass));
  
  r_FC = spkCorr.rhoRaw(idxClass{c} & idxFC , :); %Fast correct
  r_FC = transpose(reshape(r_FC,4,nClass));
  
  r_FEC = spkCorr.rhoRaw(idxClass{c} & idxFEC , :); %Fast error choice
  r_FEC = transpose(reshape(r_FEC,4,nClass));
  
  r_FET = spkCorr.rhoRaw(idxClass{c} & idxFET , :); %Fast error timing
  r_FET = transpose(reshape(r_FET,4,nClass));
  
  %absolute value spike count correlation
  rabs_AC = abs(r_AC); %Accurate correct
  rabs_AEC = abs(r_AEC); %Accurate choice error
  rabs_AET = abs(r_AET); %Accurate timing error
  rabs_FC = abs(r_FC); %Fast correct
  rabs_FEC = abs(r_FEC); %Fast choice error
  rabs_FET = abs(r_FET); %Fast timing error
  
  %compute mean and SEM across pairs
  rmu_Acc{c}  = [ mean(rabs_AC) ; mean(rabs_AEC) ; mean(rabs_AET) ];
  rmu_Fast{c} = [ mean(rabs_FC) ; mean(rabs_FEC) ; mean(rabs_FET) ];
  rse_Acc{c}  = [ std(rabs_AC) ; std(rabs_AEC) ; std(rabs_AET) ] / sqrt(nClass);
  rse_Fast{c} = [ std(rabs_FC) ; std(rabs_FEC) ; std(rabs_FET) ] / sqrt(nClass);
  
  %compute fraction of (+) and (-) correlations
  fPos_Acc{c}  = [ sum(r_AC > 0) ; sum(r_AEC > 0) ; sum(r_AET > 0) ] / nClass;
  fPos_Fast{c} = [ sum(r_FC > 0) ; sum(r_FEC > 0) ; sum(r_FET > 0) ] / nClass;
  %average across epochs
  fPos_Acc{c}   = mean(fPos_Acc{c},2);
  fPos_Fast{c}  = mean(fPos_Fast{c},2);

end % for : class (c)


%% Stats - P(r > 0)
%TODO - Format data for 3x2 chi-square analysis ***
% X_A2F = (DA_X_A2F > 0); %was modulation (+) or (-)?
% Y_A2F = (DA_Y_A2F > 0);
% %chi-square test
% [tbl,chi2stat,pval] = crosstab(X_A2F,Y_A2F);
% chi2_A2F = struct('tbl',tbl, 'chi2stat',chi2stat, 'pval',pval);


%% Stats - 3-way ANOVA - |r| - All pairs
%Three-way ANOVA with factors Condition, Outcome, and Epoch
anovaTbl.rhoRaw = abs(spkCorr.rhoRaw);
% anovaTbl.rhoRaw = log( anovaTbl.rhoRaw ./ (1-anovaTbl.rhoRaw) );
anovaTbl.Outcome = regexprep(spkCorr.condition,{'Fast','Accurate'},{'',''});
anovaTbl.SATCondition = regexprep(spkCorr.condition,{'Correct','Error.*'},{'',''});
anovaTbl.Epoch = spkCorr.alignedName;

% statsAnova3 = satAnova(anovaTbl);

%% Plotting - Fraction of positive correlations
GREEN = [0 .7 0];
MARKERSIZE = 5.0;
YLIM = [0.3 .7001];
XLIM = [0.8 4.2001];

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

return
%% Plotting - Strength of absolute correlations
BARWIDTH = 0.25;
YLIM = [0.00 0.15];

figure()
for c = 1:4
  iAcc  = 2*(c-1) + 1;
  iFast = 2*(c-1) + 2;
  
  subplot(4,2,iAcc); hold on
  bar(rmu_Acc{c}(1,:), 'FaceColor','r', 'BarWidth',BARWIDTH)
  errorbar(rmu_Acc{c}(1,:), rse_Acc{c}(1,:), 'Color','r', 'LineStyle','-', 'CapSize',0)
  errorbar(rmu_Acc{c}(2,:), rse_Acc{c}(2,:), 'Color','r', 'LineStyle','--', 'CapSize',0)
  errorbar(rmu_Acc{c}(3,:), rse_Acc{c}(3,:), 'Color','r', 'LineStyle',':', 'CapSize',0)
  ylim(YLIM); ytickformat('%3.2f'); xlim(XLIM); xticks([])
  
  subplot(4,2,iFast); hold on
  bar(rmu_Fast{c}(1,:), 'FaceColor',GREEN, 'BarWidth',BARWIDTH)
  errorbar(rmu_Fast{c}(1,:), rse_Fast{c}(1,:), 'Color',GREEN, 'LineStyle','-', 'CapSize',0)
  errorbar(rmu_Fast{c}(2,:), rse_Fast{c}(2,:), 'Color',GREEN, 'LineStyle','--', 'CapSize',0)
  errorbar(rmu_Fast{c}(3,:), rse_Fast{c}(3,:), 'Color',GREEN, 'LineStyle',':', 'CapSize',0)
  ylim(YLIM); ytickformat('%3.2f'); xlim(XLIM); xticks([]); yticks([])
end

subplot(4,2,7); xticks(1:4); xticklabels({'BL','VR','PS','PR'}); ylabel('|r|')
subplot(4,2,8); xticks(1:4); xticklabels({'BL','VR','PS','PR'})

drawnow
ppretty([4.8,5])

% end % fxn : plot_rsc_X_Epoch()
