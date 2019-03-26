function [ ] = plotProbChoiceErrXRT( binfo , moves , varargin )
%plotProbChoiceErrXRT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

[binfo, moves] = utilIsolateMonkeyBehavior(binfo, moves, args.monkey);
NUM_SESSION = length(binfo);

erAcc = NaN(1,NUM_SESSION);
erFast = NaN(1,NUM_SESSION);

rtAcc = NaN(1,NUM_SESSION);
rtFast = NaN(1,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  %index by trial outcome
  idxErr = (binfo(kk).err_dir);
  %index by condition
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  
  rtAcc(kk) = nanmedian(moves(kk).resptime(idxAcc));
  rtFast(kk) = nanmedian(moves(kk).resptime(idxFast));
  
  erAcc(kk) = sum(idxAcc & idxErr) / sum(idxAcc);
  erFast(kk) = sum(idxFast & idxErr) / sum(idxFast);
  
end%for:session(kk)

figure(); hold on
plot([rtFast;rtAcc], [erFast;erAcc], 'k-')
% plot([mean(rtFast),mean(rtAcc)], [mean(erFast),mean(erAcc)], 'k-')
% errorbarxy(mean(rtFast), mean(erFast), std(rtFast)/sqrt(NUM_SESSION), std(erFast)/sqrt(NUM_SESSION), {'g-','g','g'})
% errorbarxy(mean(rtAcc), mean(erAcc), std(rtAcc)/sqrt(NUM_SESSION), std(erAcc)/sqrt(NUM_SESSION), {'r-','r','r'})
ytickformat('%3.2f')
xlim([250 600]); ylim([.05 .4])
ppretty([4.8,3])

end%fxn:plotProbChoiceErrXRT()

