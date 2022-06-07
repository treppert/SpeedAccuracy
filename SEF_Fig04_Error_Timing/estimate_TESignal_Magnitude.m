function [ ] = estimate_TESignal_Magnitude( sdfTE , unitData )
%estimate_TESignal_Magnitude() Given the time of the timing error signal,
%estimate its magnitude.
%   Detailed explanation goes here
% 

NUM_UNIT = size(unitData,1);
NUM_BIN_TERR = 3;
NUM_BIN_dRT  = 2;

%initializations
A_TE = NaN(NUM_UNIT,NUM_BIN_TERR*NUM_BIN_dRT);

for uu = 1:NUM_UNIT
  
  %start and finish of timing error signal
  tLim_uu = unitData.SignalTE_Time(uu,:);
  tLim_uu = tLim_uu + sdfTE.Time(1,3); %take into account offset in SDF
  
  for bb = 1:NUM_BIN_TERR
    for ii = 1:NUM_BIN_dRT
      idx_ii = 3*(bb-1)+ii;
      A_TE(uu,idx_ii) = calc_ErrorSignalMag_SAT(sdfTE.Corr(uu).Acc, sdfTE.Err(uu,idx_ii).Acc, ...
        'limTest',tLim_uu, 'abs'); %absolute value of error-suppressed neurons
    end
  end % for : RT error bin (bb)
  
end % for : unit(uu)

YPLOT = (1 : NUM_UNIT);
figure(); hold on
plot(sort(A_TE(:,1)), YPLOT, 'r')
plot(sort(A_TE(:,2)), YPLOT, 'color',[.5 0 0])
title('Small RT error')
legend({'Small','Med','Large'})

figure(); hold on
plot(sort(A_TE(:,3)), YPLOT, 'r')
plot(sort(A_TE(:,4)), YPLOT, 'color',[.5 0 0])
title('Mid RT error')
legend({'Small','Med','Large'})

figure(); hold on
plot(sort(A_TE(:,5)), YPLOT, 'r')
plot(sort(A_TE(:,6)), YPLOT, 'color',[.5 0 0])
title('Large RT error')
legend({'Small','Med','Large'})

end % fxn : estimate_TESignal_Magnitude()

