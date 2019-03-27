function [ ] = plotProbChoiceErrXtaskXRT( binfo , moves , varargin )
%plotProbChoiceErrXtaskXRT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

[binfo, moves] = utilIsolateMonkeyBehavior(binfo, moves, args.monkey);

%split sessions by task type
taskType = [binfo.taskType];
binfoTask{1} = binfo(taskType == 1); movesTask{1} = moves(taskType == 1);
binfoTask{2} = binfo(taskType == 2); movesTask{2} = moves(taskType == 2);
NUM_SESSION = length(binfoTask{2});

if (length(binfoTask{1}) ~= length(binfoTask{2}))
  error('Number of sessions of each task type is different')
end

erAcc = NaN(2,NUM_SESSION); %[ Type1 ; Type2 ]
erFast = NaN(2,NUM_SESSION);

rtAcc = NaN(2,NUM_SESSION);
rtFast = NaN(2,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  for tt = 1:2 %loop over tasks
    
    %index by trial outcome
    idxErr = (binfoTask{tt}(kk).err_dir);
    %index by condition
    idxAcc = (binfoTask{tt}(kk).condition == 1);
    idxFast = (binfoTask{tt}(kk).condition == 3);

    rtAcc(tt,kk) = nanmedian(movesTask{tt}(kk).resptime(idxAcc));
    rtFast(tt,kk) = nanmedian(movesTask{tt}(kk).resptime(idxFast));

    erAcc(tt,kk) = sum(idxAcc & idxErr) / sum(idxAcc);
    erFast(tt,kk) = sum(idxFast & idxErr) / sum(idxFast);
    
  end%for:task(tt)
  
end%for:session(kk)

figure(); hold on
plot([rtFast(1,:);rtAcc(1,:)], [erFast(1,:);erAcc(1,:)], 'k-', 'LineWidth',0.75)
plot([rtFast(2,:);rtAcc(2,:)], [erFast(2,:);erAcc(2,:)], 'k-', 'LineWidth',1.75)
ytickformat('%3.2f')
% xlim([250 600]); ylim([.05 .4])
ppretty([4.8,3])

end%fxn:plotProbChoiceErrXtaskXRT()

