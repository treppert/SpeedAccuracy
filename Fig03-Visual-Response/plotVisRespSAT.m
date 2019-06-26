function [ varargout ] = plotVisRespSAT( binfo , moves , ninfo , nstats , spikes , varargin )
%plotVisRespSAT() Summary of this function goes here
%   Note - In order to use this function, first run plotBlineXcondSAT() in
%   order to obtain estimates of mean and SD of baseline activity.
% 

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});
ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\SAT\Figs-VisResp-SEF\';

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxVis = ([ninfo.visGrade] >= 2);
idxSustained = ismember({ninfo.visType}, 'sustained');
idxPhasic = ismember({ninfo.visType}, 'phasic');
idxTST = ~(isnan([nstats.VRTSTAcc]) | isnan([nstats.VRTSTFast]));
idxEff = ([ninfo.taskType] == 2);

idxKeep = (idxArea & idxMonkey & idxVis);

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
