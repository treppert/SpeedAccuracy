function [ ] = Fig4C_ProbActive_ErrorTime( unitData )
%Fig4C_ProbActive_ErrorTime Summary of this function goes here
%   Detailed explanation goes here

NUM_UNIT = size(unitData,1);
T_VEC = (-300 : 800);  OFFSET = 301;

PActiveAcc = false(NUM_UNIT,length(T_VEC));
for uu = 1:NUM_UNIT
  tErrStart_Acc = unitData.RewardSignal_Time(uu,3);
  tErrEnd_Acc = unitData.RewardSignal_Time(uu,4);
  PActiveAcc(uu,(tErrStart_Acc : tErrEnd_Acc) + OFFSET) = true;
end % for : unit(uu)

PActiveAcc = sum(PActiveAcc,1) / NUM_UNIT;

%% Plotting
tCDFAcc = unitData.RewardSignal_Time(:,3);

figure(); hold on
plot([0 0], [0 1], 'k:', 'LineWidth',1.25)
plot(T_VEC, PActiveAcc, 'r-', 'LineWidth',1.5)
xlabel('Time from reward (ms)')
ylabel('P (active)')
ytickformat('%2.1f')
ppretty([5,2.5])

end%fxn:Fig4C_ProbActive_ErrorTime()

