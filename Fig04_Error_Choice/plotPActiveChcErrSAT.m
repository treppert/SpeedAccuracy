function [ ] = plotPActiveChcErrSAT( unitData , unitData , behavData , moves , movesPP )
%plotPActiveChcErrSAT Summary of this function goes here
%   Detailed explanation goes here

idxSEF = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});

idxError = (unitData.Basic_ErrGrade >= 2);
idxEfficient = ismember(unitData.Task_LevelDifficulty, [1,2]);

idxKeep = (idxSEF & idxMonkey & idxError & idxEfficient);

NUM_CELLS = sum(idxKeep);
unitData = unitData(idxKeep);

T_RE_SACCADE = (-350 : 250);  OFFSET = 350;
NUM_SAMP = length(T_RE_SACCADE);

%initializations
PActiveAcc = false(NUM_CELLS,NUM_SAMP);
PActiveFast = false(NUM_CELLS,NUM_SAMP);

for uu = 1:NUM_CELLS
  %% Time of second saccade
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  
  %index by condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  %index by trial outcome
  idxErr = (behavData.Task_ErrChoice{kk} & ~behavData.Task_ErrTime{kk});
  %skip trials with no recorded post-primary saccade
  idxNoPP = (movesPP(kk).resptime == 0);
  
  %get time of second saccade
  tFinP = double(moves(kk).resptime) + double(moves(kk).duration);
  tInitPP = double(movesPP(kk).resptime);
  isiKK = tInitPP - tFinP;
  
  isiAcc = median(isiKK(idxAcc & idxErr & ~idxNoPP));
  isiFast = median(isiKK(idxFast & idxErr & ~idxNoPP));
  
  %% Compute time of error-related modulation relative to second saccade
  tErrStart_Acc = unitData.ChoiceErrorSignal_Time(uu,1) - isiAcc;
  tErrStart_Fast = unitData.ChoiceErrorSignal_Time(uu,2) - isiFast;
  
  tErrEnd_Acc = unitData.ChoiceErrorSignal_Time(uu,3) - isiAcc;
  tErrEnd_Fast = unitData.ChoiceErrorSignal_Time(uu,4) - isiFast;
  
  PActiveAcc(cc,(tErrStart_Acc : tErrEnd_Acc) + OFFSET) = true;
  PActiveFast(cc,(tErrStart_Fast : tErrEnd_Fast) + OFFSET) = true;
  
end%for:cells(uu)

PActiveAcc = sum(PActiveAcc,1) / NUM_CELLS;
PActiveFast = sum(PActiveFast,1) / NUM_CELLS;

%% Plotting
tCDFAcc = sort([unitData.ChoiceErrorSignal_Time(1)]);
tCDFFast = sort([unitData.ChoiceErrorSignal_Time(2)]);

figure(); hold on
plot([0 0], [0 1], 'k:', 'LineWidth',1.25)
% plot(median(tCDFAcc)*ones(1,2), [0 .4], 'r:', 'LineWidth',1.5)
% plot(median(tCDFFast)*ones(1,2), [0 .4], ':', 'Color',[0 .7 0], 'LineWidth',1.5)
plot(T_RE_SACCADE, PActiveFast, '-', 'Color',[0 .7 0], 'LineWidth',1.5)
plot(T_RE_SACCADE, PActiveAcc, 'r-', 'LineWidth',1.5)
% xlim([-100 400])
% xlabel('Time from primary saccade (ms)')
xlabel('Time from second saccade (ms)')
ylabel('P (active)')
ytickformat('%2.1f')

ppretty([6,2.5])

end%fxn:plotPActiveChcErrSAT()

