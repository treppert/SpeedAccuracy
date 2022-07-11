function [ outSpkCorr ] = Fig6B_SpkCorr_PostResponse()
%Fig6B_SpkCorr_PostResponse
%  
% see also: CREATESPIKECORRWITHSUBSAMPLING,

%% cretae datafile -- already done by running. Takes time
% CREATESPIKECORRWITHSUBSAMPLING
% [spkCorr] = createSpikeCorrWithSubSampling();
% creates the datafile.
% datafile : 
%% Load spkCorr data created in the above step
RootDir = 'C:\Users\thoma\Dropbox\Speed Accuracy\Data\SpkCorr\';
spkCorr = load([RootDir, 'rscSubSampl1K_PostSaccade_0_TrialsThresh.mat']);
spkCorr = spkCorr.spkCorr;

colNames = getColNamesToUse();
spkCorr = spkCorr(:,colNames);
spkCorr.Properties.VariableNames = regexprep(colNames,'_150ms','');

spkCorr.satCondition = regexprep(spkCorr.condition,{'Correct','Error.*'},{'',''});
spkCorr.outcome = regexprep(spkCorr.condition,{'Fast','Accurate'},{'',''});
spkCorr.epoch = spkCorr.alignedName;

%%
epoch = 'PostSaccade';
spkCorr = spkCorr(ismember(spkCorr.epoch,epoch),:);
rscTable = table();
rscTable.PairUid = spkCorr.Pair_UID;
rscTable.monkey = spkCorr.X_monkey;
rscTable.session = spkCorr.X_sess;
rscTable.X_unitNum = spkCorr.X_unitNum;
rscTable.Y_unitNum = spkCorr.Y_unitNum;
rscTable.X_area = spkCorr.X_area;
rscTable.Y_area = spkCorr.Y_area;
rscTable.condition = spkCorr.condition;
rscTable.satCondition = spkCorr.satCondition;
rscTable.outcome = spkCorr.outcome;
rscTable.epoch = spkCorr.epoch;
rscTable.nTrials = spkCorr.nTrials;
rscTable.rho = spkCorr.rhoRaw;
rscTable.pval = spkCorr.pvalRaw;
rscTable.signif_05 = spkCorr.signifRaw_05;
rscTable.rhoEst40 = spkCorr.rhoEstRaw_nTrials_40;
rscTable.rhoEst80 = spkCorr.rhoEstRaw_nTrials_80;
% add isSefErrorNeuron
rscTable.isSefErrorUnit = abs(spkCorr.X_errGrade) > 1 | abs(spkCorr.X_rewGrade) > 1;
rscTable.sefVisGrade = spkCorr.X_visGrade;
rscTable.sefMoveGrade = spkCorr.X_moveGrade;
rscTable.isSefUnitVis = spkCorr.X_visGrade > 1 & spkCorr.X_moveGrade == 0;
rscTable.isSefUnitMove = spkCorr.X_visGrade == 0 & spkCorr.X_moveGrade > 1;
rscTable.isSefUnitVisMove = spkCorr.X_visGrade > 1 & spkCorr.X_moveGrade > 1;
rscTable.isSefUnitOther = spkCorr.X_visGrade <= 1 | spkCorr.X_moveGrade <= 1;
warning('off')
%%
outSpkCorr = table();
outSpkCorr.PairUid = rscTable.PairUid;
outSpkCorr.monkey = rscTable.monkey;
outSpkCorr.session = rscTable.session;
outSpkCorr.X_unitNum = rscTable.X_unitNum;
outSpkCorr.Y_unitNum = rscTable.Y_unitNum;
outSpkCorr.unitArea1 = rscTable.X_area;
outSpkCorr.unitArea2 = rscTable.Y_area;
outSpkCorr.sefVisGrade = rscTable.sefVisGrade;
outSpkCorr.sefMoveGrade = rscTable.sefMoveGrade;
outSpkCorr.isSefErrorUnit = rscTable.isSefErrorUnit;
outSpkCorr.isSefUnitVis = rscTable.isSefUnitVis;
outSpkCorr.isSefUnitMove = rscTable.isSefUnitMove;
outSpkCorr.isSefUnitVisMove = rscTable.isSefUnitVisMove;
outSpkCorr.isSefUnitOther = rscTable.isSefUnitOther;
outSpkCorr.satCondition = regexprep(rscTable.condition,{'Correct','Error.*'},'');
outSpkCorr.outcome = regexprep(rscTable.condition,{'Accurate','Fast'},'');
outSpkCorr.satOutcome = rscTable.condition;
outSpkCorr.nTrials = rscTable.nTrials;
outSpkCorr.rscObserved = rscTable.rho;
outSpkCorr.pvalObserved = rscTable.pval;
outSpkCorr.signif05 = rscTable.signif_05;
outSpkCorr.rscEstimated_40RandomTrials = rscTable.rhoEst40;
outSpkCorr.rscEstimated_80RandomTrials = rscTable.rhoEst80;
outSpkCorr = sortrows(outSpkCorr,{'unitArea1','unitArea2','outcome','satCondition','rscObserved'});
oExcelFile = 'fig08_data.xlsx';
writetable(outSpkCorr,oExcelFile,'UseExcel',true,'Sheet','Rsc_PostSaccade');

%% [Absolute|Signed|Positive|Negative] Rsc bar plots for error/non-error by monks
% useMonkeys = {'Da_Eu','Da','Eu'};
% useErrorTypes = {{'ALL_NEURONS','ERROR_NEURONS','OTHER_NEURONS'}};
% rhoTypes = {'Absolute','Signed','Positive','Negative'};
% for rt = 1:numel(rhoTypes)
%     rhoType = rhoTypes{rt};
%     evalin('base','addCiBox = false;')
%     doBarplotAndAnovaFor(rscTable,rhoType,useMonkeys,useErrorTypes)
%     evalin('base','addCiBox = true;')
%     doBarplotAndAnovaFor(rscTable,rhoType,useMonkeys,useErrorTypes)
% end

%% [Absolute|Signed|Positive|Negative] Rsc bar plots for FEF/SC pairs by monks
useMonkeys = {'Da_Eu'};%,'Da','Eu'};
useAreaTypes = {{'ALL_NEURONS'}};%,'FEF','SC'}};
rhoTypes = {'Positive','Negative'};
for rt = 1:numel(rhoTypes)
    rhoType = rhoTypes{rt};
    evalin('base','addCiBox = true;')
    doBarplotAndAnovaFor(rscTable, rhoType, useMonkeys, useAreaTypes)
end

end % fxn : Fig6B_SpkCorr_PostResponse()


function [] = doBarplotAndAnovaFor( rscTable , rhoType , useMonkeys , useUnitTypes )
switch rhoType
    case 'Absolute'
      rscTable.rho = abs(rscTable.rho);
      rscTable.rhoEst40 = abs(rscTable.rhoEst40);
      rscTable.rhoEst80 = abs(rscTable.rhoEst80);

    case 'Signed'
      ;

    case 'Positive'
      rscTable = rscTable(rscTable.rho > 0,:);

    case 'Negative'        
      rscTable = rscTable(rscTable.rho < 0,:);
      
end

for m = 1:numel(useMonkeys)
    monkeys = useMonkeys(m);
    unitTypes = useUnitTypes;
    fig08RscMonkUnitType(rscTable, monkeys, unitTypes);
end

end % fxn : doBarplotAndAnovaFor()


function [colNames] = getColNamesToUse()
colNames = {
    'Pair_UID'
    'X_monkey'
    'X_sess'
    'X_unitNum'
    'Y_unitNum'
    'X_area'
    'Y_area'
    'X_visGrade'
    'X_moveGrade'
    'X_errGrade'
    'X_rewGrade'
    'xSpkCount_win_150ms'
    'ySpkCount_win_150ms'
    'xMeanFr_spkPerSec_win_150ms'
    'yMeanFr_spkPerSec_win_150ms'
    'condition'
    'alignedName'
    'nTrials'
    'rhoRaw'
    'pvalRaw'
    'signifRaw_05'
    'rhoEstRaw_nTrials_40'
    'rhoEstSem_nTrials_40'
    'ci95_nTrials_40'
    'rhoRawInCi95_nTrials_40'
    'rhoEstRaw_nTrials_80'
    'rhoEstSem_nTrials_80'
    'ci95_nTrials_80'
    'rhoRawInCi95_nTrials_80'
    };
end