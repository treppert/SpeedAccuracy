function [ ] = anova_TwoWay_Between_SAT( Y , Condition , Efficiency , varargin )
%anova_TwoWay_Between_SAT Summary of this function goes here
%   Input
%     'display' -- {'on','off'} -- Show ANOVA table as output?
%     'model' -- {'linear','interaction','full'}
%     'sstype' -- {'1','2','3'} -- Form of computation of sum of squares
% 

args = getopt(varargin, {{'display=','on'}, {'model=','full'}, {'sstype=',3}});

[~,tbl] = anovan(Y, {Condition Efficiency}, ...
  'display',args.display, ...
  'model',args.model, ...
  'sstype',args.sstype, ...
  'varnames',{'Condition','Efficiency'});

end % fxn : anova_TwoWay_Between_SAT()

