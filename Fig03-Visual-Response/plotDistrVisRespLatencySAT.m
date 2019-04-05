function [ varargout ] = plotDistrVisRespLatencySAT( ninfo , nstats , varargin )
%plotDistrVisRespLatencySAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxVis = ismember({ninfo.visType}, {'sustained'});

nstats = nstats(idxArea & idxMonkey & idxVis);

latAcc = [nstats.VRlatAcc];
latFast = [nstats.VRlatFast];
latDiff = latAcc - latFast;

%plot distribution of difference in response magnitude
ccFgA = ([nstats.VReffect] == 1); %cells with VR Fast > Acc
ccAgF = ([nstats.VReffect] == -1); %cells with VR Acc > Fast

figure(); hold on
histogram(latDiff, 'BinWidth',5, 'FaceColor',[.4 .4 .4], 'Normalization','count')
% histogram(latDiff(ccFgA), 'BinWidth',5, 'FaceColor',[0 .7 0], 'Normalization','count')
% histogram(latDiff(ccAgF), 'BinWidth',5, 'FaceColor','r', 'Normalization','count')
plot(mean(latDiff)*ones(1,2), [0 5], 'k--') %mark the mean
ppretty([5,5])

fprintf('Difference in latency (Acc-Fast) = %g +- %g\n', mean(latDiff), std(latDiff))

if (nargout > 0) %if desired, compute across-neuron stats
  [~,p,~,tstat] = ttest(latDiff);
  varargout{1} = struct('pval',p, 'tstat',tstat);
end

end%util:plotDistrVisRespLatencySAT()

