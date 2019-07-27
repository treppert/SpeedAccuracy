function [ ] = ttestTom( X , Y )
%ttestTom Summary of this function goes here
%   Detailed explanation goes here

%two-tailed t-test
[~,pval,~,stats] = ttest(X, Y);
tval = stats.tstat;
DF = stats.df;

%corresponding Bayes factor
bFac = bf.ttest(X, Y);

fprintf('Paired t-test: t%d = %g, p = %g, BF = %g\n', DF, tval, pval, bFac)

end%util:ttestTom()

