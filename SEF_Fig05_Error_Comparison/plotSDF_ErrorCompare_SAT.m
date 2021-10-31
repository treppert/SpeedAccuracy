function [ ] = plotSDF_ErrorCompare_SAT( behavData , moves , unitData , unitData , spikes , varargin )
%plotSDF_ErrorCompare_SAT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember(unitData.aArea, args.area);
idxMonkey = ismember(unitData.aMonkey, args.monkey);

idxErr = (unitData.Basic_ErrGrade >= 2);
idxRew = (abs(unitData.Basic_RewGrade) >= 2 & ~isnan([unitData.TimingErrorSignal_Time(2)]));

idxKeep = (idxArea & idxMonkey & (idxErr | idxRew));

NUM_CELLS = sum(idxKeep);
unitData = unitData(idxKeep);
spikes = spikes(idxKeep);

tplotResp = (-200 : 450);   offsetResp = 200;
tplotRew  = (-50 : 600);    offsetRew = 50;

%initialization -- contrast ratio (A_err - A_corr) / (A_err + A_corr)
CRacc = NaN(1,NUM_CELLS);   tEstAcc = (100 : 500) + offsetRew;
CRfast = NaN(1,NUM_CELLS);  tEstFast = (100 : 300) + offsetResp;

for uu = 1:NUM_CELLS
  fprintf('%s - %s\n', unitData.Task_Session(uu), unitData.aID{uu})
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  
  rtKK = double(moves(kk).resptime);
  trewKK = double(behavData.Task_TimeReward{kk} + behavData.Sacc_RT{kk});
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData(uu,:), behavData.Task_NumTrials{kk});
  %index by condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1 & ~idxIso & ~isnan(trewKK));
  idxFast = (behavData.Task_SATCondition{kk} == 3 & ~idxIso & ~isnan(trewKK));
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  idxErrChc = (behavData.Task_ErrChoice{kk} & ~behavData.Task_ErrTime{kk});
  idxErrTime = (~behavData.Task_ErrChoice{kk} & behavData.Task_ErrTime{kk});
  %index by screen clear on Fast trials
  idxClear = logical(behavData.Task_ClearDisplayFast{kk});
  
  %compute single-trial SDF
  sdfStim = compute_spike_density_fxn(spikes(uu).SAT);
  sdfResp = align_signal_on_response(sdfStim, rtKK);
  sdfRew  = align_signal_on_response(sdfStim, trewKK);
  
  %split SDF into groups and compute mean
  sdfFastCorr = nanmean(sdfResp(idxFast & idxCorr, tplotResp + 3500));
  sdfFastErr = nanmean(sdfResp(idxFast & idxErrChc & ~idxClear, tplotResp + 3500));
  sdfAccCorr = nanmean(sdfRew(idxAcc & idxCorr, tplotRew + 3500));
  sdfAccErr  = nanmean(sdfRew(idxAcc & idxErrTime, tplotRew + 3500));
  
  %compute contrast ratio
  muAccCorr = mean(sdfAccCorr(tEstAcc));      muAccErr = mean(sdfAccErr(tEstAcc));
  muFastCorr = mean(sdfFastCorr(tEstFast));   muFastErr = mean(sdfFastErr(tEstFast));
  
  CRacc(uu) = (muAccErr - muAccCorr) / (muAccErr + muAccCorr);
  CRfast(uu) = (muFastErr - muFastCorr) / (muFastErr + muFastCorr);
  
end%for:cells(uu)

%% Plotting - Contrast ratio

figure(); hold on
scatter(CRfast, CRacc, 30, 'r', 'filled')
xlabel('Contrast ratio - Choice error')
ylabel('Contrast ratio - Timing error')
ppretty([4.8,3])

end%fxn:plotSDF_ErrorCompare_SAT()
