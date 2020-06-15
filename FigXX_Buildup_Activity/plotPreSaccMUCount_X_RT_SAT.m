function [ ] = plotPreSaccMUCount_X_RT_SAT( binfo , moves , ninfo , spikes , varargin )
%plotPreSaccMUCount_X_RT_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

%index neurons by type
idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxMove = ([ninfo.moveGrade] >= 2);

idxKeep = (idxArea & idxMonkey & idxMove);
NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

T_PRESACC = [-100, 0]; %from primary saccade

%limits for acceptable RT
RTLIM_ACC = [390 800];
RTLIM_FAST = [150 450];

%binning by RT
RTBIN_FAST = (200 : 25 : 350);  NBIN_FAST = length(RTBIN_FAST) - 1;
RTBIN_ACC = (450 : 50 : 700);   NBIN_ACC = length(RTBIN_ACC) - 1;
MIN_PER_BIN = 5; %minimum number of trials per RT bin

%initializations
zSpkCtFast = NaN(NUM_CELLS,NBIN_FAST);
zSpkCtAcc = NaN(NUM_CELLS,NBIN_ACC);
zMuAcc = NaN(1,NUM_CELLS); %average across RT bins
zMuFast = NaN(1,NUM_CELLS);

for cc = 1:NUM_CELLS
  spikesCC = spikes(cc).SAT;
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  RTkk = double(moves(kk).resptime);
  
  %ref spikes to time of primary saccade
  for jj = 1:binfo(kk).num_trials
    spikesCC{jj} = spikesCC{jj} - (3500 + RTkk(jj));
  end
  
  %compute spike counts in pre-saccdic interval (T_PRESACC)
  spkCountCC = cellfun(@(x) sum((x > T_PRESACC(1)) & (x < T_PRESACC(2))), spikesCC);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by trial outcome
  idxErrTime = binfo(kk).err_time & ~binfo(kk).err_dir;
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc | binfo(kk).err_hold);
  %index by response direction relative to movement field MF
  idxMF = ismember(moves(kk).octant, ninfo(cc).moveField);
  %index by task condition
  idxAcc = ((binfo(kk).condition == 1) & idxCorr & idxMF & ~(idxIso | RTkk < RTLIM_ACC(1) | RTkk > RTLIM_ACC(2) | isnan(RTkk)));
  idxFast = ((binfo(kk).condition == 3) & idxCorr & idxMF & ~(idxIso | RTkk < RTLIM_FAST(1) | RTkk > RTLIM_FAST(2) | isnan(RTkk)));
  
  %split spike count by condition
  spkCountAcc = spkCountCC(idxAcc);
  spkCountFast = spkCountCC(idxFast);
  
  %cut outlier values for spike count
  idxCutAcc = estimate_spread(spkCountAcc, 3.5);    spkCountAcc(idxCutAcc) = [];
  idxCutFast = estimate_spread(spkCountFast, 3.5);  spkCountFast(idxCutFast) = [];
  
  %split RT by task condition
  RTacc = RTkk(idxAcc);   RTacc(idxCutAcc) = [];
  RTfast = RTkk(idxFast); RTfast(idxCutFast) = [];
  
  %z-score spike counts
  muSpkCt = mean([spkCountAcc spkCountFast]);
  sdSpkCt = std([spkCountAcc spkCountFast]);
  spkCountAcc = (spkCountAcc - muSpkCt) / sdSpkCt;
  spkCountFast = (spkCountFast - muSpkCt) / sdSpkCt;
  
  %save average spike count (z) per condition
  zMuAcc(cc) = mean(spkCountAcc);
  zMuFast(cc) = mean(spkCountFast);
  
  %save for across-session average
  for ii = 1:NBIN_ACC
    idxII = ((RTacc > RTBIN_ACC(ii)) & (RTacc < RTBIN_ACC(ii+1)));
    if (sum(idxII) >= MIN_PER_BIN)
      zSpkCtAcc(cc,ii) = mean(spkCountAcc(idxII));
    end
  end%for:bin-Accurate
  for ii = 1:NBIN_FAST
    idxII = ((RTfast > RTBIN_FAST(ii)) & (RTfast < RTBIN_FAST(ii+1)));
    if (sum(idxII) >= MIN_PER_BIN)
      zSpkCtFast(cc,ii) = mean(spkCountFast(idxII));
    end
  end%for:bin-Fast
  
end%for:session(kk)

%% Plotting -- Mean multi-unit spike count
ccMore = ([ninfo.taskType] == 1) & ~isnan(zMuAcc);    NUM_MORE = sum(ccMore);
ccLess = ([ninfo.taskType] == 2) & ~isnan(zMuFast);   NUM_LESS = sum(ccLess);

%multi-unit spike count average
ctAccMore = zMuAcc(ccMore);       ctAccLess = zMuAcc(ccLess);
ctFastMore = zMuFast(ccMore);     ctFastLess = zMuFast(ccLess);

muAccMore = mean(ctAccMore);      seAccMore = std(ctAccMore) / sqrt(NUM_MORE);
muAccLess = mean(ctAccLess);      seAccLess = std(ctAccLess) / sqrt(NUM_LESS);
muFastMore = mean(ctFastMore);    seFastMore = std(ctFastMore) / sqrt(NUM_MORE);
muFastLess = mean(ctFastLess);    seFastLess = std(ctFastLess) / sqrt(NUM_LESS);

% figure(); hold on
% bar(1, muFastMore, 0.7, 'FaceColor',[0 .7 0], 'LineWidth',0.25)
% bar(3, muFastLess, 0.7, 'FaceColor',[0 .7 0], 'LineWidth',1.25)
% bar(2, muAccMore, 0.7, 'FaceColor','r', 'LineWidth',0.25)
% bar(4, muAccLess, 0.7, 'FaceColor','r', 'LineWidth',1.25)
% errorbar([muFastMore muAccMore muFastLess muAccLess], [seFastMore seAccMore seFastLess seAccLess], 'Color','k', 'CapSize',0)
% xticks([]); xticklabels([])
% ylabel('Spike count at RT (z)'); ytickformat('%2.1f')
% ppretty([2,3]); pause(0.1)

%Stats - paired t-test of different means (Acc/Fast) at each level of
%search efficiency
% fprintf('More efficient:\n'); ttestTom(ctAccMore', ctFastMore')
% fprintf('Less efficient:\n'); ttestTom(ctAccLess', ctFastLess')

%% Plotting -- Spike count vs. RT
MIN_NUM_CELL = 3; %minimum number of sessions to plot a data point
RTPLOT_ACC = RTBIN_ACC(1:end-1) + diff(RTBIN_ACC)/2;
RTPLOT_FAST = RTBIN_FAST(1:end-1) + diff(RTBIN_FAST)/2;

zSpkAcc_More = zSpkCtAcc(ccMore,:);   zSpkAcc_Less = zSpkCtAcc(ccLess,:);
zSpkFast_More = zSpkCtFast(ccMore,:); zSpkFast_Less = zSpkCtFast(ccLess,:);

%remove data points with low number of sessions
nAccMore = sum(~isnan(zSpkAcc_More), 1);          nAccLess = sum(~isnan(zSpkAcc_Less), 1);
nFastMore = sum(~isnan(zSpkFast_More), 1);        nFastLess = sum(~isnan(zSpkFast_Less), 1);
zSpkAcc_More(:,nAccMore < MIN_NUM_CELL) = NaN;    zSpkAcc_Less(:,nAccLess < MIN_NUM_CELL) = NaN;
zSpkFast_More(:,nFastMore < MIN_NUM_CELL) = NaN;  zSpkFast_Less(:,nFastLess < MIN_NUM_CELL) = NaN;

NSEM_ACC_MORE = sum(~isnan(zSpkAcc_More), 1);     NSEM_ACC_LESS = sum(~isnan(zSpkAcc_Less), 1);
NSEM_FAST_MORE = sum(~isnan(zSpkFast_More), 1);   NSEM_FAST_LESS = sum(~isnan(zSpkFast_Less), 1);

figure(); hold on
plot([200 700], [0 0], 'k:')
% errorbar(RTPLOT_ACC, nanmean(zSpkAcc_More), nanstd(zSpkAcc_More)./NSEM_ACC_MORE, 'capsize',0, 'Color','r')
% errorbar(RTPLOT_FAST, nanmean(zSpkFast_More), nanstd(zSpkFast_More)./NSEM_FAST_MORE, 'capsize',0, 'Color',[0 .7 0])
errorbar(RTPLOT_ACC, nanmean(zSpkAcc_Less), nanstd(zSpkAcc_Less)./NSEM_ACC_LESS, 'capsize',0, 'Color','r', 'LineWidth',1.25)
errorbar(RTPLOT_FAST, nanmean(zSpkFast_Less), nanstd(zSpkFast_Less)./NSEM_FAST_LESS, 'capsize',0, 'Color',[0 .7 0], 'LineWidth',1.25)
xlabel('Response time (ms)')
ylabel('Spike count at RT (z)'); ytickformat('%2.1f')
ppretty([6.4,3])

%% Stats - Spike count at RT vs. RT
zSpkCtAcc = reshape(zSpkCtAcc', 1,NUM_CELLS*NBIN_ACC)';     rtAcc = repmat(RTPLOT_ACC, 1,NUM_CELLS)';
zSpkCtFast = reshape(zSpkCtFast', 1,NUM_CELLS*NBIN_FAST)';  rtFast = repmat(RTPLOT_FAST, 1,NUM_CELLS)';

%remove all NaNs
inanAcc = isnan(zSpkCtAcc);     zSpkCtAcc(inanAcc) = [];   rtAcc(inanAcc) = [];
inanFast = isnan(zSpkCtFast);   zSpkCtFast(inanFast) = [];  rtFast(inanFast) = [];

[rhoAcc,pvalAcc] = corr(rtAcc, zSpkCtAcc, 'Type','Pearson');
[rhoFast,pvalFast] = corr(rtFast, zSpkCtFast, 'Type','Pearson');
fprintf('Accurate: R = %g  p = %g\n', rhoAcc, pvalAcc)
fprintf('Fast: R = %g  p = %g\n', rhoFast, pvalFast)


end%fxn:plotPreSaccMUCount_X_RT_SAT()
