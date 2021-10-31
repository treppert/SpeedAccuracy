function [ varargout ] = plot_VisualResponse_SAT( behavData , unitData , unitData , spikes )
%plot_VisualResponse_SAT() Summary of this function goes here
%   Detailed explanation goes here

AREA_TEST = 'FEF';
DIR_PRINT = ['C:\Users\Thomas Reppert\Dropbox\SAT\Figures\Figs-VisResp-', AREA_TEST, '\'];

idxArea = ismember(unitData.aArea, {AREA_TEST});
idxMonkey = ismember(unitData.aMonkey, {'D','E','Q','S'});
idxVisUnit = (unitData.Basic_VisGrade >= 2);
idxKeep = (idxArea & idxMonkey & idxVisUnit);

NUM_CELLS = sum(idxKeep);
spikes = spikes(idxKeep);
unitData = unitData(idxKeep,:);
% unitData = unitData(idxKeep,:);

T_STIM = 3500 + (0 : 400);  OFFSET = 0;
NUM_SAMP = length(T_STIM);

sdf_AccTgt = NaN(NUM_CELLS, NUM_SAMP);    sdf_FastTgt = NaN(NUM_CELLS, NUM_SAMP);
sdf_AccDistr = NaN(NUM_CELLS, NUM_SAMP);  sdf_FastDistr = NaN(NUM_CELLS, NUM_SAMP);

for uu = 1:NUM_CELLS
  fprintf('%s - %s\n', unitData.Task_Session(uu), unitData.unit{uu})
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  
  %compute spike density function
  sdf_FromArray = compute_spike_density_fxn(spikes{uu});
  
  %index by isolation quality
  idxPoorIso = identify_trials_poor_isolation_SAT(unitData.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxPoorIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxPoorIso);
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrNoSacc{kk} | behavData.Task_ErrHold{kk});
  %index by response dir re. response field
  if ismember(9, unitData.Basic_VisField{uu})
    idxRF = true(1,behavData.Task_NumTrials(kk));
  else %standard response field
    idxRF = ismember(behavData.octant{kk}, unitData.Basic_VisField{uu});
  end
  
  %get single-trial SDF
  sdfST_AccTgt = sdf_FromArray(idxAcc & idxCorr & idxRF, T_STIM);
  sdfST_AccDistr = sdf_FromArray(idxAcc & idxCorr & ~idxRF, T_STIM);
  sdfST_FastTgt = sdf_FromArray(idxFast & idxCorr & idxRF, T_STIM);
  sdfST_FastDistr = sdf_FromArray(idxFast & idxCorr & ~idxRF, T_STIM);
  
  %compute mean SDF
  sdf_AccTgt(cc,:) = mean(sdfST_AccTgt);      sdf_FastTgt(cc,:) = mean(sdfST_FastTgt);
  sdf_AccDistr(cc,:) = mean(sdfST_AccDistr);  sdf_FastDistr(cc,:) = mean(sdfST_FastDistr);
  
  %% Parameterize the visual response
  uuStats = unitData.unitNum(uu);
  
  %latency - TODO: Util to be updated to compute unitData.VisualResponse_Latency
%   [VRlatAcc,VRlatFast] = computeVisRespLatSAT(VRAcc, VRFast, unitData(uuStats,:), OFFSET);
  %magnitude
%   [VRmagAcc,VRmagFast] = computeVisRespMagSAT(VRAcc, VRFast, unitData(uuStats,:), OFFSET);
%   unitData.VisualResponse_Magnitude(uuStats,1) = VRmagAcc;
%   unitData.VisualResponse_Magnitude(uuStats,2) = VRmagFast;
  %target selection
%   [VRTSTAcc,VRTSTFast,tVecTSH1] = computeVisRespTSTSAT(VRAcc, VRFast, unitData(uuStats,:), OFFSET);
%   unitData.VisResp_TST(uuStats,1) = VRTSTAcc;
%   unitData.VisResp_TST(uuStats,2) = VRTSTFast;
  %normalization factor
%   unitData.NormFactor_Vis(uuStats) = max(visResp(uu).FastTin);
  
  %plot individual cell activity
  sdf_UnitCC = struct('AccTgt',sdf_AccTgt(cc,:), 'AccDistr',sdf_AccDistr(cc,:), ...
    'FastTgt',sdf_FastTgt(cc,:), 'FastDistr',sdf_FastDistr(cc,:));
  plotSDF_UnitCC(T_STIM, sdf_UnitCC, unitData(cc,:), unitData(uuStats,:));
  print([DIR_PRINT, unitData.Task_Session(uu),'-',unitData.unit{uu},'-U',num2str(uuStats),'.tif'], '-dtiff')
  pause(0.1); close()
  
end%for:cells(uu)

if (nargout > 0)
  varargout{1} = unitData;
end

return

%% Plotting - Across cells
figure()

subplot(2,1,1); hold on %more difficult
shaded_error_bar(T_STIM-3500, nanmean(vrAccLess), nanstd(vrAccLess)/sqrt(NUM_LESS), {'r-', 'LineWidth',1.5})
shaded_error_bar(T_STIM-3500, nanmean(vrFastLess), nanstd(vrFastLess)/sqrt(NUM_LESS), {'-', 'Color',[0 .7 0], 'LineWidth',1.5})
ytickformat('%2.1f')

subplot(2,1,2); hold on %less difficult
shaded_error_bar(T_STIM-3500, nanmean(vrAccMore), nanstd(vrAccMore)/sqrt(NUM_MORE), {'r-'})
shaded_error_bar(T_STIM-3500, nanmean(vrFastMore), nanstd(vrFastMore)/sqrt(NUM_MORE), {'-', 'Color',[0 .7 0]})
xlabel('Time from array (ms)'); ylabel('Normalized activity'); ytickformat('%2.1f')

ppretty([4.8,4])

end%fxn:plotVisRespSAT()




function [ ] = plotSDF_UnitCC(T_STIM, SDF, unitData, unitData)

figure()

tmp = [SDF.AccTgt , SDF.AccDistr , SDF.FastTgt , SDF.FastDistr ];
yLim = [min(tmp) max(tmp)];

subplot(3,1,1); hold on %RESPONSIVENESS
plot(unitData.VisualResponse_Latency*ones(1,2), yLim, 'k:', 'LineWidth',0.5)
plot(T_STIM-3500, SDF.FastTgt, '-', 'Color',[0 .7 0])
plot(T_STIM-3500, SDF.AccTgt, 'r-')
ylabel('Activity (sp/sec)')
print_session_unit(gca , unitData, [])

subplot(3,1,2); hold on %TARGET DISCRIM :: Accurate condition
plot(unitData.VRTSTAcc*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
plot(T_STIM-3500, SDF.AccTgt, 'r-', 'LineWidth',0.75)
plot(T_STIM-3500, SDF.AccDistr, 'r:', 'LineWidth',0.5)

subplot(3,1,3); hold on %TARGET DISCRIM :: Fast condition
plot(unitData.VRTSTFast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
plot(T_STIM-3500, SDF.FastTgt, '-', 'Color',[0 .7 0], 'LineWidth',0.75)
plot(T_STIM-3500, SDF.FastDistr, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
xlabel('Time from array (ms)')

ppretty([6,7])

end % util : plotSDF_UnitCC()

