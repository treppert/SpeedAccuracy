function [ varargout ] = estimate_TESignal_Magnitude( sdfTE , unitData , varargin )
%estimate_TESignal_Magnitude() Given the time of the timing error signal,
%estimate its magnitude.
%   Detailed explanation goes here
%   
%   

args = getopt(varargin, {{'nBin_TE=',2}, {'nBin_dRT=',3}});

NUM_UNIT = size(unitData,1);
NBIN_TERR = args.nBin_TE;
NBIN_dRT  = args.nBin_dRT;

%initializations
A_TE = NaN(NUM_UNIT,NBIN_TERR*NBIN_dRT);

for uu = 1:NUM_UNIT
  
  %start and finish of timing error signal
  tLim_uu = unitData.SignalTE_Time(uu,:);
%   tLim_uu = [-400, 800];
  tLim_uu = tLim_uu - sdfTE.Time(1,3); %take into account offset in SDF
  
  for bb = 1:NBIN_TERR
    for ii = 1:NBIN_dRT
      idx_ii = NBIN_dRT*(bb-1) + ii;
      A_TE(uu,idx_ii) = calc_ErrorSignalMag_SAT(sdfTE.Corr(uu).Acc(:,3), sdfTE.Err(uu,idx_ii).Acc(:,3), 'limTest',tLim_uu);
    end % for : dRT bin (ii)
  end % for : RT error bin (bb)
  
end % for : unit(uu)

%reverse sign for error-suppressed neurons
idxSuppressed = (unitData.Grade_TErr == -1);
A_TE(idxSuppressed,:) = -A_TE(idxSuppressed,:);

YPLOT = (1 : NUM_UNIT);
CPLOT = linspace(.8, .2, NBIN_dRT);

for bb = 1:NBIN_TERR
  
  figure(); hold on
  for ii = 1:NBIN_dRT %bins of dRT
    idx_ii = NBIN_dRT*(bb-1) + ii;
    plot(sort(A_TE(:,idx_ii)), YPLOT, 'color',[CPLOT(ii) 0 0])
  end
  ylim([1 NUM_UNIT])
  
end % for : TE bin (bb)

if (nargout > 0)
  varargout{1} = A_TE;
end

end % fxn : estimate_TESignal_Magnitude()

