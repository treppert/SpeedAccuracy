function [ ] = plotProbCorr_X_ChcErrActivity( binfo , moves , movesPP , ninfo , nstats , spikes )
%plotProbCorr_X_ChcErrActivity Summary of this function goes here
%   Detailed explanation goes here

ROOTDIR_STAT = 'C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\SEF_SAT\Stats\';

idxSEF = ismember({ninfo.area}, 'SEF');
idxError = ([ninfo.errGrade] >= 2);
idxKeep = (idxSEF & idxError);

NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
nstats = nstats(idxKeep);
spikes = spikes(idxKeep);

MAX_ERR_TIME = 50; %maximum timing error for trials allowed

%bin trials by error signal (z-score)
% BINLIM_Z = (-2.5 : 1.0 : 2.5); NBIN = length(BINLIM_Z) - 1;
BINLIM_Z = (-3.0 : 2.0 : 3.0); NBIN = length(BINLIM_Z) - 1;
ZPLOT = BINLIM_Z(1:NBIN) + diff(BINLIM_Z)/2;
MIN_PER_BIN = 10; %mininum number of trials

%initializations
ProbSS2T_ = NaN(NUM_CELLS, NBIN);
RT_ = NaN(NUM_CELLS, NBIN); %save RT as control
hAll = NaN(1,NUM_CELLS);
tstatAll = NaN(1,NUM_CELLS);

for cc = 1:NUM_CELLS
%   fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  kk = ismember({binfo.session}, ninfo(cc).sess);
  RTkk = double(moves(kk).resptime);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials, 'task','SAT');
  %index by trial outcome
  idxErr = (binfo(kk).err_dir & ~(binfo(kk).err_hold | binfo(kk).err_nosacc));
  
  %remove trials with large timing errors
  errTime = RTkk - double(binfo(kk).deadline);
  idxErrTimeAcc = ((binfo(kk).condition == 1) & (errTime < -MAX_ERR_TIME));
  idxErrTimeFast = ((binfo(kk).condition == 3) & (errTime > MAX_ERR_TIME));
  idxErr = (idxErr & ~(idxErrTimeAcc | idxErrTimeFast));
  
  trialAll = find(ismember(binfo(kk).condition, [1,3,4]) & ~idxIso & idxErr);
  numTrial = length(trialAll);
  
  %save secondary saccade endpoint counts
  SS2tgtAcc = false(1,numTrial);
  SS2tgtAcc(movesPP(kk).endpt(trialAll) == 1) = true;
  %save RT as a control
  rtAll = RTkk(trialAll);
  
  %% Compute single-trial spike counts
  
  %get error interval for each task condition
  tErrAllCC = [nstats(cc).A_ChcErr_tErr_Acc+5 , nstats(cc).A_ChcErr_tErrEnd_Acc-5];
  
  spkAll = NaN(1,numTrial);
  for jj = 1:numTrial
    %spike times aligned on primary saccade
    spkTimeJJ = spikes(cc).SAT{trialAll(jj)} - (3500 + RTkk(trialAll(jj)));
    %compute number of spikes during Accurate error interval
    spkAll(jj) = sum( (spkTimeJJ >= tErrAllCC(1)) & (spkTimeJJ <= tErrAllCC(2)) );
  end%for:trialsAcc(jj)
  
  %single-neuron stats
  [hAll(cc),~,~,tmpAll] = ttest2(spkAll(SS2tgtAcc), spkAll(~SS2tgtAcc), 'alpha',0.051);
  tstatAll(cc) = tmpAll.tstat;
  
  %z-score spike counts
  spkAll = (spkAll - mean(spkAll)) / std(spkAll);
  
  %% Bin trials by spike count
  for ii = 1:NBIN
    
    idxII_Acc = ( spkAll > BINLIM_Z(ii) & spkAll <= BINLIM_Z(ii+1) );
    
    if (sum(idxII_Acc) >= MIN_PER_BIN)
      ProbSS2T_(cc,ii) = sum(SS2tgtAcc & idxII_Acc) / sum(idxII_Acc);
      RT_(cc,ii) = median(rtAll(idxII_Acc));
    end
    
  end%for:zscore-bin(ii)
  
end%for:neuron(cc)

fprintf('Number of neurons for which error activity is Enhanced with SS to Tgt: %d\n', ...
  sum((hAll == 1) & (tstatAll > 0)));
fprintf('Number of neurons for which error activity is Suppressed with SS to Tgt: %d\n', ...
  sum((hAll == 1) & (tstatAll < 0)));

%% Plotting
%probability of corrective saccade
muProb_ = nanmean(ProbSS2T_);  nAcc = sum(~isnan(ProbSS2T_), 1);
seProb_ = nanstd(ProbSS2T_) ./ sqrt(nAcc);

figure(); hold on
% plot(ZPLOT, ProbSS2T_, 'Color',[.4 .4 .4], 'LineWidth',0.75)
errorbar(ZPLOT, muProb_, seProb_, 'Color',[.4 .4 .4], 'LineWidth',1.25, 'CapSize',0)
xlabel('Error signal magnitude (z)'); xlim([-2.1 2.1]); xticks(-2:2)
ylabel('P (corrective saccade)'); ytickformat('%3.2f')
ppretty([4.8,3])

%% Stats

DV_Prob = reshape(ProbSS2T_', NUM_CELLS*NBIN,1);
F_Signal = ZPLOT; F_Signal = repmat(F_Signal, 1,NUM_CELLS)';

anovan(DV_Prob, {F_Signal})

end%fxn:plotProbCorr_X_ChcErrActivity()

