function [ ] = plot_ISI_Distr( binfo , primarySacc , secondSacc )
%plot_ISI_Distr Summary of this function goes here
%   Detailed explanation goes here

NUM_SESS = size(binfo,1);

QUANT = (0.1 : 0.1 : 0.9); %quantiles of inter-saccade interval
NUM_QUANT = length(QUANT);

isiAcc = NaN(NUM_SESS, NUM_QUANT);    isiAcc_All = [];
isiFast = NaN(NUM_SESS, NUM_QUANT);   isiFast_All = [];

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
  isiAcc_All = cat(2, isiAcc_All, ISIkk(idxAcc & idxErrChc & (idxTgt | idxDistr)));
  isiFast_All = cat(2, isiFast_All, ISIkk(idxFast & idxErrChc & (idxTgt | idxDistr)));
  isiAcc(kk,:) = quantile(ISIkk(idxAcc & idxErrChc & (idxTgt | idxDistr)), QUANT);
  isiFast(kk,:) = quantile(ISIkk(idxFast & idxErrChc & (idxTgt | idxDistr)), QUANT);
    
end%for:session(kk)

ttestTom(isiAcc(:,5), isiFast(:,5))

%% Plotting

figure(); hold on
cdfplotTR(isiFast_All, 'Color',[0 .7 0])
cdfplotTR(isiAcc_All, 'Color','r')
% shadedErrorBar(QUANT, mean(isiAcc), std(isiAcc)/sqrt(NUM_SESS), 'lineprops', {'-r', 'LineWidth',0.75}, 'transparent',true)
% shadedErrorBar(QUANT, mean(isiFast), std(isiFast)/sqrt(NUM_SESS), 'lineprops', {'-', 'Color',[0 .7 0], 'LineWidth',0.75}, 'transparent',true)
ppretty([3.2,2]); ytickformat('%2.1f')

end % fxn : plot_ISI_Distr()

