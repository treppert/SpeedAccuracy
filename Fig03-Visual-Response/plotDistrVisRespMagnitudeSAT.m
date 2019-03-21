function [ varargout ] = plotDistrVisRespMagnitudeSAT( ninfo , nstats , varargin )
%plotDistrVisRespMagnitudeSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxVis = ismember({ninfo.visType}, {'sustained'});

nstats = nstats(idxArea & idxMonkey & idxVis);
ninfo = ninfo(idxArea & idxMonkey & idxVis);

NUM_CELLS = length(nstats);

magAcc = [nstats.VRmagAcc];
magFast = [nstats.VRmagFast];

%compute the cumulative distribution function
magAcc = sort(magAcc);
magFast = sort(magFast);

yCDF = (1:NUM_CELLS) / NUM_CELLS;

figure(); hold on

plot(magAcc, yCDF, 'r.-', 'LineWidth',1.0, 'MarkerSize',10)
plot(magFast, yCDF, '.-', 'Color',[0 .7 0], 'LineWidth',1.0, 'MarkerSize',10)

ppretty([5,5])

%compute stats
[~,p,~,tstat] = ttest(magAcc-magFast);

if (nargout > 0)
  varargout{1} = struct('pval',p, 'tstat',tstat);
end

end%util:plotDistrVisRespMagnitudeSAT()

