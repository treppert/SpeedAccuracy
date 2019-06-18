function [ varargout ] = plotBlineXcondSAT( binfo , ninfo , nstats , spikes , varargin )
%plotBlineXcondSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=',{'SEF'}}, {'type=',{'Vis'}}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxBlineRate = ([nstats.blineAccMEAN] >= 3); %!!! minimum baseline discharge rate

idxVis = ([ninfo.visGrade] >= 2);   idxMove = ([ninfo.moveGrade] >= 2);
idxError = ([ninfo.errGrade] >= 2); idxReward = (abs([ninfo.rewGrade]) >= 2);

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

NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

idxMore = ([ninfo.taskType] == 1);   NUM_MORE = sum(idxMore);
idxLess = ([ninfo.taskType] == 2);   NUM_LESS = sum(idxLess);

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
  
  sdfAccCC = nanmean(sdfCC(idxAcc & idxCorr, T_BASE));
  sdfFastCC = nanmean(sdfCC(idxFast & idxCorr, T_BASE));
  
  if (idxMore(cc)) %more efficient session
    jjMore = jjMore + 1;
    sdfAccMore(jjMore,:) = sdfAccCC;
    sdfFastMore(jjMore,:) = sdfFastCC;
  else %less efficient session
    jjLess = jjLess + 1;
    sdfAccLess(jjLess,:) = sdfAccCC;
    sdfFastLess(jjLess,:) = sdfFastCC;
  end
  
  %parameterize baseline activity
%   ccNS = ninfo(cc).unitNum; %index nstats correctly
%   nstats(ccNS).blineAccMEAN = mean(sdfAccCC);
%   nstats(ccNS).blineFastMEAN = mean(sdfFastCC);
%   nstats(ccNS).blineAccSD = std(sdfAccCC);
%   nstats(ccNS).blineFastSD = std(sdfFastCC);
  
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
sdfAccMore = sdfAccMore ./ normFactor(idxMore);
sdfFastMore = sdfFastMore ./ normFactor(idxMore);
sdfAccLess = sdfAccLess ./ normFactor(idxLess);
sdfFastLess = sdfFastLess ./ normFactor(idxLess);

figure()

subplot(1,2,1); hold on %more efficient
shaded_error_bar(T_BASE-3500, mean(sdfFastMore), std(sdfFastMore)/sqrt(NUM_CELLS), {'-', 'Color',[0 .7 0], 'LineWidth',0.75})
shaded_error_bar(T_BASE-3500, mean(sdfAccMore), std(sdfAccMore)/sqrt(NUM_CELLS), {'r-', 'LineWidth',0.75})
xlabel('Time from array (ms)')
ylabel('Normalized activity'); ytickformat('%3.2f')
xlim([T_BASE(1)-20, T_BASE(end)]-3500);
yLimMore = get(gca, 'ylim');

subplot(1,2,2); hold on %less efficient
shaded_error_bar(T_BASE-3500, mean(sdfFastLess), std(sdfFastLess)/sqrt(NUM_CELLS), {'-', 'Color',[0 .7 0], 'LineWidth',1.5})
shaded_error_bar(T_BASE-3500, mean(sdfAccLess), std(sdfAccLess)/sqrt(NUM_CELLS), {'r-', 'LineWidth',1.5})
ytickformat('%3.2f')
xlim([T_BASE(1)-20, T_BASE(end)]-3500);
yLimLess = get(gca, 'ylim');

ppretty([8,1.5]); pause(0.05)

yLim = [min([yLimMore(1), yLimLess(1)]), max([yLimMore(2), yLimLess(2)])];
set(gca, 'ylim',yLim); subplot(1,2,1); set(gca, 'ylim',yLim)

end%fxn:plotBlineXcondSAT()

