function [ varargout ] = plotSDFChoiceErrSAT( binfo , moves , movesPP , ninfo , nstats , spikes , varargin )
%plotSDFChoiceErrSAT() Summary of this function goes here
%   Detailed explanation goes here

ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\SAT\Figures\Post-Response\';

args = getopt(varargin, {{'monkey=',{'D','E'}}});

idxSEF = ismember({ninfo.area}, {'SEF'});
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxErr = (([ninfo.errGrade]) >= 2);
idxEff = ismember([ninfo.taskType], [1,2]);

idxKeep = (idxSEF & idxMonkey & idxErr & idxEff);

NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

TIME.PRIMARY = 3500 + (-300 : 500); OFFSET = 300; %time from primary saccade
TIME.SECONDARY = 3500 + (-200 : 300); %time from secondary saccade
TIME.BASELINE = 3500 + (-300 : -1); %time from array

%output initializations
sdfAcc = new_struct({'RePrimary','ReSecondary','Baseline'}, 'dim',[1,NUM_CELLS]);
sdfAcc = struct('Corr',sdfAcc, 'Err',sdfAcc);
sdfFast = sdfAcc;

for cc = 1:NUM_CELLS
  fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  RTPkk = double(moves(kk).resptime); %RT of primary saccade
  RTPkk(RTPkk > 900) = NaN; %hard limit on primary RT
  RTSkk = double(movesPP(kk).resptime) - RTPkk; %RT of secondary saccade
  RTSkk(RTSkk < 0) = NaN; %trials with no secondary saccade
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials, 'task','SAT');
  %index by condition
  idxAcc = ((binfo(kk).condition == 1) & ~idxIso);
  idxFast = ((binfo(kk).condition == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold | binfo(kk).err_nosacc);
  idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  %set "ISI" on correct trials as median ISI of choice error trials
  RTSkk(idxFast & idxCorr) = round(nanmedian(RTSkk(idxFast & idxErr)));
  RTSkk(idxAcc & idxCorr) = round(nanmedian(RTSkk(idxAcc & idxErr)));
  
  %perform RT matching and group trials by condition and outcome
  trials = groupTrialsRTmatched(RTPkk, idxAcc, idxFast, idxCorr, idxErr);
  
  %get single-trials SDFs
  [sdfAccST, sdfFastST] = getSingleTrialSDF(RTPkk, RTSkk, spikes(cc).SAT, trials, TIME);
  
  %compute mean SDFs
  [sdfAcc.Corr(cc),sdfAcc.Err(cc)] = computeMeanSDF( sdfAccST );
  [sdfFast.Corr(cc),sdfFast.Err(cc)] = computeMeanSDF( sdfFastST );
  sdfCombined = struct('AccCorr',sdfAcc.Corr(cc), 'AccErr',sdfAcc.Err(cc), 'FastCorr',sdfFast.Corr(cc), 'FastErr',sdfFast.Err(cc));
    
  %% Parameterize the SDF
  ccNS = ninfo(cc).unitNum;
  
  %latency
%   if isempty(nstats(ccNS).A_ChcErr_tErr_Fast)
%     [tErrAcc,tErrFast] = calcTimeErrSignal(sdfAccST, sdfFastST, OFFSET);
%     nstats(ccNS).A_ChcErr_tErr_Acc = tErrAcc.Start;     nstats(ccNS).A_ChcErr_tErrEnd_Acc = tErrAcc.End;
%     nstats(ccNS).A_ChcErr_tErr_Fast = tErrFast.Start;   nstats(ccNS).A_ChcErr_tErrEnd_Fast = tErrFast.End;
%   end
  
  %magnitude
  [magAcc,magFast] = calcMagErrSignal(sdfCombined, OFFSET, nstats(ccNS));
  nstats(ccNS).A_ChcErr_magErr_Acc = magAcc;
  nstats(ccNS).A_ChcErr_magErr_Fast = magFast;
  
  %plot individual cell activity
%   plotSDFChcErrSATcc(TIME, sdfCombined, ninfo(cc), nstats(ccNS))
%   print([ROOTDIR, ninfo(cc).sess,'-',ninfo(cc).unit,'-U',num2str(ccNS),'.tif'], '-dtiff'); pause(0.1); close()
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = nstats;
end

end%fxn:plotSDFChoiceErrSAT()

function [ trialsGrouped ] = groupTrialsRTmatched(RT, idxAcc, idxFast, idxCorr, idxErr)

%Fast condition
trial_FC = find(idxFast & idxCorr);    RT_FC = RT(idxFast & idxCorr);
trial_FE = find(idxFast & idxErr);     RT_FE = RT(idxFast & idxErr);
[OLdist1, OLdist2, ~,~] = DistOverlap_Amir([trial_FC;RT_FC]', [trial_FE;RT_FE]');
trial_FC = OLdist1(:,1);
trial_FE = OLdist2(:,1);

%Accurate condition
trial_AC = find(idxAcc & idxCorr);    RT_AC = RT(idxAcc & idxCorr);
trial_AE = find(idxAcc & idxErr);     RT_AE = RT(idxAcc & idxErr);
[OLdist1, OLdist2, ~,~] = DistOverlap_Amir([trial_AC;RT_AC]', [trial_AE;RT_AE]');
trial_AC = OLdist1(:,1);
trial_AE = OLdist2(:,1);

%output
trialsGrouped = struct('AccCorr',trial_AC, 'AccErr',trial_AE, 'FastCorr',trial_FC, 'FastErr',trial_FE);

end%util:groupTrialsRTmatched()

function [sdfAccST, sdfFastST] = getSingleTrialSDF(RT, ISI, spikes, trials, time)

%compute SDFs and align on primary and secondary saccades
sdfReSTIM = compute_spike_density_fxn(spikes);
sdfRePRIMARY = align_signal_on_response(sdfReSTIM, RT);
sdfReSECONDARY = align_signal_on_response(sdfReSTIM, RT + ISI);

%isolate single-trial SDFs per group - Fast condition
sdfFastST.Corr.RePrimary = sdfRePRIMARY(trials.FastCorr, time.PRIMARY); %aligned on primary
sdfFastST.Err.RePrimary = sdfRePRIMARY(trials.FastErr, time.PRIMARY);
sdfFastST.Corr.ReSecondary = sdfReSECONDARY(trials.FastCorr, time.SECONDARY); %aligned on secondary
sdfFastST.Err.ReSecondary = sdfReSECONDARY(trials.FastErr, time.SECONDARY);
sdfFastST.Corr.ReStim = sdfReSTIM(trials.FastCorr, time.BASELINE); %aligned on array
sdfFastST.Err.ReStim = sdfReSTIM(trials.FastErr, time.BASELINE);

%isolate single-trial SDFs per group - Accurate condition
sdfAccST.Corr.RePrimary = sdfRePRIMARY(trials.AccCorr, time.PRIMARY); %aligned on primary
sdfAccST.Err.RePrimary = sdfRePRIMARY(trials.AccErr, time.PRIMARY);
sdfAccST.Corr.ReSecondary = sdfReSECONDARY(trials.AccCorr, time.SECONDARY); %aligned on secondary
sdfAccST.Err.ReSecondary = sdfReSECONDARY(trials.AccErr, time.SECONDARY);
sdfAccST.Corr.ReStim = sdfReSTIM(trials.AccCorr, time.BASELINE); %aligned on array
sdfAccST.Err.ReStim = sdfReSTIM(trials.AccErr, time.BASELINE);

end%util:getSingleTrialSDF()

function [ sdfCorr , sdfErr ] = computeMeanSDF( sdfSingleTrial )

sdfCorr.RePrimary = nanmean(sdfSingleTrial.Corr.RePrimary)';
sdfCorr.ReSecondary = nanmean(sdfSingleTrial.Corr.ReSecondary)';
sdfCorr.Baseline = nanmean(sdfSingleTrial.Corr.ReStim)';

sdfErr.RePrimary = nanmean(sdfSingleTrial.Err.RePrimary)';
sdfErr.ReSecondary = nanmean(sdfSingleTrial.Err.ReSecondary)';
sdfErr.Baseline = nanmean(sdfSingleTrial.Err.ReStim)';

end%util:computeMeanSDF()


function [ ] = plotSDFChcErrSATcc( TIME , sdfPlot , ninfo , nstats )
%plotSDFChcErrSATcc Summary of this function goes here
%   TIME.PRIMARY - Time from primary saccade (ms)
%   TIME.SECONDARY - Time from secondary saccade (ms)
%   SDFcc - Struct with fields CorrRe1, ErrRe1, CorrRe2, ErrRe2
% 

%compute y-limits for vertical lines
tmp = [sdfPlot.AccCorr.RePrimary ; sdfPlot.AccCorr.ReSecondary ; sdfPlot.AccErr.RePrimary ; sdfPlot.AccErr.ReSecondary ; ...
  sdfPlot.FastCorr.RePrimary ; sdfPlot.FastCorr.ReSecondary ; sdfPlot.FastErr.RePrimary ; sdfPlot.FastErr.ReSecondary];
yLim = [min(tmp) max(tmp)];

figure()

%% Fast condition

%Time from primary saccade
subplot(2,2,1); hold on
plot([0 0], yLim, 'k:')
plot(TIME.PRIMARY-3500, sdfPlot.FastCorr.RePrimary, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdfPlot.FastErr.RePrimary, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(nstats.A_ChcErr_tErr_Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
xlim([TIME.PRIMARY(1) TIME.PRIMARY(end)]-3500); xticks((TIME.PRIMARY(1):50:TIME.PRIMARY(end))-3500)
ylabel('Activity (sp/sec)')
print_session_unit(gca , ninfo,[])


%Time from secondary saccade
subplot(2,2,2); hold on
plot([0 0], yLim, 'k:')
plot(TIME.SECONDARY-3500, sdfPlot.FastCorr.ReSecondary, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.SECONDARY-3500, sdfPlot.FastErr.ReSecondary, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
xlim([TIME.SECONDARY(1) TIME.SECONDARY(end)]-3500); xticks((TIME.SECONDARY(1):50:TIME.SECONDARY(end))-3500)
set(gca, 'YAxisLocation','right')


%% Accurate condition

%Time from primary saccade
subplot(2,2,3); hold on
plot([0 0], yLim, 'k:')
plot(TIME.PRIMARY-3500, sdfPlot.AccCorr.RePrimary, '-', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdfPlot.AccErr.RePrimary, ':', 'Color',[1 0 0], 'LineWidth',1.0)
plot(nstats.A_ChcErr_tErr_Acc*ones(1,2), yLim, ':', 'Color',[1 0 0], 'LineWidth',1.0)
xlim([TIME.PRIMARY(1) TIME.PRIMARY(end)]-3500); xticks((TIME.PRIMARY(1):50:TIME.PRIMARY(end))-3500)
ylabel('Activity (sp/sec)')
xlabel('Time from primary saccade (ms)')


%Time from secondary saccade
subplot(2,2,4); hold on
plot([0 0], yLim, 'k:')
plot(TIME.SECONDARY-3500, sdfPlot.AccCorr.ReSecondary, '-', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.SECONDARY-3500, sdfPlot.AccErr.ReSecondary, ':', 'Color',[1 0 0], 'LineWidth',1.0)
xlim([TIME.SECONDARY(1) TIME.SECONDARY(end)]-3500); xticks((TIME.SECONDARY(1):50:TIME.SECONDARY(end))-3500)
xlabel('Time from secondary saccade (ms)')
set(gca, 'YAxisLocation','right')

ppretty([12,4.8])

end%util:plotSDFChcErrSATcc()
