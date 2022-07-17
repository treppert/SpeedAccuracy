function [ ] = Fig6X_SpkCorr_X_Trial( spkCorrA2F , spkCorrF2A )
%Fig6X_SpkCorr_X_Trial Summary of this function goes here
%   Detailed explanation goes here

TRIAL_PLOT = ( -4 : 3 );
NUM_TRIAL = length(TRIAL_PLOT);

idxVis = (abs(spkCorrA2F.X_Grade_Vis) > 2);   nVis = sum(idxVis);
idxCE  = (abs(spkCorrA2F.X_Grade_Err) == 1);  nCE  = sum(idxCE);
idxTE  = (abs(spkCorrA2F.X_Grade_TErr) == 1); nTE  = sum(idxTE);

% idxPairFEF = strcmp(spkCorr.Y_Area, 'FEF');
% idxPairSC  = strcmp(spkCorr.Y_Area, 'SC');

rhoA2F = abs(transpose(cell2mat(transpose(spkCorrA2F.rhoRaw))));
rhoF2A = abs(transpose(cell2mat(transpose(spkCorrF2A.rhoRaw))));


XLABEL = {'','-3','','-1','+1','','+3','','','','-3','','-1','+1','','+3',''};
XLIM = [-4,11];

figure()

subplot(3,1,1); hold on %Visual response
title('Neurons - Visual response', 'FontSize',7)
errorbar(TRIAL_PLOT           , mean(rhoA2F(idxVis,:)), std(rhoA2F(idxVis,:))/sqrt(nVis), 'Color','k', 'CapSize',0)
errorbar(TRIAL_PLOT+NUM_TRIAL , mean(rhoF2A(idxVis,:)), std(rhoF2A(idxVis,:))/sqrt(nVis), 'Color','k', 'CapSize',0)
xlim(XLIM); xticks([])
ylabel('Spike count corr.')

subplot(3,1,2); hold on %Choice error signal
title('Neurons - Choice error', 'FontSize',7)
errorbar(TRIAL_PLOT           , mean(rhoA2F(idxCE,:)), std(rhoA2F(idxCE,:))/sqrt(nCE), 'Color','k', 'CapSize',0)
errorbar(TRIAL_PLOT+NUM_TRIAL , mean(rhoF2A(idxCE,:)), std(rhoF2A(idxCE,:))/sqrt(nCE), 'Color','k', 'CapSize',0)
xlim(XLIM); xticks([])
ylabel('Spike count corr.')

subplot(3,1,3); hold on %Timing error signal
title('Neurons - Timing error', 'FontSize',7)
errorbar(TRIAL_PLOT           , mean(rhoA2F(idxTE,:)), std(rhoA2F(idxTE,:))/sqrt(nTE), 'Color','k', 'CapSize',0)
errorbar(TRIAL_PLOT+NUM_TRIAL , mean(rhoF2A(idxTE,:)), std(rhoF2A(idxTE,:))/sqrt(nTE), 'Color','k', 'CapSize',0)
xlim(XLIM); xticks(-5:12); xticklabels(XLABEL)
ylabel('Spike count corr.')

ppretty([1.6,4.0])
set(gca, 'XMinorTick','off', 'XTickLabelRotation',45)

end % fxn : Fig6X_SpkCorr_X_Trial()

