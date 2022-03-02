function [ ] = Fig2AD_Plot_SDF_Re_Array( behavData , unitData , spikesSAT , varargin )
%Fig2AD_Plot_SDF_Re_Array Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}, {'area=',{'SEF'}}, {'fig=',{'D'}}});

if strcmp(args.fig, 'A')
  BLINE_SAT_EFFECT = true;
  T_PLOT = 3500 + (-300 : 200); %from stimulus
  F_TYPE = 'V'; %neuron functional type
elseif strcmp(args.fig, 'D')
  BLINE_SAT_EFFECT = false;
  T_PLOT = 3500 + (0 : 250); %from stimulus
  F_TYPE = 'V';
end

%isolate units from MONKEY and AREA
idxArea = ismember(unitData.aArea, args.area);
idxMonkey = ismember(unitData.aMonkey, args.monkey);
unitData = unitData(idxArea & idxMonkey, :);
spikesSAT = spikesSAT(idxArea & idxMonkey, :);

%isolate units of functional type F_TYPE
switch F_TYPE
  case 'V' %visual
    uKeep = (unitData.Grade_Vis >= 3);
  case 'M' %movement
    uKeep = (unitData.Grade_Mov >= 3);
  case 'VM'
    uKeep = (unitData.Grade_Vis >= 3) | (unitData.Grade_Mov >= 3);
  case 'E' %error
    uKeep = (unitData.Grade_Err >= 2);
  case 'R' %reward
    uKeep = (abs(unitData.Grade_Rew) >= 2);
  otherwise %all
    uKeep = (unitData.Grade_Vis >= 3) | (unitData.Grade_Mov >= 3);
end

if (BLINE_SAT_EFFECT)
  uKeep = (uKeep & unitData.SAT_Effect_Baseline);
end

unitData = unitData(uKeep, :);
spikesSAT = spikesSAT(uKeep, :);
NUM_UNIT = sum(uKeep);

sdfAcc = NaN(NUM_UNIT, length(T_PLOT));
sdfFast = NaN(NUM_UNIT, length(T_PLOT));

for uu = 1:NUM_UNIT
  fprintf('%s\n', unitData.Properties.RowNames{uu})
  
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  
  %compute single-trial SDF
  SDF_uu = compute_spike_density_fxn(spikesSAT{uu});
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & idxCorr & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & idxCorr & ~idxIso);
  %index by response direction relative to RF and MF
  RF = unitData.RF{uu};
  if ismember(9, RF) %RF is omni-directional
    idxRF = true(behavData.Task_NumTrials(kk),1);
  else
    idxRF = ismember(behavData.Sacc_Octant{kk}, RF);
  end
  
  %split single-trial SDF by condition
  sdfAccST = SDF_uu(idxAcc & idxRF, T_PLOT);
  sdfFastST = SDF_uu(idxFast & idxRF, T_PLOT);
  
  %compute mean SDF
  sdfAcc(uu,:) = nanmean(sdfAccST);
  sdfFast(uu,:) = nanmean(sdfFastST);
  
end%for:cells(uu)

%normalization
sdfAcc = sdfAcc ./ unitData.Basic_NormFactor(:,1);
sdfFast = sdfFast ./ unitData.Basic_NormFactor(:,1);

%% Plotting


T_PLOT = T_PLOT - 3500;

figure()

if strcmp(args.fig, 'A')
  
  hold on
  plot([0 0], [.2 .8], 'k:')
  shaded_error_bar(T_PLOT, nanmean(sdfAcc), nanstd(sdfAcc)/sqrt(NUM_UNIT), {'r-', 'LineWidth',1})
  shaded_error_bar(T_PLOT, nanmean(sdfFast), nanstd(sdfFast)/sqrt(NUM_UNIT), {'-', 'Color',[0 .7 0], 'LineWidth',1})
  xlabel('Time from array (ms)'); ytickformat('%2.1f')
  ppretty([4,2])
  
elseif strcmp(args.fig, 'D') %split on task difficulty
  
  %split neurons by level of search efficiency
  uuLess = (unitData.Task_LevelDifficulty == 1);   NUM_LESS = sum(uuLess);
  uuMore = (unitData.Task_LevelDifficulty == 2);   NUM_MORE = sum(uuMore);
  sdfAccLess = sdfAcc(uuLess,:);     sdfFastLess = sdfFast(uuLess,:);
  sdfAccMore = sdfAcc(uuMore,:);     sdfFastMore = sdfFast(uuMore,:);
  
  %More difficult
  subplot(1,2,1); hold on
  plot([0 0], [.2 .8], 'k:')
  shaded_error_bar(T_PLOT, mean(sdfAccMore), std(sdfAccMore)/sqrt(NUM_MORE), {'r-', 'LineWidth',1.25})
  shaded_error_bar(T_PLOT, mean(sdfFastMore), std(sdfFastMore)/sqrt(NUM_MORE), {'-', 'Color',[0 .7 0], 'LineWidth',1.25})
  ylabel('Normalized activity'); ytickformat('%2.1f')
  xlabel('Time from array (ms)'); ytickformat('%2.1f')
  
  %Less difficult
  subplot(1,2,2); hold on
  plot([0 0], [.2 .8], 'k:')
  shaded_error_bar(T_PLOT, nanmean(sdfAccLess), nanstd(sdfAccLess)/sqrt(NUM_LESS), {'r-', 'LineWidth',0.75})
  shaded_error_bar(T_PLOT, nanmean(sdfFastLess), nanstd(sdfFastLess)/sqrt(NUM_LESS), {'-', 'Color',[0 .7 0], 'LineWidth',0.75})
  ytickformat('%2.1f')
  ppretty([8,2])
  
end % if (FigA) else (FigD)


end % fxn : Fig02AD_Plot_SDF_Re_Array()
