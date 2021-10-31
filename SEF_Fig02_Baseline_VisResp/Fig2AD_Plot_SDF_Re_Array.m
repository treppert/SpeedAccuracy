function [ ] = Fig2AD_Plot_SDF_Re_Array( behavData , unitData , spikes , varargin )
%Fig2AD_Plot_SDF_Re_Array Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}, {'area=',{'SEF'}}, {'fig=',{'A'}}});

if strcmp(args.fig, 'A')
  BLINE_SAT_EFFECT = true;
  T_PLOT = 3500 + (-300 : 200); %from stimulus
  F_TYPE = 'VM'; %neuron functional type
elseif strcmp(args.fig, 'D')
  BLINE_SAT_EFFECT = false;
  T_PLOT = 3500 + (0 : 250); %from stimulus
  F_TYPE = 'V';
end

%isolate units from MONKEY and AREA
idxArea = ismember(unitData.aArea, args.area);
idxMonkey = ismember(unitData.aMonkey, args.monkey);
unitData = unitData(idxArea & idxMonkey, :);
spikes = spikes(idxArea & idxMonkey, :);

%isolate units of functional type F_TYPE
switch F_TYPE
  case 'V' %visual
    uKeep = (unitData.Basic_VisGrade >= 2);
  case 'M' %movement
    uKeep = (unitData.Basic_MovGrade >= 2);
  case 'VM'
    uKeep = (unitData.Basic_VisGrade >= 2) | (unitData.Basic_MovGrade >= 2);
  case 'E' %error
    uKeep = (unitData.Basic_ErrGrade >= 2);
  case 'R' %reward
    uKeep = (abs(unitData.Basic_RewGrade) >= 2);
  otherwise %all
    uKeep = (unitData.Basic_VisGrade >= 2) | (unitData.Basic_MovGrade >= 2) | (unitData.Basic_ErrGrade >= 2) | (abs(unitData.Basic_RewGrade) >= 2);
end

if (BLINE_SAT_EFFECT)
  uKeep = (uKeep & unitData.Baseline_SAT_Effect);
end

unitData = unitData(uKeep, :);
spikes = spikes(uKeep, :);
NUM_UNIT = sum(uKeep);


sdfAcc = NaN(NUM_UNIT, length(T_PLOT));
sdfFast = NaN(NUM_UNIT, length(T_PLOT));

for uu = 1:NUM_UNIT
  fprintf('%s\n', unitData.Properties.RowNames{uu})
  
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  
  %compute single-trial SDF
  SDFcc = compute_spike_density_fxn(spikes{uu});
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & idxCorr & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & idxCorr & ~idxIso);
  %index by response direction relative to RF and MF
  [Basic_VisField,~] = determineFieldsVisMove(unitData.Basic_VisField{uu}, unitData.Basic_MovField{uu});
  idxRF = ismember(behavData.Sacc_Octant{kk}, Basic_VisField);
  
  %split single-trial SDF by condition
  sdfAccST = SDFcc(idxAcc & idxRF, T_PLOT);
  sdfFastST = SDFcc(idxFast & idxRF, T_PLOT);
  
  %compute mean SDF
  sdfAcc(uu,:) = mean(sdfAccST);
  sdfFast(uu,:) = mean(sdfFastST);
  
end%for:cells(uu)

%% Plotting

%normalization
sdfAcc = sdfAcc ./ unitData.Basic_NormFactor(:,1);
sdfFast = sdfFast ./ unitData.Basic_NormFactor(:,1);

%split neurons by level of search efficiency
ccMore = (unitData.Task_LevelDifficulty == 1);   NUM_MORE = sum(ccMore);
ccLess = (unitData.Task_LevelDifficulty == 2);   NUM_LESS = sum(ccLess);
ccBoth = (ccMore | ccLess);   NUM_BOTH = sum(ccBoth);
sdfAccMore = sdfAcc(ccMore,:);     sdfFastMore = sdfFast(ccMore,:);
sdfAccLess = sdfAcc(ccLess,:);     sdfFastLess = sdfFast(ccLess,:);
sdfAccBoth = sdfAcc(ccBoth,:);     sdfFastBoth = sdfFast(ccBoth,:);

T_PLOT = T_PLOT - 3500;

%compute common y-axis scale
tmp = [mean(sdfAccMore) mean(sdfFastMore) mean(sdfAccLess) mean(sdfFastLess)];
yLim = [(min(tmp)-0.05) , (max(tmp)+0.05)];

figure()

if strcmp(args.fig, 'A')
  hold on
  plot([0 0], yLim, 'k:')
  shaded_error_bar(T_PLOT, mean(sdfAccBoth), std(sdfAccBoth)/sqrt(NUM_LESS), {'r-', 'LineWidth',1})
  shaded_error_bar(T_PLOT, nanmean(sdfFastBoth), nanstd(sdfFastBoth)/sqrt(NUM_LESS), {'-', 'Color',[0 .7 0], 'LineWidth',1})
  xlabel('Time from array (ms)'); ytickformat('%2.1f')
  ppretty([4,2])
elseif strcmp(args.fig, 'D') %split on task difficulty
  %More difficult
  subplot(1,2,1); hold on
  plot([0 0], yLim, 'k:')
  shaded_error_bar(T_PLOT, mean(sdfAccLess), std(sdfAccLess)/sqrt(NUM_LESS), {'r-', 'LineWidth',1.25})
  shaded_error_bar(T_PLOT, nanmean(sdfFastLess), nanstd(sdfFastLess)/sqrt(NUM_LESS), {'-', 'Color',[0 .7 0], 'LineWidth',1.25})
  ylabel('Normalized activity'); ytickformat('%2.1f')
  xlabel('Time from array (ms)'); ytickformat('%2.1f')
  %Less difficult
  subplot(1,2,2); hold on
  plot([0 0], yLim, 'k:')
  shaded_error_bar(T_PLOT, mean(sdfAccMore), std(sdfAccMore)/sqrt(NUM_MORE), {'r-', 'LineWidth',0.75})
  shaded_error_bar(T_PLOT, mean(sdfFastMore), std(sdfFastMore)/sqrt(NUM_MORE), {'-', 'Color',[0 .7 0], 'LineWidth',0.75})
  ytickformat('%2.1f')
  ppretty([8,2])
end


end%fxn:Fig02AD_Plot_SDF_Re_Array()


function [Basic_VisField , Basic_MovField] = determineFieldsVisMove( Basic_VisField , Basic_MovField )

if (isempty(Basic_VisField) || ismember(9, Basic_VisField)) ; Basic_VisField = (1:8) ; end %non-specific RF
if (isempty(Basic_MovField) || ismember(9, Basic_MovField)) ; Basic_MovField = (1:8); end %non-specific MF

end%util:determineFieldsVisMove()
