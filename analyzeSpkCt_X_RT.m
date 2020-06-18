function [ ] = analyzeSpkCt_X_RT( bInfo , pSacc , unitInfo , spikes )
%analyzeSpkCt_X_RT Summary of this function goes here
%   Detailed explanation goes here

AREA = {'SEF'};
MONKEY = {'E'}; nMonkey = length(MONKEY);
INTERVAL = 'post'; %either 'pre' = baseline or 'post' = visual response

idxArea = ismember(unitInfo.area, AREA);
idxMonkey = ismember(unitInfo.monkey, MONKEY);
idxVisUnit = (unitInfo.visGrade >= 2);
idxMoveUnit = (unitInfo.moveGrade >= 2);

if strcmp(INTERVAL, 'pre')
  if (nMonkey > 1)
    MIN_PER_BIN = 50; %min no. of trials per RT bin
  else
    MIN_PER_BIN = 50;
  end
  unitTest = (idxArea & idxMonkey & (idxVisUnit | idxMoveUnit));
  T_TEST = 3500 + [-600 +20]; %interval over which to count spikes
elseif strcmp(INTERVAL, 'post')
  if (nMonkey > 1)
    MIN_PER_BIN = 25; %min no. of trials per RT bin
  else
    MIN_PER_BIN = 20;
  end
  unitTest = (idxArea & idxMonkey & idxVisUnit);
  if strcmp(AREA, 'SEF') %testing interval based on VR Latency **
    T_TEST = 3500 + [73 223];
  elseif strcmp(AREA, 'FEF')
    T_TEST = 3500 + [60 210];
  elseif strcmp(AREA, 'SC')
    T_TEST = 3500 + [43 193];
  end
end

NUM_CELLS = sum(unitTest);
unitInfo = unitInfo(unitTest,:);
spikes = spikes(unitTest);

RTBIN_ACC = (0 : 30 : 300);     NBIN_ACC = length(RTBIN_ACC) - 1;
RTBIN_FAST = (-200 : 20 : 0);   NBIN_FAST = length(RTBIN_FAST) - 1;

%initialize spike count X RT
spkCt_Acc = NaN(NUM_CELLS,NBIN_ACC);
spkCt_Fast = NaN(NUM_CELLS,NBIN_FAST);

for cc = 1:NUM_CELLS
  kk = ismember(bInfo.session, unitInfo.sess{cc});
  RTkk = double(pSacc.resptime{kk});
  
  %compute spike count for all trials
  spkCt_cc = cellfun(@(x) sum((x > T_TEST(1)) & (x < T_TEST(2))), spikes{cc});
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitInfo.trRemSAT{cc}, bInfo.num_trials(kk));
  %index by trial outcome
  idxCorr = ~(bInfo.err_hold{kk} | bInfo.err_nosacc{kk});
  %index by condition and RT limits
  idxAcc = ((bInfo.condition{kk} == 1) & idxCorr & ~idxIso);
  idxFast = ((bInfo.condition{kk} == 3) & idxCorr & ~idxIso);
  
  %split by task condition
  scAcc_cc = spkCt_cc(idxAcc);    rtAcc = RTkk(idxAcc) - double(bInfo.deadline{kk}(idxAcc));
  scFast_cc = spkCt_cc(idxFast);  rtFast = RTkk(idxFast) - double(bInfo.deadline{kk}(idxFast));
  
  %z-score spike counts
  muSpkCt = mean([scAcc_cc scFast_cc]);
  sdSpkCt = std([scAcc_cc scFast_cc]);
  scAcc_cc = (scAcc_cc - muSpkCt) / sdSpkCt;
  scFast_cc = (scFast_cc - muSpkCt) / sdSpkCt;
  
  %save mean spike count X RT
  for ii = 1:NBIN_ACC
    idx_ii = ((rtAcc > RTBIN_ACC(ii)) & (rtAcc < RTBIN_ACC(ii+1)));
    if (sum(idx_ii) >= MIN_PER_BIN)
      spkCt_Acc(cc,ii) = mean(scAcc_cc(idx_ii));
    end
  end%for:bin-Accurate
  for ii = 1:NBIN_FAST
    idx_ii = ((rtFast > RTBIN_FAST(ii)) & (rtFast < RTBIN_FAST(ii+1)));
    if (sum(idx_ii) >= MIN_PER_BIN)
      spkCt_Fast(cc,ii) = mean(scFast_cc(idx_ii));
    end
  end%for:bin-Fast
  
end % for : cell(cc)


%% Plotting
RT_PLOT_ACC = RTBIN_ACC(1:end-1) + diff(RTBIN_ACC)/2;
RT_PLOT_FAST = RTBIN_FAST(1:end-1) + diff(RTBIN_FAST)/2;

%remove bins with too few sessions
MIN_SEM = 3;
binCutAcc = (sum(~isnan(spkCt_Acc), 1) < MIN_SEM);    spkCt_Acc(:,binCutAcc) = NaN;
binCutFast = (sum(~isnan(spkCt_Fast), 1) < MIN_SEM);  spkCt_Fast(:,binCutFast) = NaN;

NSEM_ACC = sum(~isnan(spkCt_Acc), 1);
NSEM_FAST = sum(~isnan(spkCt_Fast), 1);

mu_spkCt_Acc = nanmean(spkCt_Acc);    se_spkCt_Acc = nanstd(spkCt_Acc) ./ NSEM_ACC;
mu_spkCt_Fast = nanmean(spkCt_Fast);  se_spkCt_Fast = nanstd(spkCt_Fast) ./ NSEM_FAST;

figure(); hold on
errorbar(RT_PLOT_ACC,  mu_spkCt_Acc,  se_spkCt_Acc,  'capsize',0, 'Color','r')
errorbar(RT_PLOT_FAST, mu_spkCt_Fast, se_spkCt_Fast, 'capsize',0, 'Color',[0 .7 0])
xlabel('Response time from deadline (ms)')
ylabel('Spike count (z)')
ppretty([4.8,3])

%% Stats
%prepare session averages for Pearson correlation analysis
spkCt_Acc  = reshape(spkCt_Acc',  1,NBIN_ACC*NUM_CELLS);
spkCt_Fast = reshape(spkCt_Fast', 1,NBIN_FAST*NUM_CELLS);
RT_PLOT_ACC = repmat(RT_PLOT_ACC, 1,NUM_CELLS);
RT_PLOT_FAST = repmat(RT_PLOT_FAST, 1,NUM_CELLS);

%remove all NaNs
inanFast = isnan(spkCt_Fast);   spkCt_Fast(inanFast) = [];    RT_PLOT_FAST(inanFast) = [];
inanAcc = isnan(spkCt_Acc);     spkCt_Acc(inanAcc) = [];      RT_PLOT_ACC(inanAcc) = [];

[bfFast, rhoFast, pvalFast] = bf.corr(RT_PLOT_FAST', spkCt_Fast');
[bfAcc, rhoAcc, pvalAcc] = bf.corr(RT_PLOT_ACC', spkCt_Acc');

fprintf('Fast: R = %g  ||  p = %g || BF = %g\n', rhoFast, pvalFast, bfFast)
fprintf('Accurate: R = %g  ||  p = %g || BF = %g\n', rhoAcc, pvalAcc, bfAcc)

%fit line to the data
fitFast = fit(RT_PLOT_FAST', spkCt_Fast', 'poly1');
fitAcc = fit(RT_PLOT_ACC', spkCt_Acc', 'poly1');
plot([-180,-20], fitFast([-180,-20]), '-', 'Color',[.4 .7 .4])
plot([25,200], fitAcc([25,200]), '-', 'Color',[1 .5 .5])

end % fxn : analyzeSpkCt_X_RT()
