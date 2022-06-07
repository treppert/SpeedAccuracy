function [ ] = estimate_TESignal_Magnitude( sdfTE , unitData , behavData )
%estimate_TESignal_Magnitude() Given the time of the timing error signal,
%estimate its magnitude.
%   Detailed explanation goes here
% 

NUM_UNIT = size(unitData,1);
NUM_BIN_TERR = size(sdfTE.Err,2);

NBIN_dRT = 2; %bin by RT adjustment
BINLIM_dRT = linspace(0, 1, NBIN_dRT+1);

%initializations
A_TE = NaN(NUM_UNIT,NUM_BIN_TERR);

for uu = 1:NUM_UNIT
  kk = unitData.SessionIndex(uu);
  dRT_kk = [diff(behavData.Sacc_RT{kk}); Inf];
  
  %start and finish of timing error signal
  tLim_uu = unitData.SignalTE_Time(uu,:);
  tLim_uu = tLim_uu + sdfTE.Time(1,3); %take into account offset in SDF
  
  %get quantiles of dRT for binning
  binlim_dRT = quantile(dRT_kk(idxAE), BINLIM_dRT);
  
  for bb = 1:NUM_BIN_TERR
    A_TE(uu,bb) = calc_ErrorSignalMag_SAT(sdfTE.Corr(uu).Acc, sdfTE.Err(uu,bb).Acc, ...
      'limTest',tLim_uu, 'abs'); %absolute value of error-suppressed neurons
  end % for : error magnitude bin (bb)
  
end % for : unit(uu)

for bb = 1:NUM_BIN_TERR
  figure(); cdfplot(A_TE(:,bb))
end

end % fxn : estimate_TESignal_Magnitude()

