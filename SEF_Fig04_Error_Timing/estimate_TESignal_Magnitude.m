function [ varargout ] = estimate_TESignal_Magnitude( sdfTE , unitData )
%estimate_TESignal_Magnitude() Given the time of the timing error signal,
%estimate its magnitude.
%   Detailed explanation goes here
%   
% 

NUM_UNIT = size(unitData,1);
NUM_BIN_TERR = 2;
NUM_BIN_dRT  = 3;

%initializations
A_TE = NaN(NUM_UNIT,NUM_BIN_TERR*NUM_BIN_dRT);

for uu = 1:NUM_UNIT
  
  %start and finish of timing error signal
  tLim_uu = unitData.SignalTE_Time(uu,:);
  tLim_uu = tLim_uu - sdfTE.Time(1,3); %take into account offset in SDF
  
  for bb = 1:NUM_BIN_TERR
    for ii = 1:NUM_BIN_dRT
      idx_ii = 3*(bb-1)+ii;
      A_TE(uu,idx_ii) = calc_ErrorSignalMag_SAT(sdfTE.Corr(uu).Acc(:,3), sdfTE.Err(uu,idx_ii).Acc(:,3), ...
        'limTest',tLim_uu);
    end
  end % for : RT error bin (bb)
  
end % for : unit(uu)

%reverse sign for error-suppressed neurons
idxSuppressed = (unitData.Grade_TErr == -1);
A_TE(idxSuppressed,:) = -A_TE(idxSuppressed,:);

YPLOT = (1 : NUM_UNIT);
CPLOT = linspace(.8, .2, NUM_BIN_dRT);

figure(); hold on
for ii = 1:NUM_BIN_dRT %bins of dRT
  plot(sort(A_TE(:,ii)), YPLOT, 'color',[CPLOT(ii) 0 0])
end
title('Small RT error')
legend({'Small','Med dRT','Large'}, 'location','southeast')
ylim([1 NUM_UNIT])

figure(); hold on
for ii = 1:NUM_BIN_dRT %bins of dRT
  plot(sort(A_TE(:,NUM_BIN_dRT+ii)), YPLOT, 'color',[CPLOT(ii) 0 0])
end
title('Large RT error')
legend({'Small','Med dRT','Large'}, 'location','southeast')
ylim([1 NUM_UNIT])

if (nargout > 0)
  varargout{1} = A_TE;
end
end % fxn : estimate_TESignal_Magnitude()

