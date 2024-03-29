function [ A_Err ] = calc_ErrorSignalMag_SAT( sdfCorr , sdfErr , varargin )
%calc_ErrorSignalMag_SAT Summary of this function goes here
%   We calculate the magnitude of the choice error-related signal as the
%   integral of the difference between SDFs on error and correct trials.
% 

args = getopt(varargin, {{'limTest=',[]}, 'abs'});

%parse inputs
if isempty(args.limTest)
  idxTest = (1 : length(sdfCorr));
else
  idxTest = (args.limTest(1) : args.limTest(2));
end

%compute integral of difference between correct and error activation
% A_Err = sum(sdfErr(idxTest) - sdfCorr(idxTest)); %sp/sec
% A_Err = A_Err / (idxTest(end)-idxTest(1)) * 1000; %spikes

%compute contrast ratio
muCorr = mean(sdfCorr(idxTest));
muErr  = mean(sdfErr(idxTest));
A_Err = (muErr - muCorr) / (muErr + muCorr);

if (args.abs)
  A_Err = abs(A_Err);
end

end % util : calc_ErrorSignalMag_SAT()

