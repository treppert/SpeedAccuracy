function [ idx_poor_isolation ] = removeTrials_Isolation( trialRemove , numTrial , varargin )
%identify_trials_poor_isolation_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {'print'});

idx_poor_isolation = false(numTrial,1);

if isempty(trialRemove) %no trials to remove
  return
  
elseif (trialRemove(1) == 9999) %remove all trials from consideration
  idx_poor_isolation = true(numTrial,1);
  
else %specified interval of trials to remove
  idx_poor_isolation(trialRemove(1) : trialRemove(2)) = true;
  if (args.print)
    fprintf('Skipping trials %d - %d \n', trialRemove);
  end
end

end % util : identify_trials_poor_isolation_SAT()
