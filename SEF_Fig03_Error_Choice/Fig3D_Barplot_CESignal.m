function [ ] = Fig3D_Barplot_CESignal( unitData )
%Fig3D_Barplot_CESignal Summary of this function goes here
%   Detailed explanation goes here

NUM_UNIT = size(unitData,1);
OFFSET_TIME = 500;

sigAcc = NaN(NUM_UNIT,1);
sigFast = sigAcc;

for uu = 1:NUM_UNIT
  
  sdfAC_S = unitData.sdfAC{uu}(:,3); %Accurate correct
  sdfAE_S = unitData.sdfAE{uu}(:,3); %Accurate choice error
  sdfFC_S = unitData.sdfFC{uu}(:,3); %Fast correct
  sdfFE_S = unitData.sdfFE{uu}(:,3); %Fast choice error
  
  idxTest_Fast = OFFSET_TIME + unitData.SignalCE_Time_S(uu,1:2);
  idxTest_Acc  = OFFSET_TIME + unitData.SignalCE_Time_S(uu,3:4);
  
  sigFast(uu) = calc_ErrorSignalMag_SAT(sdfFC_S, sdfFE_S, 'idxTest',idxTest_Fast, 'abs');
  sigAcc(uu)  = calc_ErrorSignalMag_SAT(sdfAC_S, sdfAE_S, 'idxTest',idxTest_Acc, 'abs');
  
end % for : unit(uu)

figure(); hold on
histogram(sigFast-sigAcc, 'BinWidth',10)
ppretty([3,3])

ttestFull(sigAcc, sigFast, 'barplot', ...
  'xticklabels',{'Acc','Fast'}, 'ylabel','Error signal magnitude (sp)')

end % fxn: Fig3D_Barplot_CESignal()

