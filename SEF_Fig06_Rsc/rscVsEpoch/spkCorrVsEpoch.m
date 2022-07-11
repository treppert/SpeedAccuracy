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

% Spike count correlation data for different pairs by pair-areas in file:
% spkCorrFile = [rootDir, 'summary/spkCorrAllPairsStaticNew.mat'];
rootDir = 'C:\Users\thoma\Dropbox\Speed Accuracy\Data\SpkCorr\';
spkCorrFile = [rootDir, 'summary/SAT_SEF_StaticRscAllPairs_New.mat'];

%% Figure parameters
pairAreas = {'SEF-FEF', 'SEF-SC'};
neuronTypes = {'AllN','ErrorChoiceN','ErrorTimingN'};
nTypes = numel(neuronTypes);

outcomes = {'Correct','ErrorChoice','ErrorTiming'};
% column name of static spike count correlation
%   rhoRaw_150ms ==> trial-by-trial spike count correlation for a given
%   pair in 150 ms window after aligning the trials on event corresponding
%   to the epoch. The data for spike corr are in the variabels in the file:
%   dataProcessed/analysis/spkCorr/summary/spkCorrAllPairsStaticNew.mat 
rscColName = 'rhoRaw_150ms';

LINESTYLE = {'-','--',':'};
% YLIMPLOT = round([.00 .20]+0.005, 2);
YLIMPLOT = [0.0 0.2];

%% Load spike corr data and merge cross areas
useCols = {
    'pairAreas'
    'nTrials'
    'X_unitNum'
    'Y_unitNum'
    'X_area'
    'Y_area'
    'X_visGrade'
    'Y_visGrade'
    'X_moveGrade'
    'Y_moveGrade'
    'X_errGrade'
    'Y_errGrade'
    'X_isErrGrade'
    'Y_isErrGrade'
    'X_rewGrade'
    'Y_rewGrade'
    'X_isRewGrade'
    'Y_isRewGrade'
    'condition'
    'alignedName'
    'alignedEvent'
    'alignedTimeWin'
    rscColName
    };
spkCorr = table();
for pa = 1:numel(pairAreas)
    paVariable = regexprep(pairAreas{pa},'-','_');
    temp = load(spkCorrFile,paVariable);
    spkCorr = [spkCorr;temp.(paVariable)(:,useCols)]; %#ok<AGROW>
end

clearvars pa* useCols temp spkCorrFile

% ensure the X_area is always SEF
uniqXarea = unique(spkCorr.X_area);
assert(numel(uniqXarea)==1 || sum(strcmp(uniqXarea,'SEF'))==1,'unique(X_Area) of spike corr table MUST be only SEF');

% Add fields to table to aid filtering for neuron types:
spkCorr.AllN = ones(size(spkCorr,1),1);
spkCorr.ErrorChoiceN = spkCorr.X_isErrGrade & ~spkCorr.X_isRewGrade;
spkCorr.ErrorTimingN = ~spkCorr.X_isErrGrade & spkCorr.X_isRewGrade;
spkCorr.ErrorChoiceAndTimingN = spkCorr.X_isErrGrade & spkCorr.X_isRewGrade;

% pool suppressed and enhanced visual responses; range is [-4,-3,-2,0,2,3,4]
% spkCorr.VisualN = abs(spkCorr.X_visGrade) >= 2;

% outcomes = {'Correct','ErrorChoice','ErrorTiming'};
spkCorr.outcome = regexprep(spkCorr.condition,'(Accurate)|(Fast)','');

% mainConditions = {'Fast','Accurate'};
spkCorr.mainCondition = regexprep(spkCorr.condition,'(Correct)|(Error.*)','');

% epochs = {'Baseline','Visual','PostSaccade','PostReward'} => alignedName
spkCorr.epoch = spkCorr.alignedName;

% use absolute spkcorr
spkCorr.rsc = double(abs(spkCorr.(rscColName)));

%% Compute stats mean, std, se for rsc
warning('off')    
% usePairAreas = { {'SEF-FEF'} , {'SEF-SC'} , {'SEF-FEF' 'SEF-SC'} };
usePairAreas = { {'SEF-FEF' 'SEF-SC'} };

for pa = 1:numel(usePairAreas)
    
    currPairArea = usePairAreas{pa};
    currSpkCorr = spkCorr(ismember(spkCorr.pairAreas,currPairArea),:);
    currPairAreaStr = char(join(currPairArea,' & '));

    pdfFile = ['spkCorrByEpoch_AllPairsFor_' char(join(currPairArea,'_')) '.pdf'];
    grpVars = {'condition' 'epoch' 'mainCondition' 'outcome'};
    whichStats = {'mean' 'std' };
    for nt = 1:nTypes
        neuronType = neuronTypes{nt};
        temp = grpstats(currSpkCorr(currSpkCorr.(neuronType)==1,:),grpVars,whichStats,'DataVars','rsc' );
        temp.se_rsc = temp.std_rsc./sqrt(temp.GroupCount);
        statsTbl.(neuronType) = temp;
    end % for : neuronType (nt)
    
    figure('Name',currPairAreaStr)

    for nt = 1:nTypes
      subplot(nTypes,1,nt); hold on
      set(gca, 'YGrid','on')
      title(neuronTypes{nt},'FontSize',9);
      
      neuronType = neuronTypes{nt};
      currData = statsTbl.(neuronType);

      for jj = 1:numel(outcomes)
        idxOutcome = strcmp(currData.outcome,outcomes{jj});
        idxAccOutcome = strcmp(currData.mainCondition,'Accurate') & idxOutcome;
        idxFastOutcome = strcmp(currData.mainCondition,'Fast') & idxOutcome;
        acc = currData(idxAccOutcome,{'mean_rsc','se_rsc','epoch'});
        fast = currData(idxFastOutcome,{'mean_rsc','se_rsc','epoch'});

        % Accurate
        plot(1:4,acc.mean_rsc,'Color','r', 'LineStyle',LINESTYLE{jj});
        errorbar((1:4), acc.mean_rsc, acc.se_rsc, 'CapSize',0, 'Color','r', ...
          'LineStyle',LINESTYLE{jj}, 'HandleVisibility','off')

        % Fast
        plot(1:4,fast.mean_rsc,'Color',[0 .7 0], 'LineStyle',LINESTYLE{jj});
        errorbar((1:4), fast.mean_rsc, fast.se_rsc, 'CapSize',0, 'Color',[0 .7 0], ...
          'LineStyle',LINESTYLE{jj},'HandleVisibility','off')

        ylabel('rsc'); ylim(YLIMPLOT); ytickformat('%3.2f') %yticks([])
        xticks(1:4); xticklabels([]); xlim([.8 4.2])
        if (nt == nTypes)
          set(gca,'XTickLabel',acc.epoch,'XTickLabelRotation',30)
        end

      end

      drawnow

    end % for : neuron type (ro)

end % for : pair(pa)

ppretty([3,6])
