function [ ] = Fig2_plot_SpkCt_X_Trial( behavData , unitData , varargin )
%Fig2_plot_SpkCt_X_Trial Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'interval=',[-600 50]}, {'monkey=',{'D','E'}}, ...
  {'area=',{'SEF'}}, {'effect=',[]}});

IDX_TEST = 3500 + args.interval;

TRIAL_TEST = (-4 : +3);
NUM_TRIAL_TEST = length(TRIAL_TEST);
trialSwitch = identify_condition_switch(behavData);

idxArea = ismember(unitData.Area, args.area);
idxMonkey = ismember(unitData.Monkey, args.monkey);
idxVisUnit = (unitData.Grade_Vis >= 3);
idxTest = (idxArea & idxMonkey & idxVisUnit);

if strcmp(args.effect, 'FgA') % Fast > Accurate
  idx_BLEffect = (unitData.SAT_Effect(:,1) == +1); %sig. SAT effect - baseline
  idx_VREffect = (unitData.SAT_Effect(:,2) == +1); %sig. SAT effect - vis resp
  PLOT_COLOR = 'k';
elseif strcmp(args.effect, 'AgF') % Accurate > Fast
  idx_BLEffect = (unitData.SAT_Effect(:,1) == -1);
  idx_VREffect = (unitData.SAT_Effect(:,2) == -1);
  PLOT_COLOR = [0 0 .9];
else % All visually-responsive neurons
  idx_BLEffect = true(size(unitData,1),1);
  idx_VREffect = true(size(unitData,1),1);
end

if (args.interval(1) < 0) %baseline
  idxTest = (idxTest & idx_BLEffect);
  FIG_ID = 1;
else %visual response
  idxTest = (idxTest & idx_VREffect);
  FIG_ID = 2;
end

unitTest = unitData(idxTest,:);
NUM_UNIT = sum(idxTest);
fprintf('\n%s -- SAT Effect %s n = %i/%i\n', args.area{1}, args.effect, NUM_UNIT, ...
  sum(idxArea & idxMonkey & idxVisUnit))

%initialize spike count
sc_A2F = NaN(NUM_UNIT,NUM_TRIAL_TEST);
sc_F2A = sc_A2F;

for uu = 1:NUM_UNIT
  kk = ismember(behavData.Task_Session, unitTest.Session(uu));
  
  %compute spike count for all trials
  spikes_uu = load_spikes_SAT(unitTest.Index(uu));
  spkCt_uu = cellfun(@(x) sum((x > IDX_TEST(1)) & (x < IDX_TEST(2))), spikes_uu);
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitTest.TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  
  %compute z-scored spike count
  spkCt_uu(~idxIso) = zscore(spkCt_uu(~idxIso));
  
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);    trialAcc = find(idxAcc);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);   trialFast = find(idxFast);
  
  %split by task condition
  scAcc_uu = spkCt_uu(idxAcc);
  scFast_uu = spkCt_uu(idxFast);
  
  %index by trial number
  for jj = 1:NUM_TRIAL_TEST
    if (TRIAL_TEST(jj) < 0) %Before condition switch
      %get all trials at this index
      idxJJ_A2F = ismember(trialAcc, trialSwitch.A2F{kk} + TRIAL_TEST(jj));
      idxJJ_F2A = ismember(trialFast, trialSwitch.F2A{kk} + TRIAL_TEST(jj));
      %compute mean spike count for this trial
      sc_A2F(uu,jj) = mean(scAcc_uu(idxJJ_A2F));
      sc_F2A(uu,jj) = mean(scFast_uu(idxJJ_F2A));
    else %After condition switch
      idxJJ_A2F = ismember(trialFast, trialSwitch.A2F{kk} + TRIAL_TEST(jj));
      idxJJ_F2A = ismember(trialAcc, trialSwitch.F2A{kk} + TRIAL_TEST(jj));
      sc_A2F(uu,jj) = mean(scFast_uu(idxJJ_A2F));
      sc_F2A(uu,jj) = mean(scAcc_uu(idxJJ_F2A));
    end
  end % for : trial (jj)
  
end % for : unit (uu)


%% Plotting
YLIM = [-0.5 0.5];
mu_A2F = mean(sc_A2F);    se_A2F = std(sc_A2F) / sqrt(NUM_UNIT);
mu_F2A = mean(sc_F2A);    se_F2A = std(sc_F2A) / sqrt(NUM_UNIT);

figure(FIG_ID)

subplot(1,2,1); hold on
plot([-3 2], [0 0], 'k:')
% plot(TRIAL_TEST, sc_A2F)
errorbar(TRIAL_TEST, mu_A2F, se_A2F, 'capsize',0, 'Color',PLOT_COLOR)
xticks(-4:3); xticklabels({}); ylabel('Spike count (z)'); ytickformat('%2.1f')
xlim([-4.5 3.5]); set(gca, 'XMinorTick','off'); ylim(YLIM)

subplot(1,2,2); hold on
plot([-3 2], [0 0], 'k:')
% plot(TRIAL_TEST, sc_F2A)
errorbar(TRIAL_TEST, mu_F2A, se_F2A, 'capsize',0, 'Color',PLOT_COLOR)
xticks(-4:3); xticklabels({}); yticks([])
xlim([-4.5 3.5]); set(gca, 'XMinorTick','off'); ylim(YLIM)

ppretty([2.4,1.0]);
drawnow

%% Stats - Single-trial modulation at cued condition switch
tmp_A2F = [mean(sc_A2F(:,[3,4]),2) , mean(sc_A2F(:,[5,6]),2)];
tmp_F2A = [mean(sc_F2A(:,[3,4]),2) , mean(sc_F2A(:,[5,6]),2)];
diffA2F =  diff(tmp_A2F, 1, 2);
diffF2A = -diff(tmp_F2A, 1, 2);
ttestFull(diffA2F, diffF2A, 'ylabel','Single-trial modulation', 'xticklabels',{'A2F','F2A'})


end%fxn:plotSpkCount_X_Trial_ReStim_SAT()
