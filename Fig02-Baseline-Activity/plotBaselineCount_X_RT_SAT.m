function [ ] = plotBaselineCount_X_RT_SAT( binfo , moves , ninfo , spikes , varargin )
%plotBaselineCount_X_RT_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

if ~any(ismember(args.monkey, {'Q','S'}))
  binfo = binfo(1:16);
end

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxVis = ([ninfo.visGrade] >= 2);   idxMove = ([ninfo.moveGrade] >= 2);
idxErr = ([ninfo.errGrade] >= 2);   idxRew = (abs([ninfo.rewGrade]) >= 2);
idxTaskRel = (idxVis | idxMove | idxErr | idxRew);

idxKeep = (idxArea & idxMonkey & idxMove);

NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

RTLIM_ACC = [390 800];
RTLIM_FAST = [150 450];

T_BLINE = 3500 + [-600 20];

RTBIN_FAST = (200 : 25 : 350);  NBIN_FAST = length(RTBIN_FAST) - 1;
RTBIN_ACC = (450 : 50 : 700);   NBIN_ACC = length(RTBIN_ACC) - 1;
MIN_PER_BIN = 10; %minimum number of trials per RT bin

%initializations
zSpkCtAcc = NaN(NUM_CELLS,NBIN_ACC);
zSpkCtFast = NaN(NUM_CELLS,NBIN_FAST);


for cc = 1:NUM_CELLS
  fprintf('Unit %s - %s\n', ninfo(cc).sess, ninfo(cc).unit);
  
  %compute spike count for all trials
  spkCtCC = cellfun(@(x) sum((x > T_BLINE(1)) & (x < T_BLINE(2))), spikes(cc).SAT);
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  RTkk = double(binfo(kk).resptime);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc | binfo(kk).err_hold);
  %index by condition and RT limits
  idxAcc = ((binfo(kk).condition == 1) & idxCorr & ~idxIso & ~(RTkk < RTLIM_ACC(1) | RTkk > RTLIM_ACC(2) | isnan(RTkk)));
  idxFast = ((binfo(kk).condition == 3) & idxCorr & ~idxIso & ~(RTkk < RTLIM_FAST(1) | RTkk > RTLIM_FAST(2) | isnan(RTkk)));
  
  spkCountAcc = spkCtCC(idxAcc);    RTacc = RTkk(idxAcc);
  spkCountFast = spkCtCC(idxFast);  RTfast = RTkk(idxFast);
  
  %remove outliers
  idxCutAcc = estimate_spread(spkCountAcc, 3.5);
  idxCutFast = estimate_spread(spkCountFast, 3.5);
  spkCountAcc(idxCutAcc) = [];      RTacc(idxCutAcc) = [];
  spkCountFast(idxCutFast) = [];    RTfast(idxCutFast) = [];
  
  %z-score spike counts
  muSpkCt = mean([spkCountAcc spkCountFast]);
  sdSpkCt = std([spkCountAcc spkCountFast]);
  spkCountAcc = (spkCountAcc - muSpkCt) / sdSpkCt;
  spkCountFast = (spkCountFast - muSpkCt) / sdSpkCt;
  
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
  
end%for:cell(cc)

%% Plotting
RTPLOT_ACC = RTBIN_ACC(1:end-1) + diff(RTBIN_ACC)/2;
RTPLOT_FAST = RTBIN_FAST(1:end-1) + diff(RTBIN_FAST)/2;

ccMore = ([ninfo.taskType] == 1);     ccLess = ([ninfo.taskType] == 2);
zSpkAcc_More = zSpkCtAcc(ccMore,:);   zSpkAcc_Less = zSpkCtAcc(ccLess,:);
zSpkFast_More = zSpkCtFast(ccMore,:); zSpkFast_Less = zSpkCtFast(ccLess,:);

NSEM_ACC_MORE = sum(~isnan(zSpkAcc_More), 1);   NSEM_ACC_LESS = sum(~isnan(zSpkAcc_Less), 1);
NSEM_FAST_MORE = sum(~isnan(zSpkFast_More), 1);   NSEM_FAST_LESS = sum(~isnan(zSpkFast_Less), 1);

figure(); hold on
errorbar(RTPLOT_ACC, nanmean(zSpkAcc_More), nanstd(zSpkAcc_More)./NSEM_ACC_MORE, 'capsize',0, 'Color','r')
errorbar(RTPLOT_FAST, nanmean(zSpkFast_More), nanstd(zSpkFast_More)./NSEM_FAST_MORE, 'capsize',0, 'Color',[0 .7 0])
errorbar(RTPLOT_ACC, nanmean(zSpkAcc_Less), nanstd(zSpkAcc_Less)./NSEM_ACC_LESS, 'capsize',0, 'Color','r', 'LineWidth',1.25)
errorbar(RTPLOT_FAST, nanmean(zSpkFast_Less), nanstd(zSpkFast_Less)./NSEM_FAST_LESS, 'capsize',0, 'Color',[0 .7 0], 'LineWidth',1.25)
xlabel('Response time (ms)')
ylabel('Spike count (z)'); ytickformat('%3.2f')
ppretty([6.4,4])


end%fxn:plotBaselineCount_X_RT_SAT()
