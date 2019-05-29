function [ varargout ] = plotBlineXcondSAT( binfo , ninfo , nstats , spikes , varargin )
%plotBlineXcondSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=',{'SEF'}}, {'type=',{'Vis'}}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxBlineRate = ([nstats.blineAccMEAN] >= 5); %!!! minimum baseline discharge rate

idxVis = ([ninfo.visGrade] >= 2);
idxMove = ([ninfo.moveGrade] >= 2);
idxError = (abs([ninfo.errGrade]) >= 2);
idxReward = (abs([ninfo.rewGrade]) >= 2);

idxKeep = (idxArea & idxMonkey & idxBlineRate);
if ismember(args.type, 'Vis')
  idxKeep = (idxKeep & idxVis);
end
if ismember(args.type, 'Move')
  idxKeep = (idxKeep & idxMove);
end
if ismember(args.type, 'Error')
  idxKeep = (idxKeep & idxError);
end
if ismember(args.type, 'Reward')
  idxKeep = (idxKeep & idxReward);
end

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);
NUM_CELLS = length(spikes);

idxMoreE = ([ninfo.taskType] == 1);   NUM_MORE = sum(idxMoreE);
idxLessE = ([ninfo.taskType] == 2);   NUM_LESS = sum(idxLessE);

T_BASE  = 3500 + (-600 : 20);

sdfAccMore = NaN(NUM_MORE,length(T_BASE));    sdfFastMore = sdfAccMore;
sdfAccLess = NaN(NUM_LESS,length(T_BASE));    sdfFastLess = sdfAccLess;

jjMore = 0; %counter for more efficient sessions
jjLess = 0; %counter for less efficient sessions

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  sdfCC = compute_spike_density_fxn(spikes(cc).SAT);

  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxAcc = ((binfo(kk).condition == 1) & ~idxIso);
  idxFast = ((binfo(kk).condition == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc);
  
  if (idxMoreE(cc)) %more efficient session
    jjMore = jjMore + 1;
    sdfAccMore(jjMore,:) = nanmean(sdfCC(idxAcc & idxCorr, T_BASE));
    sdfFastMore(jjMore,:) = nanmean(sdfCC(idxFast & idxCorr, T_BASE));
  else %less efficient session
    jjLess = jjLess + 1;
    sdfAccLess(jjLess,:) = nanmean(sdfCC(idxAcc & idxCorr, T_BASE));
    sdfFastLess(jjLess,:) = nanmean(sdfCC(idxFast & idxCorr, T_BASE));
  end
  
  %parameterize baseline activity
%   ccNS = ninfo(cc).unitNum; %index nstats correctly
%   nstats(ccNS).blineAccMEAN = mean(sdfBaseAcc(cc,:));
%   nstats(ccNS).blineFastMEAN = mean(sdfBaseFast(cc,:));
%   nstats(ccNS).blineAccSD = std(sdfBaseAcc(cc,:));
%   nstats(ccNS).blineFastSD = std(sdfBaseFast(cc,:));
  
end%for:cells(cc)

if ((jjMore ~= NUM_MORE) || (jjLess ~= NUM_LESS))
  error('Check on search efficiency counters failed')
end

if (nargout > 0)
  varargout{1} = nstats;
end

%% Plotting - spike density function
nstats = nstats(idxKeep);

%normalization
normFactor = mean([[nstats.blineAccMEAN] ; [nstats.blineFastMEAN]])';
sdfAccMore = sdfAccMore ./ normFactor(idxMoreE);
sdfFastMore = sdfFastMore ./ normFactor(idxMoreE);
sdfAccLess = sdfAccLess ./ normFactor(idxLessE);
sdfFastLess = sdfFastLess ./ normFactor(idxLessE);

figure()

subplot(1,2,1); hold on %more efficient
title('More efficient', 'FontSize',8)
shaded_error_bar(T_BASE-3500, mean(sdfFastMore), std(sdfFastMore)/sqrt(NUM_CELLS), {'-', 'Color',[0 .7 0], 'LineWidth',0.75})
shaded_error_bar(T_BASE-3500, mean(sdfAccMore), std(sdfAccMore)/sqrt(NUM_CELLS), {'r-', 'LineWidth',0.75})
xlabel('Time from array (ms)')
ylabel('Normalized activity'); ytickformat('%3.2f')
xlim([T_BASE(1)-20, T_BASE(end)]-3500);
yLimMore = get(gca, 'ylim');

subplot(1,2,2); hold on %less efficient
title('Less efficient', 'FontSize',8)
shaded_error_bar(T_BASE-3500, mean(sdfFastLess), std(sdfFastLess)/sqrt(NUM_CELLS), {'-', 'Color',[0 .7 0], 'LineWidth',1.5})
shaded_error_bar(T_BASE-3500, mean(sdfAccLess), std(sdfAccLess)/sqrt(NUM_CELLS), {'r-', 'LineWidth',1.5})
ytickformat('%3.2f')
xlim([T_BASE(1)-20, T_BASE(end)]-3500);
yLimLess = get(gca, 'ylim');

ppretty([10,1.5]); pause(0.05)

yLim = [min([yLimMore(1), yLimLess(1)]), max([yLimMore(2), yLimLess(2)])];
set(gca, 'ylim',yLim); subplot(1,2,1); set(gca, 'ylim',yLim)

%% Plotting - histogram of baseline difference
blineDiffMore = mean(sdfFastMore,2) - mean(sdfAccMore,2);
blineDiffLess = mean(sdfFastLess,2) - mean(sdfAccLess,2);

figure()

subplot(2,1,1); hold on
histogram(blineDiffMore, 'BinWidth',.05, 'FaceColor',[.4 .4 .4], 'LineWidth',0.75)
plot(mean(blineDiffMore)*ones(1,2), [0 4], 'k:', 'LineWidth',1.5)
ylabel('Number of neurons')
xtickformat('%2.1f')
xLimMore = get(gca, 'xlim');

subplot(2,1,2); hold on
histogram(blineDiffLess, 'BinWidth',.05, 'FaceColor',[.4 .4 .4], 'LineWidth',1.5)
plot(mean(blineDiffLess)*ones(1,2), [0 4], 'k:', 'LineWidth',1.5)
xlabel('Discharge rate diff. (sp/s'); xtickformat('%2.1f')
xLimLess = get(gca, 'xlim');

ppretty([4.8,1.8])
subplot(2,1,1); set(gca, 'YMinorTick','off')
subplot(2,1,2); set(gca, 'YMinorTick','off')

xLim = [min([xLimMore(1) xLimLess(1)]) , max([xLimMore(2) xLimLess(2)])];
set(gca, 'xlim',xLim); subplot(2,1,1); set(gca, 'xlim',xLim)


end%fxn:plotBlineXcondSAT()

