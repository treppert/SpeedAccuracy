function [ idx_poor_isolation ] = identify_trials_poor_isolation_SAT( ninfo , num_trials )
%identify_trials_poor_isolation_SAT Summary of this function goes here
%   Detailed explanation goes here

idx_poor_isolation = false(1,num_trials);

if ~isnan(ninfo.tRemIso)
  idx_poor_isolation(ninfo.tRemIso(1) : ninfo.tRemIso(2)) = true;
end

end%util:identify_trials_poor_isolation_SAT()

