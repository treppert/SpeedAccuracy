function [ ] = Fig4D_TESignal_X_TEMagnitude( unitData , sdfAC , sdfAE , errLim , fitHF )
%Fig4D_TESignal_X_TEMagnitude Summary of this function goes here
%   Detailed explanation goes here

NUM_UNIT = size(unitData,1);
OFFSET_TIME = 501;

%bin trials by timing error magnitude
ERR_LIM = errLim; %quantile limits for binning
NUM_BIN = size(ERR_LIM,2) - 1;

RTerr_Plot = -(errLim(:,1:NUM_BIN) + diff(errLim,1,2)/2);

%initializations
sigCorr = NaN(NUM_UNIT,1);
sigErr = NaN(NUM_UNIT,NUM_BIN);

hfPlot = NaN(NUM_UNIT,NUM_BIN);

for uu = 1:NUM_UNIT
  idxHF = unitData.SessionIndex(uu); %index to translate RT to hazard function
  hfPlot(uu,:) = polyval(fitHF{idxHF}, RTerr_Plot(uu,:));
  
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
% Xmu = nanmean(tErr_Acc);
% Ymu = nanmean(sigErr);
% Xse = nanstd(tErr_Acc) / sqrt(NUM_UNIT);
% Yse = nanstd(sigErr) / sqrt(NUM_UNIT);

% figure(); hold on
% % line([0 0], [0 10], 'Color','k', 'LineStyle',':', 'LineWidth',1.5)
% line(RTerr_Plot', sig_Plot', 'Color',.5*ones(1,3), 'Marker','.', 'MarkerSize',8, 'LineWidth',0.5)
% % errorbar(-Xmu,Ymu, Yse,Yse, Xse,Xse, 'o', 'CapSize',0, 'Color','k')
% ylabel('Activity')
% xlabel('RT error (ms)')
% ppretty([5,3])

% figure(); hold on
% line(RTerr_Plot', hfPlot', 'Color',.5*ones(1,3), 'Marker','.', 'MarkerSize',8, 'LineWidth',0.5)
% ylabel('Hazard')
% xlabel('RT error (ms)')
% ppretty([5,3])

figure(); hold on
plot(hfPlot', sig_Plot', 'Color',.5*ones(1,3), 'Marker','.', 'MarkerSize',8)
ylabel('Activity')
xlabel('Hazard')
ppretty([5,3])

end % fxn : Fig4D_TESignal_X_TEMagnitude()

