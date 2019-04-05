function [ ] = plotPErrXRT( binfo , moves, varargin )
%plotPErrXRT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

PLOT_X_TASK = true; %use this flag to split on task type or not

[binfo, moves] = utilIsolateMonkeyBehavior(binfo, moves, cell(1,length(binfo)), args.monkey);
NUM_SESSION = length(binfo);

erAcc = NaN(2,NUM_SESSION); %[ Task1 ; Task2 ]
erFast = NaN(2,NUM_SESSION);

rtAcc = NaN(2,NUM_SESSION);
rtFast = NaN(2,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  %index by condition
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  %index by trial outcome
  idxErr = (binfo(kk).err_dir);
  
  %index by task (T/L or L/T)
  tt = binfo(kk).taskType;
  
  rtAcc(tt,kk) = nanmedian(moves(kk).resptime(idxAcc));
  rtFast(tt,kk) = nanmedian(moves(kk).resptime(idxFast));
  
  erAcc(tt,kk) = sum(idxAcc & idxErr) / sum(idxAcc);
  erFast(tt,kk) = sum(idxFast & idxErr) / sum(idxFast);
  
end%for:session(kk)

if (PLOT_X_TASK)
  
  figure(); hold on
  plot([rtFast(1,:);rtAcc(1,:)], [erFast(1,:);erAcc(1,:)], 'b-', 'LineWidth',0.75)
  plot([rtFast(2,:);rtAcc(2,:)], [erFast(2,:);erAcc(2,:)], 'k-', 'LineWidth',1.75)
  ytickformat('%3.2f')
  ppretty([4.8,3])
  
else %not splitting data by task type
  
  idxT1 = ([binfo.taskType] == 1);
  idxT2 = ([binfo.taskType] == 2);
  erAcc = [erAcc(1,idxT1), erAcc(2,idxT2)]; erFast = [erFast(1,idxT1), erFast(2,idxT2)];
  rtAcc = [rtAcc(1,idxT1), rtAcc(2,idxT2)]; rtFast = [rtFast(1,idxT1), rtFast(2,idxT2)];
  
  figure(); hold on
  errorbarxy(mean(rtFast), mean(erFast), std(rtFast)/sqrt(NUM_SESSION), std(erFast)/sqrt(NUM_SESSION), {'g-','g','g'})
  errorbarxy(mean(rtAcc), mean(erAcc), std(rtAcc)/sqrt(NUM_SESSION), std(erAcc)/sqrt(NUM_SESSION), {'r-','r','r'})
  ytickformat('%3.2f')
  xlim([250 600]); ylim([.05 .4])
  ppretty([4.8,3])
  
end%if:(PLOT_X_TASK)


end%fxn:plotPErrXRT()

