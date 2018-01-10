function [ moves ] = compute_vigor_SAT( moves , parm_ms )
%compute_vigor_SAT Summary of this function goes here
%   Detailed explanation goes here

tasks = fieldnames(moves);
NUM_TASKS = length(tasks);
NUM_SESSION = length(moves.(tasks{1}));

FXN_DEF_MS = fittype({'x'}); %linear fit

for jj = 1:NUM_TASKS
  
  for kk = 1:NUM_SESSION

    pv_actual = moves.(tasks{jj})(kk).peakvel;
    pv_expected = FXN_DEF_MS(parm_ms.a, moves.(tasks{jj})(kk).displacement);

    moves.(tasks{jj})(kk).vigor(:) = pv_actual ./ pv_expected;

  end%for:sessions(kk)
  
end%for:tasks(jj)
end%function:compute_vigor_SAT()
