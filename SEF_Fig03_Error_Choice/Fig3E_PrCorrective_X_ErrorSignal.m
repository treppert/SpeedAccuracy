% function [ ] = Fig3E_PrCorrective_X_ErrorSignal( behavData , unitData , spikesSAT )
%Fig3E_PrCorrective_X_ErrorSignal Summary of this function goes here
%   Detailed explanation goes here

idxSEF = ismember(unitData.aArea, 'SEF');
idxMonkey = ismember(unitData.aMonkey, {'D','E'});
idxErrUnit = ismember(unitData.Grade_Err, 1);
idxKeep = (idxSEF & idxMonkey & idxErrUnit);

unitTest = unitData(idxKeep,:);
spikesTest = spikesSAT(idxKeep);
NUM_UNIT = sum(idxKeep);

T_COUNT_BASE = [-250, 50] + 3500; %interval over which to count baseline spikes as control
T_COUNT_ERR = [50, 350] + 3500; %interval (re. signal onset) over which to count spikes

%bin trials by error signal (z-score)
MIN_PER_BIN = 20; %mininum number of trials
BINLIM_Z = [-3, -1.5 -0.5 0.5 1.5 3];
NUM_BIN = length(BINLIM_Z) - 1;
Z_PLOT = BINLIM_Z(1:NUM_BIN) + diff(BINLIM_Z)/2;

%initializations
P_Tgt = NaN(NUM_UNIT, NUM_BIN);

for uu = 1:NUM_UNIT
  kk = ismember(behavData.Task_Session, unitTest.Task_Session(uu));
  
  RT_kk = behavData.Sacc_RT{kk};
  Sacc2_Endpt_kk = behavData.Sacc2_Endpoint{kk};
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitTest.Task_TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by task condition
%   idxCond = (behavData.Task_SATCondition{kk} == 1); %Accurate
  idxCond = (behavData.Task_SATCondition{kk} == 3); %Fast
  %index by trial outcome
  idxErr = (behavData.Task_ErrChoice{kk} & ~(behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  
  trialErr = find(idxErr & idxCond & ~idxIso);
  num_TrialErr_kk = length(trialErr);
  
  %second saccade endpoint as binary (Target = TRUE, Other = FALSE)
  idx_Sacc2Tgt = false(num_TrialErr_kk,1);
  idx_Sacc2Tgt(Sacc2_Endpt_kk(trialErr) == 1) = true;
  
  %% Compute single-trial spike counts
  
  %compute baseline spike count to control for effect of Trial Number
  spkCt_Base = cellfun(@(x) sum((x > T_COUNT_BASE(1)) & (x < T_COUNT_BASE(2))), spikesTest{uu});
  spkCt_Base = spkCt_Base(trialErr);
  
  %sync choice error interval to start of signal in correct condition
  tErr_uu = RT_kk(trialErr) + unitTest.ErrorSignal_Time(uu,1) + T_COUNT_ERR; %Fast
%   tErr_uu = RT_kk(trialErr) + unitData.ErrorSignal_Time(cc,3) + T_COUNT_ERR; %Accurate
  
  spkCt_Err = NaN(num_TrialErr_kk,1);
  for jj = 1:num_TrialErr_kk
    %spike times aligned on primary saccade
    tSpkJJ = spikesTest{uu}{trialErr(jj)};
    %compute number of spikes during error interval
    spkCt_Err(jj) = sum( (tSpkJJ >= tErr_uu(jj,1)) & (tSpkJJ <= tErr_uu(jj,2)) );
  end%for:trialsAcc(jj)
  
  %compute baseline correction and z-score
  spkCt_Err = zscore(spkCt_Err - spkCt_Base);
  
  %% Bin trials by spike count
  for bb = 1:NUM_BIN
    idx_Bin = ( spkCt_Err > BINLIM_Z(bb) & spkCt_Err < BINLIM_Z(bb+1) );
    
    if (sum(idx_Bin) >= MIN_PER_BIN)
      P_Tgt(uu,bb) = sum(idx_Sacc2Tgt & idx_Bin) / sum(idx_Bin);
    end
  end % for : zscore-bin(bb)
  
end % for : unit(uu)

%% Plotting
%probability of corrective saccade
num_Unit_X_bin = sum(~isnan(P_Tgt), 1);
seProb = nanstd(P_Tgt) ./ sqrt(num_Unit_X_bin);
muProb = nanmean(P_Tgt);

figure(); hold on
% plot(Z_PLOT, P_Tgt, 'Color',[.4 .4 .4], 'LineWidth',0.75)
errorbar(Z_PLOT, muProb, seProb, 'Color','k', 'LineWidth',1.25, 'CapSize',0)
xlabel('Error signal magnitude (z)'); %xlim([-2.1 2.1]); xticks(-2:2)
ylabel('P (Saccade to target)'); ytickformat('%3.2f'); ylim([.6 .9])
ppretty([3.2,2])

%% Stats
% DV_Prob = reshape(PTarget', NUM_CELLS*NBIN,1);
% F_Signal = ZPLOT; F_Signal = repmat(F_Signal, 1,NUM_CELLS)';
% anovan(DV_Prob, {F_Signal});

%save for ANOVA in R
% save('C:\Users\Thomas Reppert\Dropbox\SAT\Stats\PTgtXSignalErr.mat', 'DV_Prob','F_Signal')

clearvars -except behavData spikesSAT unitData
% end%fxn:Fig3E_PrCorrective_X_ErrorSignal()

