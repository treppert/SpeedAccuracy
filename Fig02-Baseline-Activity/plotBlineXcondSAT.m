function [ varargout ] = plotBlineXcondSAT( binfo , ninfo , nstats , spikes , varargin )
%plotBlineXcondSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxVis = ([ninfo.visGrade] >= 0.5);
idxKeep = (idxArea & idxMonkey & idxVis);

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

NUM_CELLS = length(spikes);
T_BASE  = 3500 + (-200 : 20);

sdfAcc = NaN(NUM_CELLS,length(T_BASE));
sdfFast = NaN(NUM_CELLS,length(T_BASE));

for cc = 1:NUM_CELLS
%   if ~(ninfo(cc).baseLine); continue; end %make sure we have modulation Fast > Acc
  kk = ismember({binfo.session}, ninfo(cc).sess);
  sdfKK = compute_spike_density_fxn(spikes(cc).SAT);

  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxAcc = ((binfo(kk).condition == 1) & ~idxIso);
  idxFast = ((binfo(kk).condition == 3) & ~idxIso);
  
  %compute SDFs
  sdfAcc(cc,:) = nanmean(sdfKK(idxAcc, T_BASE));
  sdfFast(cc,:) = nanmean(sdfKK(idxFast, T_BASE));
  
  %parameterize baseline activity
  ccNS = ninfo(cc).unitNum; %index nstats correctly
  nstats(ccNS).blineAccMEAN = mean(sdfAcc(cc,:));
  nstats(ccNS).blineFastMEAN = mean(sdfFast(cc,:));
  nstats(ccNS).blineAccSD = std(sdfAcc(cc,:));
  nstats(ccNS).blineFastSD = std(sdfFast(cc,:));
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = nstats;
end

%% Plotting
blineAcc = [nstats(idxKeep).blineAccMEAN];
blineFast = [nstats(idxKeep).blineFastMEAN];

blineDiff = blineFast - blineAcc;
blineEffect = [nstats(idxKeep).blineEffect];

figure(); hold on
histogram(blineDiff, 'BinWidth',2, 'FaceColor',[.5 .5 .5])
histogram(blineDiff(blineEffect==1), 'BinWidth',2, 'FaceColor',[0 .7 0])
histogram(blineDiff(blineEffect==-1), 'BinWidth',2, 'FaceColor','r')
plot(mean(blineDiff)*ones(1,2), [0 10], 'k:', 'LineWidth',1.5)
ppretty([5,4])


%stats
fprintf('Baseline Acc: %g +/- %g\n', mean(blineAcc), std(blineAcc))
fprintf('Baseline Fast: %g +/- %g\n', mean(blineFast), std(blineFast))
[~,pval,~,stat] = ttest(blineAcc, blineFast, 'Alpha',.05, 'Tail','both');
fprintf('Diff: p = %g  t_%d = %g\n', pval, stat.df, stat.tstat)

end%fxn:plotBlineXcondSAT()

