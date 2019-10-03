function [ ] = plot_ISI_Distr( binfo , primarySacc , secondSacc )
%plot_ISI_Distr Summary of this function goes here
%   Detailed explanation goes here

NUM_SESS = size(binfo,1);

QUANT = (0.1 : 0.1 : 0.9); %quantiles of inter-saccade interval
NUM_QUANT = length(QUANT);

isiAcc = NaN(NUM_SESS, NUM_QUANT);
isiFast = NaN(NUM_SESS, NUM_QUANT);

for kk = 1:NUM_SESS
  
  %index by condition
  idxAcc = (binfo.condition{kk} == 1);
  idxFast = (binfo.condition{kk} == 3);
  %index by trial outcome
  idxErrChc = (binfo.err_dir{kk} & ~binfo.err_time{kk});
  %index by second saccade endpoint
  idxTgt = (secondSacc.endpt{kk} == 1);
  idxDistr = (secondSacc.endpt{kk} == 2);
  
  %compute inter-saccade interval (ISI)
  ISIkk = secondSacc.resptime{kk} - (primarySacc.resptime{kk} + primarySacc.duration{kk});
  
  %compute quantiles
  isiAcc(kk,:) = quantile(ISIkk(idxAcc & idxErrChc & (idxTgt | idxDistr)), QUANT);
  isiFast(kk,:) = quantile(ISIkk(idxFast & idxErrChc & (idxTgt | idxDistr)), QUANT);
  
end%for:session(kk)

ttestTom(isiAcc(:,5), isiFast(:,5))

%% Plotting

figure(); hold on
shadedErrorBar(QUANT, mean(isiAcc), std(isiAcc)/sqrt(NUM_SESS), 'lineprops', {'-r', 'LineWidth',0.75}, 'transparent',true)
shadedErrorBar(QUANT, mean(isiFast), std(isiFast)/sqrt(NUM_SESS), 'lineprops', {'-', 'Color',[0 .7 0], 'LineWidth',0.75}, 'transparent',true)
% errorbar(QUANT+.01, mean(isiAcc), std(isiAcc)/sqrt(NUM_SESS), 'Color','r', 'LineWidth',0.75, 'CapSize',0)
% errorbar(QUANT+.01, mean(isiFast), std(isiFast)/sqrt(NUM_SESS), 'Color',[0 .7 0], 'LineWidth',0.75, 'CapSize',0)
xlim([.05 .95])
ppretty([3,4])

end % fxn : plot_ISI_Distr()

