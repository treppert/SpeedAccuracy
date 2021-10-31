function [magAcc , magFast] = calcMagRewSignal( SDF , offset , unitData )
%calcMagRewSignal Summary of this function goes here
%   Detailed explanation goes here

idxErrAcc = (unitData.TimingErrorSignal_Time(1) : unitData.TimingErrorSignal_Time(3)) + offset;
magAcc = (sum(SDF.AccErr(idxErrAcc)) - sum(SDF.AccCorr(idxErrAcc)));
magAcc = magAcc / 1000; %correct for time-scale in ms for integral in units of spikes

if ~isnan(unitData.TimingErrorSignal_Time(2))
  idxErrFast = (unitData.TimingErrorSignal_Time(2) : unitData.TimingErrorSignal_Time(4)) + offset;
  magFast = (sum(SDF.FastErr(idxErrFast)) - sum(SDF.FastCorr(idxErrFast)));
  magFast = magFast / 1000; %correct for time-scale in ms for integral in units of spikes
else
  magFast = NaN;
end

end%fxn:calcMagRewSignal()

