function [ varargout ] = Fig4X_Barplot_TESignalMag( unitData , sdfAC , sdfAE )
%Fig3D_Barplot_CESignal Summary of this function goes here
%   Detailed explanation goes here

NUM_UNIT = size(unitData,1);
OFFSET_TIME = 501; %from plot_SDF_ErrTime.m

sigAcc = NaN(NUM_UNIT,1);
for uu = 1:NUM_UNIT
  
  sdfAC_Rew = sdfAC{uu}(:,3); %Accurate correct
  sdfAE_Rew = sdfAE{uu}(:,3); %Accurate choice error
  
  idxTest  = OFFSET_TIME + unitData.SignalTE_Time(uu,:);
  
  sigAcc(uu)  = calc_ErrorSignalMag_SAT(sdfAC_Rew, sdfAE_Rew, 'idxTest',idxTest, 'abs');
  
end % for : unit(uu)

if (nargout > 0)
  varargout{1} = sigAcc;
end

figure(); hold on
histogram(sigAcc, 'BinWidth',10)
ppretty([3,3])

end % fxn: Fig4X_Barplot_TESignalMag()

