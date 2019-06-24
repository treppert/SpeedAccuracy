function [ ] = ttestTom( X , Y )
%ttestTom Summary of this function goes here
%   Detailed explanation goes here

[~,pval,~,stats] = ttest(X, Y);

tval = stats.tstat;
DF = stats.df;

fprintf('Paired t-test: t%d = %g, p = %g\n', DF, tval, pval)

end%util:ttestTom()

