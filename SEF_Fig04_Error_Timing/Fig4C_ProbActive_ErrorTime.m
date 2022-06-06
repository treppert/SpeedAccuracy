function [ ] = Fig4C_ProbActive_ErrorTime( unitData )
%Fig4C_ProbActive_ErrorTime Summary of this function goes here
%   Detailed explanation goes here

NUM_UNIT = size(unitData,1);

OFFSET = 500;  T_VEC = (-OFFSET : 1500);
N_SAMP = length(T_VEC);

%initialization
PActiveAcc = false(NUM_UNIT,N_SAMP);

for uu = 1:NUM_UNIT
  tSignalStart  = unitData.SignalTE_Time(uu,1);
  tSignalEnd    = unitData.SignalTE_Time(uu,2);
  
  PActiveAcc(uu,(tSignalStart : tSignalEnd) + OFFSET) = true;
end % for : unit(uu)

PActiveAcc = sum(PActiveAcc,1) / NUM_UNIT;

%% Plotting
XLIM = [-300 900];

figure(); hold on
plot([0 0], [0 1], 'k:', 'LineWidth',1.25)
plot(T_VEC, PActiveAcc, 'r-', 'LineWidth',1.5)
xlim(XLIM); ytickformat('%2.1f')
xlabel('Time from reward (ms)')
ylabel('P (active)')
ppretty([3,1.5])

end%fxn:Fig4C_ProbActive_ErrorTime()

