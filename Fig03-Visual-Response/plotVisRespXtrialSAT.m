function [ ] = plotVisRespXtrialSAT( binfo , moves , ninfo , nstats , spikes , varargin )
%plotVisRespXtrialSAT Summary of this function goes here
%   Note - In order to use this function, first run plotVisRespSAT() in
%   order to obtain estimates of visual response latency and magnitude.
% 

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxVis = ismember({ninfo.visType}, {'sustained'});

ninfo = ninfo(idxArea & idxMonkey & idxVis);
spikes = spikes(idxArea & idxMonkey & idxVis);

NUM_CELLS = length(spikes);
T_STIM = 3500 + (-100 : 300);

WIN_COMP_MAG = 100; %amount of time (ms) used to estimate magnitude

%sort visual response by trial number
TRIAL = (-1 : 1); %from condition switch
NUM_TRIAL = length(TRIAL);
COLORA2F = {[1 0 0], [.4 .7 .4], [0 .7 0]}; %colors for plotting
COLORF2A = {[0 .7 0], [1 .5 .5], [1 0 0]};

VRmagA2F = NaN(NUM_CELLS,NUM_TRIAL);
VRmagF2A = NaN(NUM_CELLS,NUM_TRIAL);

trialSwitch = identify_condition_switch(binfo);

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  sdfKKstim = compute_spike_density_fxn(spikes(cc).SAT);
  
  %index by isolation quality
  trialIso = find(identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials));
  %index by trial outcome
  trialCorr = find(~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc));
  %index by response dir re. response field
  trialRF = find(ismember(moves(kk).octant, ninfo(cc).visField));
  %index by trial number
  trialA2F = trialSwitch(kk).A2F;
  trialF2A = trialSwitch(kk).F2A;
  
  %combine indexing - A2F
  trialA2F = intersect(trialA2F, trialRF);
  trialA2F = intersect(trialA2F, trialCorr);
  trialA2F(ismember(trialA2F, trialIso)) = [];
  %combine indexing - F2A
  trialF2A = intersect(trialF2A, trialRF);
  trialF2A = intersect(trialF2A, trialCorr);
  trialF2A(ismember(trialF2A, trialIso)) = [];
  
  visRespA2F = NaN(NUM_TRIAL,length(T_STIM));
  visRespF2A = NaN(NUM_TRIAL,length(T_STIM));
  
  idxStats = ninfo(cc).unitNum;
  
  for jj = 1:NUM_TRIAL
    
    visRespA2F(jj,:) = nanmean(sdfKKstim(trialA2F + TRIAL(jj), T_STIM));
    visRespF2A(jj,:) = nanmean(sdfKKstim(trialF2A + TRIAL(jj), T_STIM));
    
    if (jj > NUM_TRIAL/2) %second half of trials (post-condition switch)
      idxVRA2F = nstats(idxStats).visRespFastLAT - (T_STIM(1) - 3500);
      idxVRF2A = nstats(idxStats).visRespAccLAT - (T_STIM(1) - 3500);
      VRmagA2F(cc,jj) = mean(visRespA2F(jj, idxVRA2F:idxVRA2F+WIN_COMP_MAG-1) - nstats(idxStats).blineFastMEAN);
      VRmagF2A(cc,jj) = mean(visRespF2A(jj, idxVRF2A:idxVRF2A+WIN_COMP_MAG-1) - nstats(idxStats).blineAccMEAN);
    else %first half of trials (pre-condition switch)
      idxVRA2F = nstats(idxStats).visRespAccLAT - (T_STIM(1) - 3500);
      idxVRF2A = nstats(idxStats).visRespFastLAT - (T_STIM(1) - 3500);
      VRmagA2F(cc,jj) = mean(visRespA2F(jj, idxVRA2F:idxVRA2F+WIN_COMP_MAG-1) - nstats(idxStats).blineAccMEAN);
      VRmagF2A(cc,jj) = mean(visRespF2A(jj, idxVRF2A:idxVRF2A+WIN_COMP_MAG-1) - nstats(idxStats).blineFastMEAN);
    end
    
  end%for:trial(jj)
  
  %plotting - individual neurons
  if (1)
  yLim = [min(min([visRespA2F visRespF2A])), max(max([visRespA2F visRespF2A]))];
  figure()
  
  subplot(1,2,1); hold on
  for jj = 1:NUM_TRIAL; plot(T_STIM-3500, visRespA2F(jj,:), 'Color',COLORA2F{jj}); end
  plot(nstats(idxStats).visRespAccLAT*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
  plot(nstats(idxStats).visRespFastLAT*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
  xlim([T_STIM(1) T_STIM(end)]-3500)
  print_session_unit(gca , ninfo(cc),[], 'horizontal')
  
  pause(0.1)
  
  subplot(1,2,2); hold on
  for jj = 1:NUM_TRIAL; plot(T_STIM-3500, visRespF2A(jj,:), 'Color',COLORF2A{jj}); end
  plot(nstats(idxStats).visRespAccLAT*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
  plot(nstats(idxStats).visRespFastLAT*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
  xlim([T_STIM(1) T_STIM(end)]-3500)
  
  ppretty([8,4])
  pause()
  end%if:plot-individual-neurons
  
end%for:cells(cc)

%% Plotting
%normalization
VRmagA2F = VRmagA2F ./ [nstats(idxArea & idxMonkey & idxVis).visRespNormFactor]';
VRmagF2A = VRmagF2A ./ [nstats(idxArea & idxMonkey & idxVis).visRespNormFactor]';

figure(); hold on
plot(TRIAL, VRmagA2F, 'k-', 'LineWidth',0.5)
plot(TRIAL+NUM_TRIAL+1, VRmagF2A, 'k-', 'LineWidth',0.5)
ppretty([6.4,4])


end%fxn:plotVisRespXtrialSAT()

