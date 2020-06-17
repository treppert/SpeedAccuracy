function [ ] = Fig02A_plotBaselineSDF_X_Condition( bInfo , uInfo , uStats , spikes )
%Fig02A_plotBaselineSDF_X_Condition Summary of this function goes here
%   Detailed explanation goes here

AREA = 'SEF';
MONKEY = {'E'};
F_TYPE = 'VM';

%isolate units from MONKEY and AREA with baseline SAT effect
idxArea = ismember(uInfo.area, AREA);
idxMonkey = ismember(uInfo.monkey, MONKEY);
idxSATEffect = (uStats.Baseline_SAT_Effect == 1);
idxKeep = (idxArea & idxMonkey & idxSATEffect);
uInfo = uInfo(idxKeep, :);
uStats = uStats(idxKeep, :);
spikes = spikes(idxKeep, :);

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

T_STIM = 3500 + (-300 : 200); %from stimulus

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
  
  %split single-trial SDF by condition
  sdfAccST = SDFcc(idxAcc, T_STIM);
  sdfFastST = SDFcc(idxFast, T_STIM);
  
  %compute mean SDF
  sdfAcc(cc,:) = mean(sdfAccST);
  sdfFast(cc,:) = mean(sdfFastST);
  
end%for:cells(cc)

%% Normalization
sdfAcc = sdfAcc ./ uStats.NormalizationFactor(:,1);
sdfFast = sdfFast ./ uStats.NormalizationFactor(:,1);

%% Plotting
T_STIM = T_STIM - 3500;

figure(); hold on
shaded_error_bar(T_STIM, mean(sdfAcc), std(sdfAcc)/sqrt(NUM_UNIT), {'r-', 'LineWidth',1.25})
shaded_error_bar(T_STIM, nanmean(sdfFast), nanstd(sdfFast)/sqrt(NUM_UNIT), {'-', 'Color',[0 .7 0], 'LineWidth',1.25})
xlabel('Time from array (ms)'); ytickformat('%2.1f')
ppretty([3.2,2])

end % fxn : Fig02A_plotBaselineSDF_X_Condition()
