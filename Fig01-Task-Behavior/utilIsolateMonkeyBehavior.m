function [binfo, moves] = utilIsolateMonkeyBehavior(binfo, moves, monkey)
%utilIsolateMonkeyBehavior Summary of this function goes here
%   Detailed explanation goes here

MIN_NUM_TRIALS = 500;

idxMonkey = ismember({binfo.monkey}, monkey);
idxNumTrials = ([binfo.num_trials] > MIN_NUM_TRIALS);

binfo = binfo(idxMonkey & idxNumTrials);
moves = moves(idxMonkey & idxNumTrials);

if ((length(monkey) == 1) && ismember(monkey, {'D','E'})) %remove sessions with no SEF
  binfo(1) = [];
  moves(1) = [];
end

end%util:utilIsolateMonkeyBehavior()

