nPair = size(spkCorr,1) / 24; %24 = 6(conditionXoutcome) * 4(epoch)

%index by SAT condition and trial outcome
idxAC  = ismember(spkCorr.condition, {'AccurateCorrect'});
idxFC  = ismember(spkCorr.condition, {'FastCorrect'});

%signed value spike count correlation
r_AC = spkCorr.rhoRaw(idxAC); %Accurate correct
r_AC = transpose(reshape(r_AC,4,nPair));
r_FC = spkCorr.rhoRaw(idxFC); %Fast correct
r_FC = transpose(reshape(r_FC,4,nPair));

%SEF firing rate
FR_AC = spkCorr.xMeanFr_spkPerSec_win_200ms(idxAC);
FR_AC = transpose(reshape(FR_AC,4,nPair));
FR_FC = spkCorr.xMeanFr_spkPerSec_win_200ms(idxFC);
FR_FC = transpose(reshape(FR_FC,4,nPair));

%FEF/SC firing rate
% FR_AC = spkCorr.yMeanFr_spkPerSec_win_200ms(idxAC);
% FR_AC = transpose(reshape(FR_AC,4,nPair));
% FR_FC = spkCorr.yMeanFr_spkPerSec_win_200ms(idxFC);
% FR_FC = transpose(reshape(FR_FC,4,nPair));

%% Plotting - rsc X firing rate
GREEN = [0 .7 0];

figure()

%Accurate condition
subplot(2,4,1); title('Baseline'); hold on
scatter(FR_AC(:,1), r_AC(:,1), 10, 'r', 'filled', 'o', 'MarkerFaceAlpha',0.5)
ytickformat('%2.1f')

subplot(2,4,2); title('Visual response'); hold on
scatter(FR_AC(:,2), r_AC(:,2), 10, 'r', 'filled', 'o', 'MarkerFaceAlpha',0.5)
ytickformat('%2.1f')

subplot(2,4,3); title('Post saccade'); hold on
scatter(FR_AC(:,3), r_AC(:,3), 10, 'r', 'filled', 'o', 'MarkerFaceAlpha',0.5)
ytickformat('%2.1f')

subplot(2,4,4); title('Post reward'); hold on
scatter(FR_AC(:,4), r_AC(:,4), 10, 'r', 'filled', 'o', 'MarkerFaceAlpha',0.5)
ytickformat('%2.1f')

%Fast condition
subplot(2,4,5); title('Baseline'); hold on
scatter(FR_FC(:,1), r_FC(:,1), 10, GREEN, 'filled', 'o', 'MarkerFaceAlpha',0.5)
xlabel('SEF firing rate (sp/sec)'); ylabel('r')
ytickformat('%2.1f')

subplot(2,4,6); title('Visual response'); hold on
scatter(FR_FC(:,2), r_FC(:,2), 10, GREEN, 'filled', 'o', 'MarkerFaceAlpha',0.5)
ytickformat('%2.1f')

subplot(2,4,7); title('Post saccade'); hold on
scatter(FR_FC(:,3), r_FC(:,3), 10, GREEN, 'filled', 'o', 'MarkerFaceAlpha',0.5)
ytickformat('%2.1f')

subplot(2,4,8); title('Post reward'); hold on
scatter(FR_FC(:,4), r_FC(:,4), 10, GREEN, 'filled', 'o', 'MarkerFaceAlpha',0.5)
ytickformat('%2.1f')

ppretty([8,2])

clearvars -except behavData unitData spkCorr stats* r_*
