function [ varargout ] = plotVisRespSAT( binfo , moves , ninfo , nstats , spikes , varargin )
%plotVisRespSAT() Summary of this function goes here
%   Note - In order to use this function, first run plotBlineXcondSAT() in
%   order to obtain estimates of mean and SD of baseline activity.
% 

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});
ROOT_DIR = 'C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\SEF_SAT\Figs\'; %for printing figs

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
if strcmp(args.area, 'SEF')
  idxVis = ismember({ninfo.visType}, {'sustained'});
else
  idxVis = ([ninfo.visGrade] >= 0.5);
end
% idxTST = ~(isnan([nstats.VRTSTAcc]) | isnan([nstats.VRTSTFast]));
% idxTStest = (cellfun(@length, {ninfo.visField}) < 8); %index by finite RF
idxEfficient = ismember([ninfo.taskType], 2);

idxKeep = (idxArea & idxMonkey & idxVis & idxEfficient);

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

NUM_SEM = sum(idxKeep);
NUM_CELLS = length(spikes);

T_STIM = 3500 + (0 : 300);
T_RESP = 3500 + (-300 : 100);

%output initializations: Accurate, Fast, Target in (RF), Distractor in (RF)
visResp = new_struct({'AccTin','AccDin','FastTin','FastDin'}, 'dim',[1,NUM_CELLS]);
visResp = populate_struct(visResp, {'AccTin','AccDin','FastTin','FastDin'}, NaN(length(T_STIM),1));
sdfMove = new_struct({'AccTin','AccDin','FastTin','FastDin'}, 'dim',[1,NUM_CELLS]);
sdfMove = populate_struct(sdfMove, {'AccTin','AccDin','FastTin','FastDin'}, NaN(length(T_RESP),1));

for cc = 1:NUM_CELLS
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
%   ccNS = ninfo(cc).unitNum;
%   OFFSET = 100; %tell parameterization fxns how much of the SDF to cut out as pre-array stimulus
  
  %latency
%   [VRlatAcc,VRlatFast] = computeVisRespLatSAT(VRAcc, VRFast, nstats(ccNS), OFFSET);
%   nstats(ccNS).VRlatAcc = VRlatAcc;
%   nstats(ccNS).VRlatFast = VRlatFast;
  
  %magnitude
%   [VRmagAcc,VRmagFast] = computeVisRespMagSAT(VRAcc, VRFast, nstats(ccNS), OFFSET);
%   nstats(ccNS).VRmagAcc = VRmagAcc;
%   nstats(ccNS).VRmagFast = VRmagFast;
  
  %target selection
%   [VRTSTAcc,VRTSTFast] = computeVisRespTSTSAT(VRAcc, VRFast, nstats(ccNS), OFFSET);
%   nstats(ccNS).VRTSTAcc = VRTSTAcc;
%   nstats(ccNS).VRTSTFast = VRTSTFast;
  
  %normalization factor
%   nstats(ccNS).visRespNormFactor = max(visResp(cc).Fast);
  
  %plot individual cell activity
%   plotVisRespSATcc(T_STIM, T_RESP, visResp(cc), sdfMove(cc), ninfo(cc), nstats(ccNS))
%   print([ROOT_DIR,'Visual-Response\SDF-VisResp\',ninfo(cc).area,'-',ninfo(cc).sess,'-',ninfo(cc).unit,'.tif'], '-dtiff'); pause(0.15); close()
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = nstats;
end

%% Plotting - Across cells
visRespAccTin = transpose([visResp.AccTin]);
visRespAccDin = transpose([visResp.AccDin]);
visRespFastTin = transpose([visResp.FastTin]);
visRespFastDin = transpose([visResp.FastDin]);

%normalization
normFactor = max(visRespFastTin,[],2);
visRespAccTin = visRespAccTin ./ normFactor;
visRespAccDin = visRespAccDin ./ normFactor;
visRespFastTin = visRespFastTin ./ normFactor;
visRespFastDin = visRespFastDin ./ normFactor;

figure(); hold on
% plot(T_STIM-3500, visRespFastTin, 'Color',[0 .7 0], 'LineWidth',0.75)
shaded_error_bar(T_STIM-3500, nanmean(visRespFastDin), nanstd(visRespFastDin)/sqrt(NUM_SEM), {'Color',[0 .7 0], 'LineWidth',0.5, 'LineStyle','--'})
shaded_error_bar(T_STIM-3500, nanmean(visRespFastTin), nanstd(visRespFastTin)/sqrt(NUM_SEM), {'Color',[0 .7 0], 'LineWidth',0.75})
shaded_error_bar(T_STIM-3500, nanmean(visRespAccDin), nanstd(visRespAccDin)/sqrt(NUM_SEM), {'Color','r', 'LineWidth',0.5, 'LineStyle','--'})
shaded_error_bar(T_STIM-3500, nanmean(visRespAccTin), nanstd(visRespAccTin)/sqrt(NUM_SEM), {'Color','r', 'LineWidth',0.75})
xlabel('Time from array (ms)'); ylabel('Normalized activity'); ytickformat('%2.1f')
ppretty([4.8,3])

% figure(); hold on
% plot(T_STIM-3500, visRespAccTin, 'Color','r', 'LineWidth',0.75)
% xlabel('Time from array (ms)'); ylabel('Normalized activity')
% ppretty([4.8,3])

end%fxn:plotVisRespSAT()
