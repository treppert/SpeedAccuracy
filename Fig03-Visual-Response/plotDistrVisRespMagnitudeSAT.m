function [ varargout ] = plotDistrVisRespMagnitudeSAT( ninfo , nstats , varargin )
%plotDistrVisRespMagnitudeSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxVis = ismember({ninfo.visType}, {'sustained'});

nstats = nstats(idxArea & idxMonkey & idxVis);

magAcc = [nstats.VRmagAcc];
magFast = [nstats.VRmagFast];
magDiff = magFast - magAcc;

%plot distribution of difference in response magnitude
ccFgA = ([nstats.VReffect] == 1); %cells with VR Fast > Acc
ccAgF = ([nstats.VReffect] == -1); %cells with VR Acc > Fast

figure(); hold on
histogram(magDiff, 'BinWidth',2, 'FaceColor',[.4 .4 .4], 'Normalization','count')
histogram(magDiff(ccFgA), 'BinWidth',2, 'FaceColor',[0 .7 0], 'Normalization','count')
histogram(magDiff(ccAgF), 'BinWidth',2, 'FaceColor','r', 'Normalization','count')
plot(mean(magDiff)*ones(1,2), [0 5], 'k--')
ppretty([5,5])

fprintf('Difference in magnitude (Acc-Fast) = %g +- %g\n', mean(magDiff), std(magDiff))

if (nargout > 0) %if desired, compute across-neuron stats
  [~,p,~,tstat] = ttest(magDiff);
  varargout{1} = struct('pval',p, 'tstat',tstat);
end

end%util:plotDistrVisRespMagnitudeSAT()

