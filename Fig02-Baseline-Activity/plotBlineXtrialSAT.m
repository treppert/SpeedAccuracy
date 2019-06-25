function [ ] = plotBlineXtrialSAT( binfo , ninfo , nstats , spikes , varargin )
%plotBlineXtrialSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxBlineRate = ([nstats.blineAccMEAN] >= 3); %minimum baseline discharge rate

idxVis = ([ninfo.visGrade] >= 2);   idxMove = ([ninfo.moveGrade] >= 2);
idxErr = ([ninfo.errGrade] >= 2);   idxRew = (abs([ninfo.rewGrade]) >= 2);
idxTaskRel = (idxVis | idxMove | idxErr | idxRew);
idxBlineEffect = ([nstats.blineEffect] == 1);

idxKeep = (idxArea & idxMonkey & idxTaskRel & idxBlineEffect);

NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
nstats = nstats(idxKeep);
spikes = spikes(idxKeep);

TRIAL_PLOT = (-4 : 3);  NUM_TRIAL = length(TRIAL_PLOT);
trialSwitch = identify_condition_switch(binfo);

blineMoreA2F = [];  blineMoreF2A = [];
blineLessA2F = [];  blineLessF2A = [];

T_BASE  = 3500 + (-600 : 20);

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  trialA2F = trialSwitch(kk).A2F;
  trialF2A = trialSwitch(kk).F2A;
  
  %compute single-trial spike density function
  sdfSess = compute_spike_density_fxn(spikes(cc).SAT);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc | binfo(kk).err_hold);
  
  %isolate appropriate trials at condition cue switch
  trialA2F = trialA2F(ismember(trialA2F, find(~idxIso)));
  trialF2A = trialF2A(ismember(trialF2A, find(~idxIso)));
  
  blineA2F = NaN(1,NUM_TRIAL);
  blineF2A = NaN(1,NUM_TRIAL);
  for jj = 1:NUM_TRIAL
    sdfA2F = nanmean(sdfSess(trialA2F + TRIAL_PLOT(jj), T_BASE)); %compute mean SDF
    sdfF2A = nanmean(sdfSess(trialF2A + TRIAL_PLOT(jj), T_BASE));
    blineA2F(jj) = mean(sdfA2F); %mean SDF activity
    blineF2A(jj) = mean(sdfF2A);
  end%for:trialFromSwitch(jj)
  
  %normalization
  normFactor = mean([nstats(cc).blineAccMEAN nstats(cc).blineFastMEAN]);
  blineA2F = blineA2F / normFactor;
  blineF2A = blineF2A / normFactor;
  
  %increment counter depending on level of efficiency
  if (binfo(kk).taskType == 1)
    blineMoreA2F = cat(1, blineMoreA2F, blineA2F);
    blineMoreF2A = cat(1, blineMoreF2A, blineF2A);
  elseif (binfo(kk).taskType == 2)
    blineLessA2F = cat(1, blineLessA2F, blineA2F);
    blineLessF2A = cat(1, blineLessF2A, blineF2A);
  end
  
end%for:cells(cc)

%% Plotting
NUM_MORE = size(blineMoreA2F, 1);
NUM_LESS = size(blineLessA2F, 1);

figure(); hold on
shaded_error_bar(TRIAL_PLOT, nanmean(blineMoreA2F), nanstd(blineMoreA2F)/sqrt(NUM_MORE), {'k-', 'LineWidth',0.75})
shaded_error_bar(TRIAL_PLOT+NUM_TRIAL+1, nanmean(blineMoreF2A), nanstd(blineMoreF2A)/sqrt(NUM_MORE), {'k-', 'LineWidth',0.75})
shaded_error_bar(TRIAL_PLOT, nanmean(blineLessA2F), nanstd(blineLessA2F)/sqrt(NUM_LESS), {'k-', 'LineWidth',1.25})
shaded_error_bar(TRIAL_PLOT+NUM_TRIAL+1, nanmean(blineLessF2A), nanstd(blineLessF2A)/sqrt(NUM_LESS), {'k-', 'LineWidth',1.25})
xlabel('Trial')
ylabel('Normalized activity')
xticklabels({})
ppretty([4.8,3])

%% Stats
%Mann-Whitney U-test for significant difference in single-trial change in
%normalized baseline activity
dMoreA2F = blineMoreA2F(:,5) - blineMoreA2F(:,4);   dMoreF2A = blineMoreF2A(:,5) - blineMoreF2A(:,4);
dLessA2F = blineLessA2F(:,5) - blineLessA2F(:,4);   dLessF2A = blineLessF2A(:,5) - blineLessF2A(:,4);

fprintf('A2F vs. F2A:\n')
ttestTom([dMoreA2F;dLessA2F], [dMoreF2A;dLessF2A])

fprintf('\nMore A2F vs. Less A2F\n')
[pval,~,stats] = ranksum(dMoreA2F, dLessA2F);
fprintf('Z = %g, p = %g\n', stats.zval, pval)

end%fxn:plotBlineXtrialSAT()
