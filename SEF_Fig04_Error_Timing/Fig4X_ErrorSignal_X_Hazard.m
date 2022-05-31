function [ ] = Fig4X_ErrorSignal_X_Hazard( unitData , parmFitDa, parmFitEu , varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'sessHighlight=',[]}});
kkHighlight = args.sessHighlight; %optional: specify session to highlight

NUM_UNIT = size(unitData,1);
OFFSET_TIME = 501;

%Quantiles of RT error averaged across sessions (Accurate condition)
RTERR_QUANT_Da = [3.89	37.97	79.28	147.61	225.44];
RTERR_QUANT_Eu = [4.14	38.18	68.29	98.14   188.00];

%bin trials by timing error magnitude
NUM_RTBIN = length(RTERR_QUANT_Da) - 1;

%initializations
sigCorr = NaN(NUM_UNIT,1);
sigErr  = NaN(NUM_UNIT,NUM_RTBIN);
hazard = NaN(NUM_UNIT,NUM_RTBIN);

for uu = 1:NUM_UNIT
  
  switch (unitData.Monkey{uu})
    case 'D'
      X = -(RTERR_QUANT_Da(:,1:NUM_RTBIN) + diff(RTERR_QUANT_Da,1,2)/2);
    case 'E'
      X = -(RTERR_QUANT_Eu(:,1:NUM_RTBIN) + diff(RTERR_QUANT_Eu,1,2)/2);
  end
  
  %translate RT error to instantaneous hazard rate via quadratic model h(t)
  hazard(uu,:) = transform_RT2hazard(X, unitData.SessionIndex(uu));
  
  idxTest  = OFFSET_TIME + unitData.SignalTE_Time(uu,:);
  idxTest = idxTest(1):idxTest(2);
  
  sdfAC_Rew = unitData.sdfAC_TE{uu}(idxTest,3);
  sigCorr(uu) = mean(sdfAC_Rew);
  
  for bb = 1:NUM_RTBIN
    
    sdfAE_bb = unitData.sdfAE_TE{uu}(idxTest,3*bb);
    sigErr(uu,bb) = mean(sdfAE_bb);
    
  end % for : RTerr bin(bb)
  
end % for : unit(uu)

sig_Plot = abs(sigErr-sigCorr)./mean(sigErr+sigCorr,2);

%% Plotting
uuHighlight = find(ismember(unitData.SessionIndex, kkHighlight));

figure(); hold on
line(hazard', sig_Plot', 'Color',.5*ones(1,3), 'Marker','.', 'MarkerSize',10, 'LineWidth',0.75)
if ~isempty(uuHighlight)
  title(unitData.Session{uuHighlight(1)})
  line(hazard(uuHighlight,:)', sig_Plot(uuHighlight,:)', 'Color','k', 'Marker','.', 'MarkerSize',12, 'LineWidth',1)
end
ylabel('Normalized error signal')
xlabel('Shannon information')
ppretty([5,3])

end

