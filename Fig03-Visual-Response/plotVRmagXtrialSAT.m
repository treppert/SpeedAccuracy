function [ ] = plotVRmagXtrialSAT( binfo , moves , ninfo , nstats , spikes , varargin )
%plotVRmagXtrialSAT Summary of this function goes here
%   Note - In order to use this function, first run testVRmagSAT() in
%   order to obtain estimates of visual response latency and magnitude.
% 

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxVis = ([ninfo.visGrade] >= 0.5);
idxEffect = ([nstats.VReffect] == +1);

idxKeep = (idxArea & idxMonkey & idxVis & idxEffect);

ninfo = ninfo(idxKeep);
nstats = nstats(idxKeep);
spikes = spikes(idxKeep);

NUM_CELLS = length(spikes);
T_STIM = 3500 + (0 : 300);      OFFSET = 0; %offset param for computing VRmag
T_RESP = 3500 + (-300 : 100);

%sort visual response by trial number
TRIAL = (-4 : 3); %from condition switch
NUM_TRIAL = length(TRIAL);

%initialize single-trial VR magnitude estimates
VRmagA2F = NaN(NUM_CELLS,NUM_TRIAL);
VRmagF2A = NaN(NUM_CELLS,NUM_TRIAL);

%isolate trials with a condition switch (Fast -> Acc or vice versa)
trialSwitch = identify_condition_switch(binfo);

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  RTkk = double(moves(kk).resptime);
  
  %compute SDFs
  sdfKKstim = compute_spike_density_fxn(spikes(cc).SAT);
%   sdfKKresp = align_signal_on_response(sdfKKstim, RTkk);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by trial outcome -- currently not used (to increase trial count)
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc);
  %index by trial number
  trialA2F = trialSwitch(kk).A2F;
  trialF2A = trialSwitch(kk).F2A;
  
  %combine indexing
  trialA2F = intersect(trialA2F, find(~idxIso));
  trialF2A = intersect(trialF2A, find(~idxIso));
  
  %compute median RT in Fast condition for plotting
%   idxFast = (binfo(kk).condition == 3);
%   medRTFast = median(RTkk(idxFast & idxCorr & idxRF & ~idxIso));
  
  %initialize mean SDFs for plotting
%   visRespA2F = NaN(NUM_TRIAL,length(T_STIM));
%   visRespF2A = NaN(NUM_TRIAL,length(T_STIM));
  
  for jj = 1:NUM_TRIAL %loop over trials from cued condition switch
    
    VRA2Fjj = sdfKKstim(trialA2F + TRIAL(jj), T_STIM);
    VRF2Ajj = sdfKKstim(trialF2A + TRIAL(jj), T_STIM);
    
    %inputs 1 & 2 for computeVRmag must be Acc and Fast, *in that order*
    if (TRIAL(jj) < 0) %before condition switch
      [VRmagA2F(cc,jj),VRmagF2A(cc,jj)] = computeVisRespMagSAT(VRA2Fjj, VRF2Ajj, nstats(cc), OFFSET);
    else %after condition switch
      [VRmagF2A(cc,jj),VRmagA2F(cc,jj)] = computeVisRespMagSAT(VRF2Ajj, VRA2Fjj, nstats(cc), OFFSET);
    end
    
    %compute mean SDFs
%     visRespA2F(jj,:) = mean(VRA2Fjj);
%     visRespF2A(jj,:) = mean(VRF2Ajj);
    
  end%for:trial(jj)
    
end%for:cells(cc)

%normalize with respect to mean VR in Acc condition
VRmagAvg = mean([[nstats.VRmagAcc] ; [nstats.VRmagFast]]);
VRmagNorm = repmat(VRmagAvg', 1,NUM_TRIAL);

VRmagA2F = VRmagA2F ./ VRmagNorm;
VRmagF2A = VRmagF2A ./ VRmagNorm;

% %take the absolute difference from 1.0
% VRmagA2F = abs(VRmagA2F - 1.0);
% VRmagF2A = abs(VRmagF2A - 1.0);

%% Plotting

%mean +/- SE change from mean in Accurate condition (sp/s)
figure(); hold on
plot(-0.5*ones(1,2), [0.7 1.3], 'k-') %show points of condition switch
plot( 7.5*ones(1,2), [0.7 1.3], 'k-')
shaded_error_bar(TRIAL, nanmean(VRmagA2F), nanstd(VRmagA2F)/sqrt(NUM_CELLS), {'k-', 'LineWidth',0.75})
shaded_error_bar(TRIAL+NUM_TRIAL, nanmean(VRmagF2A), nanstd(VRmagF2A)/sqrt(NUM_CELLS), {'k-', 'LineWidth',0.75})
xlabel('Trial'); xticks(-5:12); xticklabels([])
ylabel('Norm. response magnitude'); ytickformat('%2.1f')
ppretty([4.8,3])

end%fxn:plotVRmagXtrialSAT()


% COLORA2F = {[1 0 0], [.4 .7 .4], [0 .7 0]}; %colors for plotting
% COLORF2A = {[0 .7 0], [1 .5 .5], [1 0 0]};

%   %plotting - individual neurons
%   if (1)
%   yLim = [min(min([visRespA2F visRespF2A sdfMoveA2F sdfMoveF2A])), max(max([visRespA2F visRespF2A sdfMoveA2F sdfMoveF2A]))];
%   figure()
%   
%   subplot(1,4,1); hold on
%   for jj = 1:NUM_TRIAL; plot(T_STIM-3500, visRespF2A(jj,:), 'Color',COLORF2A{jj}); end
%   plot(VRlatAcc(cc)*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
%   plot(VRlatFast(cc)*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
%   plot([0 0], yLim, 'k--')
%   plot(medRTFast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
%   xlim([T_STIM(1) T_STIM(end)]-3500)
%   print_session_unit(gca , ninfo(cc), [])
%   
%   subplot(1,4,2); hold on
%   for jj = 1:NUM_TRIAL; plot(T_RESP-3500, sdfMoveF2A(jj,:), 'Color',COLORF2A{jj}); end
%   plot([0 0], yLim, 'k--')
%   xlim([T_RESP(1) T_RESP(end)]-3500)
%   
%   pause(0.1)
%   
%   subplot(1,4,3); hold on
%   for jj = 1:NUM_TRIAL; plot(T_STIM-3500, visRespA2F(jj,:), 'Color',COLORA2F{jj}); end
%   plot(nstats(cc).VRlatAcc*ones(1,2), yLim, 'r:', 'LineWidth',0.5)
%   plot(nstats(cc).VRlatFast*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
%   xlim([T_STIM(1) T_STIM(end)]-3500)
%   
%   subplot(1,4,4); hold on
%   for jj = 1:NUM_TRIAL; plot(T_RESP-3500, sdfMoveA2F(jj,:), 'Color',COLORA2F{jj}); end
%   plot((VRlatFast(cc)-medRTFast)*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',0.5)
%   plot([0 0], yLim, 'k--')
%   xlim([T_RESP(1) T_RESP(end)]-3500)
%   
%   ppretty([16,4])
%   pause()
%   end%if:plot-individual-neurons
