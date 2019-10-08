function [ idx_poor_isolation ] = identify_trials_poor_isolation_SAT( trialRemove , numTrial )
%identify_trials_poor_isolation_SAT Summary of this function goes here
%   Detailed explanation goes here

idx_poor_isolation = false(1,numTrial);

if isempty(trialRemove) %no trials to remove
  return
  
elseif (trialRemove(1) == 9999) %remove all trials from consideration
  idx_poor_isolation = true(1,numTrial);
  
else %sepcified interval of trials to remove
  idx_poor_isolation(trialRemove(1) : trialRemove(2)) = true;
  
end

end % util : identify_trials_poor_isolation_SAT()
