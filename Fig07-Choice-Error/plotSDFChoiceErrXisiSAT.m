function [ varargout ] = plotSDFChoiceErrXisiSAT( binfo , moves , movesPP , ninfo , nstats , spikes , varargin )
%plotSDFChoiceErrXisiSAT() Summary of this function goes here
%   Detailed explanation goes here

ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\SAT\Figures\Post-Response\xISI\';

args = getopt(varargin, {{'monkey=',{'D','E'}}});

idxSEF = ismember({ninfo.area}, {'SEF'});
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxErr = (([ninfo.errGrade]) >= 1);
idxEff = ismember([ninfo.taskType], [1,2]);

idxKeep = (idxSEF & idxMonkey & idxErr & idxEff);

NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

TIME.PRIMARY = 3500 + (-200 : 500); OFFSET = 200; %time from primary saccade
TIME.SECONDARY = 3500 + (-200 : 300); %time from secondary saccade
TIME.BASELINE = 3500 + (-300 : -1); %time from array

%output initializations
sdfAcc_SH = new_struct({'RePrimary','ReSecondary','Baseline'}, 'dim',[1,NUM_CELLS]);
sdfAcc_SH = struct('Corr',sdfAcc_SH, 'Err',sdfAcc_SH); %short ISI
sdfAcc_LO = sdfAcc_SH; %long ISI
sdfFast_SH = sdfAcc_SH;
sdfFast_LO = sdfAcc_SH;

rtSecond_SH = NaN(1,NUM_CELLS); %latency of the second saccade
rtSecond_LO = NaN(1,NUM_CELLS);
latSig_SH = NaN(1,NUM_CELLS); %latency of the error signal
latSig_LO = NaN(1,NUM_CELLS);

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
  %index by ISI
  medISI = nanmedian(RTSkk(idxErr));
  idxSH = (RTSkk <= medISI);
  idxLO = (RTSkk > medISI);
  
  %perform RT matching and group trials by condition and outcome
  trials_SH = groupTrialsRTmatched(RTPkk, idxAcc, idxFast, idxCorr, (idxErr & idxSH));
  trials_LO = groupTrialsRTmatched(RTPkk, idxAcc, idxFast, idxCorr, (idxErr & idxLO));
  
  rtSecond_SH(cc) = nanmedian(RTSkk(trials_SH.FastErr));
  rtSecond_LO(cc) = nanmedian(RTSkk(trials_LO.FastErr));
  
  %set RT_second on correct trials as median ISI of choice error trials
  RTSkk(trials_SH.FastCorr) = round(nanmedian(RTSkk(trials_SH.FastErr)));
  RTSkk(trials_SH.AccCorr)  = round(nanmedian(RTSkk(trials_SH.AccErr)));
  RTSkk(trials_LO.FastCorr) = round(nanmedian(RTSkk(trials_LO.FastErr)));
  RTSkk(trials_LO.AccCorr)  = round(nanmedian(RTSkk(trials_LO.AccErr)));
  
  %get single-trials SDFs
  [sdfAccST_SH, sdfFastST_SH] = getSingleTrialSDF(RTPkk, RTSkk, spikes(cc).SAT, trials_SH, TIME);
  [sdfAccST_LO, sdfFastST_LO] = getSingleTrialSDF(RTPkk, RTSkk, spikes(cc).SAT, trials_LO, TIME);
  
  %compute mean SDFs
  [sdfAcc_SH.Corr(cc),sdfAcc_SH.Err(cc)] = computeMeanSDF( sdfAccST_SH );
  [sdfFast_SH.Corr(cc),sdfFast_SH.Err(cc)] = computeMeanSDF( sdfFastST_SH );
  [sdfAcc_LO.Corr(cc),sdfAcc_LO.Err(cc)] = computeMeanSDF( sdfAccST_LO );
  [sdfFast_LO.Corr(cc),sdfFast_LO.Err(cc)] = computeMeanSDF( sdfFastST_LO );
  sdf_SH = struct('AccCorr',sdfAcc_SH.Corr(cc), 'AccErr',sdfAcc_SH.Err(cc), 'FastCorr',sdfFast_SH.Corr(cc), 'FastErr',sdfFast_SH.Err(cc));
  sdf_LO = struct('AccCorr',sdfAcc_LO.Corr(cc), 'AccErr',sdfAcc_LO.Err(cc), 'FastCorr',sdfFast_LO.Corr(cc), 'FastErr',sdfFast_LO.Err(cc));
    
  %compute signal latency
%   [~,tmp_SH] = calcTimeErrSignal(sdfAccST_SH, sdfFastST_SH, OFFSET);
%   [~,tmp_LO] = calcTimeErrSignal(sdfAccST_LO, sdfFastST_LO, OFFSET);
%   latSig_SH(cc) = tmp_SH.Start;
%   latSig_LO(cc) = tmp_LO.Start;
%   nstats(ccNS).A_ChcErr_tErr_Fast_ShortISI = latSig_SH(cc);
%   nstats(ccNS).A_ChcErr_tErr_Fast_LongISI = latSig_LO(cc);
  
  %compute the statistic used to determine "error-relatedness" of neuron
  ccNS = ninfo(cc).unitNum;
  dtSignal = ( nstats(ccNS).A_ChcErr_tErr_Fast_LongISI - nstats(ccNS).A_ChcErr_tErr_Fast_ShortISI);
  nstats(ccNS).A_ChcErr_dtErr_vs_dISI = dtSignal / (rtSecond_LO(cc) - rtSecond_SH(cc));
  
  %plot individual cell activity
  statsTime = struct('isiSH',rtSecond_SH(cc), 'isiLO',rtSecond_LO(cc), ...
    'latSH',nstats(ccNS).A_ChcErr_tErr_Fast_ShortISI, 'latLO',nstats(ccNS).A_ChcErr_tErr_Fast_LongISI);
  plotSDFChcErrXisiSATcc(TIME, sdf_SH, sdf_LO, statsTime, ninfo(cc))
  print([ROOTDIR, ninfo(cc).sess,'-',ninfo(cc).unit,'-U',num2str(ccNS),'.tif'], '-dtiff')
  pause(0.05); close()
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = nstats;
end

end%fxn:plotSDFChoiceErrXisiSAT()

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


function [ ] = plotSDFChcErrXisiSATcc( TIME , sdf_SH , sdf_LO , stats , ninfo )
%plotSDFChcErrXisiSATcc Summary of this function goes here
%   TIME.PRIMARY - Time from primary saccade (ms)
%   TIME.SECONDARY - Time from secondary saccade (ms)
%   SDFcc - Struct with fields CorrRe1, ErrRe1, CorrRe2, ErrRe2
% 

%compute y-limits for vertical lines
tmp = [sdf_SH.FastCorr.RePrimary ; sdf_SH.FastCorr.ReSecondary ; sdf_SH.FastErr.RePrimary ; sdf_SH.FastErr.ReSecondary ; ...
  sdf_LO.FastCorr.RePrimary ; sdf_LO.FastCorr.ReSecondary ; sdf_LO.FastErr.RePrimary ; sdf_LO.FastErr.ReSecondary];
yLim = [min(tmp) max(tmp)];

%compute dSig/dISI stat
ratioSig = (stats.latLO - stats.latSH) / (stats.isiLO - stats.isiSH);

figure(); hold on
title(['Ratio dSig/dISI = ', num2str(ratioSig)], 'FontSize',8)
plot(TIME.PRIMARY-3500, sdf_SH.FastCorr.RePrimary, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdf_SH.FastErr.RePrimary, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdf_LO.FastCorr.RePrimary, '-', 'Color',[0 .4 0], 'LineWidth',1.0)
plot(TIME.PRIMARY-3500, sdf_LO.FastErr.RePrimary, ':', 'Color',[0 .4 0], 'LineWidth',1.0)
plot(stats.isiSH*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0) %plot median ISI
plot(stats.isiLO*ones(1,2), yLim, ':', 'Color',[0 .4 0], 'LineWidth',1.0)
plot(stats.latSH*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0) %plot median signal latency
plot(stats.latLO*ones(1,2), yLim, ':', 'Color',[0 .4 0], 'LineWidth',1.0)
xlim([TIME.PRIMARY(1) TIME.PRIMARY(end)]-3500); xticks((TIME.PRIMARY(1):50:TIME.PRIMARY(end))-3500)
ylabel('Activity (sp/sec)')
print_session_unit(gca , ninfo,[])


ppretty([9,3])

end%util:plotSDFChcErrXisiSATcc()

