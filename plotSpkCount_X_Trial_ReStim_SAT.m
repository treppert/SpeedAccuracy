function [ ] = plotSpkCount_X_Trial_ReStim_SAT( binfo , ninfo , spikes , varargin )
%plotSpkCount_X_Trial_ReStim_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxVis = ([ninfo.visGrade] >= 2);
idxMove = ([ninfo.moveGrade] >= 2);

% idxKeep = (idxArea & idxMonkey & (idxVis | idxMove)); %baseline
idxKeep = (idxArea & idxMonkey & idxVis); %visual response

NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

% T_TEST = 3500 + [-500 20]; %baseline
T_TEST = 3500 + [75 200]; %visual response

TRIAL_PLOT = (-4 : 3);  NUM_TRIAL = length(TRIAL_PLOT);
trialSwitch = identify_condition_switch(binfo);

MIN_PER_BIN = 25; %minimum number of trials per bin

RTLIM_ACC = [390 800]; %limits on acceptable RT (used for data cleaning)
RTLIM_FAST = [150 450];

%initializations
zSpkCt_A2F = NaN(NUM_CELLS,NUM_TRIAL);
zSpkCt_F2A = NaN(NUM_CELLS,NUM_TRIAL);

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  RTkk = double(binfo(kk).resptime);
  trialA2F = trialSwitch(kk).A2F;
  trialF2A = trialSwitch(kk).F2A;
  
  %compute spike count for all trials
  spkCtCC = cellfun(@(x) sum((x > T_TEST(1)) & (x < T_TEST(2))), spikes(cc).SAT);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_time | binfo(kk).err_hold | binfo(kk).err_nosacc);
  %index by RT limits
  idxCutAcc = (RTkk < RTLIM_ACC(1) | RTkk > RTLIM_ACC(2) | isnan(RTkk));
  idxCutFast = (RTkk < RTLIM_FAST(1) | RTkk > RTLIM_FAST(2) | isnan(RTkk));
  %index by condition and RT limits
  idxAcc = ((binfo(kk).condition == 1) & idxCorr & ~idxIso & ~idxCutAcc);
  idxFast = ((binfo(kk).condition == 3) & idxCorr & ~idxIso & ~idxCutFast);
  
  %save raw spike counts
  spkCountAcc = spkCtCC(idxAcc);
  spkCountFast = spkCtCC(idxFast);
  %save corresponding trial numbers for reference
  trialAcc = find(idxAcc);
  trialFast = find(idxFast);
  
  %remove outliers
  if (nanmedian(spkCountAcc) >= 1.0) %make sure we have a minimum spike count
    idxCutAcc = estimate_spread(spkCountAcc, 3.5);    spkCountAcc(idxCutAcc) = [];    trialAcc(idxCutAcc) = [];
    idxCutFast = estimate_spread(spkCountFast, 3.5);  spkCountFast(idxCutFast) = [];  trialFast(idxCutFast) = [];
  end
  
  %z-score spike counts
  muSpkCt = mean([spkCountAcc spkCountFast]);
  sdSpkCt = std([spkCountAcc spkCountFast]);
  spkCountAcc = (spkCountAcc - muSpkCt) / sdSpkCt;
  spkCountFast = (spkCountFast - muSpkCt) / sdSpkCt;
  
  %index by trial number
  for jj = 1:NUM_TRIAL
    if (jj <= NUM_TRIAL/2) %first half
      idxJJ_A2F = ismember(trialAcc, trialA2F + TRIAL_PLOT(jj));
      idxJJ_F2A = ismember(trialFast, trialF2A + TRIAL_PLOT(jj));
      
      if (sum(idxJJ_A2F) >= MIN_PER_BIN)
        zSpkCt_A2F(cc,jj) = mean(spkCountAcc(idxJJ_A2F));
      end
      if (sum(idxJJ_F2A) >= MIN_PER_BIN)
        zSpkCt_F2A(cc,jj) = mean(spkCountFast(idxJJ_F2A));
      end
    else %second half
      idxJJ_A2F = ismember(trialFast, trialA2F + TRIAL_PLOT(jj));
      idxJJ_F2A = ismember(trialAcc, trialF2A + TRIAL_PLOT(jj));
      
      if (sum(idxJJ_A2F) >= MIN_PER_BIN)
        zSpkCt_A2F(cc,jj) = mean(spkCountFast(idxJJ_A2F));
      end
      if (sum(idxJJ_F2A) >= MIN_PER_BIN)
        zSpkCt_F2A(cc,jj) = mean(spkCountAcc(idxJJ_F2A));
      end
    end
    
  end
  
end%for:cell(cc)

%% Stats - Single-trial modulation at cued condition switch
tmp_A2F = [nanmean(zSpkCt_A2F(:,[3,4]),2) , nanmean(zSpkCt_A2F(:,[5,6]),2)];
tmp_F2A = [nanmean(zSpkCt_F2A(:,[3,4]),2) , nanmean(zSpkCt_F2A(:,[5,6]),2)];
diffA2F = diff(tmp_A2F, 1, 2);
diffF2A = diff(tmp_F2A, 1, 2);
ttestTom( diffA2F , diffF2A )

%% Plotting
NSEM_A2F = sum(~isnan(zSpkCt_A2F), 1);
NSEM_F2A = sum(~isnan(zSpkCt_F2A), 1);

muA2F = nanmean(zSpkCt_A2F);    seA2F = nanstd(zSpkCt_A2F) ./ NSEM_A2F;
muF2A = nanmean(zSpkCt_F2A);    seF2A = nanstd(zSpkCt_F2A) ./ NSEM_F2A;

figure(); hold on
plot([-4 12], [0 0], 'k:')
% plot(TRIAL_PLOT, zSpkCt_A2F', 'k-')
% plot(TRIAL_PLOT+NUM_TRIAL+1, zSpkCt_F2A', 'k-')
errorbar(TRIAL_PLOT, muA2F, seA2F, 'capsize',0, 'Color','k')
errorbar(TRIAL_PLOT+NUM_TRIAL+1, muF2A, seF2A, 'capsize',0, 'Color','k')
xlabel('Trial');  ylabel('Spike count (z)'); ytickformat('%2.1f')
xticks(-4:12); xticklabels({}); xlim([-4.5 12.5])
ppretty([4.8,2.2])
set(gca, 'XMinorTick','off')


end%fxn:plotSpkCount_X_Trial_ReStim_SAT()
