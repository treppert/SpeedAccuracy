function [ ] = Fig3E_PrCorrective_X_ErrorSignal( behavData , unitData , spikesSAT )
%Fig3E_PrCorrective_X_ErrorSignal Summary of this function goes here
%   Detailed explanation goes here

idxSEF = ismember(unitData.aArea, 'SEF');
idxMonkey = ismember(unitData.aMonkey, {'D','E'});
idxErrUnit = (idxSEF & idxMonkey & (unitData.Basic_ErrGrade >= 2));

NUM_CELLS = sum(idxErrUnit);
unitData = unitData(idxErrUnit,:);
spikesSAT = spikesSAT(idxErrUnit);

T_COUNT_BASE = [-50, 50] + 3500; %interval over which to count baseline spikes as control
T_COUNT_ERR = [0, 200] + 3500; %interval (re. signal onset) over which to count spikes
MAX_ERR_TIME = 10; %maximum timing error for trials allowed

%bin trials by error signal (z-score)
MIN_PER_BIN = 5; %mininum number of trials
BINLIM_Z = (-2.5 : 1.0 : 2.5); NBIN = length(BINLIM_Z) - 1;
ZPLOT = BINLIM_Z(1:NBIN) + diff(BINLIM_Z)/2;

%initializations
PTarget = NaN(NUM_CELLS, NBIN);
RespTime = NaN(NUM_CELLS, NBIN); %save RT as control

for cc = 1:NUM_CELLS
%   fprintf('%s - %s\n', unitData.Task_Session(uu), unitData.aID{uu})
  kk = ismember(behavData.Task_Session, unitData.Task_Session(cc));
  
  RT_kk = double(behavData.Sacc_RT{kk});
  RTerr_kk = RT_kk - double(behavData.Task_Deadline{kk});
  ssEndptKK = behavData.Sacc2_Endpoint{kk};
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData.Task_TrialRemoveSAT{cc}, behavData.Task_NumTrials(kk));
  %index by task condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  %index by trial outcome
  idxErrDir = ( behavData.Task_ErrChoice{kk} );
  %index by timing error magnitude
  idxErrTime = ( (idxAcc & (RTerr_kk < -MAX_ERR_TIME)) | (idxFast & (RTerr_kk > MAX_ERR_TIME)) );
  
  trialErr = find(idxErrDir & (idxAcc | idxFast) & ~idxErrTime & ~idxIso);
  numTrial = length(trialErr);
  
  %save RT as a control
  rtErr = RT_kk(trialErr);
  
  %second saccade endpoint as binary (Target = TRUE, Other = FALSE)
  ssEndErr = false(1,numTrial);
  ssEndErr(ssEndptKK(trialErr) == 1) = true;
  
  %% Compute single-trial spike counts
  
  %compute baseline spike count to control for effect of Trial Number
  spkBase = cellfun(@(x) sum((x > T_COUNT_BASE(1)) & (x < T_COUNT_BASE(2))), spikesSAT{cc});
  spkBase = spkBase(trialErr);
  
  %sync choice error interval to start of signal in Fast condition
  tErrCC = unitData.ChoiceErrorSignal_Time(cc,3) + T_COUNT_ERR;
  tErrCC = RT_kk(trialErr)'*ones(1,2) + tErrCC;
  
  spkErr = NaN(1,numTrial);
  for jj = 1:numTrial
    %spike times aligned on primary saccade
    tSpkJJ = spikesSAT{cc}{trialErr(jj)};
    %compute number of spikes during error interval
    spkErr(jj) = sum( (tSpkJJ >= tErrCC(jj,1)) & (tSpkJJ <= tErrCC(jj,2)) );
  end%for:trialsAcc(jj)
  
  %compute baseline correction and z-score
  spkErr = zscore(spkErr - spkBase);
  
  %% Bin trials by spike count
  for bb = 1:NBIN
    idxBB = ( spkErr > BINLIM_Z(bb) & spkErr <= BINLIM_Z(bb+1) );
    
    if (sum(idxBB) >= MIN_PER_BIN)
      PTarget(cc,bb) = sum(ssEndErr & idxBB) / sum(idxBB);
      RespTime(cc,bb) = median(rtErr(idxBB));
    end
  end%for:zscore-bin(bb)
  
end%for:cell(cc)

%% Plotting
%probability of corrective saccade
nCellXbin = sum(~isnan(PTarget), 1);
seProb = nanstd(PTarget) ./ sqrt(nCellXbin);
muProb = nanmean(PTarget);

figure(); hold on
% plot(ZPLOT, PTarget, 'Color',[.4 .4 .4], 'LineWidth',0.75)
errorbar(ZPLOT, muProb, seProb, 'Color','k', 'LineWidth',1.25, 'CapSize',0)
xlabel('Error signal magnitude (z)'); xlim([-2.1 2.1]); xticks(-2:2)
ylabel('P (Saccade to target)'); ytickformat('%3.2f'); ylim([.6 .9])
ppretty([4.8,3])

%% Stats
DV_Prob = reshape(PTarget', NUM_CELLS*NBIN,1);
F_Signal = ZPLOT; F_Signal = repmat(F_Signal, 1,NUM_CELLS)';
anovan(DV_Prob, {F_Signal});

%save for ANOVA in R
% save('C:\Users\Thomas Reppert\Dropbox\SAT\Stats\PTgtXSignalErr.mat', 'DV_Prob','F_Signal')

end%fxn:Fig3E_PrCorrective_X_ErrorSignal()

