function [ ] = plotProbCorr_X_ChcErrActivity( binfo , moves , movesPP , ninfo , nstats , spikes )
%plotProbCorr_X_ChcErrActivity Summary of this function goes here
%   Detailed explanation goes here

ROOTDIR_STAT = 'C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\SEF_SAT\Stats\';

idxSEF = ismember({ninfo.area}, 'SEF');
idxError = (abs([ninfo.errGrade]) >= 2);
idxKeep = (idxSEF & idxError);

NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
nstats = nstats(idxKeep);
spikes = spikes(idxKeep);

%bin trials by error signal (z-score)
BINLIM_Z = (-2.5 : 1.0 : 2.5); NBIN = length(BINLIM_Z) - 1;
ZPLOT = BINLIM_Z(1:NBIN) + diff(BINLIM_Z)/2;
MIN_PER_BIN = 5; %mininum number of trials

ProbSS2T_Acc = NaN(NUM_CELLS, NBIN);
ProbSS2T_Fast = NaN(NUM_CELLS, NBIN);
  
for cc = 1:NUM_CELLS
%   fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  kk = ismember({binfo.session}, ninfo(cc).sess);
  RTkk = double(moves(kk).resptime);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials, 'task','SAT');
  %index by trial outcome
  idxErr = (binfo(kk).err_dir);
%   idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  %index by condition
  trialAcc = find((binfo(kk).condition == 1) & ~idxIso & idxErr);   numAcc = length(trialAcc);
  trialFast = find((binfo(kk).condition == 3) & ~idxIso & idxErr);  numFast = length(trialFast);
  
  %save secondary saccade endpoint counts
  SS2tgtAcc = false(1,numAcc);    SS2tgtAcc(movesPP(kk).endpt(trialAcc) == 1) = true;
  SS2tgtFast = false(1,numFast);  SS2tgtFast(movesPP(kk).endpt(trialFast) == 1) = true;
  
  %% Compute single-trial spike counts
  
  %get error interval for each task condition
  tErrAccCC = [nstats(cc).A_ChcErr_tErr_Acc nstats(cc).A_ChcErr_tErrEnd_Acc];
  tErrFastCC = [nstats(cc).A_ChcErr_tErr_Fast nstats(cc).A_ChcErr_tErrEnd_Fast];
  
  spkAcc = NaN(1,numAcc);
  for jj = 1:numAcc
    %spike times aligned on primary saccade
    spkTimeJJ = spikes(cc).SAT{trialAcc(jj)} - (3500 + RTkk(trialAcc(jj)));
    %compute number of spikes during Accurate error interval
    spkAcc(jj) = sum( (spkTimeJJ >= tErrAccCC(1)) & (spkTimeJJ <= tErrAccCC(2)) );
  end%for:trialsAcc(jj)
  
  spkFast = NaN(1,numFast);
  for jj = 1:numFast
    %spike times aligned on primary saccade
    spkTimeJJ = spikes(cc).SAT{trialFast(jj)} - (3500 + RTkk(trialFast(jj)));
    %compute number of spikes during Fast error interval
    spkFast(jj) = sum( (spkTimeJJ >= tErrFastCC(1)) & (spkTimeJJ <= tErrFastCC(2)) );
  end%for:trialsFast(jj)
  
  %z-score spike counts
  spkAcc = (spkAcc - mean(spkAcc)) / std(spkAcc);
  spkFast = (spkFast - mean(spkFast)) / std(spkFast);
  
  %% Bin trials by spike count
  for ii = 1:NBIN
    
    idxII_Acc = ( spkAcc > BINLIM_Z(ii) & spkAcc <= BINLIM_Z(ii+1) );
    idxII_Fast = ( spkFast > BINLIM_Z(ii) & spkFast <= BINLIM_Z(ii+1) );
    
    if (sum(idxII_Acc) >= MIN_PER_BIN)
      ProbSS2T_Acc(cc,ii) = sum(SS2tgtAcc & idxII_Acc) / sum(idxII_Acc);
    end
    if (sum(idxII_Fast) >= MIN_PER_BIN)
      ProbSS2T_Fast(cc,ii) = sum(SS2tgtFast & idxII_Fast) / sum(idxII_Fast);
    end
    
  end%for:zscore-bin(ii)
  
end%for:neuron(cc)


%% Plotting
muProbAcc = nanmean(ProbSS2T_Acc);
muProbFast = nanmean(ProbSS2T_Fast);

nAcc = sum(~isnan(ProbSS2T_Acc), 1);    seProbAcc = nanstd(ProbSS2T_Acc) ./ sqrt(nAcc);
nFast = sum(~isnan(ProbSS2T_Acc), 1);   seProbFast = nanstd(ProbSS2T_Fast) ./ sqrt(nFast);

figure(); hold on
errorbar(ZPLOT, muProbAcc, seProbAcc, 'r', 'LineWidth',1.25, 'CapSize',0)
errorbar(ZPLOT, muProbFast, seProbFast, 'Color',[0 .7 0], 'LineWidth',1.25, 'CapSize',0)
xlabel('Error signal (z)')
ylabel('Prob. corrective saccade')
ppretty([4.8,3])

%% Stats
ProbAcc = reshape(ProbSS2T_Acc', NUM_CELLS*NBIN,1);
ProbFast = reshape(ProbSS2T_Fast', NUM_CELLS*NBIN,1);
DV_Prob = [ProbAcc ; ProbFast];
Condition = [ ones(NUM_CELLS*NBIN,1) ; 2*ones(NUM_CELLS*NBIN,1) ];
Signal = (-2 : 2); Signal = repmat(Signal, 1,2*NUM_CELLS)';
Neuron = [];
for cc = 1:NUM_CELLS
  Neuron = cat(1, Neuron, cc*ones(5,1));
end
Neuron = [Neuron; Neuron];

outStruct = struct('Neuron',Neuron, 'DV_Prob',DV_Prob, 'Condition',Condition, 'Signal',Signal);
save([ROOTDIR_STAT, 'SEF-ErrSigXBehav.mat'], 'outStruct')

end%fxn:plotProbCorr_X_ChcErrActivity()

