function [ varargout ] = plotVisRespSAT( binfo , moves , ninfo , spikes , varargin )
%plotVisRespSAT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
%remove cells w/o correct form of visual response
idxVis = ismember({ninfo.visType}, {'sustained'});

ninfo = ninfo(idxArea & idxMonkey & idxVis);
spikes = spikes(idxArea & idxMonkey & idxVis);

NUM_CELLS = length(spikes);
T_BASE = 3500 + (-300 : -1);
T_STIM = 3500 + (-100 : 300);
T_RESP.Acc = 3500 + (-300 : 100);
T_RESP.Fast = 3500 + (-100 : 100);

%visual response latency parameters
MIN_DUR_VR = 50; %mininum duration of the visual response (ms)
SD_THRESH_VR = [6, 2]; %minimum number of SDs from the mean (threshold)

%visual response magnitude parameters
DUR_COMP_MAG = 100; %amount of time (ms) after latency used to estimate mag

%output initializations
visResp = new_struct({'Acc','Fast'}, 'dim',[1,NUM_CELLS]);
visResp = populate_struct(visResp, {'Acc','Fast'}, NaN(length(T_STIM),1));
sdfMove = new_struct({'Acc','Fast'}, 'dim',[1,NUM_CELLS]);
sdfMove = populate_struct(sdfMove, {'Acc'}, NaN(length(T_RESP.Acc),1));
sdfMove = populate_struct(sdfMove, {'Fast'}, NaN(length(T_RESP.Fast),1));
RT = new_struct({'Acc','Fast'}, 'dim',[1,NUM_CELLS]);
RT = populate_struct(RT, {'Acc','Fast'}, NaN);
meanBline = RT;
latVR = RT; %visual response latency
magVR = RT; %visual response magnitude

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  RTkk = double(moves(kk).resptime);
  
  %compute spike density function
  sdfKKstim = compute_spike_density_fxn(spikes(cc).SAT);
  %align on primary response for sdfMove plots
  sdfKKresp = align_signal_on_response(sdfKKstim, RTkk);
  
  %index by condition
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc);
  %index by response dir re. response field
  idxRF = ismember(moves(kk).octant, ninfo(cc).visField);
  
  %compute SDF
  visResp(cc).Acc(:) = nanmean(sdfKKstim(idxAcc & idxCorr & idxRF, T_STIM));
  visResp(cc).Fast(:) = nanmean(sdfKKstim(idxFast & idxCorr & idxRF, T_STIM));
  sdfMove(cc).Acc(:) = nanmean(sdfKKresp(idxAcc & idxCorr & idxRF, T_RESP.Acc));
  sdfMove(cc).Fast(:) = nanmean(sdfKKresp(idxFast & idxCorr & idxRF, T_RESP.Fast));
  %compute median RT
  RT(cc).Acc = median(RTkk(idxAcc & idxCorr & idxRF));
  RT(cc).Fast = median(RTkk(idxFast & idxCorr & idxRF));
  %compute baseline activity
  blineAcc = nanmean(sdfKKstim(idxAcc & idxCorr, T_BASE));
  blineFast = nanmean(sdfKKstim(idxFast & idxCorr, T_BASE));
  meanBline(cc).Acc = mean(blineAcc);
  meanBline(cc).Fast = mean(blineFast);
  
  %compute visual response latency
  [latVR(cc).Acc, threshAcc] = computeVisRespLatency(visResp(cc).Acc(:), blineAcc, SD_THRESH_VR, MIN_DUR_VR, T_STIM);
  [latVR(cc).Fast, threshFast] = computeVisRespLatency(visResp(cc).Fast(:), blineFast, SD_THRESH_VR, MIN_DUR_VR, T_STIM);
  
  if isnan(latVR(cc).Acc)
    latVR(cc).Acc = latVR(cc).Fast;
  end
  
  %plot individual cell activity
  if (0)
  plotVisRespCC(T_STIM, T_RESP, visResp(cc), sdfMove(cc), RT(cc), latVR(cc))
  subplot(1,2,1); print_session_unit(gca , ninfo(cc), binfo(kk), 'horizontal')
%   plot([T_STIM(1) T_STIM(end)]-3500, meanBline(cc).Fast*ones(1,2), ':', 'Color',[0 .7 0], 'LineWidth',0.5)
%   plot([T_STIM(1) T_STIM(end)]-3500, threshFast.High*ones(1,2), ':', 'Color',[0 .7 0], 'LineWidth',0.5)
%   plot([T_STIM(1) T_STIM(end)]-3500, threshFast.Low*ones(1,2), ':', 'Color',[0 .7 0], 'LineWidth',0.5)
%   plot([T_STIM(1) T_STIM(end)]-3500, meanBline(cc).Acc*ones(1,2), 'r:', 'LineWidth',0.5)
%   plot([T_STIM(1) T_STIM(end)]-3500, threshAcc.High*ones(1,2), 'r:', 'LineWidth',0.5)
%   plot([T_STIM(1) T_STIM(end)]-3500, threshAcc.Low*ones(1,2), 'r:', 'LineWidth',0.5)
  pause()
  end
end%for:cells(cc)

%% Plotting - Across cells
visRespAcc = transpose([visResp.Acc]);
visRespFast = transpose([visResp.Fast]);
latVRAcc = [latVR.Acc];
latVRFast = [latVR.Fast];

%normalization
%1. subtract off baseline
visRespAcc = visRespAcc - repmat([meanBline.Acc]', 1,length(T_STIM));
visRespFast = visRespFast - repmat([meanBline.Fast]', 1,length(T_STIM));

%*** compute visual response magnitude after correcting for baseline
for cc = 1:NUM_CELLS
  latAccCC = latVR(cc).Acc - T_STIM(1) + 3500;
  latFastCC = latVR(cc).Fast - T_STIM(1) + 3500;
  magVR(cc).Acc = mean(visRespAcc(cc,latAccCC:latAccCC+DUR_COMP_MAG),2);
  magVR(cc).Fast = mean(visRespFast(cc,latFastCC:latFastCC+DUR_COMP_MAG),2);
end%for:cells(cc)

%2. divide by max in the Fast condition
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

pause(0.25)

figure(); hold on %plot the difference
imagesc(T_STIM-3500, (1:NUM_CELLS), visRespFast-visRespAcc); colorbar
text((T_STIM(1)-3500)*ones(1,NUM_CELLS), (1:NUM_CELLS), {ninfo.sess})
text(zeros(1,NUM_CELLS), (1:NUM_CELLS), {ninfo.unit})
xlim([T_STIM(1)-5, T_STIM(end)+5] - 3500)
ylim([0 NUM_CELLS+1])
ppretty([6.4,8])


%% Output variables

if (nargout > 0)
  varargout{1} = latVR;
  if (nargout > 1)
    varargout{2} = magVR;
  end
end


end%fxn:plotVisRespSAT()

function [] = plotVisRespCC(T_STIM, T_RESP, visResp, sdfMove, RT, latVR)

figure()

tmp = [visResp.Acc ; visResp.Fast ; sdfMove.Acc ; sdfMove.Fast];
yLim = [min(tmp) max(tmp)];

%visual response
subplot(1,2,1); hold on
plot([0 0], yLim, 'k--')
plot(T_STIM-3500, visResp.Acc, 'r-', 'LineWidth',0.5)
plot(T_STIM-3500, visResp.Fast, '-', 'Color',[0 .7 0], 'LineWidth',0.5)
plot(latVR.Acc*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
plot(latVR.Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
plot(RT.Acc*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
plot(RT.Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
xlim([T_STIM(1) T_STIM(end)]-3500)

%activity from primary response
subplot(1,2,2); hold on
plot([0 0], yLim, 'k--')
plot(T_RESP.Acc-3500, sdfMove.Acc, 'r-', 'LineWidth',0.5)
plot(T_RESP.Fast-3500, sdfMove.Fast, '-', 'Color',[0 .7 0], 'LineWidth',0.5)
plot(-RT.Acc*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
plot(-RT.Fast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
xlim([T_RESP.Acc(1) T_RESP.Acc(end)]-3500)
set(gca, 'YAxisLocation','right')

ppretty([8,3])

end%util:plotVisRespCC()

function [ latency , varargout ] = computeVisRespLatency(visResp, bline, SD_THRESH_VR, MIN_DUR_VR, T_STIM)

meanBline = mean(bline);
SDBline = std(bline);

THRESH_HIGH = meanBline + SD_THRESH_VR(1)*SDBline;
THRESH_LOW = meanBline + SD_THRESH_VR(2)*SDBline;

%find all points above THRESH
tCand = find(visResp > THRESH_HIGH);
nSamp = length(tCand) - MIN_DUR_VR;
dtCand = diff(tCand);

tInitVR = NaN;
for ii = 1:nSamp %loop over candidate samples and find run of MIN_DUR
  runLengthII = sum(dtCand(ii:ii+MIN_DUR_VR-1));
  if (runLengthII == MIN_DUR_VR)%found a run of MIN_DUR_VR above threshold
    tInitVR = tCand(ii);
    %now walk back to baseline mean + 2*SD
    tCand = find(visResp < THRESH_LOW);
    tInitVR = tCand(find(tCand < tInitVR, 1, 'last'));
    break
  end
end%for:sample(ii)

if isnan(tInitVR)
  warning('Unable to locate VR initiation. Setting Acc latency = Fast latency.')
end

latency = T_STIM(1) + tInitVR - 3500;

if (nargout > 1) %return threshold values for plotting
  varargout{1} = struct('High',THRESH_HIGH, 'Low',THRESH_LOW);
end

end%util:computeVisRespLatency()
