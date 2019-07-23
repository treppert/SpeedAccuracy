function [ varargout ] = plotSDFChoiceErrXisiSAT( binfo , moves , movesPP , ninfo , nstats , spikes , varargin )
%plotSDFChoiceErrXisiSAT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});
ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\SEF_SAT\Figs\5-Error\SDF-ChoiceErr-xISI-Test-2\';

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxErrorGrade = (abs([ninfo.errGrade]) >= 1);

% idxEfficient = ismember([ninfo.taskType], [1,2]);

idxKeep = (idxArea & idxMonkey & idxErrorGrade);% & idxEfficient);

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);
NUM_CELLS = length(spikes);

TIME.PRIMARY = 3500 + (-200 : 200); OFFSET = 200; %time from primary saccade
TIME.SECONDARY = 3500 + (-200 : 200); %time from secondary saccade
TIME.BASELINE = 3500 + (-300 : -1); %time from array

T_INTERVAL_ESTIMATE_MAG = 200; %interval over which we compute the integral of error signal

%output initializations
sdfAccSH = new_struct({'RePrimary','ReSecondary','Baseline'}, 'dim',[1,NUM_CELLS]);
sdfAccSH = struct('Corr',sdfAccSH, 'Err',sdfAccSH); %short ISI
sdfAccLO = sdfAccSH; %long ISI
sdfFastSH = sdfAccSH; %short ISI
sdfFastLO = sdfAccSH; %long ISI

for cc = 1:NUM_CELLS
  fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  RTkk = double(moves(kk).resptime);
  ISIkk = double(movesPP(kk).resptime) - RTkk;
  ISIkk(ISIkk < 0) = NaN; %trials with no secondary saccade
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials, 'task','SAT');
  %index by condition
  idxAcc = ((binfo(kk).condition == 1) & ~idxIso);
  idxFast = ((binfo(kk).condition == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold | binfo(kk).err_nosacc);
  idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  %index by ISI
  medISI = nanmedian(ISIkk(idxErr));
  idxSH = (ISIkk <= medISI);
  idxLO = (ISIkk > medISI);
  
  %perform RT matching and group trials by condition and outcome
  trialsSH = groupTrialsRTmatched(RTkk, idxAcc, idxFast, idxCorr, (idxErr & idxSH));
  trialsLO = groupTrialsRTmatched(RTkk, idxAcc, idxFast, idxCorr, (idxErr & idxLO));
  
  %set "ISI" on correct trials as median ISI of choice error trials
  ISIkk(trialsSH.FastCorr) = round(nanmedian(ISIkk(trialsSH.FastErr)));
  ISIkk(trialsSH.AccCorr)  = round(nanmedian(ISIkk(trialsSH.AccErr)));
  ISIkk(trialsLO.FastCorr) = round(nanmedian(ISIkk(trialsLO.FastErr)));
  ISIkk(trialsLO.AccCorr)  = round(nanmedian(ISIkk(trialsLO.AccErr)));
  
  %save ISI for plotting
%   ISIplot = struct('AccSH',ISIkk(trialsSH.AccCorr(1)), 'FastSH',ISIkk(trialsSH.FastCorr(1)), ...
%     'AccLO',ISIkk(trialsLO.AccCorr(1)), 'FastLO',ISIkk(trialsLO.FastCorr(1)));
  
  %get single-trials SDFs
  [sdfAccST_SH, sdfFastST_SH] = getSingleTrialSDF(RTkk, ISIkk, spikes(cc).SAT, trialsSH, TIME);
  [sdfAccST_LO, sdfFastST_LO] = getSingleTrialSDF(RTkk, ISIkk, spikes(cc).SAT, trialsLO, TIME);
  
  %compute mean SDFs
  [sdfAccSH.Corr(cc),sdfAccSH.Err(cc)] = computeMeanSDF( sdfAccST_SH );
  [sdfFastSH.Corr(cc),sdfFastSH.Err(cc)] = computeMeanSDF( sdfFastST_SH );
  [sdfAccLO.Corr(cc),sdfAccLO.Err(cc)] = computeMeanSDF( sdfAccST_LO );
  [sdfFastLO.Corr(cc),sdfFastLO.Err(cc)] = computeMeanSDF( sdfFastST_LO );
    
  %% Parameterize the SDF
  ccNS = ninfo(cc).unitNum;
  
  %latency
%   [tErrAcc,tErrFast] = calcTimeErrSignal(sdfAccST, sdfFastST, OFFSET);
%   nstats(ccNS).A_ChcErr_tErrEnd_Acc = tErrAcc.End;
%   nstats(ccNS).A_ChcErr_tErrEnd_Fast = tErrFast.End;
  
  %plot individual cell activity
  sdfPlotCC = struct('AccCorrSH',sdfAccSH.Corr(cc), 'AccErrSH',sdfAccSH.Err(cc), ... %short ISI
    'FastCorrSH',sdfFastSH.Corr(cc), 'FastErrSH',sdfFastSH.Err(cc), ...
  	'AccCorrLO',sdfAccLO.Corr(cc), 'AccErrLO',sdfAccLO.Err(cc), ... %long ISI
    'FastCorrLO',sdfFastLO.Corr(cc), 'FastErrLO',sdfFastLO.Err(cc));
  plotSDFChcErrXisiSATcc(TIME, sdfPlotCC, ninfo(cc), nstats(ccNS))
  print([ROOTDIR, ninfo(cc).sess,'-',ninfo(cc).unit,'.tif'], '-dtiff')
  pause(0.1); close(); pause(0.1)
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = nstats;
end

end%fxn:plotSDFChoiceErrXisiSAT2()

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


function [ ] = plotSDFChcErrXisiSATcc( TIME , sdfPlot , ninfo , nstats )
%plotSDFChcErrXisiSATcc Summary of this function goes here
%   TIME.PRIMARY - Time from primary saccade (ms)
%   TIME.SECONDARY - Time from secondary saccade (ms)
%   SDFcc - Struct with fields CorrRe1, ErrRe1, CorrRe2, ErrRe2
% 

%compute y-limits for vertical lines
tmp = [sdfPlot.AccCorrSH.RePrimary ; sdfPlot.AccCorrSH.ReSecondary ; sdfPlot.AccErrSH.RePrimary ; sdfPlot.AccErrSH.ReSecondary ; ...
  sdfPlot.FastCorrSH.RePrimary ; sdfPlot.FastCorrSH.ReSecondary ; sdfPlot.FastErrSH.RePrimary ; sdfPlot.FastErrSH.ReSecondary ; ...
  sdfPlot.AccCorrLO.RePrimary ; sdfPlot.AccCorrLO.ReSecondary ; sdfPlot.AccErrLO.RePrimary ; sdfPlot.AccErrLO.ReSecondary ; ...
  sdfPlot.FastCorrLO.RePrimary ; sdfPlot.FastCorrLO.ReSecondary ; sdfPlot.FastErrLO.RePrimary ; sdfPlot.FastErrLO.ReSecondary];

yLim = [min(tmp) max(tmp)];

figure()

%% Fast condition

%Time from primary saccade
subplot(2,2,1); hold on
plot([0 0], yLim, 'k:')

plot(TIME.PRIMARY-3500, sdfPlot.FastCorrSH.RePrimary, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdfPlot.FastErrSH.RePrimary, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdfPlot.FastCorrLO.RePrimary, '-', 'Color',[0 .4 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdfPlot.FastErrLO.RePrimary, ':', 'Color',[0 .4 0], 'LineWidth',1.0)

% plot(nstats.A_ChcErr_tErr_Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
% plot(nstats.A_ChcErr_tErrEnd_Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0)

xlim([TIME.PRIMARY(1) TIME.PRIMARY(end)]-3500); xticks((TIME.PRIMARY(1):50:TIME.PRIMARY(end))-3500)
ylabel('Activity (sp/sec)')
% title(['Magnitude = ', num2str(round(nstats.A_ChcErr_magErr_Fast)), ' sp/s'])
print_session_unit(gca , ninfo,[])


%Time from secondary saccade
subplot(2,2,2); hold on
plot([0 0], yLim, 'k:')

plot(TIME.SECONDARY-3500, sdfPlot.FastCorrSH.ReSecondary, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.SECONDARY-3500, sdfPlot.FastErrSH.ReSecondary, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.SECONDARY-3500, sdfPlot.FastCorrLO.ReSecondary, '-', 'Color',[0 .4 0], 'LineWidth',1.0)
plot(TIME.SECONDARY-3500, sdfPlot.FastErrLO.ReSecondary, ':', 'Color',[0 .4 0], 'LineWidth',1.0)

xlim([TIME.SECONDARY(1) TIME.SECONDARY(end)]-3500); xticks((TIME.SECONDARY(1):50:TIME.SECONDARY(end))-3500)
set(gca, 'YAxisLocation','right')


%% Accurate condition

%Time from primary saccade
subplot(2,2,3); hold on
plot([0 0], yLim, 'k:')

plot(TIME.PRIMARY-3500, sdfPlot.AccCorrSH.RePrimary, '-', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdfPlot.AccErrSH.RePrimary, ':', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdfPlot.AccCorrLO.RePrimary, '-', 'Color',[.5 0 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdfPlot.AccErrLO.RePrimary, ':', 'Color',[.5 0 0], 'LineWidth',1.0)

% plot(nstats.A_ChcErr_tErr_Acc*ones(1,2), yLim, ':', 'Color',[1 0 0], 'LineWidth',1.0)
% plot(nstats.A_ChcErr_tErrEnd_Acc*ones(1,2), yLim, ':', 'Color',[1 0 0], 'LineWidth',1.0)

xlim([TIME.PRIMARY(1) TIME.PRIMARY(end)]-3500); xticks((TIME.PRIMARY(1):50:TIME.PRIMARY(end))-3500)
ylabel('Activity (sp/sec)')
xlabel('Time from primary saccade (ms)')
% title(['Magnitude = ', num2str(round(nstats.A_ChcErr_magErr_Acc)), ' sp/s'])


%Time from secondary saccade
subplot(2,2,4); hold on
plot([0 0], yLim, 'k:')

plot(TIME.SECONDARY-3500, sdfPlot.AccCorrSH.ReSecondary, '-', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.SECONDARY-3500, sdfPlot.AccErrSH.ReSecondary, ':', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.SECONDARY-3500, sdfPlot.AccCorrLO.ReSecondary, '-', 'Color',[.5 0 0], 'LineWidth',1.0)
plot(TIME.SECONDARY-3500, sdfPlot.AccErrLO.ReSecondary, ':', 'Color',[.5 0 0], 'LineWidth',1.0)

xlim([TIME.SECONDARY(1) TIME.SECONDARY(end)]-3500); xticks((TIME.SECONDARY(1):50:TIME.SECONDARY(end))-3500)
xlabel('Time from secondary saccade (ms)')
set(gca, 'YAxisLocation','right')

ppretty([12,4.8])

end%util:plotSDFChcErrXisiSATcc()

