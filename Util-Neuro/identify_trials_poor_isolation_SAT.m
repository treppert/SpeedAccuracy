function [ idx_poor_isolation ] = identify_trials_poor_isolation_SAT( ninfo , num_trials )
%identify_trials_poor_isolation_SAT Summary of this function goes here
%   Detailed explanation goes here

idx_poor_isolation = false(1,num_trials);

if (ninfo.iRem1)
  idx_poor_isolation(ninfo.iRem1 : ninfo.iRem2) = true;
end

end%util:identify_trials_poor_isolation_SAT()

