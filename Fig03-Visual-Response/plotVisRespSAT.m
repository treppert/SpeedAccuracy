function [ varargout ] = plotVisRespSAT( binfo , moves , ninfo , nstats , spikes , varargin )
%plotVisRespSAT() Summary of this function goes here
%   Note - In order to use this function, first run plotBlineXcondSAT() in
%   order to obtain estimates of mean and SD of baseline activity.
% 

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});
ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\SAT\Figs-VisResp-SEF\';

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxVis = ([ninfo.visGrade] >= 2);   idxMove = ([ninfo.moveGrade] >= 2);
idxErr = ([ninfo.errGrade] >= 2);   idxRew = (abs([ninfo.rewGrade]) >= 2);
idxTaskRel = (idxVis | idxMove | idxErr | idxRew);

idxKeep = (idxArea & idxMonkey & idxTaskRel);

NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

T_STIM = 3500 + (-50 : 300);  OFFSET = 50;

%output initializations: Accurate, Fast, Target in (RF), Distractor in (RF)
visResp = new_struct({'AccTin','AccDin','FastTin','FastDin'}, 'dim',[1,NUM_CELLS]);
visResp = populate_struct(visResp, {'AccTin','AccDin','FastTin','FastDin'}, NaN(length(T_STIM),1));

for cc = 1:NUM_CELLS
  fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  RTkk = double(moves(kk).resptime);
  
  %compute spike density function
  sdfKKstim = compute_spike_density_fxn(spikes(cc).SAT);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxAcc = (binfo(kk).condition == 1 & ~idxIso);
  idxFast = (binfo(kk).condition == 3 & ~idxIso);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc | binfo(kk).err_hold);
  %index by response dir re. response field
  if ismember(9, ninfo(cc).visField)
    idxRF = true(1,binfo(kk).num_trials);
  elseif isempty(ninfo(cc).visField)
    idxRF = true(1,binfo(kk).num_trials);
  else %standard response field
    idxRF = ismember(moves(kk).octant, ninfo(cc).visField);
  end
  
  %isolate single-trial SDFs
  VRAcc.Tin = sdfKKstim(idxAcc & idxCorr & idxRF, T_STIM);
  VRAcc.Din = sdfKKstim(idxAcc & idxCorr & ~idxRF, T_STIM);
  VRFast.Tin = sdfKKstim(idxFast & idxCorr & idxRF, T_STIM);
  VRFast.Din = sdfKKstim(idxFast & idxCorr & ~idxRF, T_STIM);
  
  %compute mean SDFs
  visResp(cc).AccTin(:) = mean(VRAcc.Tin);    visResp(cc).AccDin(:) = mean(VRAcc.Din);
  visResp(cc).FastTin(:) = mean(VRFast.Tin);  visResp(cc).FastDin(:) = mean(VRFast.Din);
  
  %% Parameterize the visual response
  ccNS = ninfo(cc).unitNum;
  
  %latency
%   [VRlatAcc,VRlatFast] = computeVisRespLatSAT(VRAcc, VRFast, nstats(ccNS), OFFSET);
%   nstats(ccNS).VRlatAcc = VRlatAcc;
%   nstats(ccNS).VRlatFast = VRlatFast;
  
  %magnitude
%   [VRmagAcc,VRmagFast] = computeVisRespMagSAT(VRAcc, VRFast, nstats(ccNS), OFFSET);
%   nstats(ccNS).VRmagAcc = VRmagAcc;
%   nstats(ccNS).VRmagFast = VRmagFast;
  
  %target selection
%   [VRTSTAcc,VRTSTFast,tVecTSH1] = computeVisRespTSTSAT(VRAcc, VRFast, nstats(ccNS), OFFSET);
%   nstats(ccNS).VRTSTAcc = VRTSTAcc;
%   nstats(ccNS).VRTSTFast = VRTSTFast;
  
  %normalization factor
%   nstats(ccNS).NormFactor_Vis = max(visResp(cc).FastTin);
  
  %plot individual cell activity
%   plotVisRespSATcc(T_STIM, visResp(cc), ninfo(cc), nstats(ccNS));
%   print([ROOTDIR, ninfo(cc).sess,'-',ninfo(cc).unit,'-U',num2str(ccNS),'.tif'], '-dtiff'); pause(0.1); close()
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = nstats;
end


%% Plotting - Across cells
nstats = nstats(idxKeep);

% quantTSTAcc = quantile([nstats.VRTSTAcc], [.1 .5 .9]);
medTSTAcc = median([nstats.VRTSTAcc]); %plot median TST
medTSTFast = median([nstats.VRTSTFast]);

visRespAccTin = transpose([visResp.AccTin]);    visRespAccDin = transpose([visResp.AccDin]);
visRespFastTin = transpose([visResp.FastTin]);  visRespFastDin = transpose([visResp.FastDin]);

%normalization
normFactor = [nstats.NormFactor_Vis];
visRespAccTin = visRespAccTin ./ normFactor;    visRespAccDin = visRespAccDin ./ normFactor;
visRespFastTin = visRespFastTin ./ normFactor;  visRespFastDin = visRespFastDin ./ normFactor;

figure(); hold on

plot(T_STIM-3500, nanmean(visRespFastDin), 'Color',[0 .7 0], 'LineWidth',0.75, 'LineStyle',':')
plot(T_STIM-3500, nanmean(visRespFastTin), 'Color',[0 .7 0], 'LineWidth',1.25)
plot(T_STIM-3500, nanmean(visRespAccDin), 'Color','r', 'LineWidth',0.75, 'LineStyle',':')
plot(T_STIM-3500, nanmean(visRespAccTin), 'Color','r', 'LineWidth',1.25)

plot(medTSTAcc*ones(1,2), [.25 .75], 'r:', 'LineWidth',1.0)
plot(medTSTFast*ones(1,2), [.25 .75], ':', 'Color',[0 .7 0], 'LineWidth',1.0)

xlabel('Time from array (ms)'); ylabel('Normalized activity'); ytickformat('%2.1f')
ppretty([4.8,2.5])

% figure(); hold on
% plot(T_STIM-3500, visRespAccTin, 'Color','r', 'LineWidth',0.75)
% xlabel('Time from array (ms)'); ylabel('Normalized activity')
% ppretty([4.8,3])

end%fxn:plotVisRespSAT()




function [ ] = plotVisRespSATcc(T_STIM, visResp, ninfo, nstats, varargin)
%plotVisRespSATcc Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'tVec=',[]}});

figure(); hold on

tmp = [visResp.AccTin ; visResp.FastTin];
yLim = [min(tmp) max(tmp)];

subplot(2,1,1); hold on %Fast condition
plot([0 0], yLim, 'k--')
plot(T_STIM-3500, visResp.FastTin, '-', 'Color',[0 .7 0], 'LineWidth',0.75)
plot(T_STIM-3500, visResp.FastDin, '--', 'Color',[0 .7 0], 'LineWidth',0.5)
plot(nstats.VRlatFast*ones(1,2), yLim, 'k:', 'LineWidth',0.5)
plot(nstats.VRTSTFast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
% plot([T_STIM(1) T_STIM(end)]-3500, nstats.blineFastMEAN*ones(1,2), ':', 'Color',[0 .7 0], 'LineWidth',0.5)
title(['mag(A) = ',num2str(nstats.VRmagAcc)], 'FontSize',8)
print_session_unit(gca , ninfo,[])

subplot(2,1,2); hold on %Accurate condition
plot([0 0], yLim, 'k--')
plot(T_STIM-3500, visResp.AccTin, 'r-', 'LineWidth',0.75)
plot(T_STIM-3500, visResp.AccDin, 'r--', 'LineWidth',0.5)
plot(nstats.VRlatAcc*ones(1,2), yLim, 'k:', 'LineWidth',0.5)
plot(nstats.VRTSTAcc*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
% plot([T_STIM(1) T_STIM(end)]-3500, nstats.blineAccMEAN*ones(1,2), 'r:', 'LineWidth',0.5)
title(['mag(A) = ',num2str(nstats.VRmagFast)], 'FontSize',8)
xlabel('Time from array (ms)')
ylabel('Activity (sp/sec)')

ppretty([6,4])

% if ~isempty(args.tVec) %plot vector of timestamps of target selection
%   plot(args.tVec.Acc, yLim(1)+diff(yLim)*.1, '.', 'MarkerSize',10, 'Color',[.5 0 0])
%   plot(args.tVec.Fast, yLim(1)+diff(yLim)*.05, '.', 'MarkerSize',10, 'Color',[0 .4 0])
% end

end%util:plotVisRespSATcc()

