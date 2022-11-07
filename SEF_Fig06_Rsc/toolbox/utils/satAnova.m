function [anovaResults] = satAnova(valsGroupsTbl,varargin)
%SATANOVA Do a multiway anova for the given table of inputs
%   Column1 = Y-Values numeric
%   Columns (2 to end) = groups/factors over which the anonan is run
% ***Terminology: group == factor
% ***Note: dont use "factor" *** --> Its is a matlab funtion for primes  doc FACTOR
% see also ANOVAN, MULTCOMPARE

argsParser = inputParser();
argsParser.addParameter('model','interaction'); %linear|interaction|full
argsParser.addParameter('display','on');%off|on --> for anova tbl
argsParser.addParameter('alpha',0.05);
argsParser.addParameter('sstype',3);%1|2|3|'h' default = 3
argsParser.addParameter('doMultiCompare',true);
argsParser.addParameter('multiCompareDisplay','on');%off|on --> for multiple comparisons

argsParser.addParameter('displayMeans',false);%show group means?

argsParser.parse(varargin{:});
args = argsParser.Results;

yVals = valsGroupsTbl{:,1};
assert(isnumeric(yVals),'Y-Values must be numeric');

factorNames = valsGroupsTbl.Properties.VariableNames;
factorNames = factorNames(2:end);

groups = cell(1,numel(factorNames));
for ii = 1:numel(factorNames)
    groups{ii} = valsGroupsTbl.(factorNames{ii});
end

% anovaTbl header:
% {'Source' 'Sum Sq.' 'd.f.' 'Singular?' 'Mean Sq.' 'F'  'Prob>F'}
anovaResults = struct();
anovaTblVarNames = {'Source', 'SumSq' 'df' 'IsSingular' 'MeanSq' 'F'  'ProbGtF'};

[~,temp,anovaStats] = anovan(yVals,groups,'model',args.model,'varnames',factorNames, 'display','on');
anovaTbl = cell2table(temp(2:end,:),'VariableNames',anovaTblVarNames);
% add '*' p(F >= .05) and '**' p(F >=  .01)
idx = find(~ismember(anovaTbl.Source,{'Error','Total'}));
for jj = 1:numel(idx)
    str = 'N.S.';
    probGtF = anovaTbl.ProbGtF{jj};
    if probGtF <= 0.01
        str = '**';
    elseif probGtF<=0.05
        str = '*';
    end
    anovaTbl.signifStr{jj} = str;
end
anovaResults.anovaTbl = anovaTbl;
% Compare results for different LEVELS *WITHIN* each group/Factor independently 
% for bonferroni use 'CType', ... see doc multcompare
if (args.doMultiCompare)
  %MAIN EFFECTS
  for gr = 1:numel(factorNames)
      [temp,means,~,grpNames] = multcompare(anovaStats,'Dimension',gr,'Alpha',args.alpha,'display',args.multiCompareDisplay);
      if (args.displayMeans); display(means); end
      anovaResults.(factorNames{gr}) = annotateMultcompareResults(temp,grpNames);
  end
  
  %INTERACTION EFFECTS
  nWays = 2;
  n2GrpComparisions = combnk(1:numel(factorNames),nWays);
  
  for jj = 1:size(n2GrpComparisions,1)
      idx = n2GrpComparisions(jj,:);
      fn = char(join(factorNames(idx),'_'));
      [temp,~,~,grpNames] = multcompare(anovaStats,'Dimension',idx,'Alpha',args.alpha,'display',args.multiCompareDisplay);
      anovaResults.(fn) = annotateMultcompareResults(temp,grpNames);
  end
end

end % fxn : satAnova()

function [resultsAsTbl] = annotateMultcompareResults(results,grpNames)
% see also multcompare

levelNamesNew = split(grpNames,{',','='});
levelNamesNew = levelNamesNew(:,2:2:end);
levelNamesNew = arrayfun(@(x) char(join(levelNamesNew(x,:),'_')),1:size(levelNamesNew,1),'UniformOutput',false)';

resultsAsTbl = table();
resultsAsTbl.levelName1 = arrayfun(@(x) levelNamesNew{x},results(:,1),'UniformOutput',false);
resultsAsTbl.levelName2 = arrayfun(@(x) levelNamesNew{x},results(:,2),'UniformOutput',false);
resultsAsTbl = [resultsAsTbl array2table(results(:,3:end),'VariableNames',{'loCI95','meanDiff','hiCI95','pval_H0'})];
resultsAsTbl.group1 = results(:,1);
resultsAsTbl.group2 = results(:,2);

end % util : annotateMultcompareResults()
