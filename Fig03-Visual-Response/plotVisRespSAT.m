function [ varargout ] = plotVisRespSAT( binfo , moves , ninfo , nstats , spikes , varargin )
%plotVisRespSAT() Summary of this function goes here
%   Note - In order to use this function, first run plotBlineXcondSAT() in
%   order to obtain estimates of mean and SD of baseline activity.
% 

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});
ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\SEF_SAT\Figs\Visual-Response\';

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

% idxVis = ([ninfo.visGrade] >= 2);
idxVis = ([ninfo.visGrade] >= 2 & ismember({ninfo.visType}, 'sustained'));
idxTST = (isnan([nstats.VRTSTAcc]) | isnan([nstats.VRTSTFast]));
idxRF = ([ninfo.visField] == 9);
idxEff = ([ninfo.taskType] == 1);

idxKeep = (idxArea & idxMonkey & idxVis & idxTST & idxRF & idxEff);

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);
NUM_CELLS = length(spikes);

T_STIM = 3500 + (-50 : 350);  OFFSET = 50;
T_RESP = 3500 + (-300 : 100);

%if desired, isolate one neuron of interest
sessionPlot = [];   unitPlot = [];

%output initializations: Accurate, Fast, Target in (RF), Distractor in (RF)
visResp = new_struct({'AccTin','AccDin','FastTin','FastDin'}, 'dim',[1,NUM_CELLS]);
visResp = populate_struct(visResp, {'AccTin','AccDin','FastTin','FastDin'}, NaN(length(T_STIM),1));
sdfMove = new_struct({'AccTin','AccDin','FastTin','FastDin'}, 'dim',[1,NUM_CELLS]);
sdfMove = populate_struct(sdfMove, {'AccTin','AccDin','FastTin','FastDin'}, NaN(length(T_RESP),1));

for cc = 1:NUM_CELLS
  if ~isempty(sessionPlot) && ~(ismember(ninfo(cc).sess, sessionPlot) && ismember(ninfo(cc).unit, unitPlot))
    continue %if desired, isolate one neuron of interest
  end
  fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  RTkk = double(moves(kk).resptime);
  
  %compute spike density function
  sdfKKstim = compute_spike_density_fxn(spikes(cc).SAT);
  %align on primary response for sdfMove plots
  sdfKKresp = align_signal_on_response(sdfKKstim, RTkk);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxAcc = (binfo(kk).condition == 1 & ~idxIso);
  idxFast = (binfo(kk).condition == 3 & ~idxIso);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc);
  %index by response dir re. response field
%   idxRF = ismember(moves(kk).octant, ninfo(cc).visField);
  idxRF = ismember(moves(kk).octant, (1:8)); %for plotting w/o TST
  
  %isolate single-trial SDFs
  VRAcc.Tin = sdfKKstim(idxAcc & idxCorr & idxRF, T_STIM);     SMAcc.Tin = sdfKKresp(idxAcc & idxCorr & idxRF, T_RESP);
  VRAcc.Din = sdfKKstim(idxAcc & idxCorr & ~idxRF, T_STIM);    SMAcc.Din = sdfKKresp(idxAcc & idxCorr & ~idxRF, T_RESP);
  VRFast.Tin = sdfKKstim(idxFast & idxCorr & idxRF, T_STIM);   SMFast.Tin = sdfKKresp(idxFast & idxCorr & idxRF, T_RESP);
  VRFast.Din = sdfKKstim(idxFast & idxCorr & ~idxRF, T_STIM);  SMFast.Din = sdfKKresp(idxFast & idxCorr & ~idxRF, T_RESP);
  
  %compute mean SDFs
  visResp(cc).AccTin(:) = mean(VRAcc.Tin);    visResp(cc).AccDin(:) = mean(VRAcc.Din);
  visResp(cc).FastTin(:) = mean(VRFast.Tin);  visResp(cc).FastDin(:) = mean(VRFast.Din);
  sdfMove(cc).AccTin(:) = mean(SMAcc.Tin);    sdfMove(cc).AccDin(:) = mean(SMAcc.Din);
  sdfMove(cc).FastTin(:) = mean(SMFast.Tin);  sdfMove(cc).FastDin(:) = nanmean(SMFast.Din);
  
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
%   nstats(ccNS).visRespNormFactor = max(visResp(cc).Fast);
  
  %plot individual cell activity
%   plotVisRespSATcc(T_STIM, T_RESP, visResp(cc), sdfMove(cc), ninfo(cc), nstats(ccNS));
%   print([ROOTDIR,'SDF-VisResp\',ninfo(cc).area,'-',ninfo(cc).sess,'-',ninfo(cc).unit,'-N',num2str(ccNS),'.tif'], '-dtiff'); pause(0.1); close()
  
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
normFactor = max(visRespFastTin,[],2);
visRespAccTin = visRespAccTin ./ normFactor;    visRespAccDin = visRespAccDin ./ normFactor;
visRespFastTin = visRespFastTin ./ normFactor;  visRespFastDin = visRespFastDin ./ normFactor;

figure(); hold on

% plot(T_STIM-3500, nanmean(visRespFastDin), 'Color',[0 .7 0], 'LineWidth',0.75, 'LineStyle',':')
plot(T_STIM-3500, nanmean(visRespFastTin), 'Color',[0 .7 0], 'LineWidth',1.25)
% plot(T_STIM-3500, nanmean(visRespAccDin), 'Color','r', 'LineWidth',0.75, 'LineStyle',':')
plot(T_STIM-3500, nanmean(visRespAccTin), 'Color','r', 'LineWidth',1.25)

% plot(medTSTAcc*ones(1,2), [.25 .75], 'r:', 'LineWidth',1.0)
% plot(medTSTFast*ones(1,2), [.25 .75], ':', 'Color',[0 .7 0], 'LineWidth',1.0)

xlabel('Time from array (ms)'); ylabel('Normalized activity'); ytickformat('%2.1f')
ppretty([4.8,2.5])

% figure(); hold on
% plot(T_STIM-3500, visRespAccTin, 'Color','r', 'LineWidth',0.75)
% xlabel('Time from array (ms)'); ylabel('Normalized activity')
% ppretty([4.8,3])

end%fxn:plotVisRespSAT()
