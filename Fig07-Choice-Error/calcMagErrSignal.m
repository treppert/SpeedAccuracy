function [magAcc , magFast] = calcMagErrSignal( SDF , offset , nstats )
%calcMagErrSignal Summary of this function goes here
%   Detailed explanation goes here

if ~isnan(nstats.A_ChcErr_tErr_Acc)
  idxErrAcc = (nstats.A_ChcErr_tErr_Acc : nstats.A_ChcErr_tErrEnd_Acc) + offset;
  magAcc = (sum(SDF.AccErr.RePrimary(idxErrAcc)) - sum(SDF.AccCorr.RePrimary(idxErrAcc)));
  magAcc = magAcc / 1000; %correct for time-scale in ms for integral in units of spikes
else
  magAcc = NaN;
end


idxErrFast = (nstats.A_ChcErr_tErr_Fast : nstats.A_ChcErr_tErrEnd_Fast) + offset;
magFast = (sum(SDF.FastErr.RePrimary(idxErrFast)) - sum(SDF.FastCorr.RePrimary(idxErrFast)));
magFast = magFast / 1000; %correct for time-scale in ms for integral in units of spikes

end%fxn:calcMagErrSignal()

