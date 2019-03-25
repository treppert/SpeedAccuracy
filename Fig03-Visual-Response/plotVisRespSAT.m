function [ varargout ] = plotVisRespSAT( binfo , moves , ninfo , nstats , spikes , varargin )
%plotVisRespSAT() Summary of this function goes here
%   Note - In order to use this function, first run plotBlineXcondSAT() in
%   order to obtain estimates of mean and SD of baseline activity.
% 

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxVis = ismember({ninfo.visType}, {'sustained'});

ninfo = ninfo(idxArea & idxMonkey & idxVis);
spikes = spikes(idxArea & idxMonkey & idxVis);

NUM_CELLS = length(spikes);
T_STIM = 3500 + (-100 : 300);
T_RESP = 3500 + (-300 : 100);

%output initializations
visResp = new_struct({'Acc','Fast'}, 'dim',[1,NUM_CELLS]);
visResp = populate_struct(visResp, {'Acc','Fast'}, NaN(length(T_STIM),1));
sdfMove = new_struct({'Acc','Fast'}, 'dim',[1,NUM_CELLS]);
sdfMove = populate_struct(sdfMove, {'Acc','Fast'}, NaN(length(T_RESP),1));

for cc = 1:NUM_CELLS
%   fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  kk = ismember({binfo.session}, ninfo(cc).sess);
  ccNS = ninfo(cc).unitNum;
  if (nstats(ccNS).VReffect ~= 1); continue; end
  
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
  idxRF = ismember(moves(kk).octant, ninfo(cc).visField);
  
  %isolate single-trial SDFs
  VRAccCC = sdfKKstim(idxAcc & idxCorr & idxRF, T_STIM);
  VRFastCC = sdfKKstim(idxFast & idxCorr & idxRF, T_STIM);
  
  %compute mean SDFs
  visResp(cc).Acc(:) = mean(VRAccCC);
  visResp(cc).Fast(:) = mean(VRFastCC);
  sdfMove(cc).Acc(:) = mean(sdfKKresp(idxAcc & idxCorr & idxRF, T_RESP));
  sdfMove(cc).Fast(:) = mean(sdfKKresp(idxFast & idxCorr & idxRF, T_RESP));
  
  %% Parameterize the visual response
  %latency
%   [VRlatAcc,VRlatFast] = computeVisRespLatSAT(VRAccCC(:,101:400), VRFastCC(:,101:400), nstats(ccNS));
  VRlatAcc = nstats(ccNS).VRlatAcc; %already computed
  VRlatFast = nstats(ccNS).VRlatFast;
  
  %magnitude
  [VRmagAcc,VRmagFast] = computeVisRespMagSAT(VRAccCC(:,101:400), VRFastCC(:,101:400), VRlatAcc, VRlatFast, nstats(ccNS));
  nstats(ccNS).VRmagAcc = VRmagAcc;
  nstats(ccNS).VRmagFast = VRmagFast;
  
  %normalization factor
%   nstats(ccNS).visRespNormFactor = max(visResp(cc).Fast);
  
  %plot individual cell activity
  plotVisRespSATcc(T_STIM, T_RESP, visResp(cc), sdfMove(cc), ninfo(cc), nstats(ccNS))
%   print(['~/Dropbox/Speed Accuracy/SEF_SAT/Figs/Visual-Response/SDF-VisResp/',ninfo(cc).sess,'-',ninfo(cc).unit,'.tif'], '-dtiff')
  pause()
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = nstats;
end

%% Plotting - Across cells
visRespAcc = transpose([visResp.Acc]);
visRespFast = transpose([visResp.Fast]);
latVRAcc = [nstats(idxArea & idxMonkey & idxVis).VRlatAcc];
latVRFast = [nstats(idxArea & idxMonkey & idxVis).VRlatFast];

%normalization
visRespAcc = visRespAcc ./ max(visRespFast,[],2);
visRespFast = visRespFast ./ max(visRespFast,[],2);

%sort neurons by visual response latency in the Fast condition
[latVRFast,idxVRFast] = sort(latVRFast);
visRespFast = visRespFast(idxVRFast,:);
visRespAcc = visRespAcc(idxVRFast,:);
latVRAcc = latVRAcc(idxVRFast);
ninfo = ninfo(idxVRFast);

figure() %plot Fast and Acc separately

subplot(1,2,1); hold on %Fast
imagesc(T_STIM-3500, (1:NUM_CELLS), visRespFast); %colorbar
plot(latVRFast, (1:NUM_CELLS), 'k.', 'MarkerSize',15)
text((T_STIM(1)-3500)*ones(1,NUM_CELLS), (1:NUM_CELLS), {ninfo.sess})
text(zeros(1,NUM_CELLS), (1:NUM_CELLS), {ninfo.unit})
xlim([T_STIM(1)-5, T_STIM(end)+5] - 3500)
ylim([0 NUM_CELLS+1])
cLim1 = caxis(gca);

subplot(1,2,2); hold on %Acc
imagesc(T_STIM-3500, (1:NUM_CELLS), visRespAcc); %colorbar
plot(latVRAcc, (1:NUM_CELLS), 'k.', 'MarkerSize',15)
xlim([T_STIM(1)-5, T_STIM(end)+5] - 3500)
ylim([0 NUM_CELLS+1])
cLim2 = caxis(gca);

%set color limits to match
cLim = [min([cLim1 cLim2]), max([cLim1 cLim2])];
subplot(1,2,1); caxis(cLim)
subplot(1,2,2); caxis(cLim)

ppretty([12,8])

end%fxn:plotVisRespSAT()
