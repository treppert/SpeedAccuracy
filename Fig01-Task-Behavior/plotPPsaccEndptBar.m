function [ ] = plotPPsaccEndptBar( binfo , movesPP , varargin )
%plotPPsaccEndptBar Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

[binfo, ~, movesPP] = utilIsolateMonkeyBehavior(binfo, cell(1,length(binfo)), movesPP, args.monkey);
NUM_SESSION = length(binfo);

endptT = NaN(2,NUM_SESSION); %rows refer to tasks T/L and L/T
endptD = NaN(2,NUM_SESSION);
endptF = NaN(2,NUM_SESSION);
endptN = NaN(2,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  %index by condition
  idxCond = ((binfo(kk).condition == 1) | (binfo(kk).condition == 3));
  %index by trial outcome
  idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  %index by task (T/L or L/T)
  tt = binfo(kk).taskType;
  
  endptN(tt,kk) = sum((movesPP(kk).endpt == 0) & idxCond & idxErr) / sum(idxCond & idxErr);
  endptT(tt,kk) = sum((movesPP(kk).endpt == 1) & idxCond & idxErr) / sum(idxCond & idxErr);
  endptD(tt,kk) = sum((movesPP(kk).endpt == 2) & idxCond & idxErr) / sum(idxCond & idxErr);
  endptF(tt,kk) = sum((movesPP(kk).endpt == 3) & idxCond & idxErr) / sum(idxCond & idxErr);
  
end%for:session(kk)

%% Plotting
NSEM_T1 = sum(~isnan(endptN(1,:)));
NSEM_T2 = sum(~isnan(endptN(2,:)));

yyMeanT1 = [nanmean(endptN(1,:)), nanmean(endptT(1,:)), nanmean(endptD(1,:)), nanmean(endptF(1,:))];
yyMeanT2 = [nanmean(endptN(2,:)), nanmean(endptT(2,:)), nanmean(endptD(2,:)), nanmean(endptF(2,:))];
yySE1 = [nanstd(endptN(1,:)), nanstd(endptT(1,:)), nanstd(endptD(1,:)), nanstd(endptF(1,:))] / sqrt(NSEM_T1);
yySE2 = [nanstd(endptN(2,:)), nanstd(endptT(2,:)), nanstd(endptD(2,:)), nanstd(endptF(2,:))] / sqrt(NSEM_T2);

figure(); hold on
bar((1:2:7), yyMeanT1, 'BarWidth',0.4, 'FaceColor',[.7 .7 .7])
bar((2:2:8), yyMeanT2, 'BarWidth',0.4, 'FaceColor',[.3 .3 .3])
errorbar((1:2:7), yyMeanT1, yySE1, 'Color','k', 'LineWidth',0.75, 'CapSize',0)
errorbar((2:2:8), yyMeanT2, yySE2, 'Color',[.5 .5 .5], 'LineWidth',0.75, 'CapSize',0)
ppretty([5,4])

end%fxn:plotPPsaccEndptBar()

