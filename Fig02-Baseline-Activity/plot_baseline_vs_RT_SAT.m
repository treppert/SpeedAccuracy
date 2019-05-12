function [ varargout ] = plot_baseline_vs_RT_SAT( binfo , moves , ninfo , nstats , spikes , varargin )
%plot_baseline_vs_RT_SAT Summary of this function goes here
%   Detailed explanation goes here

MIN_NUM_CELLS = 3; %for plotting across all cells
PLOT_INDIV_CELLS = false;
LIM_RT = [100,1000];

args = getopt(varargin, {'export', {'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
if strcmp(args.area, 'SEF')
  idxVis = ismember({ninfo.visType}, {'sustained','phasic'});
else
  idxVis = ([ninfo.visGrade] >= 0.5);
end
idxErrorGrade = (abs([ninfo.errGrade]) >= 0.5);
idxBlineRate = ([nstats.blineAccMEAN] >= 5); %minimum baseline discharge rate
idxBlineEffect = ([nstats.blineEffect] == 1);

idxKeep = (idxArea & idxMonkey & idxBlineRate & idxBlineEffect);

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);
NUM_CELLS = length(spikes);

BIN_RT_ACC = (400 : 40 : 700);
BIN_RT_FAST = (200 : 30 : 400);

RT_PLOT_ACC = BIN_RT_ACC(1:end-1) + diff(BIN_RT_ACC)/2;     NUM_BIN_ACC = length(RT_PLOT_ACC);
RT_PLOT_FAST = BIN_RT_FAST(1:end-1) + diff(BIN_RT_FAST)/2;  NUM_BIN_FAST = length(RT_PLOT_FAST);

TIME_BASE = ( -600 : 20 );
IDX_BASE = TIME_BASE([1,end]) + 3500;

%initializations
spkCtAcc = NaN(NUM_CELLS,NUM_BIN_ACC);
spkCtFast = NaN(NUM_CELLS,NUM_BIN_FAST);

%stats
rhoAcc = NaN(1,NUM_CELLS);    rhoFast = NaN(1,NUM_CELLS);
pvalAcc = NaN(1,NUM_CELLS);   pvalFast = NaN(1,NUM_CELLS);

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  rtKK = double(moves(kk).resptime);
  
  %remove outlier values for RT
  rtKK((rtKK > LIM_RT(2)) | (rtKK < LIM_RT(1))) = NaN;
  idxNaN = isnan(rtKK);
  
  %get spike counts for each trial
  spkCtKK = NaN(1,binfo(kk).num_trials);
  for jj = 1:binfo(kk).num_trials
    spkCtKK(jj) = sum((spikes(cc).SAT{jj} > IDX_BASE(1)) & (spikes(cc).SAT{jj} > IDX_BASE(2)));
  end
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxAcc = ((binfo(kk).condition == 1) & ~idxIso);
  idxFast = ((binfo(kk).condition == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_nosacc);
  
  rtAccKK = rtKK(idxAcc & idxCorr & ~idxIso & ~idxNaN);
  spkCtAccCC = spkCtKK(idxAcc & idxCorr & ~idxIso & ~idxNaN);
  rtFastKK = rtKK(idxFast & idxCorr & ~idxIso & ~idxNaN);
  spkCtFastCC = spkCtKK(idxFast & idxCorr & ~idxIso & ~idxNaN);
  
  fitLinAcc = fit(rtAccKK', spkCtAccCC', 'poly1');
  fitLinFast = fit(rtFastKK', spkCtFastCC', 'poly1');
  
  %linear regression to determine cells that show a postive relationship
  [rhoAcc(cc),pvalAcc(cc)] = corr(rtAccKK', spkCtAccCC', 'type','Spearman');
  [rhoFast(cc),pvalFast(cc)] = corr(rtFastKK', spkCtFastCC', 'type','Spearman');
  
  %save the statistics from the Spearman rank correlation test
  ccNS = ninfo(cc).unitNum;
  if (pvalAcc(cc) < 0.054)
    nstats(ccNS).blineRhoRTvsSpkCt_Acc = rhoAcc(cc);
  else
    nstats(ccNS).blineRhoRTvsSpkCt_Acc = NaN;
  end
  if (pvalFast(cc) < 0.054)
    nstats(ccNS).blineRhoRTvsSpkCt_Fast = rhoFast(cc);
  else
    nstats(ccNS).blineRhoRTvsSpkCt_Fast = NaN;
  end
  
  if (PLOT_INDIV_CELLS)
    figure()
    subplot(2,1,1); hold on
    scatter(rtAccKK, spkCtAccCC, 20, 'r', 'filled')
    plot([BIN_RT_ACC(1),BIN_RT_ACC(end)], fitLinAcc([BIN_RT_ACC(1),BIN_RT_ACC(end)]), 'k-')
    ylabel('Baseline spike count')
    title(['R = ',num2str(rhoAcc(cc)),'  p = ',num2str(pvalAcc(cc))])
    print_session_unit(gca, ninfo(cc), [])
    
    subplot(2,1,2); hold on
    scatter(rtFastKK, spkCtFastCC, 20, [0 .7 0], 'filled')
    plot([BIN_RT_FAST(1),BIN_RT_FAST(end)], fitLinFast([BIN_RT_FAST(1),BIN_RT_FAST(end)]), 'k-')
    xlabel('Response time (ms)')
    title(['R = ',num2str(rhoFast(cc)),'  p = ',num2str(pvalFast(cc))])
    
    ppretty([4.8,7])
    pause()
  end
  
end%for:cells(cc)

figure()
subplot(2,2,1); hold on
histogram(-log(pvalAcc), 'FaceColor','r', 'BinWidth',1)
plot(-log(.05)*ones(1,2), [0 10], 'k--', 'LineWidth',1.25)
plot(-log(.01)*ones(1,2), [0 10], 'k--', 'LineWidth',1.25)
ylabel('Number of neurons')

subplot(2,2,2); hold on
histogram(rhoAcc(pvalAcc<.054), 'FaceColor','r', 'BinWidth',.05)
xLimAcc = get(gca, 'xlim');

subplot(2,2,3); hold on
histogram(-log(pvalFast), 'FaceColor',[0 .7 0], 'BinWidth',1)
plot(-log(.05)*ones(1,2), [0 10], 'k--', 'LineWidth',1.25)
plot(-log(.01)*ones(1,2), [0 10], 'k--', 'LineWidth',1.25)
xlabel('-log(p)')

subplot(2,2,4); hold on
histogram(rhoFast(pvalFast<.054), 'FaceColor',[0 .7 0], 'BinWidth',.05)
xlabel('Spearman correlation coefficient')
xLimFast = get(gca, 'xlim');

xLim = [min([xLimAcc(1) xLimFast(1)]) max([xLimAcc(2) xLimFast(2)])];
set(gca, 'xlim', xLim); subplot(2,2,2); set(gca, 'xlim',xLim)

ppretty([6.4,4])

if (nargout > 0)
  varargout{1} = nstats;
end

return

%% Plotting
if strcmp(condition, 'acc')
  COLOR_PLOT = 'r';
else
  COLOR_PLOT = [0 .7 0];
end

spkCtAcc(:,sum(~isnan(spkCtAcc),1) < MIN_NUM_CELLS) = NaN;
NUM_SEM = sum(~isnan(spkCtAcc),1);

%perform a linear fit to the data
xx_fit = repmat(RT_PLOT_ACC', NUM_CELLS,1);
yy_fit = reshape(spkCtAcc', NUM_CELLS*NUM_BIN,1);
i_nan = isnan(yy_fit);
xx_fit(i_nan) = [];
yy_fit(i_nan) = [];
[fitLinAcc,gof_lin] = fit(xx_fit, yy_fit, 'poly1');

figure(); hold on
% plot(RT_PLOT, sp_Corr, 'ko')
plot(RT_PLOT_ACC, fitLinAcc(RT_PLOT_ACC), '-', 'color',COLOR_PLOT)
errorbar_no_caps(RT_PLOT_ACC, nanmean(spkCtAcc), 'err',nanstd(spkCtAcc)./sqrt(NUM_SEM), 'color',COLOR_PLOT)
ppretty()

pause(0.25)

figure(); hold on
plot([-.2 .3], -log(.05)*ones(1,2), '-', 'Color',[.5 .5 .5])
plot([-.2 .3], -log(.01)*ones(1,2), '-', 'Color',[.5 .5 .5])
plot([-.2 .3], -log(.001)*ones(1,2), '-', 'Color',[.5 .5 .5])
plot(rhoAcc, -log(pvalAcc), 'ko')
ppretty('image_size',[3.2,5])

end%fxn:plot_baseline_vs_RT_SAT()

