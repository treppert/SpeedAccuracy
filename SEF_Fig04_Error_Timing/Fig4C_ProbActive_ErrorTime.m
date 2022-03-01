function [ ] = Fig4C_ProbActive_ErrorTime( unitData )
%Fig4C_ProbActive_ErrorTime Summary of this function goes here
%   Detailed explanation goes here

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});

idxRew = (unitData.Grade_Rew == 2);
idxKeep = (idxArea & idxMonkey & idxRew);

NUM_CELLS = sum(idxKeep);
unitData = unitData(idxKeep,:);

T_VEC = (-100 : 600);  OFFSET = 101;

%initializations
PActiveAcc = false(NUM_CELLS,length(T_VEC));
PActiveFast = false(NUM_CELLS,length(T_VEC));

%cells for which we have an estimate of error timing in Fast condition
idxFast = ~isnan(unitData.RewardSignal_Time(:,1));
nFast = sum(idxFast);

for cc = 1:NUM_CELLS
  %Accurate condition
  tErrStart_Acc = unitData.RewardSignal_Time(cc,3);
  tErrEnd_Acc = unitData.RewardSignal_Time(cc,4);
  PActiveAcc(cc,(tErrStart_Acc : tErrEnd_Acc) + OFFSET) = true;
  
  %Fast condition
  if idxFast(cc) %if we have estimate for Fast condition
    tErrStart_Fast = unitData.RewardSignal_Time(cc,1);
    tErrEnd_Fast = unitData.RewardSignal_Time(cc,2);
    PActiveFast(cc,(tErrStart_Fast : tErrEnd_Fast) + OFFSET) = true;
  end
end%for : cells(cc)

PActiveAcc = sum(PActiveAcc,1) / NUM_CELLS;
PActiveFast = sum(PActiveFast,1) / nFast;

%% Plotting
tCDFAcc = unitData.RewardSignal_Time(:,3);
tCDFFast = unitData.RewardSignal_Time(idxFast,1);

figure(); hold on
plot([0 0], [0 1], 'k:', 'LineWidth',1.25)
plot(T_VEC, PActiveFast, '-', 'Color',[0 .7 0], 'LineWidth',1.5)
plot(T_VEC, PActiveAcc, 'r-', 'LineWidth',1.5)
xlabel('Time from reward (ms)')
ylabel('P (active)')
ytickformat('%2.1f')
ppretty([5,2.5])

fprintf('Error signal time:\n')
fprintf('Accurate: %5.2f +/- %5.2f\n', mean(tCDFAcc), std(tCDFAcc)/sqrt(NUM_CELLS))
fprintf('Fast: %5.2f +/- %5.2f\n', mean(tCDFFast), std(tCDFFast)/sqrt(nFast))

end%fxn:Fig4C_ProbActive_ErrorTime()

