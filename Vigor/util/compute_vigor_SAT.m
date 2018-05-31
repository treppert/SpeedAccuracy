function [ moves ] = compute_vigor_SAT( moves , varargin )
%compute_vigor_SAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(moves);

FXN_DEF_MS = fittype({'x'});
DEBUG = false;

if (nargin > 1)
  parm_ms = varargin{1};
end

for kk = 1:NUM_SESSION

  if (nargin == 1)
    
    i_nan = isnan(moves(kk).displacement);
    parm_ms = fit(moves(kk).displacement(~i_nan)', moves(kk).peakvel(~i_nan)', FXN_DEF_MS);

  end

  pv_expected = FXN_DEF_MS(parm_ms.a, moves(kk).displacement);

  moves(kk).vigor(:) = moves(kk).peakvel ./ pv_expected;
  
  if (DEBUG)
    figure(); hold on
    plot(moves(kk).displacement, moves(kk).peakvel, 'ko', 'MarkerSize',3)
    plot([0, 10], FXN_DEF_MS(parm_ms.a, [0 10]), 'b-')
  end
  
end%for:sessions(kk)
  
end%function:compute_vigor_SAT()
