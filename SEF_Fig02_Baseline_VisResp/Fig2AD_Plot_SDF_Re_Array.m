function [ ] = Fig2AD_Plot_SDF_Re_Array( behavData , unitData , varargin )
%Fig2AD_Plot_SDF_Re_Array Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}, {'area=',{'SEF'}}, {'fig=',{'D'}}});

if strcmp(args.fig, 'A')
  BLINE_SAT_EFFECT = true;
  T_PLOT = 3500 + (-300 : 200); %from stimulus
elseif strcmp(args.fig, 'D')
  BLINE_SAT_EFFECT = false;
  T_PLOT = 3500 + (0 : 250); %from stimulus
end

%isolate visually-responsive units from MONKEY and AREA
idxArea = ismember(unitData.Area, args.area);
idxMonkey = ismember(unitData.Monkey, args.monkey);
idxFxn = (unitData.Grade_Vis >= 3);
idxKeep = (idxArea & idxMonkey & idxFxn);

if (BLINE_SAT_EFFECT)
  idxKeep = (idxKeep & unitData.SAT_Effect_Baseline);
end

unitData = unitData(idxKeep, :);
NUM_UNIT = sum(idxKeep);

sdfAcc = NaN(NUM_UNIT, length(T_PLOT));
sdfFast = NaN(NUM_UNIT, length(T_PLOT));

for uu = 1:NUM_UNIT
  fprintf('%s\n', unitData.Properties.RowNames{uu})
  
  kk = ismember(behavData.Task_Session, unitData.Session(uu));
  
  %compute single-trial SDF
  spikes_uu = load_spikes_SAT(unitData.Index(uu), 'user','thoma');
  SDF_uu = compute_spike_density_fxn(spikes_uu);
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitData.TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & idxCorr & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & idxCorr & ~idxIso);
  %index by response direction relative to RF and MF
  RF = unitData.RF{uu};
  idxRF = ismember(behavData.Sacc_Octant{kk}, RF);
  
  %split single-trial SDF by condition
  sdfAccST = SDF_uu(idxAcc & idxRF, T_PLOT);
  sdfFastST = SDF_uu(idxFast & idxRF, T_PLOT);
  
  %compute mean SDF
  sdfAcc(uu,:) = mean(sdfAccST);
  sdfFast(uu,:) = mean(sdfFastST);
  
end%for:cells(uu)

%normalization
sdfAcc = sdfAcc ./ unitData.NormFactor(:,1);
sdfFast = sdfFast ./ unitData.NormFactor(:,1);

%% Plotting
T_PLOT = T_PLOT - 3500;

figure(); hold on

plot([0 0], [.2 .8], 'k:')
shaded_error_bar(T_PLOT, nanmean(sdfAcc), nanstd(sdfAcc)/sqrt(NUM_UNIT), {'r-', 'LineWidth',1.25})
shaded_error_bar(T_PLOT, nanmean(sdfFast), nanstd(sdfFast)/sqrt(NUM_UNIT), {'-', 'Color',[0 .7 0], 'LineWidth',1.25})

ylabel('Normalized activity'); ytickformat('%2.1f')
xlabel('Time from array (ms)')
ppretty([2.4,1.2])

end % fxn : Fig02AD_Plot_SDF_Re_Array()
