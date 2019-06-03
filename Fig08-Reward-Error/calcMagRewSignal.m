function [magAcc , magFast] = calcMagRewSignal( SDF , offset , nstats )
%calcMagRewSignal Summary of this function goes here
%   Detailed explanation goes here

idxErrAcc = (nstats.A_Reward_tErrStart_Acc : nstats.A_Reward_tErrEnd_Acc) + offset;
magAcc = (sum(SDF.AccErr.Reward(idxErrAcc)) - sum(SDF.AccCorr.Reward(idxErrAcc)));
magAcc = magAcc / 1000; %correct for time-scale in ms for integral in units of spikes

if ~isnan(nstats.A_Reward_tErrStart_Fast)
  idxErrFast = (nstats.A_Reward_tErrStart_Fast : nstats.A_Reward_tErrEnd_Fast) + offset;
  magFast = (sum(SDF.FastErr.Reward(idxErrFast)) - sum(SDF.FastCorr.Reward(idxErrFast)));
  magFast = magFast / 1000; %correct for time-scale in ms for integral in units of spikes
else
  magFast = NaN;
end

end%fxn:calcMagRewSignal()

