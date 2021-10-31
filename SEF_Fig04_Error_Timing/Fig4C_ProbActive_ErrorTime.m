function [ ] = Fig4C_ProbActive_ErrorTime( unitData )
%Fig4C_ProbActive_ErrorTime Summary of this function goes here
%   Detailed explanation goes here

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});

idxRew = ((abs(unitData.Basic_RewGrade) >= 2) & ~isnan(unitData.TimingErrorSignal_Time(:,3)));
% idxRew = (abs(unitData.Basic_RewGrade) >= 2);
idxKeep = (idxArea & idxMonkey & idxRew);

NUM_CELLS = sum(idxKeep);
unitData = unitData(idxKeep,:);

T_VEC = (-100 : 800);  OFFSET = 101;

%initializations
PActiveAcc = false(NUM_CELLS,length(T_VEC));
PActiveFast = false(NUM_CELLS,length(T_VEC));

for cc = 1:NUM_CELLS
  tErrStart_Acc = unitData.TimingErrorSignal_Time(cc,1);
  tErrStart_Fast = unitData.TimingErrorSignal_Time(cc,3);
  
  tErrEnd_Acc = unitData.TimingErrorSignal_Time(cc,2);
  tErrEnd_Fast = unitData.TimingErrorSignal_Time(cc,4);
  
  PActiveAcc(cc,(tErrStart_Acc : tErrEnd_Acc) + OFFSET) = true;
  PActiveFast(cc,(tErrStart_Fast : tErrEnd_Fast) + OFFSET) = true;
end%for:cells-Acc(uu)

PActiveAcc = sum(PActiveAcc,1) / NUM_CELLS;
PActiveFast = sum(PActiveFast,1) / NUM_CELLS;

%% Plotting
tCDFAcc = unitData.TimingErrorSignal_Time(:,1);
tCDFFast = unitData.TimingErrorSignal_Time(:,3);

figure(); hold on
plot([0 0], [0 1], 'k:', 'LineWidth',1.25)
plot(mean(tCDFAcc)*ones(1,2), [0 .4], 'r:', 'LineWidth',1.5)
plot(mean(tCDFFast)*ones(1,2), [0 .4], ':', 'Color',[0 .7 0], 'LineWidth',1.5)
plot(T_VEC, PActiveFast, '-', 'Color',[0 .7 0], 'LineWidth',1.5)
plot(T_VEC, PActiveAcc, 'r-', 'LineWidth',1.5)
xlabel('Time from reward (ms)')
ylabel('P (active)')
ytickformat('%2.1f')
ppretty([5,2.5])

fprintf('Error signal time:\n')
fprintf('Accurate: %5.2f +/- %5.2f\n', mean(tCDFAcc), std(tCDFAcc)/sqrt(NUM_CELLS))
fprintf('Fast: %5.2f +/- %5.2f\n', mean(tCDFFast), std(tCDFFast)/sqrt(NUM_CELLS))

end%fxn:Fig4C_ProbActive_ErrorTime()

