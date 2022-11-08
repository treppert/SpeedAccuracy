function [ ] = Fig6X_SpkCorr_X_Trial( spkCorrA2F , spkCorrF2A , unitData )
%Fig6X_SpkCorr_X_Trial Summary of this function goes here
%   Detailed explanation goes here

%sub-sample pairs with SEF neurons with SAT effect
% uSEF_SATeffect = unitData.Index(ismember(unitData.Area,{'SEF'})  & ismember(unitData.SAT_Effect(:,2),+1));
% idxu_A2F = ismember(spkCorrA2F.X_Index, uSEF_SATeffect);  spkCorrA2F = spkCorrA2F(idxu_A2F,:);
% idxu_F2A = ismember(spkCorrF2A.X_Index, uSEF_SATeffect);  spkCorrF2A = spkCorrF2A(idxu_F2A,:);

trialIndex = ( -4 : 3 );
nTrial = length(trialIndex);

nPair = size(spkCorrA2F,1) / nTrial;

rhoA2F = NaN(nPair,nTrial);
rhoF2A = rhoA2F;

for tt = 1:nTrial

  idxttA2F = (spkCorrA2F.trialIndex == trialIndex(tt));
  idxttF2A = (spkCorrF2A.trialIndex == trialIndex(tt));

  rhoA2F(:,tt) = transpose(spkCorrA2F.rhoRaw(idxttA2F));
  rhoF2A(:,tt) = transpose(spkCorrF2A.rhoRaw(idxttF2A));

end

%% Plotting
XLABEL = {'','','-3','','-1','+1','','+3','','','','-3','','-1','+1','','+3',''};
XLIM = [-5,12];

muA2F = mean(rhoA2F,1); %mean
muF2A = mean(rhoF2A,1);
seA2F = std(rhoA2F,0,1)/sqrt(nPair); %standard error
seF2A = std(rhoF2A,0,1)/sqrt(nPair);

figure(); hold on

errorbar(trialIndex, muA2F, seA2F, 'Color','k', 'CapSize',0)
errorbar(nTrial+trialIndex, muF2A, seF2A, 'Color','k', 'CapSize',0)
xlim(XLIM); xticks(-5:12); xticklabels(XLABEL)
ylabel('r')

ppretty([4.0,1.6])
set(gca, 'XMinorTick','off', 'XTickLabelRotation',45)

end % fxn : Fig6X_SpkCorr_X_Trial()

