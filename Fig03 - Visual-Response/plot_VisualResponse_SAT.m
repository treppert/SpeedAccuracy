function [ varargout ] = plot_VisualResponse_SAT( bInfo , uInfo , uStats , spikes )
%plot_VisualResponse_SAT() Summary of this function goes here
%   Detailed explanation goes here

AREA = 'SEF';
MONKEY = {'D','E'};

idxArea = ismember(uInfo.area, AREA);
idxMonkey = ismember(uInfo.monkey, MONKEY);
idxVisUnit = (uInfo.visGrade >= 2);
idxKeep = (idxArea & idxMonkey & idxVisUnit);

NUM_CELLS = sum(idxKeep);
spikes = spikes(idxKeep);
uInfo = uInfo(idxKeep,:);
% unitStats = unitStats(idxKeep,:);

T_STIM = 3500 + (0 : 250);  OFFSET = 0;
NUM_SAMP = length(T_STIM);

sdf_AccTgt = NaN(NUM_CELLS, NUM_SAMP);    sdf_FastTgt = NaN(NUM_CELLS, NUM_SAMP);
sdf_AccDistr = NaN(NUM_CELLS, NUM_SAMP);  sdf_FastDistr = NaN(NUM_CELLS, NUM_SAMP);

for cc = 1:NUM_CELLS
  fprintf('%s - %s\n', uInfo.sess{cc}, uInfo.unit{cc})
  kk = ismember(bInfo.session, uInfo.sess{cc});
  
  %compute spike density function
  sdf_FromArray = compute_spike_density_fxn(spikes{cc});
  
  %index by isolation quality
  idxPoorIso = identify_trials_poor_isolation_SAT(uInfo.trRemSAT{cc}, bInfo.num_trials(kk));
  %index by condition
  idxAcc = ((bInfo.condition{kk} == 1) & ~idxPoorIso);
  idxFast = ((bInfo.condition{kk} == 3) & ~idxPoorIso);
  %index by trial outcome
  idxCorr = ~(bInfo.err_dir{kk} | bInfo.err_time{kk} | bInfo.err_nosacc{kk} | bInfo.err_hold{kk});
  %index by response dir re. response field
  if ismember(9, uInfo.visField{cc})
    idxRF = true(1,bInfo.num_trials(kk));
  else %standard response field
    idxRF = ismember(bInfo.octant{kk}, uInfo.visField{cc});
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
  ccStats = uInfo.unitNum(cc);
  
  %latency - TODO: Util to be updated to compute unitInfo.VR_Latency
%   [VRlatAcc,VRlatFast] = computeVisRespLatSAT(VRAcc, VRFast, nstats(ccStats), OFFSET);
  %magnitude
%   [VRmagAcc,VRmagFast] = computeVisRespMagSAT(VRAcc, VRFast, nstats(ccStats), OFFSET);
%   nstats(ccStats).VRmagAcc = VRmagAcc;
%   nstats(ccStats).VRmagFast = VRmagFast;
  %target selection
%   [VRTSTAcc,VRTSTFast,tVecTSH1] = computeVisRespTSTSAT(VRAcc, VRFast, nstats(ccStats), OFFSET);
%   nstats(ccStats).VRTSTAcc = VRTSTAcc;
%   nstats(ccStats).VRTSTFast = VRTSTFast;
  %normalization factor
%   unitStats.NormFactor_Vis(ccStats) = max(visResp(cc).FastTin);
  
  %plot individual cell activity
%   sdf_UnitCC = struct('AccTgt',sdf_AccTgt(cc,:), 'AccDistr',sdf_AccDistr(cc,:), ...
%     'FastTgt',sdf_FastTgt(cc,:), 'FastDistr',sdf_FastDistr(cc,:));
%   plotSDF_UnitCC(T_STIM, sdf_UnitCC, unitInfo(cc,:), unitStats(ccStats,:));
%   print([DIR_PRINT, unitInfo.sess{cc},'-',unitInfo.unit{cc},'-U',num2str(ccStats),'.tif'], '-dtiff')
%   pause(0.1); close()
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = uStats;
end

%% Plotting - Across cells
figure()

subplot(2,1,1); hold on %more difficult
shaded_error_bar(T_STIM-3500, nanmean(sdf_AccTgt), nanstd(sdf_AccTgt)/sqrt(NUM_CELLS), {'r-', 'LineWidth',1.5})
shaded_error_bar(T_STIM-3500, nanmean(sdf_FastTgt), nanstd(sdf_FastTgt)/sqrt(NUM_CELLS), {'-', 'Color',[0 .7 0], 'LineWidth',1.5})

subplot(2,1,2); hold on %less difficult
% shaded_error_bar(T_STIM-3500, nanmean(vrAccMore), nanstd(vrAccMore)/sqrt(NUM_MORE), {'r-'})
% shaded_error_bar(T_STIM-3500, nanmean(vrFastMore), nanstd(vrFastMore)/sqrt(NUM_MORE), {'-', 'Color',[0 .7 0]})
xlabel('Time from array (ms)'); ylabel('Normalized activity'); ytickformat('%2.1f')

ppretty([4.8,4])

end%fxn:plotVisRespSAT()




function [ ] = plotSDF_UnitCC(T_STIM, SDF, unitInfo, unitStats)

figure()

tmp = [SDF.AccTgt , SDF.AccDistr , SDF.FastTgt , SDF.FastDistr ];
yLim = [min(tmp) max(tmp)];

subplot(3,1,1); hold on %RESPONSIVENESS
plot(unitStats.VR_Latency*ones(1,2), yLim, 'k:', 'LineWidth',0.5)
plot(T_STIM-3500, SDF.FastTgt, '-', 'Color',[0 .7 0])
plot(T_STIM-3500, SDF.AccTgt, 'r-')
ylabel('Activity (sp/sec)')
print_session_unit(gca , unitInfo, [])

subplot(3,1,2); hold on %TARGET DISCRIM :: Accurate condition
plot(unitStats.VRTSTAcc*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
plot(T_STIM-3500, SDF.AccTgt, 'r-', 'LineWidth',0.75)
plot(T_STIM-3500, SDF.AccDistr, 'r:', 'LineWidth',0.5)

subplot(3,1,3); hold on %TARGET DISCRIM :: Fast condition
plot(unitStats.VRTSTFast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
plot(T_STIM-3500, SDF.FastTgt, '-', 'Color',[0 .7 0], 'LineWidth',0.75)
plot(T_STIM-3500, SDF.FastDistr, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
xlabel('Time from array (ms)')

ppretty([6,7])

end % util : plotSDF_UnitCC()

