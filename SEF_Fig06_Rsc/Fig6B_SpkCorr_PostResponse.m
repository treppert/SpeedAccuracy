function [ varargout ] = Fig6B_SpkCorr_PostResponse( spkCorr , monkey , rhoType )
%Fig6B_SpkCorr_PostResponse() Summary goes here.

%% Create datafile spkCorr -- already done by running. Takes time.
% CREATESPIKECORRWITHSUBSAMPLING
% [spkCorr] = createSpikeCorrWithSubSampling();
% creates the datafile.

Y_AREA = {'SC'};
% FUNC_TYPE = {'ERROR','VISUAL','ALL'};
FUNC_TYPE = {'ERROR'};

colNames = getColNamesToUse();
spkCorr = spkCorr(:,colNames);
spkCorr.Properties.VariableNames = regexprep(colNames,'_150ms','');

spkCorr.satCondition = regexprep(spkCorr.condition,{'Correct','Error.*'},{'',''});
spkCorr.outcome = regexprep(spkCorr.condition,{'Fast','Accurate'},{'',''});
spkCorr.epoch = spkCorr.alignedName;

spkCorr = spkCorr(ismember(spkCorr.epoch,'PostSaccade'),:);

rscTable = table();
rscTable.PairUid = spkCorr.Pair_UID;
rscTable.monkey = spkCorr.X_Monkey;
rscTable.session = spkCorr.X_Session;
rscTable.rho = spkCorr.rhoRaw;
rscTable.pval = spkCorr.pvalRaw;
rscTable.signif_05 = spkCorr.signifRaw_05;
rscTable.rhoEst40 = spkCorr.rhoEstRaw_nTrials_40;
rscTable.rhoEst80 = spkCorr.rhoEstRaw_nTrials_80;
rscTable.isSefErrorUnit = (abs(spkCorr.X_Grade_Err) == 1) | (abs(spkCorr.X_Grade_TErr) == 1);
rscTable.isSefUnitVis = (abs(spkCorr.X_Grade_Vis) > 2);

%% Optional output
if (nargout > 0)
  varargout{1} = sortrows(rscTable,{'X_Index','Y_Index','outcome','satCondition'});
end

%% [Absolute|Signed|Positive|Negative] Rsc bar plots for error/non-error by monks
for rt = 1:numel(rhoType)
  figure()
  evalin('base','addCiBox = true;')
  doBarplotAndAnovaFor(rscTable, rhoType{rt}, monkey, FUNC_TYPE, Y_AREA)
  ppretty([1.2*numel(FUNC_TYPE) 2.4]); ytickformat('%3.2f')
  drawnow
end

end % fxn : Fig6B_SpkCorr_PostResponse()


function [] = doBarplotAndAnovaFor( rscTable , rhoType , useMonkeys , useUnitTypes , yArea )

switch rhoType
    case 'Absolute'
      rscTable.rho = abs(rscTable.rho);
      rscTable.rhoEst40 = abs(rscTable.rhoEst40);
      rscTable.rhoEst80 = abs(rscTable.rhoEst80);
    case 'Positive'
      rscTable = rscTable(rscTable.rho > 0,:);
    case 'Negative'        
      rscTable = rscTable(rscTable.rho < 0,:);
end

fig08RscMonkUnitType(rscTable, useMonkeys, useUnitTypes, yArea);

end % fxn : doBarplotAndAnovaFor()

function [colNames] = getColNamesToUse()
colNames = {
    'Pair_UID'
    'X_Monkey'
    'X_SessionIndex'
    'X_Session'
    'X_Index'
    'Y_Index'
    'X_Area'
    'Y_Area'
    'X_Grade_Vis'
    'X_Grade_Err'
    'X_isErrGrade'
    'X_Grade_TErr'
    'X_isRewGrade'
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