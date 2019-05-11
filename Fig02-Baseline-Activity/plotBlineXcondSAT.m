function [ varargout ] = plotBlineXcondSAT( binfo , ninfo , nstats , spikes , varargin )
%plotBlineXcondSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
if strcmp(args.area, 'SEF')
  idxVis = ismember({ninfo.visType}, {'sustained','phasic'});
else
  idxVis = ([ninfo.visGrade] >= 0.5);
end
idxBlineRate = ([nstats.blineAccMEAN] >= 5); %minimum baseline discharge rate
idxKeep = (idxArea & idxMonkey & idxVis & idxBlineRate);

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);
NUM_CELLS = length(spikes);

idxMoreE = ([ninfo.taskType] == 1);   NUM_MORE = sum(idxMoreE);
idxLessE = ([ninfo.taskType] == 2);   NUM_LESS = sum(idxLessE);

T_BASE  = 3500 + (-600 : 20);

sdfAccMore = NaN(NUM_MORE,length(T_BASE)); sdfFastMore = sdfAccMore;
sdfAccLess = NaN(NUM_LESS,length(T_BASE)); sdfFastLess = sdfAccLess;

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

%% Plotting - histogram of baseline difference
% blineDiff = mean(sdfBaseFast,2) - mean(sdfBaseAcc,2);
% 
% figure(); hold on
% histogram(blineDiff, 'FaceColor',[.5 .5 .5])
% % histogram(blineDiff(blineEffect==1), 'FaceColor',[0 .7 0])
% plot(mean(blineDiff)*ones(1,2), [0 4], 'k:', 'LineWidth',2.0)
% xlabel('Discharge rate diff. (sp/s')
% ylabel('Number of neurons')
% 
% ppretty([4.8,3]); pause(0.05)

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
ylabel('Normalized activity')
xlim([T_BASE(1)-20, T_BASE(end)]-3500);
yLimMore = get(gca, 'ylim');

subplot(1,2,2); hold on %less efficient
title('Less efficient', 'FontSize',8)
shaded_error_bar(T_BASE-3500, mean(sdfFastLess), std(sdfFastLess)/sqrt(NUM_CELLS), {'-', 'Color',[0 .7 0], 'LineWidth',1.5})
shaded_error_bar(T_BASE-3500, mean(sdfAccLess), std(sdfAccLess)/sqrt(NUM_CELLS), {'r-', 'LineWidth',1.5})
xlabel('Time from array (ms)')
xlim([T_BASE(1)-20, T_BASE(end)]-3500);
yLimLess = get(gca, 'ylim');

ppretty([10,3])

yLim = [min([yLimMore(1), yLimLess(1)]), max([yLimMore(2), yLimLess(2)])];
set(gca, 'ylim',yLim); subplot(1,2,1); set(gca, 'ylim',yLim)

end%fxn:plotBlineXcondSAT()

