function [ ] = plotProbCorr_X_ChcErrActivity( binfo , movesPP , ninfo , nstats , spikes )
%plotProbCorr_X_ChcErrActivity Summary of this function goes here
%   Detailed explanation goes here

idxSEF = ismember({ninfo.area}, 'SEF');
idxMonkey = ismember({ninfo.monkey}, {'D','E'});
idxErr = ([ninfo.errGrade] >= 2);
idxKeep = (idxSEF & idxMonkey & idxErr);

NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
nstats = nstats(idxKeep);
spikes = spikes(idxKeep);

T_COUNT_BASE = [-50, 50] + 3500; %interval over which to count baseline spikes as control
T_COUNT_ERR = [0, 200] + 3500; %interval (re. signal onset) over which to count spikes
MAX_ERR_TIME = 25; %maximum timing error for trials allowed

%bin trials by error signal (z-score)
MIN_PER_BIN = 5; %mininum number of trials
BINLIM_Z = (-2.5 : 1.0 : 2.5); NBIN = length(BINLIM_Z) - 1;
ZPLOT = BINLIM_Z(1:NBIN) + diff(BINLIM_Z)/2;

%initializations
PTarget = NaN(NUM_CELLS, NBIN);
RespTime = NaN(NUM_CELLS, NBIN); %save RT as control

for cc = 1:NUM_CELLS
%   fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  kk = ismember({binfo.session}, ninfo(cc).sess);
  rtKK = double(binfo(kk).resptime);
  errKK = rtKK - double(binfo(kk).deadline);
  ssEndKK = movesPP(kk).endpt; %second saccade endpoint
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials, 'task','SAT');
  %index by task condition
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  %index by trial outcome
  idxErrDir = ( binfo(kk).err_dir );
  %index by timing error magnitude
  idxErrTime = ( (idxAcc & (errKK < -MAX_ERR_TIME)) | (idxFast & (errKK > MAX_ERR_TIME)) );
  
  trialErr = find(idxErrDir & (idxAcc | idxFast) & ~idxErrTime & ~idxIso);
  numTrial = length(trialErr);
  
  %save RT as a control
  rtErr = rtKK(trialErr);
  
  %second saccade endpoint as binary (Target = TRUE, Other = FALSE)
  ssEndErr = false(1,numTrial);
  ssEndErr(ssEndKK(trialErr) == 1) = true;
  
  %% Compute single-trial spike counts
  
  %compute baseline spike count to control for effect of Trial Number
  spkBase = cellfun(@(x) sum((x > T_COUNT_BASE(1)) & (x < T_COUNT_BASE(2))), spikes(cc).SAT);
  spkBase = spkBase(trialErr);
  
  %get error interval for each task condition
  tErrCC = nstats(cc).A_ChcErr_tErr_Fast + T_COUNT_ERR;
  tErrCC = rtKK(trialErr)'*ones(1,2) + tErrCC;
  
  spkErr = NaN(1,numTrial);
  for jj = 1:numTrial
    %spike times aligned on primary saccade
    tSpkJJ = spikes(cc).SAT{trialErr(jj)};
    %compute number of spikes during Accurate error interval
    spkErr(jj) = sum( (tSpkJJ >= tErrCC(jj,1)) & (tSpkJJ <= tErrCC(jj,2)) );
  end%for:trialsAcc(jj)
  
  %COMPUTE BASELINE CORRECTION
  spkErr = spkErr - spkBase;
  
  %compute z-score spike count
  spkErr = (spkErr - mean(spkErr)) / std(spkErr);
  
  %% Bin trials by spike count
  for bb = 1:NBIN
    idxBB = ( spkErr > BINLIM_Z(bb) & spkErr <= BINLIM_Z(bb+1) );
    
    if (sum(idxBB) >= MIN_PER_BIN)
      PTarget(cc,bb) = sum(ssEndErr & idxBB) / sum(idxBB);
      RespTime(cc,bb) = median(rtErr(idxBB));
    end
  end%for:zscore-bin(bb)
  
end%for:neuron(cc)

%% Plotting
%probability of corrective saccade
nCellXbin = sum(~isnan(PTarget), 1);
seProb = nanstd(PTarget) ./ sqrt(nCellXbin);
muProb = nanmean(PTarget);

figure(); hold on
% plot(ZPLOT, PTarget, 'Color',[.4 .4 .4], 'LineWidth',0.75)
errorbar(ZPLOT, muProb, seProb, 'Color','k', 'LineWidth',1.25, 'CapSize',0)
xlabel('Error signal magnitude (z)'); xlim([-2.1 2.1]); xticks(-2:2)
ylabel('P (Saccade to target)'); ytickformat('%3.2f')
ppretty([4.8,3])

%% Stats
DV_Prob = reshape(PTarget', NUM_CELLS*NBIN,1);
F_Signal = ZPLOT; F_Signal = repmat(F_Signal, 1,NUM_CELLS)';

anovan(DV_Prob, {F_Signal});

%save for ANOVA in R
% save('C:\Users\Thomas Reppert\Dropbox\SAT\Stats\PTgtXSignalErr.mat', 'DV_Prob','F_Signal')

end%fxn:plotProbCorr_X_ChcErrActivity()

