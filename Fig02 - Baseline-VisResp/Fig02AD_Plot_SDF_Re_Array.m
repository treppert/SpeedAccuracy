function [ ] = Fig02AD_Plot_SDF_Re_Array( behavData , unitData , spikes )
%Fig02AD_Plot_SDF_Re_Array Summary of this function goes here
%   Detailed explanation goes here

AREA = 'SEF';
MONKEY = {'D','E'};
F_TYPE = 'VM';

T_PLOT = 3500 + (-300 : 200); %from stimulus

%isolate units from MONKEY and AREA
idxArea = ismember(unitData.area, AREA);
idxMonkey = ismember(unitData.monkey, MONKEY);
unitData = unitData(idxArea & idxMonkey, :);
spikes = spikes(idxArea & idxMonkey, :);

%isolate units of functional type F_TYPE
switch F_TYPE
  case 'V' %visual
    uKeep = (unitData.visGrade >= 2);
  case 'M' %movement
    uKeep = (unitData.moveGrade >= 2);
  case 'VM'
    uKeep = (unitData.visGrade >= 2) | (unitData.moveGrade >= 2);
  case 'E' %error
    uKeep = (unitData.errGrade >= 2);
  case 'R' %reward
    uKeep = (abs(unitData.rewGrade) >= 2);
  otherwise %all
    uKeep = (unitData.visGrade >= 2) | (unitData.moveGrade >= 2) | (unitData.errGrade >= 2) | (abs(unitData.rewGrade) >= 2);
end

unitData = unitData(uKeep, :);
spikes = spikes(uKeep, :);
NUM_UNIT = sum(uKeep);


sdfAcc = NaN(NUM_UNIT, length(T_PLOT));
sdfFast = NaN(NUM_UNIT, length(T_PLOT));

for cc = 1:NUM_UNIT
  fprintf('%s - %s\n', unitData.sess{cc}, unitData.unit{cc})
  
  kk = ismember(behavData.session, unitData.sess{cc});
  
  %compute single-trial SDF
  SDFcc = compute_spike_density_fxn(spikes{cc});
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData.trRemSAT{cc}, behavData.num_trials(kk));
  %index by trial outcome
  idxCorr = ~(behavData.err_dir{kk} | behavData.err_time{kk} | behavData.err_hold{kk} | behavData.err_nosacc{kk});
  %index by condition
  idxAcc = ((behavData.condition{kk} == 1) & idxCorr & ~idxIso);
  idxFast = ((behavData.condition{kk} == 3) & idxCorr & ~idxIso);
  %index by response direction relative to RF and MF
  [visField,~] = determineFieldsVisMove(unitData.visField{cc}, unitData.moveField{cc});
  idxRF = ismember(behavData.octant{kk}, visField);
  
  %split single-trial SDF by condition
  sdfAccST = SDFcc(idxAcc & idxRF, T_PLOT);
  sdfFastST = SDFcc(idxFast & idxRF, T_PLOT);
  
  %compute mean SDF
  sdfAcc(cc,:) = mean(sdfAccST);
  sdfFast(cc,:) = mean(sdfFastST);
  
end%for:cells(cc)

%% Plotting

%normalization
sdfAcc = sdfAcc ./ unitData.NormalizationFactor(:,1);
sdfFast = sdfFast ./ unitData.NormalizationFactor(:,1);

%split neurons by level of search efficiency
ccMore = ([unitData.taskType] == 1);   NUM_MORE = sum(ccMore);
ccLess = ([unitData.taskType] == 2);   NUM_LESS = sum(ccLess);
sdfAccMore = sdfAcc(ccMore,:);     sdfFastMore = sdfFast(ccMore,:);
sdfAccLess = sdfAcc(ccLess,:);     sdfFastLess = sdfFast(ccLess,:);

T_PLOT = T_PLOT - 3500;

%compute common y-axis scale
tmp = [mean(sdfAccMore) mean(sdfFastMore) mean(sdfAccLess) mean(sdfFastLess)];
yLim = [(min(tmp)-0.05) , (max(tmp)+0.05)];

figure()

%Less efficient
subplot(1,2,1); hold on %from stimulus
plot([0 0], yLim, 'k:')
shaded_error_bar(T_PLOT, mean(sdfAccLess), std(sdfAccLess)/sqrt(NUM_LESS), {'r-', 'LineWidth',1.25})
shaded_error_bar(T_PLOT, nanmean(sdfFastLess), nanstd(sdfFastLess)/sqrt(NUM_LESS), {'-', 'Color',[0 .7 0], 'LineWidth',1.25})
xlabel('Time from array (ms)'); ytickformat('%2.1f')

%More efficient
subplot(1,2,2); hold on %from stimulus
plot([0 0], yLim, 'k:')
shaded_error_bar(T_PLOT, mean(sdfAccMore), std(sdfAccMore)/sqrt(NUM_MORE), {'r-', 'LineWidth',0.75})
shaded_error_bar(T_PLOT, mean(sdfFastMore), std(sdfFastMore)/sqrt(NUM_MORE), {'-', 'Color',[0 .7 0], 'LineWidth',0.75})
ylabel('Norm. activity'); ytickformat('%2.1f')

ppretty([8,2])

end%fxn:Fig02AD_Plot_SDF_Re_Array()


function [visField , moveField] = determineFieldsVisMove( visField , moveField )

if (isempty(visField) || ismember(9, visField)) ; visField = (1:8) ; end %non-specific RF
if (isempty(moveField) || ismember(9, moveField)) ; moveField = (1:8); end %non-specific MF

end%util:determineFieldsVisMove()
