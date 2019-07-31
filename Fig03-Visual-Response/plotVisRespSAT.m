function [ varargout ] = plotVisRespSAT( binfo , moves , ninfo , nstats , spikes , varargin )
%plotVisRespSAT() Summary of this function goes here
%   Note - In order to use this function, first run plotBlineXcondSAT() in
%   order to obtain estimates of mean and SD of baseline activity.
% 

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});
ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\SAT\Figures\Figs-VisResp-SEF\';

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxVis = ([ninfo.visGrade] >= 2);
idxKeep = (idxArea & idxMonkey & idxVis);

NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

T_STIM = 3500 + (0 : 250);  OFFSET = 0;

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
%   idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc | binfo(kk).err_hold);
  idxCorr = ~(binfo(kk).err_time | binfo(kk).err_nosacc | binfo(kk).err_hold);
  %index by response dir re. response field
  if ismember(9, ninfo(cc).visField)
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

vrAccTin = transpose([visResp.AccTin]);    vrAccDin = transpose([visResp.AccDin]);
vrFastTin = transpose([visResp.FastTin]);  vrFastDin = transpose([visResp.FastDin]);

%normalization
normFactor = [nstats(idxKeep).NormFactor_Vis]';
vrAccTin = vrAccTin ./ normFactor;    vrAccDin = vrAccDin ./ normFactor;
vrFastTin = vrFastTin ./ normFactor;  vrFastDin = vrFastDin ./ normFactor;

%split on levels of search efficiency
ccMore = ([ninfo.taskType] == 1);   NUM_MORE = sum(ccMore);
ccLess = ([ninfo.taskType] == 2);   NUM_LESS = sum(ccLess);

vrAccMore = vrAccTin(ccMore,:);     vrAccLess = vrAccTin(ccLess,:);
vrFastMore = vrFastTin(ccMore,:);   vrFastLess = vrFastTin(ccLess,:);

%% Plotting - Across cells
figure()

subplot(2,1,1); hold on %less efficient search
% plot(T_STIM-3500, (vrFastTin), 'Color',[0 .7 0])
% plot(T_STIM-3500, (vrAccTin), 'Color','r')
shaded_error_bar(T_STIM-3500, nanmean(vrAccLess), nanstd(vrAccLess)/sqrt(NUM_LESS), {'r-', 'LineWidth',1.5})
shaded_error_bar(T_STIM-3500, nanmean(vrFastLess), nanstd(vrFastLess)/sqrt(NUM_LESS), {'-', 'Color',[0 .7 0], 'LineWidth',1.5})
ytickformat('%2.1f')

subplot(2,1,2); hold on %more efficient search
shaded_error_bar(T_STIM-3500, nanmean(vrAccMore), nanstd(vrAccMore)/sqrt(NUM_MORE), {'r-'})
shaded_error_bar(T_STIM-3500, nanmean(vrFastMore), nanstd(vrFastMore)/sqrt(NUM_MORE), {'-', 'Color',[0 .7 0]})
xlabel('Time from array (ms)'); ylabel('Normalized activity'); ytickformat('%2.1f')

ppretty([4.8,4])

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

