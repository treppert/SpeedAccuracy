function [ varargout ] = Fig6B_SpkCorr_PostResponse( spkCorr , monkey , rhoType , neuronType )
%Fig6B_SpkCorr_PostResponse() Summary goes here.

%% Create datafile spkCorr -- already done by running. Takes time.
% CREATESPIKECORRWITHSUBSAMPLING
% [spkCorr] = createSpikeCorrWithSubSampling();
% creates the datafile.

%focus on the post-response interval
spkCorr = spkCorr(ismember(spkCorr.alignedName,'PostSaccade'),:);

varNames = spkCorr.Properties.VariableNames;
spkCorr.Properties.VariableNames = regexprep(varNames,'_150ms','');

spkCorr.satCondition = regexprep(spkCorr.condition,{'Correct','Error.*'},{'',''});
spkCorr.outcome = regexprep(spkCorr.condition,{'Fast','Accurate'},{'',''});
spkCorr.epoch = spkCorr.alignedName;

spkCorr.PairUid = spkCorr.Pair_UID;
spkCorr.monkey = spkCorr.X_Monkey;
spkCorr.session = spkCorr.X_Session;
spkCorr.rho = spkCorr.rhoRaw;
spkCorr.pval = spkCorr.pvalRaw;
spkCorr.signif_05 = spkCorr.signifRaw_05;
spkCorr.rhoEst40 = spkCorr.rhoEstRaw_nTrials_40;
spkCorr.rhoEst80 = spkCorr.rhoEstRaw_nTrials_80;

%% Optional output
if (nargout > 0)
  varargout{1} = sortrows(spkCorr,{'X_Index','Y_Index','outcome','satCondition'});
end

%% [Absolute|Signed|Positive|Negative] Rsc bar plots for error/non-error by monks
for rt = 1:numel(rhoType)
  figure()
  evalin('base','addCiBox = true;')
  doBarplotAndAnovaFor(spkCorr, rhoType{rt}, monkey, neuronType)
  ppretty([1.2*numel(neuronType) 2.4]); ytickformat('%3.2f')
  drawnow
end

end % fxn : Fig6B_SpkCorr_PostResponse()


function [] = doBarplotAndAnovaFor( spkCorr , rhoType , useMonkeys , useUnitTypes )

switch rhoType
    case 'Absolute'
      spkCorr.rho = abs(spkCorr.rho);
      spkCorr.rhoEst40 = abs(spkCorr.rhoEst40);
      spkCorr.rhoEst80 = abs(spkCorr.rhoEst80);
    case 'Positive'
      spkCorr = spkCorr(spkCorr.rho > 0,:);
    case 'Negative'        
      spkCorr = spkCorr(spkCorr.rho < 0,:);
end

fig08RscMonkUnitType(spkCorr, useMonkeys, useUnitTypes);

end % fxn : doBarplotAndAnovaFor()
