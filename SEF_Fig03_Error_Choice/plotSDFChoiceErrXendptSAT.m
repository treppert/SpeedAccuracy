function [ varargout ] = plotSDFChoiceErrXendptSAT( behavData , moves , movesPP , unitData , unitData , spikes , varargin )
%plotSDFChoiceErrXendptSAT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});
ROOTDIR = 'C:\Users\Thomas Reppert\Dropbox\SAT\Figs-ChcErr-SEF\SDF-Final\';

idxArea = ismember(unitData.aArea, args.area);
idxMonkey = ismember(unitData.aMonkey, args.monkey);

idxError = (abs(unitData.Basic_ErrGrade) >= 2);
idxEfficiency = ismember(unitData.Task_LevelDifficulty, [1,2]);

idxKeep = (idxArea & idxMonkey & idxError & idxEfficiency);

unitData = unitData(idxKeep);
spikes = spikes(idxKeep);
NUM_CELLS = length(spikes);

tVec.Primary = 3500 + (-100 : 150); OFFSET = 200; %time from primary saccade
tVec.Secondary = 3500 + (-150 : 100); %time from secondary saccade

%output initializations
sdfAcc = new_struct({'Primary','Secondary'}, 'dim',[1,NUM_CELLS]);
sdfAcc = struct('Corr',sdfAcc, 'ErrT',sdfAcc, 'ErrD',sdfAcc);
sdfFast = sdfAcc;

effectSecondary = new_struct({'AccPrimary','AccSecondary','FastPrimary','FastSecondary'}, 'dim',[1,NUM_CELLS]);
effectSecondary = populate_struct(effectSecondary, {'AccPrimary','AccSecondary','FastPrimary','FastSecondary'}, 0);

for uu = 1:NUM_CELLS
  fprintf('%s - %s\n', unitData.Task_Session(uu), unitData.aID{uu})
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  
  RTkk = double(moves(kk).resptime);
  ISIkk = double(movesPP(kk).resptime) - RTkk;
  ISIkk(ISIkk < 0) = NaN; %trials with no secondary saccade
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData(uu,:), behavData.Task_NumTrials{kk}, 'task','SAT');
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  idxErr = (behavData.Task_ErrChoice{kk} & ~behavData.Task_ErrTime{kk});
  
  %set "ISI" on correct trials as median ISI of choice error trials
  ISIkk(idxFast & idxCorr) = round(nanmedian(ISIkk(idxFast & idxErr)));
  ISIkk(idxAcc & idxCorr) = round(nanmedian(ISIkk(idxAcc & idxErr)));
  
  %perform RT matching and group trials by condition and outcome
  trials = groupTrialsRTmatched(RTkk, idxAcc, idxFast, idxCorr, idxErr);
  
  %**** index by secondary saccade endpoint ****
  idxTarg = find(movesPP(kk).endpt == 1); %secondary to Target
  idxDistr = find(movesPP(kk).endpt == 2); %secondary to Distractor/Fixation
  
  trials.FastErrT = intersect(trials.FastErr, idxTarg);   trials.AccErrT = intersect(trials.AccErr, idxTarg);
  trials.FastErrD = intersect(trials.FastErr, idxDistr);  trials.AccErrD = intersect(trials.AccErr, idxDistr);
  trials = rmfield(trials, {'AccErr','FastErr'});
  
  %test for different discharge rates for Corrective vs. Non-Corrective
%   effectSecondary(uu) = testSecondaryEndpoint( spikes(uu).SAT , trials , RTkk , ISIkk );
  
  %get single-trials SDFs
  [sdfAccST, sdfFastST] = getSingleTrialSDF(RTkk, ISIkk, spikes(uu).SAT, trials, tVec);
  
  %compute mean SDFs
  [sdfFast.Corr(uu), sdfFast.ErrT(uu), sdfFast.ErrD(uu)] = computeMeanSDF( sdfFastST );
  [sdfAcc.Corr(uu), sdfAcc.ErrT(uu), sdfAcc.ErrD(uu)] = computeMeanSDF( sdfAccST );
  sdfCombined = struct('FastCorr',sdfFast.Corr(uu), 'FastErrT',sdfFast.ErrT(uu), 'FastErrD',sdfFast.ErrD(uu), ...
    'AccCorr',sdfAcc.Corr(uu), 'AccErrT',sdfAcc.ErrT(uu), 'AccErrD',sdfAcc.ErrD(uu));
  
  %% Parameterize the SDF
  uuNS = unitData.aIndex(uu);
  
  %magnitude
%   [magAcc,magFast] = calcMagErrSignal(sdfCombined, OFFSET, unitData(uuNS));
%   unitData(uuNS).A_ChcErr_magErr_Acc = magAcc;
%   unitData(uuNS).A_ChcErr_magErr_Fast = magFast;
  
  %plot individual cell activity
  plotSDFChcErrXendptSATcc(tVec, sdfCombined, unitData(uu,:), unitData(uuNS))
%   print([ROOTDIR, unitData.aArea{uu},'-',unitData.Task_Session(uu),'-',unitData.aID{uu},'.tif'], '-dtiff'); pause(0.1); close()
  
end%for:cells(uu)

if (nargout > 0)
  varargout{1} = unitData;
  if (nargout > 1)
    varargout{2} = effectSecondary;
  end
end

end%fxn:plotSDFChoiceErrXendptSAT()

function [ trialsGrouped ] = groupTrialsRTmatched(RT, idxAcc, idxFast, idxCorr, idxErr)

%Fast condition
trial_FC = find(idxFast & idxCorr);    RT_FC = RT(idxFast & idxCorr);
trial_FE = find(idxFast & idxErr);     RT_FE = RT(idxFast & idxErr);
[OLdist1, OLdist2, ~,~] = DistOverlap_Amir([trial_FC;RT_FC]', [trial_FE;RT_FE]');
trial_FC = OLdist1(:,1);
trial_FE = OLdist2(:,1);

%Accurate condition
trial_AC = find(idxAcc & idxCorr);    RT_AC = RT(idxAcc & idxCorr);
trial_AE = find(idxAcc & idxErr);     RT_AE = RT(idxAcc & idxErr);
[OLdist1, OLdist2, ~,~] = DistOverlap_Amir([trial_AC;RT_AC]', [trial_AE;RT_AE]');
trial_AC = OLdist1(:,1);
trial_AE = OLdist2(:,1);

%output
trialsGrouped = struct('AccCorr',trial_AC, 'AccErr',trial_AE, 'FastCorr',trial_FC, 'FastErr',trial_FE);

end%util:groupTrialsRTmatched()

function [sdfAccST, sdfFastST] = getSingleTrialSDF(RT, ISI, spikes, trials, time)

%compute SDFs and align on primary and secondary saccades
sdfReSTIM = compute_spike_density_fxn(spikes);
sdfRePRIMARY = align_signal_on_response(sdfReSTIM, RT);
sdfReSECONDARY = align_signal_on_response(sdfReSTIM, RT + ISI);

%isolate single-trial SDFs per group - Fast condition
sdfFastST.Corr.Primary = sdfRePRIMARY(trials.FastCorr, time.Primary); %aligned on primary
sdfFastST.ErrT.Primary = sdfRePRIMARY(trials.FastErrT, time.Primary);
sdfFastST.ErrD.Primary = sdfRePRIMARY(trials.FastErrD, time.Primary);
sdfFastST.Corr.Secondary = sdfReSECONDARY(trials.FastCorr, time.Secondary); %aligned on secondary
sdfFastST.ErrT.Secondary = sdfReSECONDARY(trials.FastErrT, time.Secondary);
sdfFastST.ErrD.Secondary = sdfReSECONDARY(trials.FastErrD, time.Secondary);

%isolate single-trial SDFs per group - Accurate condition
sdfAccST.Corr.Primary = sdfRePRIMARY(trials.AccCorr, time.Primary); %aligned on primary
sdfAccST.ErrT.Primary = sdfRePRIMARY(trials.AccErrT, time.Primary);
sdfAccST.ErrD.Primary = sdfRePRIMARY(trials.AccErrD, time.Primary);
sdfAccST.Corr.Secondary = sdfReSECONDARY(trials.AccCorr, time.Secondary); %aligned on secondary
sdfAccST.ErrT.Secondary = sdfReSECONDARY(trials.AccErrT, time.Secondary);
sdfAccST.ErrD.Secondary = sdfReSECONDARY(trials.AccErrD, time.Secondary);

end%util:getSingleTrialSDF()

function [ sdfCorr , sdfErrT , sdfErrD ] = computeMeanSDF( sdfSingleTrial )

sdfCorr.Primary = nanmean(sdfSingleTrial.Corr.Primary)';
sdfCorr.Secondary = nanmean(sdfSingleTrial.Corr.Secondary)';

sdfErrT.Primary = nanmean(sdfSingleTrial.ErrT.Primary)';
sdfErrT.Secondary = nanmean(sdfSingleTrial.ErrT.Secondary)';

sdfErrD.Primary = nanmean(sdfSingleTrial.ErrD.Primary)';
sdfErrD.Secondary = nanmean(sdfSingleTrial.ErrD.Secondary)';

end%util:computeMeanSDF()

function [ effectStruct ] = testSecondaryEndpoint( spikes , trials , RT , ISI)
%This util tests for a difference in discharge rate pre-secondary saccade
%on trials with Corrective (i.e. To Target) vs. Non-Corrective (i.e. to
%Distractor) secondary saccade. The test is Mann-Whitney U test.

T_TEST_PRIMARY = [0 150];
T_TEST_SECONDARY = [-150, 0];

N_ACC_TGT = length(trials.AccErrT);   N_FAST_TGT = length(trials.FastErrT);
N_ACC_DISTR = length(trials.AccErrD); N_FAST_DISTR = length(trials.FastErrD);

%% Accurate condition

spkCtAccT = NaN(1,N_ACC_TGT);   spkCtAccT = struct('RePrimary',spkCtAccT, 'ReSecondary',spkCtAccT);

for jj = 1:N_ACC_TGT
  RTjj = RT(trials.AccErrT(jj));
  ISIjj = ISI(trials.AccErrT(jj));
  spksRePrimary = spikes{trials.AccErrT(jj)} - ( 3500 + RTjj );
  spksReSecondary = spikes{trials.AccErrT(jj)} - ( 3500 + RTjj + ISIjj );
  spkCtAccT.RePrimary(jj) = sum( (spksRePrimary > T_TEST_PRIMARY(1)) & (spksRePrimary < T_TEST_PRIMARY(2)) );
  spkCtAccT.ReSecondary(jj) = sum( (spksReSecondary > T_TEST_SECONDARY(1)) & (spksReSecondary < T_TEST_SECONDARY(2)) );
end

spkCtAccD = NaN(1,N_ACC_DISTR); spkCtAccD = struct('RePrimary',spkCtAccD, 'ReSecondary',spkCtAccD);

for jj = 1:N_ACC_DISTR
  RTjj = RT(trials.AccErrD(jj));
  ISIjj = ISI(trials.AccErrD(jj));
  spksRePrimary = spikes{trials.AccErrD(jj)} - ( 3500 + RTjj );
  spksReSecondary = spikes{trials.AccErrD(jj)} - ( 3500 + RTjj + ISIjj );
  spkCtAccD.RePrimary(jj) = sum( (spksRePrimary > T_TEST_PRIMARY(1)) & (spksRePrimary < T_TEST_PRIMARY(2)) );
  spkCtAccD.ReSecondary(jj) = sum( (spksReSecondary > T_TEST_SECONDARY(1)) & (spksReSecondary < T_TEST_SECONDARY(2)) );
end

%Mann-Whitney U test for the difference between means -- Accurate condition
[pValAccPrimary,~,tmpAccPrimary] = ranksum(spkCtAccT.RePrimary, spkCtAccD.RePrimary);
[pValAccSecondary,~,tmpAccSecondary] = ranksum(spkCtAccT.ReSecondary, spkCtAccD.ReSecondary);

if (pValAccPrimary < 0.055)
  if (tmpAccPrimary.zval > 0) %Tgt > Distr
    effectAccPrimary = 1;
  else %Distr > Tgt
    effectAccPrimary = -1;
  end
else %no effect
  effectAccPrimary = 0;
end

if (pValAccSecondary < 0.055)
  if (tmpAccSecondary.zval > 0) %Tgt > Distr
    effectAccSecondary = 1;
  else %Distr > Tgt
    effectAccSecondary = -1;
  end
else %no effect
  effectAccSecondary = 0;
end

%% Fast condition

spkCtFastT = NaN(1,N_FAST_TGT);   spkCtFastT = struct('RePrimary',spkCtFastT, 'ReSecondary',spkCtFastT);

for jj = 1:N_FAST_TGT
  RTjj = RT(trials.FastErrT(jj));
  ISIjj = ISI(trials.FastErrT(jj));
  spksRePrimary = spikes{trials.FastErrT(jj)} - ( 3500 + RTjj );
  spksReSecondary = spikes{trials.FastErrT(jj)} - ( 3500 + RTjj + ISIjj );
  spkCtFastT.RePrimary(jj) = sum( (spksRePrimary > T_TEST_PRIMARY(1)) & (spksRePrimary < T_TEST_PRIMARY(2)) );
  spkCtFastT.ReSecondary(jj) = sum( (spksReSecondary > T_TEST_SECONDARY(1)) & (spksReSecondary < T_TEST_SECONDARY(2)) );
end

spkCtFastD = NaN(1,N_FAST_DISTR); spkCtFastD = struct('RePrimary',spkCtFastD, 'ReSecondary',spkCtFastD);

for jj = 1:N_FAST_DISTR
  RTjj = RT(trials.FastErrD(jj));
  ISIjj = ISI(trials.FastErrD(jj));
  spksRePrimary = spikes{trials.FastErrD(jj)} - ( 3500 + RTjj );
  spksReSecondary = spikes{trials.FastErrD(jj)} - ( 3500 + RTjj + ISIjj );
  spkCtFastD.RePrimary(jj) = sum( (spksRePrimary > T_TEST_PRIMARY(1)) & (spksRePrimary < T_TEST_PRIMARY(2)) );
  spkCtFastD.ReSecondary(jj) = sum( (spksReSecondary > T_TEST_SECONDARY(1)) & (spksReSecondary < T_TEST_SECONDARY(2)) );
end

%Mann-Whitney U test for the difference between means -- Fasturate condition
[pValFastPrimary,~,tmpFastPrimary] = ranksum(spkCtFastT.RePrimary, spkCtFastD.RePrimary);
[pValFastSecondary,~,tmpFastSecondary] = ranksum(spkCtFastT.ReSecondary, spkCtFastD.ReSecondary);

if (pValFastPrimary < 0.10)
  if (tmpFastPrimary.zval > 0) %Tgt > Distr
    effectFastPrimary = 1;
  else %Distr > Tgt
    effectFastPrimary = -1;
  end
else %no effect
  effectFastPrimary = 0;
end

if (pValFastSecondary < 0.10)
  if (tmpFastSecondary.zval > 0) %Tgt > Distr
    effectFastSecondary = 1;
  else %Distr > Tgt
    effectFastSecondary = -1;
  end
else %no effect
  effectFastSecondary = 0;
end

%% Output

effectStruct = struct('AccPrimary',effectAccPrimary, 'AccSecondary',effectAccSecondary, ...
  'FastPrimary',effectFastPrimary, 'FastSecondary',effectFastSecondary);

end%util:testSecondaryEndpoint()


function [ ] = plotSDFChcErrXendptSATcc( TIME , sdfPlot , unitData , unitData )
%plotSDFChcErrXendptSATcc Summary of this function goes here
%   TIME.Primary - Time from primary saccade (ms)
%   TIME.Secondary - Time from secondary saccade (ms)
%   SDFcc - Struct with fields CorrRe1, ErrRe1, CorrRe2, ErrRe2
% 

%compute y-limits for vertical lines
tmp = [sdfPlot.AccCorr.Primary ; sdfPlot.AccCorr.Secondary ; sdfPlot.AccErrT.Primary ; sdfPlot.AccErrT.Secondary ; ...
  sdfPlot.FastCorr.Primary ; sdfPlot.FastCorr.Secondary ; sdfPlot.FastErrT.Primary ; sdfPlot.FastErrT.Secondary];
yLim = [min(tmp) max(tmp)];

figure()

%% Fast condition

%Time from primary saccade
subplot(2,2,1); hold on
plot([0 0], yLim, 'k:')

plot(TIME.Primary-3500, sdfPlot.FastCorr.Primary, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.Primary-3500, sdfPlot.FastErrT.Primary, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.Primary-3500, sdfPlot.FastErrD.Primary, ':', 'Color',[0 .3 0], 'LineWidth',1.0)

plot(unitData.ChoiceErrorSignal_Time(2)*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(unitData.ChoiceErrorSignal_Time(4)*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0)

xlim([TIME.Primary(1) TIME.Primary(end)]-3500)
ylabel('Activity (sp/sec)')
print_session_unit(gca , unitData,[])


%Time from secondary saccade
subplot(2,2,2); hold on
plot([0 0], yLim, 'k:')

plot(TIME.Secondary-3500, sdfPlot.FastCorr.Secondary, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.Secondary-3500, sdfPlot.FastErrT.Secondary, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
plot(TIME.Secondary-3500, sdfPlot.FastErrD.Secondary, ':', 'Color',[0 .3 0], 'LineWidth',1.0)

xlim([TIME.Secondary(1) TIME.Secondary(end)]-3500)
set(gca, 'YAxisLocation','right')


%% Accurate condition

%Time from primary saccade
subplot(2,2,3); hold on
plot([0 0], yLim, 'k:')

plot(TIME.Primary-3500, sdfPlot.AccCorr.Primary, '-', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.Primary-3500, sdfPlot.AccErrT.Primary, ':', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.Primary-3500, sdfPlot.AccErrD.Primary, ':', 'Color',[.4 0 0], 'LineWidth',1.0)

plot(unitData.ChoiceErrorSignal_Time(1)*ones(1,2), yLim, ':', 'Color',[1 0 0], 'LineWidth',1.0)
plot(unitData.ChoiceErrorSignal_Time(3)*ones(1,2), yLim, ':', 'Color',[1 0 0], 'LineWidth',1.0)

xlim([TIME.Primary(1) TIME.Primary(end)]-3500)
ylabel('Activity (sp/sec)')
xlabel('Time from primary saccade (ms)')


%Time from secondary saccade
subplot(2,2,4); hold on
plot([0 0], yLim, 'k:')

plot(TIME.Secondary-3500, sdfPlot.AccCorr.Secondary, '-', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.Secondary-3500, sdfPlot.AccErrT.Secondary, ':', 'Color',[1 0 0], 'LineWidth',1.0)
plot(TIME.Secondary-3500, sdfPlot.AccErrD.Secondary, ':', 'Color',[.4 0 0], 'LineWidth',1.0)

xlim([TIME.Secondary(1) TIME.Secondary(end)]-3500)
xlabel('Time from secondary saccade (ms)')
set(gca, 'YAxisLocation','right')

ppretty([10,4])

end%util:plotSDFChcErrXendptSATcc()

