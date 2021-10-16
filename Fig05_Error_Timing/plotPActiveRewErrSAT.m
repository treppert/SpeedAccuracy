function [ ] = plotPActiveRewErrSAT( unitData , unitData )
%plotPActiveRewErrSAT Summary of this function goes here
%   Detailed explanation goes here

idxArea = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'D','E'});

idxRew = ((abs(unitData.Basic_RewGrade) >= 2) & ~isnan([unitData.TimingErrorSignal_Time(2)]));
% idxRew = (abs(unitData.Basic_RewGrade) >= 2);
idxKeep = (idxArea & idxMonkey & idxRew);

NUM_CELLS = sum(idxKeep)
return
unitData = unitData(idxKeep);

T_VEC = (-100 : 800);  OFFSET = 101;

%initializations
PActiveAcc = false(NUM_CELLS,length(T_VEC));
PActiveFast = false(NUM_CELLS,length(T_VEC));

for uu = 1:NUM_CELLS
  tErrStart_Acc = unitData.TimingErrorSignal_Time(uu,1);
  tErrStart_Fast = unitData.TimingErrorSignal_Time(uu,2);
  
  tErrEnd_Acc = unitData.TimingErrorSignal_Time(uu,3);
  tErrEnd_Fast = unitData.TimingErrorSignal_Time(uu,4);
  
  PActiveAcc(cc,(tErrStart_Acc : tErrEnd_Acc) + OFFSET) = true;
  PActiveFast(cc,(tErrStart_Fast : tErrEnd_Fast) + OFFSET) = true;
end%for:cells-Acc(uu)

PActiveAcc = sum(PActiveAcc,1) / NUM_CELLS;
PActiveFast = sum(PActiveFast,1) / NUM_CELLS;

%% Plotting
tCDFAcc = sort([unitData.TimingErrorSignal_Time(1)]);
tCDFFast = sort([unitData.TimingErrorSignal_Time(2)]);

figure(); hold on
plot([0 0], [0 1], 'k:', 'LineWidth',1.25)
plot(median(tCDFAcc)*ones(1,2), [0 .4], 'r:', 'LineWidth',1.5)
plot(median(tCDFFast)*ones(1,2), [0 .4], ':', 'Color',[0 .7 0], 'LineWidth',1.5)
plot(T_VEC, PActiveFast, '-', 'Color',[0 .7 0], 'LineWidth',1.5)
plot(T_VEC, PActiveAcc, 'r-', 'LineWidth',1.5)
xlabel('Time from reward (ms)')
ylabel('P (active)')
ytickformat('%2.1f')

ppretty([6,2.5])

end%fxn:plotPActiveRewErrSAT()

