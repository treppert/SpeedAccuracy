function [ A_Err ] = calc_ErrorSignalMag_SAT( sdfCorr , sdfErr , varargin )
%calc_ErrorSignalMag_SAT Summary of this function goes here
%   We calculate the magnitude of the choice error-related signal as the
%   integral of the difference between SDFs on error and correct trials.
% 

args = getopt(varargin, {{'idxTest=',[]}, 'abs'});

%parse inputs
if isempty(args.idxTest)
  idxTest = (1 : length(sdfCorr));
else
  idxTest = args.idxTest;
end

%compute integral of difference between correct and error activation
A_Err = sum(sdfErr(idxTest) - sdfCorr(idxTest)); %sp/sec
A_Err = A_Err / (idxTest(end)-idxTest(1)) * 1000; %spikes

if (args.abs)
  A_Err = abs(A_Err);
end

end % util : calc_ErrorSignalMag_SAT()

