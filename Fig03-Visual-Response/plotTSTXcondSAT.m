function [ ] = plotTSTXcondSAT( ninfo , nstats , varargin )
%plotTSTXcondSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxVis = ([ninfo.visGrade] >= 0.5);
% idxVis = ismember({ninfo.visType}, {'sustained'});
idxTST = ~(isnan([nstats.VRTSTAcc]) | isnan([nstats.VRTSTFast]));

idxKeep = (idxArea & idxMonkey & idxVis & idxTST);

ninfo = ninfo(idxKeep);
nstats = nstats(idxKeep);

idxEff = ([ninfo.taskType] == 1);
idxIneff = ([ninfo.taskType] == 2);

TSTAccEff = [nstats(idxEff).VRTSTAcc];
TSTAccIneff = [nstats(idxIneff).VRTSTAcc];
TSTFastEff = [nstats(idxEff).VRTSTFast];
TSTFastIneff = [nstats(idxIneff).VRTSTFast];

%% Plotting

%scatterplot
figure(); hold on
plot([60 240], [60 240], 'k:', 'LineWidth',0.75)
plot(TSTAccEff, TSTFastEff, 'k.', 'MarkerSize',25)
plot(TSTAccIneff, TSTFastIneff, 'ko', 'MarkerSize',7)
xlabel('Target selection time (ms)')
ylabel('Target selection time (ms)')
ppretty([5,4])
axis square

pause(0.25)

%histogram
figure(); hold on
histogram([TSTAccEff TSTAccIneff]-[TSTFastEff TSTFastIneff], 'BinWidth',10, 'FaceColor',[.5 .5 .5])
ppretty([5,4])

end%fxn:plotTSTXcondSAT()

