function [ ] = Fig4C_ProbActive_ErrorTime( unitData )
%Fig4C_ProbActive_ErrorTime Summary of this function goes here
%   Detailed explanation goes here

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});

idxRew = (unitData.Grade_Rew == 2);
idxKeep = (idxArea & idxMonkey & idxRew);

NUM_UNIT = sum(idxKeep);
unitData = unitData(idxKeep,:);

T_VEC = (-200 : 600);  OFFSET = 201;

%initializations
PActiveAcc = false(NUM_UNIT,length(T_VEC));
PActiveFast = false(NUM_UNIT,length(T_VEC));

%cells for which we have an estimate of error timing in Fast condition
idxFast = ~isnan(unitData.RewardSignal_Time(:,1));
nFast = sum(idxFast);

for uu = 1:NUM_UNIT
  %Accurate condition
  tErrStart_Acc = unitData.RewardSignal_Time(uu,3);
  tErrEnd_Acc = unitData.RewardSignal_Time(uu,4);
  PActiveAcc(uu,(tErrStart_Acc : tErrEnd_Acc) + OFFSET) = true;
  
  %Fast condition
  if idxFast(uu) %if we have estimate for Fast condition
    tErrStart_Fast = unitData.RewardSignal_Time(uu,1);
    tErrEnd_Fast = unitData.RewardSignal_Time(uu,2);
    PActiveFast(uu,(tErrStart_Fast : tErrEnd_Fast) + OFFSET) = true;
  end
end % for : unit(uu)

PActiveAcc = sum(PActiveAcc,1) / NUM_UNIT;
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
fprintf('Accurate: %5.2f +/- %5.2f\n', mean(tCDFAcc), std(tCDFAcc)/sqrt(NUM_UNIT))
fprintf('Fast: %5.2f +/- %5.2f\n', mean(tCDFFast), std(tCDFFast)/sqrt(nFast))
ttestTom(unitData.RewardSignal_Time(idxFast,3), unitData.RewardSignal_Time(idxFast,1), 'barplot')
ylabel('Error signal onset (ms)')

end%fxn:Fig4C_ProbActive_ErrorTime()

