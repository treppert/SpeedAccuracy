function [magAcc , magFast] = calcMagErrSignal( SDF , offset , nstats )
%calcMagErrSignal Summary of this function goes here
%   We calculate the magnitude of the choice error-related signal as the
%   integral of the difference between SDFs on error and correct trials.
%   This integral is computed for the first 150 ms of error signaling.

WIN_TEST = 200; %number of millisec used to compute signal magnitude

DEBUG = false;

if isnan(nstats.A_ChcErr_tErr_Acc)
  error('No start time for error signaling in the Accurate condition')
end

%Accurate condition
idxErrAcc = (nstats.A_ChcErr_tErr_Acc : (nstats.A_ChcErr_tErr_Acc + WIN_TEST)) + offset;
magAcc = (sum(SDF.AccErr.RePrimary(idxErrAcc)) - sum(SDF.AccCorr.RePrimary(idxErrAcc)));
magAcc = magAcc / 1000; %correct for time-scale in ms for integral in units of spikes

%Fast condition
idxErrFast = (nstats.A_ChcErr_tErr_Fast : nstats.A_ChcErr_tErr_Fast + WIN_TEST) + offset;
magFast = (sum(SDF.FastErr.RePrimary(idxErrFast)) - sum(SDF.FastCorr.RePrimary(idxErrFast)));
magFast = magFast / 1000; %correct for time-scale in ms for integral in units of spikes

if (DEBUG)
  figure()
  
  %Accurate condition
  subplot(2,1,1); hold on
  plot(SDF.AccErr.RePrimary, 'r:')
  plot(SDF.AccCorr.RePrimary, 'r-')
  plot(idxErrAcc, 1, 'k.')
  title(['Mag. = ', num2str(magAcc), ' sp'], 'FontSize',8)
  
  %Fast condition
  subplot(2,1,2); hold on
  plot(SDF.FastErr.RePrimary, 'g:')
  plot(SDF.FastCorr.RePrimary, 'g-')
  plot(idxErrFast, 1, 'k.')
  title(['Mag. = ', num2str(magFast), ' sp'], 'FontSize',8)
  
  pause()
  
end

end%fxn:calcMagErrSignal()

