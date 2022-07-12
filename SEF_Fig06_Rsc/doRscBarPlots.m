function [ ] = doRscBarPlots( rscData , sefType , yArea )

groupCols = {'condition','satCondition','outcome'};
rhocols = {'rho','rhoEst40','rhoEst80'};
allOutcomes = {'Correct','ErrorChoice','ErrorTiming'};

if strcmp(sefType,'ERROR')
    idxRos = (rscData.isSefErrorUnit);
elseif strcmp(sefType,'VISUAL')
    idxRos = (rscData.isSefUnitVis & ~rscData.isSefErrorUnit);
elseif strcmp(sefType,'ALL')
    idxRos = (rscData.isSefUnitVis | rscData.isSefErrorUnit);
end

idxRos = idxRos & ismember(rscData.Y_Area, yArea);

if (sum(idxRos) == 0); return; end

rscSatConditionStats = grpstats(rscData(idxRos,['satCondition', rhocols]),'satCondition',{'mean','std','sem'});
rscSatConditionStats.Properties.RowNames = {};

rscOutcomesStats = grpstats(rscData(idxRos,[groupCols rhocols]),groupCols,{'mean','std','sem'});
rscOutcomesStats = sortrows(rscOutcomesStats,{'outcome','satCondition'});
rscOutcomesStats.Properties.RowNames = {};

outcomeStats = rscOutcomesStats(:,[1,4,5,6,7,8,9,11,12]);
satStats = rscSatConditionStats(:,[1,2,3,4,5,6,7,9,10]);
satStats.Properties.VariableNames = outcomeStats.Properties.VariableNames;
allStats = [satStats; outcomeStats];

% add CI table
temp = zeros(size(allStats,1),1);
allStats.loCI_40 = temp;
allStats.hiCI_40 = temp;
allStats.loCI_80 = temp;
allStats.hiCI_80 = temp;


%% Plot results/means
% display 3 groups of 2 bars each

idxAccu = ismember(rscOutcomesStats.satCondition,'Accurate');
idxFast = ismember(rscOutcomesStats.satCondition,'Fast');

accuTbl = rscOutcomesStats(idxAccu,{'outcome','mean_rho','sem_rho'});
fastTbl = rscOutcomesStats(idxFast,{'outcome','mean_rho','sem_rho'});

% 04/30: Check if each SAT condition has all 3 outcomes
% 1. ensure outcome column is sorted as in allOutcomes
% 2. Insert NaNs for an outcome not present for sat condition
temp = cell2table(allOutcomes','VariableNames',{'outcome'});
accuTbl = outerjoin(temp,accuTbl,'LeftVariables','outcome','RightVariables',{'mean_rho','sem_rho'});
fastTbl = outerjoin(temp,fastTbl,'LeftVariables','outcome','RightVariables',{'mean_rho','sem_rho'});


plotGroupBarsWithErrors([accuTbl.mean_rho fastTbl.mean_rho], ...
    [accuTbl.sem_rho fastTbl.sem_rho]);

% Add boxes for Confidence interval
% Acurate_Error_Timing ci/percentile 10/90 for 40 subsamples
idx = ismember(rscData.condition,'AccurateErrorTiming');
ci = getCi((rscData.rhoEst40(idx)));
overplotBox(2.85,ci,'k','-');
idx = ismember(allStats.condition,'AccurateErrorTiming');
allStats.loCI_40(idx) = ci(1);
allStats.hiCI_40(idx) = ci(2);

% Fast_Error_Choice ci/percentile 10/90 for 80 subsamples
idx = ismember(rscData.condition,'FastErrorChoice');
barCenter = 2.15;
ci = getCi((rscData.rhoEst80(idx)));
overplotBox(barCenter,ci,'k',':');
idx = ismember(allStats.condition,'FastErrorChoice');
allStats.loCI_80(idx) = ci(1);
allStats.hiCI_80(idx) = ci(2);

% Accurate_Correct percentile 10/90 for 80 subsamples
idx = ismember(rscData.condition,'AccurateCorrect');
ci40 = getCi((rscData.rhoEst40(idx)));
overplotBox(0.80,ci40,'k','-');
ci80 = getCi((rscData.rhoEst80(idx)));
overplotBox(0.85,ci80,'k',':');
idx = ismember(allStats.condition,'AccurateCorrect');
allStats.loCI_40(idx) = ci40(1);
allStats.hiCI_40(idx) = ci40(2);
allStats.loCI_80(idx) = ci80(1);
allStats.hiCI_80(idx) = ci80(2);

% Fast_Correct percentile 10/90 for 80 subsamples
idx = ismember(rscData.condition,'FastCorrect');
ci40 = getCi((rscData.rhoEst40(idx)));
overplotBox(1.05,ci40,'k','-');
ci80 = getCi((rscData.rhoEst80(idx)));
overplotBox(1.1,ci80,'k',':');
idx = ismember(allStats.condition,'FastCorrect');
allStats.loCI_40(idx) = ci40(1);
allStats.hiCI_40(idx) = ci40(2);
allStats.loCI_80(idx) = ci80(1);
allStats.hiCI_80(idx) = ci80(2);

drawnow

end % fxn : doRscBarPlots()

function [pH] = overplotBox(barCenter,yBeginEnd,edgeColor,lineStyle)
doCiBox = true;
if evalin('base','exist(''addCiBox'',''var'')')
    doCiBox = evalin('base','addCiBox');
end
if ~doCiBox
    pH = [];
    return;
end
xBeginEnd = barCenter + [-0.125 0.125];
xVec = [xBeginEnd fliplr(xBeginEnd)];
yVec = [yBeginEnd;yBeginEnd];
yVec = yVec(:)';
pH = patch(xVec,yVec,[1 1 1],'FaceAlpha',0.0);
set(pH,'EdgeColor',edgeColor)
set(pH,'LineStyle',lineStyle)
set(pH,'LineWidth',0.5)
end

function [normCi] = getCi(vec)
vecMean = nanmean(vec);
vecSem = nanstd(vec)/sqrt(numel(vec));
% compute t-statistic for 0.025, 0.975
ts = tinv([0.025,0.975],numel(vec)-1);
normCi = vecMean + vecSem*ts;
end


