function [ ] = plotSignal_X_ErrMag_RPE( binfo , ninfo , nstats , spikes )
%plotSignal_X_ErrMag_RPE Summary of this function goes here
%   Detailed explanation goes here

idxArea = ismember({ninfo.area}, {'SEF'});
idxMonkey = ismember({ninfo.monkey}, {'D','E'});
idxRew = ([ninfo.rewGrade] >= 2);
idxKeep = (idxArea & idxMonkey & idxRew);

NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
nstats = nstats(idxKeep);
spikes = spikes(idxKeep);

DEBUG = false;
MIN_PER_BIN = 5; %minimum number of trials per errRT bin
T_COUNT_REW = 3500 + [0, 200]; %window over which to count spikes (0 = onset of encoding)
T_COUNT_BASE = 3500 + [-300, 20]; %window for BASELINE CORRECTION

%prepare to bin trials by timing error magnitude
T_LIM = -fliplr(logspace(0.4, 2.4, 9));  N_BIN = length(T_LIM) - 1;
T_ERR = T_LIM(1:N_BIN) + diff(T_LIM)/2;

%initializations
spkCT_All = NaN(NUM_CELLS,N_BIN);

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  trewKK = double(binfo(kk).rewtime) + double(binfo(kk).resptime);
  errKK = double(binfo(kk).resptime) - double(binfo(kk).deadline);
  
  %get window over which to count spikes
  tCountRew = nstats(cc).A_Reward_tErrStart_Acc + T_COUNT_REW + nanmedian(trewKK);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials, 'task','SAT');
  %index by condition
  idxAcc = (binfo(kk).condition == 1 & ~idxIso & ~isnan(trewKK));
  %index by trial outcome
  idxErr = (binfo(kk).err_time & ~binfo(kk).err_dir);
  %index by screen clear on Fast trials
%   idxClear = logical(binfo(kk).clearDisplayFast);
  
  %compute the BASELINE-CORRECTED spike count for each trial
  spkCTcc = cellfun(@(x) sum((x > tCountRew(1)) & (x < tCountRew(2))), spikes(cc).SAT);
  spkCTbase = cellfun(@(x) sum((x > T_COUNT_BASE(1)) & (x < T_COUNT_BASE(2))), spikes(cc).SAT);
  spkCTcc = spkCTcc - spkCTbase;
  
  %z-score spike counts
  spkCTcc = (spkCTcc - mean(spkCTcc)) / std(spkCTcc) ;
  
  if (DEBUG)
    figure(); hold on
  end
  
  %bin trials by RT error magnitude
  for bb = 1:N_BIN
    idxBB = ((errKK > T_LIM(bb)) & (errKK <= T_LIM(bb+1)));
    idxBB = (idxBB & idxAcc & idxErr);
    
    if (sum(idxBB) >= MIN_PER_BIN) %check for minimum number of trials per RTerr bin
      spkCT_All(cc,bb) = median(spkCTcc(idxBB)); %store the MEDIAN spike count
    else %not enough trials in this bin
      continue
    end
    
    if (DEBUG)
      plot(T_ERR(bb), spkCTcc(idxBB), 'r.', 'MarkerSize',20)
    end
  end%for:RTerr-bin (bb)
  
  if (DEBUG)
    plot(T_ERR, spkCT_All(cc,:), 'k.-', 'LineWidth',1.25)
  end
  
end%for:cells(cc)

%% Stats
DV_Signal = reshape(spkCT_All', NUM_CELLS*N_BIN,1);
F_Error = T_ERR; F_Error = repmat(F_Error, 1,NUM_CELLS)';
anovan(DV_Signal, {F_Error});

%save for ANOVA in R
% save('C:\Users\Thomas Reppert\Dropbox\SAT\Stats\TErrSignalXRTErr.mat', 'F_Error','DV_Signal')

%% Plotting

figure(); hold on

plot([-200 0], [0 0], 'k:')
% plot(TERR_ACC, spkCT_Acc', 'k-')
errorbar(T_ERR, nanmean(spkCT_All), nanstd(spkCT_All)/sqrt(NUM_CELLS), ...
  'LineWidth',1.25, 'Capsize',0, 'Color','k')
ylabel('Signal magnitude (z)'); ytickformat('%2.1f')
xlabel('RT error (ms)')

ppretty([4.8,3])

end%fxn:plotSignal_X_ErrMag_RPE()

