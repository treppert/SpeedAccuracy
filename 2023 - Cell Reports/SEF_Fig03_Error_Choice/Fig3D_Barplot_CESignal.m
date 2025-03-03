function [ ] = Fig3D_Barplot_CESignal( unitData )
%Fig3D_Barplot_CESignal Summary of this function goes here
%   Detailed explanation goes here

NUM_UNIT = size(unitData,1);
OFFSET_TIME = 500;

sigAcc = NaN(NUM_UNIT,1);
sigFast = sigAcc;

for uu = 1:NUM_UNIT
  
  sdfAC_S = unitData.sdfAC_CE{uu}(:,3); %Accurate correct
  sdfAE_S = unitData.sdfAE_CE{uu}(:,3); %Accurate choice error
  sdfFC_S = unitData.sdfFC_CE{uu}(:,3); %Fast correct
  sdfFE_S = unitData.sdfFE_CE{uu}(:,3); %Fast choice error
  
  limTest_Fast = OFFSET_TIME + unitData.SignalCE_Time_S(uu,1:2);
  limTest_Acc  = OFFSET_TIME + unitData.SignalCE_Time_S(uu,3:4);
  
  sigFast(uu) = calc_ErrorSignalMag_SAT(sdfFC_S, sdfFE_S, 'limTest',limTest_Fast, 'abs');
  sigAcc(uu)  = calc_ErrorSignalMag_SAT(sdfAC_S, sdfAE_S, 'limTest',limTest_Acc, 'abs');
  
end % for : unit(uu)

figure(); hold on
histogram(sigFast-sigAcc, 'BinWidth',10)
ppretty([3,3])

ttestFull(sigAcc, sigFast, 'barplot', ...
  'xticklabels',{'Acc','Fast'}, 'ylabel','Error signal magnitude (sp)')

end % fxn: Fig3D_Barplot_CESignal()

