function [ ] = FigS3A_ProbActive_ErrorChoice( unitData )
%FigS3A_ProbActive_ErrorChoice Summary of this function goes here
%   Detailed explanation goes here

idxArea = ismember(unitData.Area, {'SEF'});
idxMonkey = ismember(unitData.Monkey, {'D','E'});

idxErrUnit = ismember(unitData.Grade_Err, [1,-1]);
idxKeep = (idxArea & idxMonkey & idxErrUnit);

NUM_UNIT = sum(idxKeep);
unitData = unitData(idxKeep,:);

T_VEC = (-350 : 400);  OFFSET = 351;

%initializations
PActiveAcc = false(NUM_UNIT, length(T_VEC));
PActiveFast = false(NUM_UNIT, length(T_VEC));

%cells for which we have no estimate of error in Fast condition
idxFast = ~isnan(unitData.ErrorSignal_Time(:,1));
nFast = sum(idxFast);

for uu = 1:NUM_UNIT
  %Fast condition
  if idxFast(uu) %if we have estimate for Fast condition
    tErrStart_Fast = unitData.ErrorSignal_Time(uu,1);
    tErrEnd_Fast = unitData.ErrorSignal_Time(uu,2);
    PActiveFast(uu,(tErrStart_Fast : tErrEnd_Fast) + OFFSET) = true;
  end
  
  %Accurate condition
  tErrStart_Acc = unitData.ErrorSignal_Time(uu,3);
  tErrEnd_Acc = unitData.ErrorSignal_Time(uu,4);
  PActiveAcc(uu,(tErrStart_Acc : tErrEnd_Acc) + OFFSET) = true;
end % for : cells(cc)

PActiveAcc = sum(PActiveAcc,1) / NUM_UNIT;
PActiveFast = sum(PActiveFast,1) / nFast;

%% Plotting
tCDFAcc = unitData.ErrorSignal_Time(:,3);
tCDFFast = unitData.ErrorSignal_Time(idxFast,1);

figure(); hold on
plot([0 0], [0 1], 'k:', 'LineWidth',1.25)
plot(T_VEC, PActiveFast, '-', 'Color',[0 .7 0], 'LineWidth',1.5)
plot(T_VEC, PActiveAcc, 'r-', 'LineWidth',1.5)
xlabel('Time from primary saccade (ms)')
ylabel('P (active)')
ytickformat('%2.1f')
xlim([-350 400])
ppretty([5,2.5])

fprintf('Error signal time:\n')
fprintf('Accurate: %5.2f +/- %5.2f\n', mean(tCDFAcc), std(tCDFAcc)/sqrt(nFast))
fprintf('Fast: %5.2f +/- %5.2f\n', mean(tCDFFast), std(tCDFFast)/sqrt(NUM_UNIT))

end % fxn : FigS3A_ProbActive_ErrorChoice()

