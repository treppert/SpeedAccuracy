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

NUM_CELLS = length(spikes);
ninfo = ninfo(idxKeep);
nstats = nstats(idxKeep);
spikes = spikes(idxKeep);

TRIAL_PLOT = (-4 : 3);  NUM_TRIAL = length(TRIAL_PLOT);
trialSwitch = identify_condition_switch(binfo);

VRmagMoreA2F = [];  VRmagMoreF2A = [];
VRmagLessA2F = [];  VRmagLessF2A = [];

T_STIM = 3500 + (0 : 300);      OFFSET = 0; %offset param for computing VRmag

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  trialA2F = trialSwitch(kk).A2F;
  trialF2A = trialSwitch(kk).F2A;
  
  %compute SDFs
  sdfKK = compute_spike_density_fxn(spikes(cc).SAT);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by trial outcome -- currently not used (to increase trial count)
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc | binfo(kk).err_hold);
  
  %isolate appropriate trials at condition cue switch
  trialA2F = trialA2F(ismember(trialA2F, find(~idxIso)));
  trialF2A = trialF2A(ismember(trialF2A, find(~idxIso)));
  
  VRmagA2F = NaN(1,NUM_TRIAL);
  VRmagF2A = NaN(1,NUM_TRIAL);
  for jj = 1:NUM_TRIAL
    sdfA2Fjj = sdfKK(trialA2F + TRIAL_PLOT(jj), T_STIM);
    sdfF2Ajj = sdfKK(trialF2A + TRIAL_PLOT(jj), T_STIM);
    
    %inputs 1 & 2 for computeVRmag must be Acc and Fast, *in that order*
    if (TRIAL_PLOT(jj) < 0) %before condition switch
      [VRmagA2F(jj),VRmagF2A(jj)] = computeVisRespMagSAT(sdfA2Fjj, sdfF2Ajj, nstats(cc), OFFSET);
    else %after condition switch
      [VRmagF2A(jj),VRmagA2F(jj)] = computeVisRespMagSAT(sdfF2Ajj, sdfA2Fjj, nstats(cc), OFFSET);
    end
  end%for:trialFromSwitch(jj)
    
  %normalization
  normFactor = mean([nstats(cc).VRmagAcc nstats(cc).VRmagFast]);
  VRmagA2F = VRmagA2F / normFactor;
  VRmagF2A = VRmagF2A / normFactor;
  
  %increment counter depending on level of efficiency
  if (binfo(kk).taskType == 1)
    VRmagMoreA2F = cat(1, VRmagMoreA2F, VRmagA2F);
    VRmagMoreF2A = cat(1, VRmagMoreF2A, VRmagF2A);
  elseif (binfo(kk).taskType == 2)
    VRmagLessA2F = cat(1, VRmagLessA2F, VRmagA2F);
    VRmagLessF2A = cat(1, VRmagLessF2A, VRmagF2A);
  end
  
end%for:cells(cc)

%% Plotting
NUM_MORE = size(VRmagMoreA2F, 1);
NUM_LESS = size(VRmagLessA2F, 1);

figure(); hold on
shaded_error_bar(TRIAL_PLOT, nanmean(VRmagMoreA2F), nanstd(VRmagMoreA2F)/sqrt(NUM_MORE), {'k-', 'LineWidth',0.75})
shaded_error_bar(TRIAL_PLOT+NUM_TRIAL+1, nanmean(VRmagMoreF2A), nanstd(VRmagMoreF2A)/sqrt(NUM_MORE), {'k-', 'LineWidth',0.75})
shaded_error_bar(TRIAL_PLOT, nanmean(VRmagLessA2F), nanstd(VRmagLessA2F)/sqrt(NUM_LESS), {'k-', 'LineWidth',1.25})
shaded_error_bar(TRIAL_PLOT+NUM_TRIAL+1, nanmean(VRmagLessF2A), nanstd(VRmagLessF2A)/sqrt(NUM_LESS), {'k-', 'LineWidth',1.25})
xlabel('Trial')
ylabel('Norm. visual response')
xticklabels({})
ppretty([4.8,3])

end%fxn:plotVRmagXtrialSAT()
