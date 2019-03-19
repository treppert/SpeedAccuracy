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
T_RESP.Acc = 3500 + (-300 : 100);
T_RESP.Fast = 3500 + (-100 : 100);

%param used to quantify the visual response
MIN_DUR_VR = 50; %mininum duration of the visual response (ms)
SD_THRESH_VR = [6, 2]; %minimum number of SDs from the mean (threshold)
WIN_COMP_MAG = 100; %amount of time (ms) used to estimate magnitude

%output initializations
visResp = new_struct({'Acc','Fast'}, 'dim',[1,NUM_CELLS]);
visResp = populate_struct(visResp, {'Acc','Fast'}, NaN(length(T_STIM),1));
sdfMove = new_struct({'Acc','Fast'}, 'dim',[1,NUM_CELLS]);
sdfMove = populate_struct(sdfMove, {'Acc'}, NaN(length(T_RESP.Acc),1));
sdfMove = populate_struct(sdfMove, {'Fast'}, NaN(length(T_RESP.Fast),1));
RT = new_struct({'Acc','Fast'}, 'dim',[1,NUM_CELLS]);
RT = populate_struct(RT, {'Acc','Fast'}, NaN);

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
  idxRF = ismember(moves(kk).octant, ninfo(cc).visField);
  
  %compute SDF
  VRAccCC = sdfKKstim(idxAcc & idxCorr & idxRF, T_STIM);
  VRFastCC = sdfKKstim(idxFast & idxCorr & idxRF, T_STIM);
  visResp(cc).Acc(:) = nanmean(VRAccCC);
  visResp(cc).Fast(:) = nanmean(VRFastCC);
  sdfMove(cc).Acc(:) = nanmean(sdfKKresp(idxAcc & idxCorr & idxRF, T_RESP.Acc));
  sdfMove(cc).Fast(:) = nanmean(sdfKKresp(idxFast & idxCorr & idxRF, T_RESP.Fast));
  %compute median RT
  RT(cc).Acc = median(RTkk(idxAcc & idxCorr & idxRF));
  RT(cc).Fast = median(RTkk(idxFast & idxCorr & idxRF));
  
  %% Parameterize the visual response
  idxStats = ninfo(cc).unitNum;
  
  %normalization factor
  nstats(idxStats).visRespNormFactor = max(visResp(cc).Fast);
  
  %latency
  nstats(idxStats).visRespAccLAT = computeVisRespLatency(VRAccCC, nstats(idxStats).blineAccMEAN, nstats(idxStats).blineAccSD, SD_THRESH_VR, MIN_DUR_VR, T_STIM);
  nstats(idxStats).visRespFastLAT = computeVisRespLatency(VRFastCC, nstats(idxStats).blineFastMEAN, nstats(idxStats).blineFastSD, SD_THRESH_VR, MIN_DUR_VR, T_STIM);
  
  %magnitude
  %subtract baseline activity
  VRAccCC = visResp(cc).Acc - nstats(idxStats).blineAccMEAN;
  VRFastCC = visResp(cc).Fast - nstats(idxStats).blineFastMEAN;
  
  %mean activity during 100-ms interval post-onset
  idxVRAcc = nstats(idxStats).visRespAccLAT - (T_STIM(1) - 3500);
  idxVRFast = nstats(idxStats).visRespFastLAT - (T_STIM(1) - 3500);
  nstats(idxStats).visRespAccMAG = mean(VRAccCC(idxVRAcc:idxVRAcc+WIN_COMP_MAG-1));
  nstats(idxStats).visRespFastMAG = mean(VRFastCC(idxVRFast:idxVRFast+WIN_COMP_MAG-1));
  
  %plot individual cell activity
%   plotVisRespSATcc(T_STIM, T_RESP, visResp(cc), sdfMove(cc), RT(cc), ninfo(cc), nstats(idxStats)); pause()
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = nstats;
end

%% Plotting - Across cells
visRespAcc = transpose([visResp.Acc]);
visRespFast = transpose([visResp.Fast]);
latVRAcc = [nstats(idxArea & idxMonkey & idxVis).visRespAccLAT];
latVRFast = [nstats(idxArea & idxMonkey & idxVis).visRespFastLAT];

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

function [ latency , varargout ] = computeVisRespLatency(visResp, MEANBline, SDBline, SD_THRESH_VR, MIN_DUR_VR, T_STIM)

%start testing for vis response at MIN_VIS_LAT
MIN_VIS_LAT = 20; %minimum acceptable value for response latency
idxTestStart = find((T_STIM-3500) == MIN_VIS_LAT);
visResp = visResp(:,idxTestStart:end);
T_STIM = T_STIM(idxTestStart:end);

%bootstrapping parameters
NUM_ITER = 1; %number of times to sample
NUM_TRIAL = size(visResp,1); %number of trials from which to sample

%initializations
latency = NaN(1,NUM_ITER);

%compute activity threshold values based on baseline activity
THRESH_HIGH = MEANBline + SD_THRESH_VR(1)*SDBline;
THRESH_LOW = MEANBline + SD_THRESH_VR(2)*SDBline;

for jj = 1:NUM_ITER
  %sample with replacement from candidate trials
  trialJJ = datasample((1:NUM_TRIAL), NUM_TRIAL, 'Replace',false);
  %use the sampled trials to compute the SDF
  visRespJJ = nanmean(visResp(trialJJ,:));
  
  %find all points above THRESH
  tCand = find(visRespJJ > THRESH_HIGH);
  nSamp = length(tCand) - MIN_DUR_VR;
  dtCand = diff(tCand);
  
  tInitVR = NaN;
  for ii = 1:nSamp %loop over candidate samples and find run of MIN_DUR
    runLengthII = sum(dtCand(ii:ii+MIN_DUR_VR-1));
    if (runLengthII == MIN_DUR_VR)%found a run of MIN_DUR_VR above top threshold
      %tag the start of the run as the vis resp latency
      tInitVR = tCand(ii);
      %now walk back to the bottom threshold
      tCand = find(visRespJJ < THRESH_LOW); %find points below bottom threshold
      idxVRNew = find(tCand < tInitVR, 1, 'last'); %find last such point before VR
      if ~isempty(idxVRNew) %if there is no such point, then keep current estimate
        tInitVR = tCand(idxVRNew);
      end
      break
    end
  end%for:sample(ii)
  
  if isnan(tInitVR)
    fprintf('Warning jj=%d: Unable to locate VR initiation\n', jj)
  end
  
  latency(jj) = T_STIM(1) + tInitVR - 3500;
  
end%for:bootstrap-iter(jj)

latency = nanmedian(latency);

if (nargout > 1) %if desired, return threshold values for plotting
  varargout{1} = struct('High',THRESH_HIGH, 'Low',THRESH_LOW);
end

end%util:computeVisRespLatency()
