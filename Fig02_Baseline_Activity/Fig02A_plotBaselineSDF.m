function [ ] = Fig02A_plotBaselineSDF( bInfo , pSacc , uInfo , uStats , spikes , varargin )
%Fig02A_plotBaselineSDF Summary of this function goes here
%   Detailed explanation goes here

AREA = 'SEF';
MONKEY = {'D','E'};
F_TYPE = 'VM';

%isolate units from MONKEY and AREA
idxArea = ismember(uInfo.area, AREA);
idxMonkey = ismember(uInfo.monkey, MONKEY);
uInfo = uInfo(idxArea & idxMonkey, :);
uStats = uStats(idxArea & idxMonkey, :);
spikes = spikes(idxArea & idxMonkey, :);

%isolate units of functional type F_TYPE
switch F_TYPE
  case 'V' %visual
    uKeep = (uInfo.visGrade >= 2);
  case 'M' %movement
    uKeep = (uInfo.moveGrade >= 2);
  case 'VM'
    uKeep = (uInfo.visGrade >= 2) | (uInfo.moveGrade >= 2);
  case 'E' %error
    uKeep = (uInfo.errGrade >= 2);
  case 'R' %reward
    uKeep = (abs(uInfo.rewGrade) >= 2);
  otherwise %all
    uKeep = (uInfo.visGrade >= 2) | (uInfo.moveGrade >= 2) | (uInfo.errGrade >= 2) | (abs(uInfo.rewGrade) >= 2);
end
uInfo = uInfo(uKeep, :);
uStats = uStats(uKeep, :);
spikes = spikes(uKeep, :);
NUM_UNIT = sum(uKeep);

T_STIM = 3500 + (-300 : 150); %from stimulus
T_FOCUSED = (-150 : -50); %for "focused" plot

sdfAcc = NaN(NUM_UNIT, length(T_STIM));
sdfFast = NaN(NUM_UNIT, length(T_STIM));

for cc = 1:NUM_UNIT
  fprintf('%s - %s\n', uInfo.sess{cc}, uInfo.unit{cc})
  
  kk = ismember(bInfo.session, uInfo.sess{cc});
  
  %compute single-trial SDF
  SDFcc = compute_spike_density_fxn(spikes{cc});
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(uInfo.trRemSAT{cc}, bInfo.num_trials(kk));
  %index by trial outcome
  idxCorr = ~(bInfo.err_dir{kk} | bInfo.err_time{kk} | bInfo.err_hold{kk} | bInfo.err_nosacc{kk});
  %index by condition
  idxAcc = ((bInfo.condition{kk} == 1) & idxCorr & ~idxIso);
  idxFast = ((bInfo.condition{kk} == 3) & idxCorr & ~idxIso);
  %index by response direction relative to RF and MF
  [visField,~] = determineFieldsVisMove(uInfo.visField{cc}, uInfo.moveField{cc});
  idxRF = ismember(pSacc.octant{kk}, visField);
  
  %split single-trial SDF by condition
  sdfAccST = SDFcc(idxAcc & idxRF, T_STIM);
  sdfFastST = SDFcc(idxFast & idxRF, T_STIM);
  
  %compute mean SDF
  sdfAcc(cc,:) = mean(sdfAccST);
  sdfFast(cc,:) = mean(sdfFastST);
  
end%for:cells(cc)

%% Plotting

%normalization
sdfAcc = sdfAcc ./ uStats.NormalizationFactor(:,1);
sdfFast = sdfFast ./ uStats.NormalizationFactor(:,1);

%split neurons by level of search difficulty
ccLessDiff = (uInfo.taskType == 1);     NUM_LESS_DIFF = sum(ccLessDiff);
ccMoreDiff = (uInfo.taskType == 2);     NUM_MORE_DIFF = sum(ccMoreDiff);
sdfAccLD = sdfAcc(ccLessDiff,:);        sdfFastLD = sdfFast(ccLessDiff,:);
sdfAccMD = sdfAcc(ccMoreDiff,:);        sdfFastMD = sdfFast(ccMoreDiff,:);

T_STIM = T_STIM - 3500;

%time from stimulus for plotting close-up of baseline
IDX_FOCUSED = ismember(T_STIM, T_FOCUSED);

%compute common y-axis scale
tmp = [mean(sdfAccLD) mean(sdfFastLD) mean(sdfAccMD) mean(sdfFastMD)];
yLim = [(min(tmp)-0.05) , (max(tmp)+0.05)];

figure()

%More difficult
subplot(2,2,1); hold on %from stimulus
plot([0 0], yLim, 'k:')
shaded_error_bar(T_STIM, mean(sdfAccMD), std(sdfAccMD)/sqrt(NUM_MORE_DIFF), {'r-', 'LineWidth',1.25})
shaded_error_bar(T_STIM, nanmean(sdfFastMD), nanstd(sdfFastMD)/sqrt(NUM_MORE_DIFF), {'-', 'Color',[0 .7 0], 'LineWidth',1.25})
xlabel('Time from array (ms)'); ytickformat('%2.1f')

subplot(2,2,2); hold on %focused look at baseline
plot(T_FOCUSED, mean(sdfAccMD(:,IDX_FOCUSED)), 'r-', 'LineWidth',1.25)
plot(T_FOCUSED, nanmean(sdfFastMD(:,IDX_FOCUSED)), '-', 'Color',[0 .7 0], 'LineWidth',1.25)

%Less difficult
subplot(2,2,3); hold on %from stimulus
plot([0 0], yLim, 'k:')
shaded_error_bar(T_STIM, mean(sdfAccLD), std(sdfAccLD)/sqrt(NUM_LESS_DIFF), {'r-', 'LineWidth',0.75})
shaded_error_bar(T_STIM, mean(sdfFastLD), std(sdfFastLD)/sqrt(NUM_LESS_DIFF), {'-', 'Color',[0 .7 0], 'LineWidth',0.75})
ylabel('Norm. activity'); ytickformat('%2.1f')

subplot(2,2,4); hold on %focused look at baseline
plot(T_FOCUSED, mean(sdfAccLD(:,IDX_FOCUSED)), 'r-', 'LineWidth',0.75)
plot(T_FOCUSED, mean(sdfFastLD(:,IDX_FOCUSED)), '-', 'Color',[0 .7 0], 'LineWidth',0.75)

ppretty([8,1.8])

end%fxn:Fig02A_plotBaselineSDF()


function [visField , moveField] = determineFieldsVisMove( visField , moveField )

if (isempty(visField) || ismember(9, visField)) %non-specific RF
  visField = (1:8);
else %specific RF
  visField = visField;
end

if (isempty(moveField) || ismember(9, moveField)) %non-specific MF
  moveField = (1:8);
else %specific MF
  moveField = moveField;
end

end%util:determineFieldsVisMove()
