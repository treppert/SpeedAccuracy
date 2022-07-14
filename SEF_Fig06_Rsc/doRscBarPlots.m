function [ ] = doRscBarPlots( rscData )

groupCols = {'condition','satCondition','outcome'};
rhocols = {'rho'};
allOutcomes = {'Correct','ErrorChoice','ErrorTiming'};

rscSatConditionStats = grpstats(rscData(:,['satCondition', rhocols]),'satCondition',{'mean','std','sem'});
rscSatConditionStats.Properties.RowNames = {};

rscOutcomesStats = grpstats(rscData(:,[groupCols rhocols]),groupCols,{'mean','std','sem'});
rscOutcomesStats = sortrows(rscOutcomesStats,{'outcome','satCondition'});
rscOutcomesStats.Properties.RowNames = {};

%% Plot results/means
% display 3 groups of 2 bars each

idxAccu = ismember(rscOutcomesStats.satCondition,'Accurate');
idxFast = ismember(rscOutcomesStats.satCondition,'Fast');

accuTbl = rscOutcomesStats(idxAccu,{'outcome','mean_rho','sem_rho'});
fastTbl = rscOutcomesStats(idxFast,{'outcome','mean_rho','sem_rho'});

% Check if each SAT condition has all 3 outcomes
% 1. ensure outcome column is sorted as in allOutcomes
% 2. Insert NaNs for an outcome not present for sat condition
temp = cell2table(allOutcomes','VariableNames',{'outcome'});
accuTbl = outerjoin(temp,accuTbl,'LeftVariables','outcome','RightVariables',{'mean_rho','sem_rho'});
fastTbl = outerjoin(temp,fastTbl,'LeftVariables','outcome','RightVariables',{'mean_rho','sem_rho'});

plotGroupBarsWithErrors([accuTbl.mean_rho fastTbl.mean_rho], [accuTbl.sem_rho fastTbl.sem_rho]);

drawnow

end % fxn : doRscBarPlots()
