function [ ] = spkCorrVsEpoch( spkCorr , rscColName , neuronTypes )
% spkCorrVsEpoch.m
% Collect absolute static spike count correlation (r_sc) for pairs from
%         pairAreas (SEF-FEF, SEF-SC) filter by functional
%         neuronTypes (ErrorChoiceNeurons, ErrorTimingNeurons,
%                    ErrorChoiceAndTimingNeurons,SefVisualNeurons, and All)
% For different 
%         outcomes (Correct, ErrorChoice, ErrorTiming) by
%         mainConditions (Fast, Accurate) by
%         epochs (Baseline, Visual, PostSaccade, PostReward)
% 
% Comput ANOVA withs factors of EPOCH (4 levels) and CONDITION (2 levels)
% for the different functional neuron types
%
% Mean unsigned r_sc of pooled SEF-FEF & SEF-SC pairs as a function of
% task-condition (Accurate, Fast) and trial epoch (abscissa)
% VSS Figure of r_sc plot:
% Split by SEF neuron function --> Only use unsigned-cross-area r_sc.
%     i. Choice error neurons -->  isErrGrade & ~isRewGrade
%    ii. Timing error neurons --> ~isErrGrade & isRewGrade
%   iii. Choice and Timing error neurons -->  isErrGrade & isRewGrade
%    iv. Visually-responsive neurons --> visually responsive SEF neurons paired with any FEF/SC neurons
%     v. All cross area pairs (VSS figure)

% ensure the X_Area is always SEF
uniqXarea = unique(spkCorr.X_Area);
assert(numel(uniqXarea)==1 || sum(strcmp(uniqXarea,'SEF'))==1,'unique(X_Area) of spike corr table must be SEF only');

% figure parameters
LINESTYLE = {'-','--',':'};
YLIMPLOT = [0.04 0.17];

%% Prepare spike corr data

% *** Use absolute spkcorr
spkCorr.rsc = double(abs(spkCorr.(rscColName)));

spkCorr.outcome = regexprep(spkCorr.condition,'(Accurate)|(Fast)',''); %{'Correct','ErrorChoice','ErrorTiming'}
spkCorr.mainCondition = regexprep(spkCorr.condition,'(Correct)|(Error.*)',''); %{'Fast','Accurate'}
spkCorr.epoch = spkCorr.alignedName; %{'Baseline','Visual','PostSaccade','PostReward'}

% Factor: Trial outcome
outcomesPlot = {'Correct','ErrorChoice','ErrorTiming'};
% outcomesPlot = {'Correct'};

%% Compute stats mean, std, se for rsc
grpVars = {'condition' 'epoch' 'mainCondition' 'outcome'};
whichStats = {'mean' 'std' };

for nt = 1:numel(neuronTypes)
    neuronType = neuronTypes{nt};
    temp = grpstats(spkCorr(spkCorr.(neuronType)==1,:),grpVars,whichStats,'DataVars','rsc' );
    temp.se_rsc = temp.std_rsc./sqrt(temp.GroupCount);
    statsTbl.(neuronType) = temp;
end % for : neuronType (nt)

figure()

for nt = 1:numel(neuronTypes)
  subplot(numel(neuronTypes),1,nt); hold on
  set(gca, 'YGrid','on')
  title(neuronTypes{nt},'FontSize',9);
  
  neuronType = neuronTypes{nt};
  currData = statsTbl.(neuronType);

  for jj = 1:numel(outcomesPlot)
    idxOutcome = strcmp(currData.outcome,outcomesPlot{jj});
    idxAccOutcome = strcmp(currData.mainCondition,'Accurate') & idxOutcome;
    idxFastOutcome = strcmp(currData.mainCondition,'Fast') & idxOutcome;
    acc = currData(idxAccOutcome,{'mean_rsc','se_rsc','epoch'});
    fast = currData(idxFastOutcome,{'mean_rsc','se_rsc','epoch'});

    % Accurate
    plot(1:4,acc.mean_rsc,'Color','r', 'LineStyle',LINESTYLE{jj});
    errorbar((1:4), acc.mean_rsc, acc.se_rsc, 'CapSize',0, 'Color','r', ...
      'LineStyle',LINESTYLE{jj}, 'HandleVisibility','off')

    % Fast
%     if (jj == numel(outcomesPlot)); continue; end %leave out Fast 
    plot(1:4,fast.mean_rsc,'Color',[0 .7 0], 'LineStyle',LINESTYLE{jj});
    errorbar((1:4), fast.mean_rsc, fast.se_rsc, 'CapSize',0, 'Color',[0 .7 0], ...
      'LineStyle',LINESTYLE{jj},'HandleVisibility','off')

    ylabel('rsc'); ytickformat('%3.2f'); ylim(YLIMPLOT) %yticks([]); 
    xticks(1:4); xticklabels([]); xlim([.8 4.2])
  end

  if (nt == numel(neuronTypes))
    set(gca,'XTickLabel',acc.epoch,'XTickLabelRotation',30)
    set(gca, 'XMinorTick','off')
  else
    xticks([])
  end

  drawnow

end % for : neuron type (ro)

ppretty([3,6])

end % fxn : spkCorrVsEpoch()
