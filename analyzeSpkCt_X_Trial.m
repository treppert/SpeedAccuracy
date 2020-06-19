function [ singleTrialMod ] = analyzeSpkCt_X_Trial( behavInfo , unitInfo , unitStats , spikes )
%analyzeSpkCt_X_Trial Summary of this function goes here
%   Detailed explanation goes here
%   Output "singleTrialMod" is the single-trial modulation at the time of
%   condition switch. This output is for comparison across SEF, FEF, & SC.
% 

AREA = 'FEF';
MONKEY = {'D','E'};
INTERVAL = 'post'; %either 'pre' = baseline or 'post' = visual response

idxArea = ismember(unitInfo.area, {AREA});
idxMonkey = ismember(unitInfo.monkey, MONKEY);
idxVisUnit = (unitInfo.visGrade >= 2);
idxMoveUnit = (unitInfo.moveGrade >= 2);

if strcmp(INTERVAL, 'pre')
  idxSATEffect = (unitStats.Baseline_SAT_Effect == 1);
  unitTest = (idxArea & idxMonkey & (idxVisUnit | idxMoveUnit) & idxSATEffect);
  T_TEST = 3500 + [-600 +20]; %interval over which to count spikes
elseif strcmp(INTERVAL, 'post')
  idxSATEffect = (unitStats.VisualResponse_SAT_Effect == 1);
  unitTest = (idxArea & idxMonkey & idxVisUnit & idxSATEffect);
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

TRIAL_TEST = (-4 : +3);
NUM_TRIAL_TEST = length(TRIAL_TEST);
trialSwitch = identify_condition_switch(behavInfo);

%initialize spike count
spkCt_A2F = NaN(NUM_CELLS,NUM_TRIAL_TEST);
spkCt_F2A = NaN(NUM_CELLS,NUM_TRIAL_TEST);

for cc = 1:NUM_CELLS
  kk = ismember(behavInfo.session, unitInfo.sess{cc});
  
  %compute spike count for all trials
  sc_CC = cellfun(@(x) sum((x > T_TEST(1)) & (x < T_TEST(2))), spikes{cc});
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitInfo.trRemSAT{cc}, behavInfo.num_trials(kk));
  %index by trial outcome
  idxCorr = ~(behavInfo.err_dir{kk} | behavInfo.err_time{kk} | behavInfo.err_hold{kk} | behavInfo.err_nosacc{kk});
  %index by condition
  idxAcc = ((behavInfo.condition{kk} == 1) & idxCorr & ~idxIso);    trialAcc = find(idxAcc);
  idxFast = ((behavInfo.condition{kk} == 3) & idxCorr & ~idxIso);   trialFast = find(idxFast);
  
  %split by task condition
  scAcc_cc = sc_CC(idxAcc);
  scFast_cc = sc_CC(idxFast);
  
  %compute z-scored spike count
  muSpkCt = mean([scAcc_cc scFast_cc]);
  sdSpkCt = std([scAcc_cc scFast_cc]);
  scAcc_cc = (scAcc_cc - muSpkCt) / sdSpkCt;
  scFast_cc = (scFast_cc - muSpkCt) / sdSpkCt;
  
  %index by trial number
  for jj = 1:NUM_TRIAL_TEST
    if (TRIAL_TEST(jj) < 0) %Before condition switch
      %get all trials at this index
      idxJJ_A2F = ismember(trialAcc, trialSwitch.A2F{kk} + TRIAL_TEST(jj));
      idxJJ_F2A = ismember(trialFast, trialSwitch.F2A{kk} + TRIAL_TEST(jj));
      %compute mean spike count for this trial
      spkCt_A2F(cc,jj) = mean(scAcc_cc(idxJJ_A2F));
      spkCt_F2A(cc,jj) = mean(scFast_cc(idxJJ_F2A));
    else %After condition switch
      idxJJ_A2F = ismember(trialFast, trialSwitch.A2F{kk} + TRIAL_TEST(jj));
      idxJJ_F2A = ismember(trialAcc, trialSwitch.F2A{kk} + TRIAL_TEST(jj));
      spkCt_A2F(cc,jj) = mean(scFast_cc(idxJJ_A2F));
      spkCt_F2A(cc,jj) = mean(scAcc_cc(idxJJ_F2A));
    end
  end % for : trial (jj)
  
end % for : cell (cc)


%% Plotting
mu_A2F = nanmean(spkCt_A2F);    se_A2F = nanstd(spkCt_A2F) / sqrt(NUM_CELLS);
mu_F2A = nanmean(spkCt_F2A);    se_F2A = nanstd(spkCt_F2A) / sqrt(NUM_CELLS);

figure()

subplot(1,2,1); hold on
plot([-3 2], [0 0], 'k:')
% plot(TRIAL_TEST, scA2F_All)
errorbar(TRIAL_TEST, mu_A2F, se_A2F, 'capsize',0, 'Color','k')
xticks(-3:2); xticklabels({}); ylabel('Spike count (z)'); ytickformat('%2.1f')

subplot(1,2,2); hold on
plot([-3 2], [0 0], 'k:')
% plot(TRIAL_TEST, scF2A_All)
errorbar(TRIAL_TEST, mu_F2A, se_F2A, 'capsize',0, 'Color','k')
xticks(-3:2); xticklabels({}); yticks([]); ytickformat('%2.1f')

ppretty([4.8,2.2], 'XMinorTick','off'); 


%% Stats - Single-trial modulation at cued condition switch
singleTrialMod_A2F =  diff(spkCt_A2F(:,[4,5]),1,2);
singleTrialMod_F2A = -diff(spkCt_F2A(:,[4,5]),1,2); %negative for comparison
ttestTom( singleTrialMod_A2F , singleTrialMod_F2A , 'paired' )
fprintf('A2F: %3.2f +- %3.2f\n', mean(singleTrialMod_A2F), std(singleTrialMod_A2F)/sqrt(NUM_CELLS))
fprintf('F2A: %3.2f +- %3.2f\n', mean(singleTrialMod_F2A), std(singleTrialMod_F2A)/sqrt(NUM_CELLS))

%output for comparison across areas
singleTrialMod = abs([singleTrialMod_A2F; singleTrialMod_F2A]);

end % fxn : analyzeSpkCt_X_Trial()
