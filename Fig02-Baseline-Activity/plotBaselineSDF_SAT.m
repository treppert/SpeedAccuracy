function [ ] = plotBaselineSDF_SAT( binfo , moves , ninfo , nstats , spikes , varargin )
%plotBaselineSDF_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=',{'SEF'}}, {'type=',{'Vis'}}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxVis = ([ninfo.visGrade] >= 2);   idxMove = ([ninfo.moveGrade] >= 2);
idxErr = ([ninfo.errGrade] >= 2);   idxRew = (abs([ninfo.rewGrade]) >= 2);

idxKeep = (idxArea & idxMonkey);
if ismember(args.type, 'Vis')
  idxKeep = (idxKeep & idxVis);
end
if ismember(args.type, 'Move')
  idxKeep = (idxKeep & idxMove);
end
if ismember(args.type, 'Error')
  idxKeep = (idxKeep & idxErr);
end
if ismember(args.type, 'Reward')
  idxKeep = (idxKeep & idxRew);
end

NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
nstats = nstats(idxKeep);
spikes = spikes(idxKeep);

TIME.STIM = 3500 + (-400 : 200); %from stimulus
TIME.RESP = 3500 + (-300 : 300); %from response
N_SAMP = length(TIME.STIM); %number of samples consistent across epochs

sdfAccStim = NaN(NUM_CELLS, N_SAMP);    sdfFastStim = NaN(NUM_CELLS, N_SAMP);
sdfAccResp = NaN(NUM_CELLS, N_SAMP);    sdfFastResp = NaN(NUM_CELLS, N_SAMP);

for cc = 1:NUM_CELLS
  fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  rtKK = double(moves(kk).resptime);
  
  %compute single-trial SDF
  SDFstim = compute_spike_density_fxn(spikes(cc).SAT);
  SDFresp = align_signal_on_response(SDFstim, rtKK);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials, 'task','SAT');
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold | binfo(kk).err_nosacc);
  %index by condition
  idxAcc = ((binfo(kk).condition == 1) & idxCorr & ~idxIso);
  idxFast = ((binfo(kk).condition == 3) & idxCorr & ~idxIso);
  %index by response direction relative to RF and MF
  [visField,moveField] = determineFieldsVisMove( ninfo(cc) );
  idxRF = ismember(moves(kk).octant, visField);
  idxMF = ismember(moves(kk).octant, moveField);
  
  %split single-trial SDF by condition
  sdfAccStimST = SDFstim(idxAcc & idxRF, TIME.STIM);    sdfFastStimST = SDFstim(idxFast & idxRF, TIME.STIM);
  sdfAccRespST = SDFresp(idxAcc & idxMF, TIME.RESP);    sdfFastRespST = SDFresp(idxFast & idxMF, TIME.RESP);
  
  %compute mean SDF
  sdfAccStim(cc,:) = mean(sdfAccStimST);    sdfFastStim(cc,:) = mean(sdfFastStimST);
  sdfAccResp(cc,:) = mean(sdfAccRespST);    sdfFastResp(cc,:) = mean(sdfFastRespST);
  
end%for:cells(cc)

%% Plotting

%normalization
sdfAccStim = sdfAccStim ./ [nstats.NormFactor_All]';    sdfFastStim = sdfFastStim ./ [nstats.NormFactor_All]';
sdfAccResp = sdfAccResp ./ [nstats.NormFactor_All]';    sdfFastResp = sdfFastResp ./ [nstats.NormFactor_All]';

%split neurons by level of search efficiency
ccMore = ([ninfo.taskType] == 1);   NUM_MORE = sum(ccMore);
ccLess = ([ninfo.taskType] == 2);   NUM_LESS = sum(ccLess);
sdfAcc.Stim.More = sdfAccStim(ccMore,:);    sdfFast.Stim.More = sdfFastStim(ccMore,:);
sdfAcc.Stim.Less = sdfAccStim(ccLess,:);    sdfFast.Stim.Less = sdfFastStim(ccLess,:);
sdfAcc.Resp.More = sdfAccResp(ccMore,:);    sdfFast.Resp.More = sdfFastResp(ccMore,:);
sdfAcc.Resp.Less = sdfAccResp(ccLess,:);    sdfFast.Resp.Less = sdfFastResp(ccLess,:);

TIME.STIM = TIME.STIM - 3500;
TIME.RESP = TIME.RESP - 3500;

%time from stimulus for plotting close-up of baseline
T_FOCUSED = (-350 : -150);
IDX_FOCUSED = ismember(TIME.STIM, T_FOCUSED);

%compute common y-axis scale
tmp = [mean(sdfAcc.Stim.More) mean(sdfAcc.Resp.More) mean(sdfFast.Stim.More) mean(sdfFast.Resp.More) ...
  mean(sdfAcc.Stim.Less) mean(sdfAcc.Resp.Less) mean(sdfFast.Stim.Less) mean(sdfFast.Resp.Less)];
yLim = [min(tmp) max(tmp)];

figure()

%More efficient
subplot(2,3,1); hold on %from stimulus
plot([0 0], yLim, 'k:')
shaded_error_bar(TIME.STIM, mean(sdfAcc.Stim.More), std(sdfAcc.Stim.More)/sqrt(NUM_MORE), {'r-', 'LineWidth',0.75})
shaded_error_bar(TIME.STIM, mean(sdfFast.Stim.More), std(sdfFast.Stim.More)/sqrt(NUM_MORE), {'-', 'Color',[0 .7 0], 'LineWidth',0.75})
xlabel('Time from array (ms)'); ylabel('Normalized activity')

subplot(2,3,2); hold on %from response
plot([0 0], yLim, 'k:')
shaded_error_bar(TIME.RESP, mean(sdfAcc.Resp.More), std(sdfAcc.Resp.More)/sqrt(NUM_MORE), {'r-', 'LineWidth',0.75})
shaded_error_bar(TIME.RESP, mean(sdfFast.Resp.More), std(sdfFast.Resp.More)/sqrt(NUM_MORE), {'-', 'Color',[0 .7 0], 'LineWidth',0.75})
xlabel('Time from response (ms)'); xlim([TIME.RESP(1) TIME.RESP(end)])

subplot(2,3,3); hold on %focused look at baseline
plot(T_FOCUSED, mean(sdfAcc.Stim.More(:,IDX_FOCUSED)), 'r-', 'LineWidth',0.75)
plot(T_FOCUSED, mean(sdfFast.Stim.More(:,IDX_FOCUSED)), '-', 'Color',[0 .7 0], 'LineWidth',0.75)

%Less efficient
subplot(1,3,1); hold on %from stimulus
plot([0 0], yLim, 'k:')
shaded_error_bar(TIME.STIM, mean(sdfAcc.Stim.Less), std(sdfAcc.Stim.Less)/sqrt(NUM_LESS), {'r-', 'LineWidth',1.25})
shaded_error_bar(TIME.STIM, mean(sdfFast.Stim.Less), std(sdfFast.Stim.Less)/sqrt(NUM_LESS), {'-', 'Color',[0 .7 0], 'LineWidth',1.25})
xlabel('Time from array (ms)')

subplot(1,3,2); hold on %from response
plot([0 0], yLim, 'k:')
shaded_error_bar(TIME.RESP, mean(sdfAcc.Resp.Less), std(sdfAcc.Resp.Less)/sqrt(NUM_LESS), {'r-', 'LineWidth',1.25})
shaded_error_bar(TIME.RESP, mean(sdfFast.Resp.Less), std(sdfFast.Resp.Less)/sqrt(NUM_LESS), {'-', 'Color',[0 .7 0], 'LineWidth',1.25})
xlabel('Time from response (ms)'); xlim([TIME.RESP(1) TIME.RESP(end)])

subplot(1,3,3); hold on %focused look at baseline
plot(T_FOCUSED, mean(sdfAcc.Stim.Less(:,IDX_FOCUSED)), 'r-', 'LineWidth',1.25)
plot(T_FOCUSED, mean(sdfFast.Stim.Less(:,IDX_FOCUSED)), '-', 'Color',[0 .7 0], 'LineWidth',1.25)

ppretty([12,1.4])

end%fxn:plotBaselineSDF_SAT()


function [visField , moveField] = determineFieldsVisMove( ninfo )

if (isempty(ninfo.visField) || ismember(9, ninfo.visField)) %non-specific RF
  visField = (1:8);
else %specific RF
  visField = ninfo.visField;
end

if (isempty(ninfo.moveField) || ismember(9, ninfo.moveField)) %non-specific MF
  moveField = (1:8);
else %specific MF
  moveField = ninfo.moveField;
end

end%util:determineFieldsVisMove()
