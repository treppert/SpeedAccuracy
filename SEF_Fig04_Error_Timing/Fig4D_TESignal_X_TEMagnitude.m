function [ ] = Fig4D_TESignal_X_TEMagnitude( unitData , sdfAC , sdfAE , rtErrLim , pHF_Scale )
%Fig4D_TESignal_X_TEMagnitude Summary of this function goes here
%   Detailed explanation goes here

NUM_UNIT = size(unitData,1);
OFFSET_TIME = 501;

%bin trials by timing error magnitude
ERR_LIM = rtErrLim;
NUM_BIN = size(ERR_LIM,2) - 1;
RTerr_Plot = -(ERR_LIM(:,1:NUM_BIN) + diff(ERR_LIM,1,2)/2);

%quadratic fit to hazard rate data
pHF_Da = [1.84e-6 , .001633 , .301060];
pHF_Eu = [1.94e-6 , .001449 , .243276];

%initializations
sigCorr = NaN(NUM_UNIT,1);
sigErr  = NaN(NUM_UNIT,NUM_BIN);
haz_Plot = NaN(NUM_UNIT,NUM_BIN);

for uu = 1:NUM_UNIT
  kk = unitData.SessionIndex(uu);
  
  %translate RT error to instantaneous hazard rate via quadratic model h(t)
  X = RTerr_Plot(uu,:);
  switch (unitData.Monkey{uu})
    case 'D'
      haz_Plot(uu,:) = pHF_Scale(kk) * (pHF_Da(1)*X.^2 + pHF_Da(2)*X + pHF_Da(3));
    case 'E'
      haz_Plot(uu,:) = pHF_Scale(kk) * (pHF_Eu(1)*X.^2 + pHF_Eu(2)*X + pHF_Eu(3));
  end
  
  idxTest  = OFFSET_TIME + unitData.SignalTE_Time(uu,:);
  idxTest = idxTest(1):idxTest(2);
  
  sdfAC_Rew = sdfAC{uu}(idxTest,3);
  sigCorr(uu) = mean(sdfAC_Rew);
  
  for bb = 1:NUM_BIN
    
    sdfAE_bb = sdfAE{uu}(idxTest,3*bb);
    sigErr(uu,bb) = mean(sdfAE_bb);
    
  end % for : RTerr bin(bb)
  
end % for : unit(uu)

sig_Plot = abs(sigErr-sigCorr)./mean(sigErr+sigCorr,2);

%% Plotting
X_PLOT = haz_Plot;

Xmu = nanmean(X_PLOT);
Ymu = nanmean(sig_Plot);
Xse = nanstd(X_PLOT) / sqrt(NUM_UNIT);
Yse = nanstd(sig_Plot) / sqrt(NUM_UNIT);

figure(); hold on
% line([0 0], [0 10], 'Color','k', 'LineStyle',':', 'LineWidth',1.5)
line(X_PLOT', sig_Plot', 'Color',.5*ones(1,3), 'Marker','.', 'MarkerSize',8, 'LineWidth',0.5)
% errorbar(Xmu,Ymu, Yse,Yse, Xse,Xse, 'o', 'CapSize',0, 'Color','k')
ylabel('Normalized error signal')
% xlabel('RT error (ms)')
ppretty([5,3])

end % fxn : Fig4D_TESignal_X_TEMagnitude()

