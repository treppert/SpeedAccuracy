function [ ] = plotSpkCount_X_RT_ReStim_SAT( binfo , moves , ninfo , spikes , varargin )
%plotSpkCount_X_RT_ReStim_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}, {'interval','Baseline'}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxVis = ([ninfo.visGrade] >= 2);
idxMove = ([ninfo.moveGrade] >= 2);

if strcmp(args.interval, 'Baseline')
  idxKeep = (idxArea & idxMonkey & (idxVis | idxMove));
  T_TEST = 3500 + [-500 20];
  MIN_PER_BIN = 50;
else %Visual response
  idxKeep = (idxArea & idxMonkey & idxVis);
  T_TEST = 3500 + [75 200];
  MIN_PER_BIN = 25;
end

NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

RTBIN_ACC = (0 : 30 : 300);     NBIN_ACC = length(RTBIN_ACC) - 1;
RTBIN_FAST = (-200 : 20 : 0);   NBIN_FAST = length(RTBIN_FAST) - 1;

RTLIM_ACC = [390 800]; %limits on acceptable RT (used for data cleaning)
RTLIM_FAST = [150 450];

%initializations
zSpkCtAcc = NaN(NUM_CELLS,NBIN_ACC);
zSpkCtFast = NaN(NUM_CELLS,NBIN_FAST);

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  RTkk = double(moves(kk).resptime);
  
  %compute spike count for all trials
  spkCtCC = cellfun(@(x) sum((x > T_TEST(1)) & (x < T_TEST(2))), spikes(cc).SAT);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_time | binfo(kk).err_nosacc);
  %index by RT limits
  idxCutAcc = (RTkk < RTLIM_ACC(1) | RTkk > RTLIM_ACC(2) | isnan(RTkk));
  idxCutFast = (RTkk < RTLIM_FAST(1) | RTkk > RTLIM_FAST(2) | isnan(RTkk));
  %index by condition and RT limits
  idxAcc = ((binfo(kk).condition == 1) & idxCorr & ~idxIso & ~idxCutAcc);
  idxFast = ((binfo(kk).condition == 3) & idxCorr & ~idxIso & ~idxCutFast);
  
  spkCountAcc = spkCtCC(idxAcc);    RTacc = RTkk(idxAcc) - double(binfo(kk).deadline(idxAcc));
  spkCountFast = spkCtCC(idxFast);  RTfast = RTkk(idxFast) - double(binfo(kk).deadline(idxFast));
  
  %remove outliers
  if (nanmedian(spkCountAcc) >= 1.0) %make sure we have a minimum spike count
    idxCutAcc = estimate_spread(spkCountAcc, 3.5);
    idxCutFast = estimate_spread(spkCountFast, 3.5);
    spkCountAcc(idxCutAcc) = [];      RTacc(idxCutAcc) = [];
    spkCountFast(idxCutFast) = [];    RTfast(idxCutFast) = [];
  end
  
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
MIN_SEM = 5;

RTPLOT_ACC = RTBIN_ACC(1:end-1) + diff(RTBIN_ACC)/2;
RTPLOT_FAST = RTBIN_FAST(1:end-1) + diff(RTBIN_FAST)/2;

%remove bins with too few sessions
binCutAcc = (sum(~isnan(zSpkCtAcc), 1) < MIN_SEM);    zSpkCtAcc(:,binCutAcc) = NaN;
binCutFast = (sum(~isnan(zSpkCtFast), 1) < MIN_SEM);  zSpkCtFast(:,binCutFast) = NaN;

NSEM_ACC = sum(~isnan(zSpkCtAcc), 1);
NSEM_FAST = sum(~isnan(zSpkCtFast), 1);

figure(); hold on
plot([-190 190], [0 0], 'k:')
% plot(RTPLOT_ACC, zSpkCtAcc, 'r-')
% plot(RTPLOT_FAST, zSpkCtFast, 'g-')
errorbar(RTPLOT_ACC, nanmean(zSpkCtAcc), nanstd(zSpkCtAcc)./NSEM_ACC, 'capsize',0, 'Color','r')
errorbar(RTPLOT_FAST, nanmean(zSpkCtFast), nanstd(zSpkCtFast)./NSEM_FAST, 'capsize',0, 'Color',[0 .7 0])
xlabel('Response time from deadline (ms)')
ylabel('Spike count (z)')
ppretty([4.8,2])


%% Stats
zSpkCtAcc = reshape(zSpkCtAcc', 1,NBIN_ACC*NUM_CELLS);       RTPLOT_ACC = repmat(RTPLOT_ACC, 1,NUM_CELLS);
zSpkCtFast = reshape(zSpkCtFast', 1,NBIN_FAST*NUM_CELLS);    RTPLOT_FAST = repmat(RTPLOT_FAST, 1,NUM_CELLS);

inanAcc = isnan(zSpkCtAcc);     zSpkCtAcc(inanAcc) = [];      RTPLOT_ACC(inanAcc) = [];
inanFast = isnan(zSpkCtFast);   zSpkCtFast(inanFast) = [];    RTPLOT_FAST(inanFast) = [];

[bfAcc, rhoAcc, pvalAcc] = bf.corr(RTPLOT_ACC', zSpkCtAcc');
[bfFast, rhoFast, pvalFast] = bf.corr(RTPLOT_FAST', zSpkCtFast');

fprintf('Accurate: R = %g  ||  p = %g || BF = %g\n', rhoAcc, pvalAcc, bfAcc)
fprintf('Fast: R = %g  ||  p = %g || BF = %g\n', rhoFast, pvalFast, bfFast)

%fit line to the data
% fitFast = fit(RTPLOT_FAST', zSpkCtFast', 'poly1');
% fitAcc = fit(RTPLOT_ACC', zSpkCtAcc', 'poly1');
% plot([-190,-10], fitFast([-190,-10]), '-', 'Color',[.4 .7 .4])
% plot([10,200], fitAcc([10,200]), '-', 'Color',[1 .5 .5])

end%fxn:plotSpkCount_X_RT_ReStim_SAT()
