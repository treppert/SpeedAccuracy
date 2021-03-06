function [ ] = plot_EndptSS_Bar( behavInfo , secondSacc )
%plot_EndptSS_Bar Summary of this function goes here
%   Detailed explanation goes here

NUM_SESS = size(behavInfo,1);

Ptgt_Acc = NaN(1,NUM_SESS);     Ptgt_Fast = NaN(1,NUM_SESS);
Pdistr_Acc = NaN(1,NUM_SESS);   Pdistr_Fast = NaN(1,NUM_SESS);

for kk = 1:NUM_SESS
  
  %index by condition
  idxAcc = (behavInfo.condition{kk} == 1);
  idxFast = (behavInfo.condition{kk} == 3);
  %index by trial outcome
  idxErrChc = (behavInfo.err_dir{kk} & ~behavInfo.err_time{kk});
  %index by second saccade endpoint
  idxTgt = (secondSacc.endpt{kk} == 1);
  idxDistr = (secondSacc.endpt{kk} == 2);
%   idxNone = (secondSacc.endpt{kk} == 0);
%   idxFix = (secondSacc.endpt{kk} == 3);
  
  Ptgt_Acc(kk) = sum(idxAcc & idxErrChc & idxTgt) / sum(idxAcc & idxErrChc & (idxTgt | idxDistr));
  Ptgt_Fast(kk) = sum(idxFast & idxErrChc & idxTgt) / sum(idxFast & idxErrChc & (idxTgt | idxDistr));
  Pdistr_Acc(kk) = sum(idxAcc & idxErrChc & idxDistr) / sum(idxAcc & idxErrChc & (idxTgt | idxDistr));
  Pdistr_Fast(kk) = sum(idxFast & idxErrChc & idxDistr) / sum(idxFast & idxErrChc & (idxTgt | idxDistr));
  
end%for:session(kk)

% ttestTom(Ptgt_Acc, Ptgt_Fast)

%% Plotting
muTgt_Acc = mean(Ptgt_Acc);         seTgt_Acc = std(Ptgt_Acc) / sqrt(NUM_SESS);
muTgt_Fast = mean(Ptgt_Fast);       seTgt_Fast = std(Ptgt_Fast) / sqrt(NUM_SESS);
muDistr_Acc = mean(Pdistr_Acc);     seDistr_Acc = std(Pdistr_Acc) / sqrt(NUM_SESS);
muDistr_Fast = mean(Pdistr_Fast);   seDistr_Fast = std(Pdistr_Fast) / sqrt(NUM_SESS);

figure(); hold on
bar([1 2 3 4], [muTgt_Acc muTgt_Fast muDistr_Acc muDistr_Fast], 0.4, 'FaceColor',[.5 .5 .5], 'LineWidth',0.5)
errorbar([1 2 3 4], [muTgt_Acc muTgt_Fast muDistr_Acc muDistr_Fast], [seTgt_Acc seTgt_Fast seDistr_Acc seDistr_Fast], 'Color','k', 'CapSize',0)
ppretty([3,3]); xticks([1 2 3 4]); xticklabels({'A','F','A','F'}); ytickformat('%2.1f')

%% Stats - two-way between-subjects ANOVA
matStats = [Ptgt_Acc Pdistr_Acc ; Ptgt_Fast Pdistr_Fast]';
anova2_TR(matStats, NUM_SESS)

end%fxn:plot_EndptSS_Bar()
