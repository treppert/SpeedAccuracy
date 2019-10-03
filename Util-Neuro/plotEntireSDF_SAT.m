function [ varargout ] = plotEntireSDF_SAT( binfo , moves , ninfo , nstats , spikes , varargin )
%plotEntireSDF_SAT() Summary of this function goes here
%   Note: Use this function to compute normalization factors for all
%   task-related neurons.
% 

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});
ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\SAT\Figs-Entire-SDF\';

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxVis = ([ninfo.visGrade] >= 2);   idxMove = ([ninfo.moveGrade] >= 2);
idxErr = ([ninfo.errGrade] >= 2);   idxRew = ([ninfo.rewGrade] >= 2);
idxTaskRel = (idxVis | idxMove | idxErr | idxRew);

idxKeep = (idxArea & idxMonkey & idxTaskRel);

NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

TIME.STIM = 3500 + (-200 : 300); %from stimulus
TIME.RESP = 3500 + (-200 : 300); %from response
TIME.REW  = 3500 + (-200 : 300); %from reward
N_SAMP = length(TIME.STIM); %number of samples consistent across epochs

for cc = 1:NUM_CELLS
  fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  
  %initialize SDF
  tmp = NaN(1,N_SAMP);
  sdfAcc = struct('stim',tmp, 'resp',tmp, 'rew',tmp);
  sdfFast = struct('stim',tmp, 'resp',tmp, 'rew',tmp);
  
  %gather time of response and time of reward
  kk = ismember({binfo.session}, ninfo(cc).sess);
  rtKK = double(moves(kk).resptime);
  trewKK = double(binfo(kk).rewtime + binfo(kk).resptime);
  
  if ~ismember(args.area, {'SEF'})
    trewKK = zeros(1,binfo(kk).num_trials);
  end
  
  %compute single-trial SDF
  SDFstim = compute_spike_density_fxn(spikes(cc).SAT);
  SDFresp = align_signal_on_response(SDFstim, rtKK);
  SDFrew  = align_signal_on_response(SDFstim, trewKK);
  
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
  sdfAccVis = SDFstim(idxAcc & idxRF, TIME.STIM);
  sdfAccMove = SDFresp(idxAcc & idxMF, TIME.RESP);
  sdfAccRew = SDFrew(idxAcc & ~isnan(trewKK), TIME.REW);
  sdfFastVis = SDFstim(idxFast & idxRF, TIME.STIM);
  sdfFastMove = SDFresp(idxFast & idxMF, TIME.RESP);
  sdfFastRew = SDFrew(idxFast & ~isnan(trewKK), TIME.REW);
  
  %compute mean SDF
  sdfAcc.stim = mean(sdfAccVis);    sdfFast.stim = mean(sdfFastVis);
  sdfAcc.resp = mean(sdfAccMove);   sdfFast.resp = mean(sdfFastMove);
  sdfAcc.rew  = mean(sdfAccRew);    sdfFast.rew  = mean(sdfFastRew);
  
  %compute normalization factors based on each epoch
  ccNS = ninfo(cc).unitNum;
  nfVis  = max(mean([sdfAcc.stim ; sdfFast.stim]));
  nfMove = max(mean([sdfAcc.resp ; sdfFast.resp]));
  nfRew  = max(mean([sdfAcc.rew  ; sdfFast.rew]));
  nstats(ccNS).NormFactor_Vis  = nfVis;
  nstats(ccNS).NormFactor_Move = nfMove;
  nstats(ccNS).NormFactor_Rew  = nfRew;
  nstats(ccNS).NormFactor_All  = max([nfVis nfMove nfRew]);
  
  %plotting
  plotSDFcc(TIME, sdfAcc, sdfFast, ninfo(cc), nstats(ccNS)); pause(0.1)
%   print([ROOTDIR, ninfo(cc).sess,'-',ninfo(cc).unit,'-U',num2str(ccNS),'.tif'], '-dtiff');
%   pause(0.1); close()
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = nstats;
end

end%fxn:plotEntireSDF_SAT()


function [ ] = plotSDFcc( TIME , sdfAcc , sdfFast , ninfo , nstats )
%plotSDFcc Summary of this function goes here
%   Detailed explanation goes here

TIME.STIM = TIME.STIM - 3500;
TIME.RESP = TIME.RESP - 3500;
TIME.REW  = TIME.REW  - 3500;

%compute common y-axis scale
tmp = [sdfAcc.stim sdfAcc.resp sdfAcc.rew sdfFast.stim sdfFast.resp sdfFast.rew];
yLim = [min(tmp) max(tmp)];

%compute average SDF across both conditions (used for normalization)
sdfMean.stim = mean([sdfAcc.stim ; sdfFast.stim]);
sdfMean.resp = mean([sdfAcc.resp ; sdfFast.resp]);
sdfMean.rew  = mean([sdfAcc.rew  ; sdfFast.rew]);

figure()

subplot(1,3,1); hold on %from stimulus
plot([0 0], yLim, 'k:')
plot([TIME.STIM(1) TIME.STIM(end)], nstats.NormFactor_Vis*ones(1,2), 'k:')
plot(TIME.STIM, sdfMean.stim, 'k-', 'LineWidth',1.0)
plot(TIME.STIM, sdfAcc.stim, 'r-', 'LineWidth',1.0)
plot(TIME.STIM, sdfFast.stim, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
xlabel('Time from array (ms)');  ylabel('Activity (sp/sec)')
print_session_unit(gca , ninfo, [])

subplot(1,3,2); hold on %from response
plot([0 0], yLim, 'k:')
plot([TIME.RESP(1) TIME.RESP(end)], nstats.NormFactor_Move*ones(1,2), 'k:')
plot(TIME.RESP, sdfMean.resp, 'k-', 'LineWidth',1.0)
plot(TIME.RESP, sdfAcc.resp, 'r-', 'LineWidth',1.0)
plot(TIME.RESP, sdfFast.resp, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
xlabel('Time from response (ms)'); yticklabels([])

subplot(1,3,3); hold on %from reward
plot([0 0], yLim, 'k:')
plot([TIME.REW(1) TIME.REW(end)], nstats.NormFactor_Rew*ones(1,2), 'k:')
plot(TIME.REW, sdfMean.rew, 'k-', 'LineWidth',1.0)
plot(TIME.REW, sdfAcc.rew, 'r-', 'LineWidth',1.0)
plot(TIME.REW, sdfFast.rew, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
xlabel('Time from reward (ms)'); yticklabels([])

ppretty([12,2])

%determine title based on unit type
figTitle = [];
if (ninfo.visGrade >= 2)
  figTitle = [figTitle 'Vis'];
end
if (ninfo.moveGrade >= 2)
  figTitle = [figTitle 'Move'];
end
if (ninfo.errGrade >= 2)
  figTitle = [figTitle 'Err'];
end
if (ninfo.rewGrade >= 2)
  figTitle = [figTitle 'Rew'];
end

subplot(1,3,2); title(figTitle, 'FontSize',8)

end%util:plotSDFcc()


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