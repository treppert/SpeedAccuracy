function [ ] = plotBlineXtrialSAT( binfo , ninfo , nstats , spikes , varargin )
%plotBlineXtrialSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxBlineEffect = ([nstats.blineEffect] == 1);
idxVis = ([ninfo.visGrade] >= 2);
idxMove = ([ninfo.moveGrade] >= 2);
idxEff = ([ninfo.taskType] == 2);

idxKeep = (idxArea & idxMonkey & idxBlineEffect & idxEff);

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

NUM_CELLS = length(spikes);
T_BASE  = 3500 + (-600 : 20);

TRIAL_PLOT = (-4 : 3);
NUM_TRIAL = length(TRIAL_PLOT);

blineA2F = NaN(NUM_CELLS,NUM_TRIAL);
blineF2A = NaN(NUM_CELLS,NUM_TRIAL);

trialSwitch = identify_condition_switch(binfo);

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);

  %compute spike density function
  sdfSess = compute_spike_density_fxn(spikes(cc).SAT);
  
  %index by isolation quality
  trialIso = find(identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials));
  
  trialA2F = trialSwitch(kk).A2F; trialA2F(ismember(trialA2F, trialIso)) = [];
  trialF2A = trialSwitch(kk).F2A; trialF2A(ismember(trialF2A, trialIso)) = [];
  
  for jj = 1:NUM_TRIAL
    sdfA2F = nanmean(sdfSess(trialA2F + TRIAL_PLOT(jj), T_BASE));
    sdfF2A = nanmean(sdfSess(trialF2A + TRIAL_PLOT(jj), T_BASE));
    
    blineA2F(cc,jj) = mean(sdfA2F);
    blineF2A(cc,jj) = mean(sdfF2A);
  end%for:trial(jj)
  
end%for:cells(cc)


%% Plotting
nstats = nstats(idxKeep); NUM_SEM = sum(idxKeep);

%normalization
normFactor = mean([[nstats.blineAccMEAN] ; [nstats.blineFastMEAN]])';
blineA2F = blineA2F ./ normFactor;
blineF2A = blineF2A ./ normFactor;

figure(); hold on
shaded_error_bar(TRIAL_PLOT, nanmean(blineA2F), nanstd(blineA2F)/sqrt(NUM_SEM), {'k-'})
shaded_error_bar(TRIAL_PLOT+NUM_TRIAL+1, nanmean(blineF2A), nanstd(blineF2A)/sqrt(NUM_SEM), {'k-'})
xlabel('Trial from switch')
ylabel('Normalized activity')
% xticklabels({})
ppretty([4.8,3])

end%fxn:plotBlineXtrialSAT()
