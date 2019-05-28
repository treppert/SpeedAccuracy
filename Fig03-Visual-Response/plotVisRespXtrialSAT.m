function [ ] = plotVisRespXtrialSAT( binfo , moves , ninfo , nstats , spikes , varargin )
%plotVisRespXtrialSAT Summary of this function goes here
%   Note - In order to use this function, first run plotVisRespSAT() in
%   order to obtain estimates of visual response latency and magnitude.
% 

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxVis = ([ninfo.visGrade] >= 0.5);

ninfo = ninfo(idxArea & idxMonkey & idxVis);
spikes = spikes(idxArea & idxMonkey & idxVis);

NUM_CELLS = length(spikes);
T_STIM = 3500 + (-100 : 300);
T_RESP = 3500 + (-300 : 100);

%sort visual response by trial number
TRIAL = (-3 : 4); %from condition switch
NUM_TRIAL = length(TRIAL);
COLORA2F = {[1 0 0], [.4 .7 .4], [0 .7 0]}; %colors for plotting
COLORF2A = {[0 .7 0], [1 .5 .5], [1 0 0]};

%retrieve response latencies
VRlatAcc = [nstats.VRlatAcc];
VRlatFast = [nstats.VRlatFast];

trialSwitch = identify_condition_switch(binfo);

VRmagA2F = NaN(NUM_CELLS,NUM_TRIAL);
VRmagF2A = NaN(NUM_CELLS,NUM_TRIAL);

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  ccNS = ninfo(cc).unitNum;
  if (nstats(ccNS).VReffect ~= 1); continue; end
  
  RTkk = double(moves(kk).resptime);
  
  %compute SDFs
  sdfKKstim = compute_spike_density_fxn(spikes(cc).SAT);
  sdfKKresp = align_signal_on_response(sdfKKstim, RTkk);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc);
  %index by response dir re. response field
  idxRF = ismember(moves(kk).octant, ninfo(cc).visField);
  %index by trial number
  trialA2F = trialSwitch(kk).A2F;
  trialF2A = trialSwitch(kk).F2A;
  
  %combine indexing
  trialA2F = intersect(trialA2F, find(~idxIso & idxCorr & idxRF));
  trialF2A = intersect(trialF2A, find(~idxIso & idxCorr & idxRF));
  
  %compute median RT in Fast condition for plotting
  idxFast = (binfo(kk).condition == 3);
  medRTFast = median(RTkk(idxFast & idxCorr & idxRF & ~idxIso));
  
  %initialize mean SDFs for plotting
  visRespA2F = NaN(NUM_TRIAL,length(T_STIM));
  visRespF2A = NaN(NUM_TRIAL,length(T_STIM));
  sdfMoveA2F = NaN(NUM_TRIAL,length(T_STIM));
  sdfMoveF2A = NaN(NUM_TRIAL,length(T_STIM));
  
  for jj = 1:NUM_TRIAL %loop over trials from cued condition switch
    
    %isolate single-trial SDFs (used to compute response magnitude)
    VRA2Fjj = sdfKKstim(trialA2F + TRIAL(jj), T_STIM);
    VRF2Ajj = sdfKKstim(trialF2A + TRIAL(jj), T_STIM);
    SDFmoveA2Fjj = sdfKKresp(trialA2F + TRIAL(jj), T_RESP);
    SDFmoveF2Ajj = sdfKKresp(trialF2A + TRIAL(jj), T_RESP);
    
    %compute mean SDFs
    visRespA2F(jj,:) = mean(VRA2Fjj);
    visRespF2A(jj,:) = mean(VRF2Ajj);
    sdfMoveA2F(jj,:) = mean(SDFmoveA2Fjj);
    sdfMoveF2A(jj,:) = mean(SDFmoveF2Ajj);
    
    if (TRIAL(jj) < 0) %pre-switch
      [VRmagA2F(cc,jj),VRmagF2A(cc,jj)] = computeVisRespMagSAT(VRA2Fjj(:,101:400), VRF2Ajj(:,101:400), ...
        VRlatAcc(ccNS), VRlatFast(ccNS), nstats(ccNS));
    else %post-switch
      [VRmagF2A(cc,jj),VRmagA2F(cc,jj)] = computeVisRespMagSAT(VRF2Ajj(:,101:400), VRA2Fjj(:,101:400), ...
        VRlatAcc(ccNS), VRlatFast(ccNS), nstats(ccNS));
    end
    
  end%for:trial(jj)
  
  %plotting - individual neurons
  if (0)
  yLim = [min(min([visRespA2F visRespF2A sdfMoveA2F sdfMoveF2A])), max(max([visRespA2F visRespF2A sdfMoveA2F sdfMoveF2A]))];
  figure()
  
  subplot(1,4,1); hold on
  for jj = 1:NUM_TRIAL; plot(T_STIM-3500, visRespF2A(jj,:), 'Color',COLORF2A{jj}); end
  plot(VRlatAcc(ccNS)*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
  plot(VRlatFast(ccNS)*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
  plot([0 0], yLim, 'k--')
  plot(medRTFast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
  xlim([T_STIM(1) T_STIM(end)]-3500)
  print_session_unit(gca , ninfo(cc), [])
  
  subplot(1,4,2); hold on
  for jj = 1:NUM_TRIAL; plot(T_RESP-3500, sdfMoveF2A(jj,:), 'Color',COLORF2A{jj}); end
  plot([0 0], yLim, 'k--')
  xlim([T_RESP(1) T_RESP(end)]-3500)
  
  pause(0.1)
  
  subplot(1,4,3); hold on
  for jj = 1:NUM_TRIAL; plot(T_STIM-3500, visRespA2F(jj,:), 'Color',COLORA2F{jj}); end
  plot(nstats(ccNS).VRlatAcc*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
  plot(nstats(ccNS).VRlatFast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
  xlim([T_STIM(1) T_STIM(end)]-3500)
  
  subplot(1,4,4); hold on
  for jj = 1:NUM_TRIAL; plot(T_RESP-3500, sdfMoveA2F(jj,:), 'Color',COLORA2F{jj}); end
  plot((VRlatFast(ccNS)-medRTFast)*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
  plot([0 0], yLim, 'k--')
  xlim([T_RESP(1) T_RESP(end)]-3500)
  
  ppretty([16,4])
  pause()
  end%if:plot-individual-neurons
  
end%for:cells(cc)

%% Plotting - Mean change in normalized response magnitude
NUM_SEM = sum([nstats.VReffect] == 1);

%normalization - use mean response magnitude across the two conditions
VRmagAcc = [nstats(idxArea & idxMonkey & idxVis).VRmagAcc];
VRmagFast = [nstats(idxArea & idxMonkey & idxVis).VRmagFast];
normFactor = mean([VRmagAcc;VRmagFast]);
VRmagA2F = VRmagA2F ./ normFactor';
VRmagF2A = VRmagF2A ./ normFactor';

figure(); hold on
shaded_error_bar(TRIAL, nanmean(VRmagF2A), nanstd(VRmagF2A)/sqrt(NUM_SEM), {'k-', 'LineWidth',0.5})
shaded_error_bar(TRIAL+NUM_TRIAL, nanmean(VRmagA2F), nanstd(VRmagA2F)/sqrt(NUM_SEM), {'k-', 'LineWidth',0.5})
ppretty([6.4,4])


end%fxn:plotVisRespXtrialSAT()

