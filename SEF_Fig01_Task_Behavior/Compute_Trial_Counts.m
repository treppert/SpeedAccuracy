
N_Correct = NaN(16,1);
N_ChoiceErrOnly = N_Correct;
N_TimeErrOnly = N_Correct;
N_BothErr = N_Correct;

CONDITION = 1; %Accurate
% CONDITION = 3; %Fast

for k = 1:16

  N_Correct(k) = sum( (behavData.Task_SATCondition{k} == CONDITION) & behavData.Task_Correct{k} );
  N_BothErr(k) = sum( (behavData.Task_SATCondition{k} == CONDITION) & behavData.Task_ErrTime{k} & behavData.Task_ErrChoice{k} );
  N_TimeErrOnly(k) = sum( (behavData.Task_SATCondition{k} == CONDITION) & behavData.Task_ErrTimeOnly{k} );
  N_ChoiceErrOnly(k) = sum( (behavData.Task_SATCondition{k} == CONDITION) & behavData.Task_ErrChoiceOnly{k} );

end

X = [N_Correct, N_ChoiceErrOnly, N_TimeErrOnly, N_BothErr];
