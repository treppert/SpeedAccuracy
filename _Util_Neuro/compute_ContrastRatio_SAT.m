function [ CR ] = compute_ContrastRatio_SAT( A_X , A_Y )
%compute_ContrastRatio_SAT Summary of this function goes here
%   Detailed explanation goes here

CR = (A_Y - A_X) ./ (A_X + A_Y); 

end % util : compute_ContrastRatio_SAT()

