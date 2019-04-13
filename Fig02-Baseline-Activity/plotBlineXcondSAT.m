function [ varargout ] = plotBlineXcondSAT( binfo , ninfo , nstats , spikes , varargin )
%plotBlineXcondSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
if strcmp(args.area, 'SEF')
  idxVis = ismember({ninfo.visType}, {'sustained'});
else
  idxVis = ([ninfo.visGrade] >= 0.5);
end
idxKeep = (idxArea & idxMonkey & idxVis);

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

NUM_CELLS = length(spikes);
T_BASE  = 3500 + (-600 : 20);

sdfAcc{1} = NaN(NUM_CELLS,length(T_BASE));    sdfAcc{2} = sdfAcc{1}; %split X efficiency
sdfFast{1} = NaN(NUM_CELLS,length(T_BASE));   sdfFast{2} = sdfFast{1};

for cc = 1:NUM_CELLS
  sdfCC = compute_spike_density_fxn(spikes(cc).SAT);
  kk = ismember({binfo.session}, ninfo(cc).sess);
  tt = ninfo(cc).taskType;

  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxAcc = ((binfo(kk).condition == 1) & ~idxIso);
  idxFast = ((binfo(kk).condition == 3) & ~idxIso);
  
  %compute SDFs
  sdfAcc{tt}(cc,:) = nanmean(sdfCC(idxAcc, T_BASE));
  sdfFast{tt}(cc,:) = nanmean(sdfCC(idxFast, T_BASE));
  
  %parameterize baseline activity
  ccNS = ninfo(cc).unitNum; %index nstats correctly
  nstats(ccNS).blineAccMEAN = mean(sdfAcc{tt}(cc,:));
  nstats(ccNS).blineFastMEAN = mean(sdfFast{tt}(cc,:));
  nstats(ccNS).blineAccSD = std(sdfAcc{tt}(cc,:));
  nstats(ccNS).blineFastSD = std(sdfFast{tt}(cc,:));
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = nstats;
end
nstats = nstats(idxKeep);
normFactor = mean([[nstats.blineAccMEAN] ; [nstats.blineFastMEAN]])';

%% Plotting - spike density function
%normalization -- equivalent for both efficiencies (!)
for tt = 1:2
  sdfAcc{tt} = sdfAcc{tt} ./ normFactor;
  sdfFast{tt} = sdfFast{tt} ./ normFactor;
end%for:task-efficiency(tt)

%split by task efficiency
idxEff = ([ninfo.taskType] == 1);   idxIneff = ([ninfo.taskType] == 2);

sdfAcc{1} = sdfAcc{1}(idxEff,:);    sdfAcc{2} = sdfAcc{2}(idxIneff,:);
sdfFast{1} = sdfFast{1}(idxEff,:);  sdfFast{2} = sdfFast{2}(idxIneff,:);

NSEM_EFF = sum(idxEff);   NSEM_INEFF = sum(idxIneff);

figure()

subplot(1,2,1); hold on %Efficient search
shaded_error_bar(T_BASE-3500, mean(sdfFast{1}), std(sdfFast{1})/sqrt(NSEM_EFF), {'-', 'Color',[0 .7 0], 'LineWidth',0.75})
shaded_error_bar(T_BASE-3500, mean(sdfAcc{1}), std(sdfAcc{1})/sqrt(NSEM_EFF), {'r-', 'LineWidth',0.75})
xlabel('Time from array (ms)')
ylabel('Normalized activity')
xlim([T_BASE(1)-20, T_BASE(end)]-3500); title('Efficient search', 'FontSize',8)

subplot(1,2,2); hold on %Inefficient search
shaded_error_bar(T_BASE-3500, mean(sdfFast{2}), std(sdfFast{2})/sqrt(NSEM_INEFF), {'-', 'Color',[0 .7 0], 'LineWidth',1.25})
shaded_error_bar(T_BASE-3500, mean(sdfAcc{2}), std(sdfAcc{2})/sqrt(NSEM_INEFF), {'r-', 'LineWidth',1.25})
xlim([T_BASE(1)-20, T_BASE(end)]-3500); title('Inefficient search', 'FontSize',8)

ppretty([9,3]); pause(0.1)


%% Plotting - histogram of avg baseline activity
%split by task efficiency
blineAccEff = [nstats(idxEff).blineAccMEAN];
blineFastEff = [nstats(idxEff).blineFastMEAN];
blineAccIneff = [nstats(idxIneff).blineAccMEAN];
blineFastIneff = [nstats(idxIneff).blineFastMEAN];

blineDiffEff = blineFastEff - blineAccEff;          blineEffectEff = [nstats(idxEff).blineEffect];
blineDiffIneff = blineFastIneff - blineAccIneff;    blineEffectIneff = [nstats(idxIneff).blineEffect];

figure()

subplot(1,2,1); hold on %Efficient search
histogram(blineDiffEff, 'BinWidth',2, 'FaceColor',[.5 .5 .5])
histogram(blineDiffEff(blineEffectEff==1), 'BinWidth',2, 'FaceColor',[0 .7 0])
histogram(blineDiffEff(blineEffectEff==-1), 'BinWidth',2, 'FaceColor','r')
plot(mean(blineDiffEff)*ones(1,2), [0 4], 'k:', 'LineWidth',2.0)
xlabel('Discharge rate diff. (sp/s')
ylabel('Number of neurons')
title('Efficient search', 'FontSize',8)

subplot(1,2,2); hold on %Inefficient search
histogram(blineDiffIneff, 'BinWidth',2, 'FaceColor',[.5 .5 .5])
histogram(blineDiffIneff(blineEffectIneff==1), 'BinWidth',2, 'FaceColor',[0 .7 0])
histogram(blineDiffIneff(blineEffectIneff==-1), 'BinWidth',2, 'FaceColor','r')
plot(mean(blineDiffIneff)*ones(1,2), [0 4], 'k:', 'LineWidth',2.0)
title('Inefficient search', 'FontSize',8)

ppretty([7,3])

%% Perform stats tests
blineAccEff = blineAccEff ./ normFactor(idxEff)';
blineFastEff = blineFastEff ./ normFactor(idxEff)';
blineAccIneff = blineAccIneff ./ normFactor(idxIneff)';
blineFastIneff = blineFastIneff ./ normFactor(idxIneff)';

%independent variable - NORMALIZED baseline discharge rate
baseline = [blineAccEff, blineAccIneff, blineFastEff, blineFastIneff]';
%two factors
condition = [ones(1,sum(idxEff | idxIneff)), 2*ones(1,sum(idxEff | idxIneff))]';
efficiency = [ones(1,sum(idxEff)), 2*ones(1,sum(idxIneff)), ones(1,sum(idxEff)), 2*ones(1,sum(idxIneff))]';

[~,ANtbl] = anovan(baseline, {condition efficiency}, 'model','interaction', 'varnames',{'Condition','Efficiency'}, 'display','off');

if (nargout > 1)
  varargout{2} = ANtbl;
end

blineDiff = [blineFastEff blineFastIneff] - [blineAccEff blineAccIneff];
fprintf('Baseline difference: %g +/- %g\n', mean(blineDiff), std(blineDiff))

end%fxn:plotBlineXcondSAT()

