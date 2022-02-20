function [ ] = plotPActiveChcErrSAT( unitData )
%plotPActiveChcErrSAT Summary of this function goes here
%   Detailed explanation goes here

idxSEF = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, {'E'});
idxErrUnit = (unitData.Grade_Err == 1);
idxKeep = (idxSEF & idxMonkey & idxErrUnit);

unitData = unitData(idxKeep,:);
NUM_CELLS = sum(idxKeep);

T_VEC = (-200 : 400);  OFFSET = 201;
NUM_SAMP = length(T_VEC);

%initializations
PActiveAcc = false(NUM_CELLS,NUM_SAMP);
PActiveFast = false(NUM_CELLS,NUM_SAMP);

%cells for which we have an estimate of error timing in Accurate condition
idxAcc = ~isnan(unitData.ErrorSignal_Time(:,3));
nAcc = sum(idxAcc);

for cc = 1:NUM_CELLS
  %Accurate condition
  if idxAcc(cc) %if we have estimate for Accurate condition
    tErrStart_Acc = unitData.ErrorSignal_Time(cc,3);
    tErrEnd_Acc = unitData.ErrorSignal_Time(cc,4);
    PActiveAcc(cc,(tErrStart_Acc : tErrEnd_Acc) + OFFSET) = true;
  end
  
  %Fast condition
  tErrStart_Fast = unitData.ErrorSignal_Time(cc,1);
  tErrEnd_Fast = unitData.ErrorSignal_Time(cc,2);
  PActiveFast(cc,(tErrStart_Fast : tErrEnd_Fast) + OFFSET) = true;
end % for : cells(cc)

PActiveAcc = sum(PActiveAcc,1) / nAcc;
PActiveFast = sum(PActiveFast,1) / NUM_CELLS;

%% Plotting
tCDFAcc = unitData.ErrorSignal_Time(idxAcc,3);
tCDFFast = unitData.ErrorSignal_Time(:,1);

figure(); hold on
plot([0 0], [0 1], 'k:', 'LineWidth',1.25)
plot(T_VEC, PActiveFast, '-', 'Color',[0 .7 0], 'LineWidth',1.5)
plot(T_VEC, PActiveAcc, 'r-', 'LineWidth',1.5)
xlabel('Time from primary saccade (ms)')
ylabel('P (active)')
ytickformat('%2.1f')
xlim([-200 400])
ppretty([5,2.5])

fprintf('Error signal time:\n')
fprintf('Accurate: %5.2f +/- %5.2f\n', mean(tCDFAcc), std(tCDFAcc)/sqrt(nAcc))
fprintf('Fast: %5.2f +/- %5.2f\n', mean(tCDFFast), std(tCDFFast)/sqrt(NUM_CELLS))


end%fxn:plotPActiveChcErrSAT()

