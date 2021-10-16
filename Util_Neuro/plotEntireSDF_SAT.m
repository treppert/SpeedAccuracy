function [ varargout ] = plotEntireSDF_SAT( behavData , moves , unitData , unitData , spikes , varargin )
%plotEntireSDF_SAT() Summary of this function goes here
%   Note: Use this function to compute normalization factors for all
%   task-related neurons.
% 

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});
ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\SAT\Figs-Entire-SDF\';

idxArea = ismember(unitData.aArea, args.area);
idxMonkey = ismember(unitData.aMonkey, args.monkey);

idxVis = ([unitData.Basic_VisGrade] >= 2);   idxMove = (unitData.Basic_MovGrade >= 2);
idxErr = (unitData.Basic_ErrGrade >= 2);   idxRew = (unitData.Basic_RewGrade >= 2);
idxTaskRel = (idxVis | idxMove | idxErr | idxRew);

idxKeep = (idxArea & idxMonkey & idxTaskRel);

NUM_CELLS = sum(idxKeep);
unitData = unitData(idxKeep);
spikes = spikes(idxKeep);

TIME.STIM = 3500 + (-200 : 300); %from stimulus
TIME.RESP = 3500 + (-200 : 300); %from response
TIME.REW  = 3500 + (-200 : 300); %from reward
N_SAMP = length(TIME.STIM); %number of samples consistent across epochs

for uu = 1:NUM_CELLS
  fprintf('%s - %s\n', unitData.Task_Session(uu), unitData.aID{uu})
  
  %initialize SDF
  tmp = NaN(1,N_SAMP);
  sdfAcc = struct('stim',tmp, 'resp',tmp, 'rew',tmp);
  sdfFast = struct('stim',tmp, 'resp',tmp, 'rew',tmp);
  
  %gather time of response and time of reward
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  rtKK = double(moves(kk).resptime);
  trewKK = double(behavData.Task_TimeReward{kk} + behavData.Sacc_RT{kk});
  
  if ~ismember(args.area, {'SEF'})
    trewKK = zeros(1,behavData.Task_NumTrials{kk});
  end
  
  %compute single-trial SDF
  SDFstim = compute_spike_density_fxn(spikes(uu).SAT);
  SDFresp = align_signal_on_response(SDFstim, rtKK);
  SDFrew  = align_signal_on_response(SDFstim, trewKK);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData(uu,:), behavData.Task_NumTrials{kk}, 'task','SAT');
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & idxCorr & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & idxCorr & ~idxIso);
  %index by response direction relative to RF and MF
  [visField,moveField] = determineFieldsVisMove( unitData(uu) );
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
  uuNS = unitData.aIndex(uu);
  nfVis  = max(mean([sdfAcc.stim ; sdfFast.stim]));
  nfMove = max(mean([sdfAcc.resp ; sdfFast.resp]));
  nfRew  = max(mean([sdfAcc.rew  ; sdfFast.rew]));
  unitData(uuNS).NormFactor_Vis  = nfVis;
  unitData(uuNS).NormFactor_Move = nfMove;
  unitData(uuNS).NormFactor_Rew  = nfRew;
  unitData(uuNS).NormFactor_All  = max([nfVis nfMove nfRew]);
  
  %plotting
  plotSDFcc(TIME, sdfAcc, sdfFast, unitData(uu,:), unitData(uuNS)); pause(0.1)
%   print([ROOTDIR, unitData.Task_Session(uu),'-',unitData.aID{uu},'-U',num2str(uuNS),'.tif'], '-dtiff');
%   pause(0.1); close()
  
end%for:cells(uu)

if (nargout > 0)
  varargout{1} = unitData;
end

end%fxn:plotEntireSDF_SAT()


function [ ] = plotSDFcc( TIME , sdfAcc , sdfFast , unitData , unitData )
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
plot([TIME.STIM(1) TIME.STIM(end)], unitData.NormFactor_Vis*ones(1,2), 'k:')
plot(TIME.STIM, sdfMean.stim, 'k-', 'LineWidth',1.0)
plot(TIME.STIM, sdfAcc.stim, 'r-', 'LineWidth',1.0)
plot(TIME.STIM, sdfFast.stim, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
xlabel('Time from array (ms)');  ylabel('Activity (sp/sec)')
print_session_unit(gca , unitData, [])

subplot(1,3,2); hold on %from response
plot([0 0], yLim, 'k:')
plot([TIME.RESP(1) TIME.RESP(end)], unitData.NormFactor_Move*ones(1,2), 'k:')
plot(TIME.RESP, sdfMean.resp, 'k-', 'LineWidth',1.0)
plot(TIME.RESP, sdfAcc.resp, 'r-', 'LineWidth',1.0)
plot(TIME.RESP, sdfFast.resp, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
xlabel('Time from response (ms)'); yticklabels([])

subplot(1,3,3); hold on %from reward
plot([0 0], yLim, 'k:')
plot([TIME.REW(1) TIME.REW(end)], unitData.NormFactor_Rew*ones(1,2), 'k:')
plot(TIME.REW, sdfMean.rew, 'k-', 'LineWidth',1.0)
plot(TIME.REW, sdfAcc.rew, 'r-', 'LineWidth',1.0)
plot(TIME.REW, sdfFast.rew, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
xlabel('Time from reward (ms)'); yticklabels([])

ppretty([12,2])

%determine title based on unit type
figTitle = [];
if (unitData.Basic_VisGrade >= 2)
  figTitle = [figTitle 'Vis'];
end
if (unitData.moveGrade >= 2)
  figTitle = [figTitle 'Move'];
end
if (unitData.errGrade >= 2)
  figTitle = [figTitle 'Err'];
end
if (unitData.rewGrade >= 2)
  figTitle = [figTitle 'Rew'];
end

subplot(1,3,2); title(figTitle, 'FontSize',8)

end%util:plotSDFcc()


function [visField , moveField] = determineFieldsVisMove( unitData )

if (isempty(unitData.Basic_VisField) || ismember(9, unitData.Basic_VisField)) %non-specific RF
  visField = (1:8);
else %specific RF
  visField = unitData.Basic_VisField;
end

if (isempty(unitData.Basic_MovField) || ismember(9, unitData.Basic_MovField)) %non-specific MF
  moveField = (1:8);
else %specific MF
  moveField = unitData.Basic_MovField;
end

end%util:determineFieldsVisMove()