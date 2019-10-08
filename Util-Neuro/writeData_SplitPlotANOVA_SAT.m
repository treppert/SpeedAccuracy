function [ ] = writeData_SplitPlotANOVA_SAT( param , fname , varargin )
%writeData_SplitPlotANOVA_SAT This function writes to a .mat file data
%formatted for computation of split-plot ANOVA in R, with factors Task
%Condition (Fast/Accurate), and search efficiency (More/Less)
%   
%   Note: Input "param" should have the following fields:
%     AccMore
%     AccLess
%     FastMore
%     FastLess
% 

args = getopt(varargin, {'compareBetweenANOVA'});
rootDir = 'C:\Users\Thomas Reppert\Dropbox\SAT\Stats\';

numCells_More = length(param.AccMore);
numCells_Less = length(param.AccLess);
numCells = numCells_More + numCells_Less;

%dependent variable
param_Acc =   [ param.AccMore param.AccLess ]';
param_Fast =  [ param.FastMore param.FastLess ]';

%factors
% F_Condition = [ ones(1,numCells) 2*ones(1,numCells) ]';
F_Efficiency = [ ones(1,numCells_More) 2*ones(1,numCells_Less) ]';
F_Neuron = (1 : numCells)';

%write data
save([rootDir, fname], 'param_Acc','param_Fast','F_Efficiency','F_Neuron')

%if desired, perform a two-way between-subjects ANOVA for comparison
if (args.compareBetweenANOVA)
  tmp = [param.AccMore param.AccLess param.FastMore param.FastLess]';
  Condition = [ones(1,numCells) 2*ones(1,numCells)]';
  Efficiency = [ones(1,numCells_More) 2*ones(1,numCells_Less) ones(1,numCells_More) 2*ones(1,numCells_Less)]';
  anovan(tmp, {Condition Efficiency}, 'model','interaction', 'sstype',2, 'varnames',{'Condition','Efficiency'});
end

end % util : writeData_SplitPlotANOVA_SAT()

