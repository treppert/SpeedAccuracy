function [ ] = plot_EndptSS_Bar( binfo , secondSacc )
%plot_EndptSS_Bar Summary of this function goes here
%   Detailed explanation goes here

NUM_SESS = size(binfo,1);

Ptgt_Acc = NaN(1,NUM_SESS);
Ptgt_Fast = NaN(1,NUM_SESS);

for kk = 1:NUM_SESS
  
  %index by condition
  idxAcc = (binfo.condition{kk} == 1);
  idxFast = (binfo.condition{kk} == 3);
  %index by trial outcome
  idxErrChc = (binfo.err_dir{kk} & ~binfo.err_time{kk});
  %index by second saccade endpoint
  idxTgt = (secondSacc.endpt{kk} == 1);
  idxDistr = (secondSacc.endpt{kk} == 2);
%   idxNone = (secondSacc.endpt{kk} == 0);
%   idxFix = (secondSacc.endpt{kk} == 3);
  
  Ptgt_Acc(kk) = sum(idxAcc & idxErrChc & idxTgt) / sum(idxAcc & idxErrChc & (idxTgt | idxDistr));
  Ptgt_Fast(kk) = sum(idxFast & idxErrChc & idxTgt) / sum(idxFast & idxErrChc & (idxTgt | idxDistr));
  
end%for:session(kk)

ttestTom(Ptgt_Acc, Ptgt_Fast)

%% Plotting
muAcc = mean(Ptgt_Acc);     seAcc = std(Ptgt_Acc) / sqrt(NUM_SESS);
muFast = mean(Ptgt_Fast);   seFast = std(Ptgt_Fast) / sqrt(NUM_SESS);

figure(); hold on
bar([1 2], [muAcc muFast], 0.4, 'FaceColor',[.5 .5 .5], 'LineWidth',0.5)
errorbar([1 2], [muAcc muFast], [seAcc seFast], 'Color','k', 'CapSize',0)
ppretty([2,3]); xticks([1 2]); xticklabels({'A','F'})

%% Stats - two-way between-subjects ANOVA
% DV_Pr2tgt = [Pr2tgt.AccMore Pr2tgt.AccLess Pr2tgt.FastMore Pr2tgt.FastLess]';
% Condition = [ones(1,NUM_SESS) 2*ones(1,NUM_SESS)]';
% Efficiency = [ones(1,NUM_MORE) 2*ones(1,NUM_LESS) ones(1,NUM_MORE) 2*ones(1,NUM_LESS)]';
% anovan(DV_Pr2tgt, {Condition Efficiency}, 'model','interaction', 'varnames',{'Condition','Efficiency'});

end%fxn:plot_EndptSS_Bar()
