function [ varargout ] = plotDistrVisRespLatencySAT( ninfo , nstats , varargin )
%plotDistrVisRespLatencySAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxVis = ismember({ninfo.visType}, {'sustained'});

nstats = nstats(idxArea & idxMonkey & idxVis);
ninfo = ninfo(idxArea & idxMonkey & idxVis);

NUM_CELLS = length(nstats);

latAcc = [nstats.VRlatAcc];
latFast = [nstats.VRlatFast];

%plot the distribution of difference in latency
figure(); hold on
histogram(latAcc-latFast, 'BinWidth',5, 'FaceColor',[.4 .4 .4], 'Normalization','count')
ppretty([5,5])
pause(0.25)

%compute the cumulative distribution
latAcc = sort(latAcc);
latFast = sort(latFast);

yCDF = (1:NUM_CELLS) / NUM_CELLS;

figure(); hold on
plot(latAcc, yCDF, 'r.-', 'LineWidth',1.0, 'MarkerSize',10)
plot(latFast, yCDF, '.-', 'Color',[0 .7 0], 'LineWidth',1.0, 'MarkerSize',10)
ppretty([5,5])

%compute stats
[~,p,~,tstat] = ttest(latAcc-latFast);

if (nargout > 0)
  varargout{1} = struct('pval',p, 'tstat',tstat);
end

end%util:plotDistrVisRespLatencySAT()

