function [ ] = plotVisRespMUCount_X_RT_SAT( binfo , moves , ninfo , nstats , spikes , varargin )
%plotVisRespMUCount_X_RT_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

if ~any(ismember(args.monkey, {'Q','S'}))
  binfo = binfo(1:16);
end

NUM_SESSION = length(binfo);

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxVis = ([ninfo.visGrade] >= 2);   idxMove = ([ninfo.moveGrade] >= 2);
idxErr = ([ninfo.errGrade] >= 2);   idxRew = (abs([ninfo.rewGrade]) >= 2);
idxTaskRel = (idxVis | idxMove | idxErr | idxRew);

idxKeep = (idxArea & idxMonkey & idxVis);

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

%limits for acceptable RT
RTLIM_ACC = [390 800];
RTLIM_FAST = [150 450];

%binning by RT
RTBIN_FAST = (200 : 25 : 350);  NBIN_FAST = length(RTBIN_FAST) - 1;
RTBIN_ACC = (450 : 50 : 700);   NBIN_ACC = length(RTBIN_ACC) - 1;
MIN_PER_BIN = 10; %minimum number of trials per RT bin

%initializations
zSpkCtAcc = NaN(NUM_SESSION,NBIN_ACC);
zSpkCtFast = NaN(NUM_SESSION,NBIN_FAST);
zMuAcc = NaN(1,NUM_SESSION); %average across RT bins
zMuFast = NaN(1,NUM_SESSION);

for kk = 1:NUM_SESSION
  ccKK = find(ismember({ninfo.sess}, binfo(kk).session));  numCells = length(ccKK);
  RTkk = double(moves(kk).resptime);
  
  %make sure we have neurons from this session
  if (numCells == 0); continue; end
  
  %session-specific initializations
  spkCount = NaN(numCells,binfo(kk).num_trials);
  idxPoorIso = false(numCells,binfo(kk).num_trials);
  
  %loop over all neurons from this session to compute spike counts
  for cc = 1:numCells
    spikesCC = spikes(ccKK(cc)).SAT;
    
    %ref spikes to time of visual response
    ccNS = ninfo(ccKK(cc)).unitNum;
    visRespLatency = nstats(ccNS).VRlatAcc; %note: VRlatAcc = VRlatFast
    T_VISRESP = 3500 + visRespLatency + [0 150];
    
    %compute spike counts in visual response interval [Latency + 150 ms]
    spkCount(cc,:)  = cellfun(@(x) sum((x > T_VISRESP(1)) & (x < T_VISRESP(2))), spikesCC);
    
    %account for trials with poor isolation
    idxPoorIso(cc,:) = identify_trials_poor_isolation_SAT(ninfo(ccKK(cc)), binfo(kk).num_trials);
    
  end%for:cells(cc)
  
  %remove trials with poor unit isolation
  idxPoorIso = logical(sum(idxPoorIso,1));
  
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc | binfo(kk).err_hold);
  %index by task condition
  idxAcc = ((binfo(kk).condition == 1) & idxCorr & ~(idxPoorIso | RTkk < RTLIM_ACC(1) | RTkk > RTLIM_ACC(2) | isnan(RTkk)));
  idxFast = ((binfo(kk).condition == 3) & idxCorr & ~(idxPoorIso | RTkk < RTLIM_FAST(1) | RTkk > RTLIM_FAST(2) | isnan(RTkk)));
  
  %sum discharge rate across all units from this session
  spkCountAcc = sum(spkCount(:,idxAcc), 1);
  spkCountFast = sum(spkCount(:,idxFast), 1);
  
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
  zMuAcc(kk) = mean(spkCountAcc);
  zMuFast(kk) = mean(spkCountFast);
  
  %save for across-session average
  for ii = 1:NBIN_ACC
    idxII = ((RTacc > RTBIN_ACC(ii)) & (RTacc < RTBIN_ACC(ii+1)));
    if (sum(idxII) >= MIN_PER_BIN)
      zSpkCtAcc(kk,ii) = mean(spkCountAcc(idxII));
    end
  end%for:bin-Accurate
  for ii = 1:NBIN_FAST
    idxII = ((RTfast > RTBIN_FAST(ii)) & (RTfast < RTBIN_FAST(ii+1)));
    if (sum(idxII) >= MIN_PER_BIN)
      zSpkCtFast(kk,ii) = mean(spkCountFast(idxII));
    end
  end%for:bin-Fast
  
end%for:session(kk)

%% Plotting -- Mean multi-unit spike count
kkMore = ([binfo.taskType] == 1) & ~isnan(zMuAcc);    NUM_MORE = sum(kkMore);
kkLess = ([binfo.taskType] == 2) & ~isnan(zMuFast);   NUM_LESS = sum(kkLess);

%multi-unit spike count average
ctAccMore = zMuAcc(kkMore);       ctAccLess = zMuAcc(kkLess);
ctFastMore = zMuFast(kkMore);     ctFastLess = zMuFast(kkLess);

muAccMore = mean(ctAccMore);      seAccMore = std(ctAccMore) / sqrt(NUM_MORE);
muAccLess = mean(ctAccLess);      seAccLess = std(ctAccLess) / sqrt(NUM_LESS);
muFastMore = mean(ctFastMore);    seFastMore = std(ctFastMore) / sqrt(NUM_MORE);
muFastLess = mean(ctFastLess);    seFastLess = std(ctFastLess) / sqrt(NUM_LESS);

figure(); hold on
bar(1, muFastMore, 0.7, 'FaceColor',[0 .7 0], 'LineWidth',0.25)
bar(2, muFastLess, 0.7, 'FaceColor',[0 .7 0], 'LineWidth',1.25)
bar(3, muAccMore, 0.7, 'FaceColor','r', 'LineWidth',0.25)
bar(4, muAccLess, 0.7, 'FaceColor','r', 'LineWidth',1.25)
errorbar([muFastMore muFastLess muAccMore muAccLess], [seFastMore seFastLess seAccMore seAccLess], 'Color','k', 'CapSize',0)
xticks([]); xticklabels([])
ylabel('Multi-unit spike count (z)'); ytickformat('%2.1f')
ppretty([2,3]); pause(0.1)

%Stats - paired t-test of different means (Acc/Fast) at each level of
%search efficiency
fprintf('More efficient:\n'); ttestTom(ctAccMore', ctFastMore')
fprintf('Less efficient:\n'); ttestTom(ctAccLess', ctFastLess')

%% Plotting -- Multi-unit spike count vs. RT
MIN_NUM_SESS = 3; %minimum number of sessions to plot a data point
RTPLOT_ACC = RTBIN_ACC(1:end-1) + diff(RTBIN_ACC)/2;
RTPLOT_FAST = RTBIN_FAST(1:end-1) + diff(RTBIN_FAST)/2;

zSpkAcc_More = zSpkCtAcc(kkMore,:);   zSpkAcc_Less = zSpkCtAcc(kkLess,:);
zSpkFast_More = zSpkCtFast(kkMore,:); zSpkFast_Less = zSpkCtFast(kkLess,:);

%remove data points with low number of sessions
nAccMore = sum(~isnan(zSpkAcc_More), 1);          nAccLess = sum(~isnan(zSpkAcc_Less), 1);
nFastMore = sum(~isnan(zSpkFast_More), 1);        nFastLess = sum(~isnan(zSpkFast_Less), 1);
zSpkAcc_More(:,nAccMore < MIN_NUM_SESS) = NaN;    zSpkAcc_Less(:,nAccLess < MIN_NUM_SESS) = NaN;
zSpkFast_More(:,nFastMore < MIN_NUM_SESS) = NaN;  zSpkFast_Less(:,nFastLess < MIN_NUM_SESS) = NaN;

NSEM_ACC_MORE = sum(~isnan(zSpkAcc_More), 1);     NSEM_ACC_LESS = sum(~isnan(zSpkAcc_Less), 1);
NSEM_FAST_MORE = sum(~isnan(zSpkFast_More), 1);   NSEM_FAST_LESS = sum(~isnan(zSpkFast_Less), 1);

figure(); hold on
plot([200 700], [0 0], 'k:')
errorbar(RTPLOT_ACC, nanmean(zSpkAcc_More), nanstd(zSpkAcc_More)./NSEM_ACC_MORE, 'capsize',0, 'Color','r')
errorbar(RTPLOT_FAST, nanmean(zSpkFast_More), nanstd(zSpkFast_More)./NSEM_FAST_MORE, 'capsize',0, 'Color',[0 .7 0])
errorbar(RTPLOT_ACC, nanmean(zSpkAcc_Less), nanstd(zSpkAcc_Less)./NSEM_ACC_LESS, 'capsize',0, 'Color','r', 'LineWidth',1.25)
errorbar(RTPLOT_FAST, nanmean(zSpkFast_Less), nanstd(zSpkFast_Less)./NSEM_FAST_LESS, 'capsize',0, 'Color',[0 .7 0], 'LineWidth',1.25)
xlabel('Response time (ms)')
ylabel('Multi-unit spike count (z)'); ytickformat('%2.1f')
ppretty([6.4,3])

%% Compute stats on session averages
zSpkCtAcc = reshape(zSpkCtAcc', 1,NUM_SESSION*NBIN_ACC)';     rtAcc = repmat(RTPLOT_ACC, 1,NUM_SESSION)';
zSpkCtFast = reshape(zSpkCtFast', 1,NUM_SESSION*NBIN_FAST)';  rtFast = repmat(RTPLOT_FAST, 1,NUM_SESSION)';

%remove all NaNs
inanAcc = isnan(zSpkCtAcc);     zSpkCtAcc(inanAcc) = [];   rtAcc(inanAcc) = [];
inanFast = isnan(zSpkCtFast);   zSpkCtFast(inanFast) = [];  rtFast(inanFast) = [];

[rhoAcc,pvalAcc] = corr(rtAcc, zSpkCtAcc, 'Type','Pearson');
[rhoFast,pvalFast] = corr(rtFast, zSpkCtFast, 'Type','Pearson');
fprintf('Accurate: R = %g  p = %g\n', rhoAcc, pvalAcc)
fprintf('Fast: R = %g  p = %g\n', rhoFast, pvalFast)

end%fxn:plotVisRespMUCount_X_RT_SAT()
