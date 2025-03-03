function [ ] = Fig2AD_Plot_SDF_Re_Array( behavData , unitData , varargin )
%Fig2AD_Plot_SDF_Re_Array Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}, {'area=',{'SEF'}}});
UNIT_PLOT = 25;

% TVEC_PLOT = 3500 + (-300 : 100); %baseline
TVEC_PLOT = 3500 + (-100 : 500); %visual response

%isolate visually-responsive units from MONKEY and AREA
idxArea = ismember(unitData.Area, args.area);
idxMonkey = ismember(unitData.Monkey, args.monkey);
idxVisResp = (abs(unitData.Grade_Vis) >= 3);
idxSATEffect = (unitData.SAT_Effect(:,2) == -1);
idxKeep = (idxArea & idxMonkey & idxVisResp & idxSATEffect);

unitTest = unitData(idxKeep, :);
NUM_UNIT = sum(idxKeep);

sdfAcc  = NaN(NUM_UNIT, length(TVEC_PLOT));
sdfFast = NaN(NUM_UNIT, length(TVEC_PLOT));

for uu = 1:NUM_UNIT
%   if ~ismember(UNIT_PLOT, unitTest.Index(uu)); continue; end
  fprintf('%s\n', unitTest.Properties.RowNames{uu})
  
  kk = ismember(behavData.Task_Session, unitTest.Session(uu));
  
  %compute single-trial SDF
  spikes_uu = load_spikes_SAT(unitTest.Index(uu));
  SDF_uu = compute_spike_density_fxn(spikes_uu);
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitTest.TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & idxCorr & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & idxCorr & ~idxIso);
  %index by response direction relative to RF and MF
  RF = unitTest.RF{uu};
  idxRF = ismember(behavData.Sacc_Octant{kk}, RF);
  
  %split single-trial SDF by condition
  sdfAccST = SDF_uu(idxAcc & idxRF, TVEC_PLOT);
  sdfFastST = SDF_uu(idxFast & idxRF, TVEC_PLOT);
  
  %compute mean SDF
  sdfAcc(uu,:) = mean(sdfAccST);
  sdfFast(uu,:) = mean(sdfFastST);
  
end%for:cells(uu)

%normalization
sdfAcc = sdfAcc ./ unitTest.NormFactor(:,1);
sdfFast = sdfFast ./ unitTest.NormFactor(:,1);

%% Plotting
TVEC_PLOT = TVEC_PLOT - 3500;

figure(); hold on

plot([0 0], [.2 .8], 'k:')
shaded_error_bar(TVEC_PLOT, nanmean(sdfAcc), nanstd(sdfAcc)/sqrt(NUM_UNIT), {'r-', 'LineWidth',1.25})
shaded_error_bar(TVEC_PLOT, nanmean(sdfFast), nanstd(sdfFast)/sqrt(NUM_UNIT), {'-', 'Color',[0 .7 0], 'LineWidth',1.25})

ylabel('Normalized activity'); ytickformat('%2.1f')
xlabel('Time from array (ms)')
ppretty([2.4,1.2])

end % fxn : Fig02AD_Plot_SDF_Re_Array()
