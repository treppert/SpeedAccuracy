function [  ] = plotVisRespSAT( binfo , moves , ninfo , spikes , varargin )
%plotVisRespSAT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idx_area = ismember({ninfo.area}, args.area);
idx_monkey = ismember({ninfo.monkey}, args.monkey);

ninfo = ninfo(idx_area & idx_monkey);
spikes = spikes(idx_area & idx_monkey);

NUM_CELLS = length(spikes);
T_BASE = 3500 + (-600 : -1);
T_STIM = 3500 + (-100 : 300);
T_RESP_ACC = 3500 + (-300 : 100);
T_RESP_FAST = 3500 + (-100 : 100);

%initializations
visRespAcc = NaN(NUM_CELLS,length(T_STIM));
visRespFast = NaN(NUM_CELLS,length(T_STIM));
sdfMoveAcc = NaN(NUM_CELLS,length(T_RESP_ACC));
sdfMoveFast = NaN(NUM_CELLS,length(T_RESP_FAST));
RTAcc = NaN(1,NUM_CELLS);
RTFast = NaN(1,NUM_CELLS);

%visual response latency
latVRAcc = NaN(1,NUM_CELLS);
latVRFast = NaN(1,NUM_CELLS);

for cc = 1:NUM_CELLS
  if ~strcmp(ninfo(cc).visType, 'sustained'); continue; end
  
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
  
  visRespAcc(cc,:) = nanmean(sdfKKstim(idxAcc & idxCorr & idxRF, T_STIM));
  visRespFast(cc,:) = nanmean(sdfKKstim(idxFast & idxCorr & idxRF, T_STIM));
  sdfMoveAcc(cc,:) = nanmean(sdfKKresp(idxAcc & idxCorr & idxRF, T_RESP_ACC));
  sdfMoveFast(cc,:) = nanmean(sdfKKresp(idxFast & idxCorr & idxRF, T_RESP_FAST));
  
  RTAcc(cc) = median(RTkk(idxAcc & idxCorr & idxRF));
  RTFast(cc) = median(RTkk(idxFast & idxCorr & idxRF));
  
  
  %% Compute visual response latency
  blineCC = nanmean(sdfKKstim((idxAcc | idxFast) & idxCorr, T_BASE));
  blineMean = mean(blineCC);
  blineSD = std(blineCC);
  
  THRESH = blineMean + 6*blineSD;
  
  %find all points above THRESH
  idxPrelimFast = find(visRespFast(cc,:) > THRESH);
  
  latVRFast(cc) = T_STIM(1) + idxPrelimFast(1) - 3500;
  
  %% Plotting
  figure()
  
  tmp = [visRespAcc(cc,:) visRespFast(cc,:) sdfMoveAcc(cc,:) sdfMoveFast(cc,:)];
  yLim = [min(tmp) max(tmp)];
  
  %visual response
  subplot(1,2,1); hold on
  plot([0 0], yLim, 'k--')
  plot(T_STIM-3500, visRespAcc(cc,:), 'r-', 'LineWidth',0.5)
  plot(T_STIM-3500, visRespFast(cc,:), '-', 'Color',[0 .7 0], 'LineWidth',0.5)
  plot(latVRFast(cc)*ones(1,2), yLim, 'k:', 'LineWidth',0.5)
  plot([T_STIM(1) T_STIM(end)]-3500, blineMean*ones(1,2), 'k:', 'LineWidth',0.5)
  plot([T_STIM(1) T_STIM(end)]-3500, THRESH*ones(1,2), 'k--', 'LineWidth',0.5)
  plot(RTAcc(cc)*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
  plot(RTFast(cc)*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
  xlim([T_STIM(1) T_STIM(end)]-3500)
  print_session_unit(gca , ninfo(cc), binfo(kk))
  
  %activity from primary response
  subplot(1,2,2); hold on
  plot([0 0], yLim, 'k--')
  plot(T_RESP_ACC-3500, sdfMoveAcc(cc,:), 'r-', 'LineWidth',0.5)
  plot(T_RESP_FAST-3500, sdfMoveFast(cc,:), '-', 'Color',[0 .7 0], 'LineWidth',0.5)
  plot(-RTAcc(cc)*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
  plot(-RTFast(cc)*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
  xlim([T_RESP_ACC(1) T_RESP_ACC(end)]-3500)
  set(gca, 'YAxisLocation','right')
  
  ppretty([8,3])
  pause(); close()
  
end%for:cells(cc)


%% Plotting - Across cells
NUM_CELLS_PLOT = sum(ismember({ninfo.visType}, {'sustained'}));

%remove cells with no visual response
ccRemove = ~ismember({ninfo.visType}, {'sustained'});
ninfo(ccRemove) = [];
visRespAcc(ccRemove,:) = [];
visRespFast(ccRemove,:) = [];
sdfMoveAcc(ccRemove,:) = [];
sdfMoveFast(ccRemove,:) = [];
RTAcc(ccRemove) = [];
RTFast(ccRemove) = [];
latVRFast(ccRemove) = [];

%normalization
visRespAcc = visRespAcc ./ max(visRespFast,[],2);
visRespFast = visRespFast ./ max(visRespFast,[],2);

%sort neurons by visual response latency
[latVRFast,idxVRFast] = sort(latVRFast);
visRespFast = visRespFast(idxVRFast,:);
ninfo = ninfo(idxVRFast);

figure(); hold on
imagesc(T_STIM-3500, (1:NUM_CELLS_PLOT), visRespFast); %colorbar
plot(latVRFast, (1:NUM_CELLS_PLOT), 'k.', 'MarkerSize',15)
text((T_STIM(1)-3500)*ones(1,NUM_CELLS_PLOT), (1:NUM_CELLS_PLOT), {ninfo.sess})
text(zeros(1,NUM_CELLS_PLOT), (1:NUM_CELLS_PLOT), {ninfo.unit})
xlim([T_STIM(1)-5, T_STIM(end)+5] - 3500)
ylim([0 NUM_CELLS_PLOT+1])
ppretty([6.4,8])

% figure(); hold on
% plot(T_STIM-3500, visRespAcc, 'r-', 'LineWidth',0.5)
% plot(T_STIM-3500, visRespFast, '-', 'Color',[0 .7 0], 'LineWidth',0.5)
% % plot(nanmean(RTAcc)*ones(1,2), [.2 .8], 'r:', 'LineWidth',0.5)
% % plot(nanmean(RTFast)*ones(1,2), [.2 .8], ':', 'Color',[0 .7 0], 'LineWidth',0.5)
% xlim([T_STIM(1) T_STIM(end)]-3500)
% ppretty([6.4,4])

end%fxn:plotVisRespSAT()
