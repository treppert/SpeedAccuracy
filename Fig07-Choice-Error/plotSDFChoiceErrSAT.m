function [ varargout ] = plotSDFChoiceErrSAT( behavInfo , primarySacc , secondSacc , unitInfo , unitStats , spikes )
%plotSDFChoiceErrSAT() Summary of this function goes here
%   Detailed explanation goes here

ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\SAT\Figures\Post-Response\';

idxArea = ismember(unitInfo.area, {'SEF'});
idxMonkey = ismember(unitInfo.monkey, {'D','E'});
idxErrUnit = (unitInfo.errGrade >= 2);
idxKeep = (idxArea & idxMonkey & idxErrUnit);

NUM_CELLS = sum(idxKeep);
unitInfo = unitInfo(idxKeep,:);
unitStats = unitStats(idxKeep,:);
spikes = spikes(idxKeep);

TIME.PRIMARY = 3500 + (-300 : 500); OFFSET = 300; %time from primary saccade
TIME.SECONDARY = 3500 + (-200 : 300); %time from secondary saccade

%output initializations
sdfAcc = new_struct({'RePrimary','ReSecondary','Baseline'}, 'dim',[1,NUM_CELLS]);
sdfAcc = struct('Corr',sdfAcc, 'Err',sdfAcc);
sdfFast = sdfAcc;

for cc = 1:NUM_CELLS
  fprintf('%s - %s\n', unitInfo.sess{cc}, unitInfo.unit{cc})
  kk = ismember(behavInfo.session, unitInfo.sess{cc});
  
  RT_Primary_kk = primarySacc.resptime{kk};
  RT_Primary_kk(RT_Primary_kk > 900) = NaN; %hard limit on primary RT
  RT_Second_kk = secondSacc.resptime{kk};
  RT_Second_kk(RT_Second_kk < 0) = NaN; %trials with no secondary saccade
  
  %prepare event-aligned SDFs
  SDF_FromArray = compute_spike_density_fxn(spikes{cc});
  SDF_FromPrimary = align_signal_on_response(SDF_FromArray, RT_Primary_kk);
  SDF_FromSecond  = align_signal_on_response(SDF_FromArray, RT_Second_kk);
  
  %index by isolation quality
  idxPoorIso = identify_trials_poor_isolation_SAT(unitInfo(cc), behavInfo(kk).num_trials, 'task','SAT');
  %index by second saccade endpoint
  idxSS2Tgt = (secondSacc.endpt{kk} == 1);
  idxSS2Distr = (secondSacc.endpt{kk} == 2);
  %index by condition
  idxAcc = ((behavInfo(kk).condition == 1) & ~idxPoorIso & (idxSS2Tgt | idxSS2Distr));
  idxFast = ((behavInfo(kk).condition == 3) & ~idxPoorIso & (idxSS2Tgt | idxSS2Distr));
  %index by trial outcome
  idxCorr = ~(behavInfo(kk).err_dir | behavInfo(kk).err_time | behavInfo(kk).err_hold | behavInfo(kk).err_nosacc);
  idxErrChc = (behavInfo(kk).err_dir & ~behavInfo(kk).err_time);
  
  %set "ISI" on correct trials as median ISI of choice error trials
%   ISI_kk(idxFast & idxCorr) = round(nanmedian(ISI_kk(idxFast & idxErrChc)));
%   ISI_kk(idxAcc & idxCorr) = round(nanmedian(ISI_kk(idxAcc & idxErrChc)));
  
  %perform RT matching across Correct and Error trials
  [Trials.AccCorr,  Trials.AccErr]  = matchRT_Correct_Error(RT_Primary_kk, idxAcc,  idxCorr, idxErrChc);
  [Trials.FastCorr, Trials.FastErr] = matchRT_Correct_Error(RT_Primary_kk, idxFast, idxCorr, idxErrChc);
  
  %get single-trials SDFs
  [sdfAccST, sdfFastST] = getSingleTrialSDF(RT_Primary_kk, RT_Second_kk, spikes(cc).SAT, trials, TIME);
  
  %compute mean SDFs
  [sdfAcc.Corr(cc),sdfAcc.Err(cc)] = computeMeanSDF( sdfAccST );
  [sdfFast.Corr(cc),sdfFast.Err(cc)] = computeMeanSDF( sdfFastST );
  sdfCombined = struct('AccCorr',sdfAcc.Corr(cc), 'AccErr',sdfAcc.Err(cc), 'FastCorr',sdfFast.Corr(cc), 'FastErr',sdfFast.Err(cc));
    
  %% Parameterize the SDF
  ccStats = unitInfo(cc).unitNum;
  
  %plot individual cell activity
  plotSDF_UnitCC(TIME, sdfCombined, unitInfo(cc,:), nstats(ccStats))
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = unitStats;
end

end%fxn:plotSDFChoiceErrSAT()

function [ trial_Corr , trial_Err ] = matchRT_Correct_Error(RT, idxTaskCond, idxCorr, idxErr)

trial_Corr = find(idxTaskCond & idxCorr);   RT_Corr = RT(idxTaskCond & idxCorr);
trial_Err  = find(idxTaskCond & idxErr);     RT_Err = RT(idxTaskCond & idxErr);

[OLdist_Corr, OLdist_Err, ~, ~] = DistOverlap_Amir([trial_Corr;RT_Corr]', [trial_Err;RT_Err]');

trial_Corr = OLdist_Corr(:,1);
trial_Err = OLdist_Err(:,1);

end % util : matchRT_Correct_Error()

function [sdfAccST, sdfFastST] = getSingleTrialSDF(RT, ISI, spikes, trials, time)

%isolate single-trial SDFs per group - Fast condition
sdfFastST.Corr.RePrimary = sdfRePRIMARY(trials.FastCorr, time.PRIMARY); %aligned on primary
sdfFastST.Err.RePrimary = sdfRePRIMARY(trials.FastErr, time.PRIMARY);
sdfFastST.Corr.ReSecondary = sdfReSECONDARY(trials.FastCorr, time.SECONDARY); %aligned on secondary
sdfFastST.Err.ReSecondary = sdfReSECONDARY(trials.FastErr, time.SECONDARY);

%isolate single-trial SDFs per group - Accurate condition
sdfAccST.Corr.RePrimary = sdfRePRIMARY(trials.AccCorr, time.PRIMARY); %aligned on primary
sdfAccST.Err.RePrimary = sdfRePRIMARY(trials.AccErr, time.PRIMARY);
sdfAccST.Corr.ReSecondary = sdfReSECONDARY(trials.AccCorr, time.SECONDARY); %aligned on secondary
sdfAccST.Err.ReSecondary = sdfReSECONDARY(trials.AccErr, time.SECONDARY);

end%util:getSingleTrialSDF()

function [ sdfCorr , sdfErr ] = computeMeanSDF( sdfSingleTrial )

sdfCorr.RePrimary = nanmean(sdfSingleTrial.Corr.RePrimary)';
sdfCorr.ReSecondary = nanmean(sdfSingleTrial.Corr.ReSecondary)';

sdfErr.RePrimary = nanmean(sdfSingleTrial.Err.RePrimary)';
sdfErr.ReSecondary = nanmean(sdfSingleTrial.Err.ReSecondary)';

end%util:computeMeanSDF()


function [ ] = plotSDF_UnitCC( TIME , sdfPlot , ninfo , nstats )
%plotSDF_UnitCC Summary of this function goes here
% 

%compute y-limits for vertical lines
tmp = [sdfPlot.AccCorr.RePrimary ; sdfPlot.AccCorr.ReSecondary ; sdfPlot.AccErr.RePrimary ; sdfPlot.AccErr.ReSecondary ; ...
  sdfPlot.FastCorr.RePrimary ; sdfPlot.FastCorr.ReSecondary ; sdfPlot.FastErr.RePrimary ; sdfPlot.FastErr.ReSecondary];
yLim = [min(tmp) max(tmp)];

figure()

%% Fast condition
subplot(2,2,1); hold on %from primary saccade
plot([0 0], yLim, 'k:')
plot(TIME.PRIMARY-3500, sdfPlot.FastCorr.RePrimary, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdfPlot.FastErr.RePrimary, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(nstats.A_ChcErr_tErr_Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
xlim([TIME.PRIMARY(1) TIME.PRIMARY(end)]-3500); xticks((TIME.PRIMARY(1):50:TIME.PRIMARY(end))-3500)
ylabel('Activity (sp/sec)')
print_session_unit(gca , ninfo,[])

subplot(2,2,2); hold on %from second saccade
plot([0 0], yLim, 'k:')
plot(TIME.SECONDARY-3500, sdfPlot.FastCorr.ReSecondary, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.SECONDARY-3500, sdfPlot.FastErr.ReSecondary, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
xlim([TIME.SECONDARY(1) TIME.SECONDARY(end)]-3500); xticks((TIME.SECONDARY(1):50:TIME.SECONDARY(end))-3500)
set(gca, 'YAxisLocation','right')


%% Accurate condition
subplot(2,2,3); hold on %from primary saccade
plot([0 0], yLim, 'k:')
plot(TIME.PRIMARY-3500, sdfPlot.AccCorr.RePrimary, '-', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdfPlot.AccErr.RePrimary, ':', 'Color',[1 0 0], 'LineWidth',1.0)
plot(nstats.A_ChcErr_tErr_Acc*ones(1,2), yLim, ':', 'Color',[1 0 0], 'LineWidth',1.0)
xlim([TIME.PRIMARY(1) TIME.PRIMARY(end)]-3500); xticks((TIME.PRIMARY(1):50:TIME.PRIMARY(end))-3500)
ylabel('Activity (sp/sec)')
xlabel('Time from primary saccade (ms)')

subplot(2,2,4); hold on %from second saccade
plot([0 0], yLim, 'k:')
plot(TIME.SECONDARY-3500, sdfPlot.AccCorr.ReSecondary, '-', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.SECONDARY-3500, sdfPlot.AccErr.ReSecondary, ':', 'Color',[1 0 0], 'LineWidth',1.0)
xlim([TIME.SECONDARY(1) TIME.SECONDARY(end)]-3500); xticks((TIME.SECONDARY(1):50:TIME.SECONDARY(end))-3500)
xlabel('Time from secondary saccade (ms)')
set(gca, 'YAxisLocation','right')

ppretty([12,4.8])

end%util:plotSDF_UnitCC()
