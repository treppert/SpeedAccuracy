function [ ] = plotdRTvsChcErrMagSAT( binfo , moves , ninfo , nstats , spikes , varargin )
%plotdRTvsChcErrMagSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});
ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\SEF_SAT\Stats\';

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxError = (abs([ninfo.errGrade]) >= 2);
idxKeep = (idxArea & idxMonkey & idxError);

ninfo = ninfo(idxKeep);
nstats = nstats(idxKeep);
spikes = spikes(idxKeep);
NUM_CELLS = length(spikes);

trialSwitch = identify_condition_switch(binfo);

%output initializations
pvalFast = NaN(1,NUM_CELLS); %p-value from Pearson correlation coeff.
pvalAcc = NaN(1,NUM_CELLS);
tstatFast = NaN(1,NUM_CELLS); %t-stat corresponding to Pearson test
tstatAcc = NaN(1,NUM_CELLS);
nFast = NaN(1,NUM_CELLS); %number of trials used in estimate
nAcc = NaN(1,NUM_CELLS);

for cc = 1:NUM_CELLS
  fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  spikesCC = spikes(cc).SAT;
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  RTkk = double(moves(kk).resptime);
  RTkk(RTkk > 1000) = NaN; %remove outlier values of RT
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxAcc = (binfo(kk).condition == 1 & ~idxIso);
  idxFast = (binfo(kk).condition == 3 & ~idxIso);
  %index by trial outcome
  idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  trialFast = find(idxFast & idxErr);
  trialAcc = find(idxAcc & idxErr);
  if (trialFast(end) == binfo(kk).num_trials); trialFast(end) = []; end
  if (trialAcc(end) == binfo(kk).num_trials);   trialAcc(end) = []; end
  
  %remove all trials at condition switch
  trialPreSwitch = [trialSwitch(kk).A2F, trialSwitch(kk).F2A] - 1; 
  [~,idxCut] = intersect(trialFast, trialPreSwitch);  trialFast(idxCut) = [];
  [~,idxCut] = intersect(trialAcc, trialPreSwitch);   trialAcc(idxCut) = [];
  
  %remove all trials for which the next trial (n+1) is a timing error
  jjCutFast = (binfo(kk).err_time(trialFast+1));    trialFast(jjCutFast) = [];
%   jjCutAcc = (binfo(kk).err_time(trialAcc+1));      trialAcc(jjCutAcc) = [];
  
  %compute change in RT from Trial n to Trial n+1
  dRT_Fast = RTkk(trialFast+1) - RTkk(trialFast);
  dRT_Acc = RTkk(trialAcc+1) - RTkk(trialAcc);
  
  %reference spikes to time of primary response
  for jj = 1:length(trialFast)
    spikesCC{trialFast(jj)} = spikesCC{trialFast(jj)} - (3500 + RTkk(trialFast(jj)));
  end
  for jj = 1:length(trialAcc)
    spikesCC{trialAcc(jj)} = spikesCC{trialAcc(jj)} - (3500 + RTkk(trialAcc(jj)));
  end
  
  tLimFast = [nstats(cc).A_ChcErr_tErr_Fast, nstats(cc).A_ChcErr_tErrEnd_Fast];
  tLimAcc = [nstats(cc).A_ChcErr_tErr_Acc, nstats(cc).A_ChcErr_tErrEnd_Acc];
  
  spCtFast = cellfun(@(x) sum((x > tLimFast(1)) & (x < tLimFast(2))), spikesCC(trialFast));
  spCtAcc = cellfun(@(x) sum((x > tLimAcc(1)) & (x < tLimAcc(2))), spikesCC(trialAcc));
  
  %remove trials with NaN values for RT
  spCtFast(isnan(dRT_Fast)) = []; dRT_Fast(isnan(dRT_Fast)) = [];  
  spCtAcc(isnan(dRT_Acc)) = [];   dRT_Acc(isnan(dRT_Acc)) = [];
  
  [rhoFast,tmpFast] = corr([spCtFast ; dRT_Fast]', 'Type','Pearson');   pvalFast(cc) = tmpFast(1,2);
  [rhoAcc,tmpAcc] = corr([spCtAcc ; dRT_Acc]', 'Type','Pearson');       pvalAcc(cc) = tmpAcc(1,2);
  
  %convert correlation coeff to t-statistic (to compute BF in R)
  tstatFast(cc) = computeTStat(rhoFast(1,2), length(dRT_Fast));
  tstatAcc(cc) = computeTStat(rhoAcc(1,2), length(dRT_Acc));
  nFast(cc) = length(dRT_Fast);
  nAcc(cc) = length(dRT_Acc);
  
  figure()
  subplot(1,2,1); hold on
  scatter(spCtFast, dRT_Fast, 20, [0 .7 0], 'filled')
  xlabel('Spike count'); ylabel('Change in RT (ms)')
  print_session_unit(gca , ninfo(cc), [])
  subplot(1,2,2); hold on
  scatter(spCtAcc, dRT_Acc, 20, 'r', 'filled')
  ppretty([8 4])
  
end%for:cells(cc)

figure()
subplot(2,1,1); hold on
histogram(-log(pvalFast), 'BinWidth',.5)
plot(-log(0.05)*ones(1,2), [0 8], 'k:', 'LineWidth',1.25)
plot(-log(0.01)*ones(1,2), [0 8], 'k:', 'LineWidth',1.25)
subplot(2,1,2); hold on
histogram(-log(pvalAcc), 'BinWidth',.5)
plot(-log(0.05)*ones(1,2), [0 8], 'k:', 'LineWidth',1.25)
plot(-log(0.01)*ones(1,2), [0 8], 'k:', 'LineWidth',1.25)
ppretty([4.8,4])
subplot(2,1,1); set(gca, 'YMinorTick','off')
subplot(2,1,2); set(gca, 'YMinorTick','off')

%prepare to calculate corresponding BF in R
% save([ROOTDIR, 'TStatDRTxErrMag.mat'], 'tstatFast','tstatAcc','nFast','nAcc')

end%plotdRTvsChcErrMagSAT()

function [ t ] = computeTStat( rho , n )
%This util computes the t-statistic corresponding to a Pearson correlation
%coefficienct.

t = sqrt( (n-2)*rho^2 / (1-rho^2) );

end%util:computeTStat()
