function [ ] = plot_ISI_Distr( binfo , moves , movesPP , varargin )
%plot_ISI_Distr Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});
SAVEDIR = 'C:\Users\Thomas Reppert\Dropbox\Speed Accuracy\SEF_SAT\Stats\';

[binfo, moves, movesPP] = utilIsolateMonkeyBehavior(binfo, moves, movesPP, args.monkey);
NUM_SESSION = length(binfo);

QUANT = (0.1 : 0.1 : 0.9); %quantiles of inter-saccade interval
NUM_QUANT = length(QUANT);

isiAcc{1} = NaN(NUM_SESSION,NUM_QUANT); isiAcc{2} = isiAcc{1};
isiFast{1} = NaN(NUM_SESSION,NUM_QUANT); isiFast{2} = isiFast{1};

for kk = 1:NUM_SESSION
  
  %index by condition
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  %index by trial outcome
  idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  %skip trials with no recorded post-primary saccade
  idxNoPP = (movesPP(kk).resptime == 0);
  
  %isolate timing data
  tFinP = double(moves(kk).resptime) + double(moves(kk).duration);
  tInitPP = double(movesPP(kk).resptime);
  ISIkk = tInitPP - tFinP;
  
  %index by task (T/L or L/T)
  tt = binfo(kk).taskType;
  
  isiAcc{tt}(kk,:) = quantile(ISIkk(idxAcc & idxErr & ~idxNoPP), QUANT);
  isiFast{tt}(kk,:) = quantile(ISIkk(idxFast & idxErr & ~idxNoPP), QUANT);
  
end%for:session(kk)

%remove extra NaNs based on task (T/L or L/T)
idxTT1 = ([binfo.taskType] == 1);
idxTT2 = ([binfo.taskType] == 2);
isiAcc{1}(idxTT2,:) = []; isiFast{1}(idxTT2,:) = [];
isiAcc{2}(idxTT1,:) = []; isiFast{2}(idxTT1,:) = [];

%% Plotting
NUM_SESS_T1 = size(isiAcc{1}, 1);
NUM_SESS_T2 = size(isiAcc{2}, 1);

%cumulative distribution
figure(); hold on
errorbar(QUANT+.01, mean(isiAcc{1}), std(isiAcc{1})/sqrt(NUM_SESS_T1), 'Color','r', 'LineWidth',0.75, 'CapSize',0)
errorbar(QUANT+.01, mean(isiFast{1}), std(isiFast{1})/sqrt(NUM_SESS_T1), 'Color',[0 .7 0], 'LineWidth',0.75, 'CapSize',0)
errorbar(QUANT-.01, mean(isiAcc{2}), std(isiAcc{2})/sqrt(NUM_SESS_T2), 'Color','r', 'LineWidth',1.75, 'CapSize',0)
errorbar(QUANT-.01, mean(isiFast{2}), std(isiFast{2})/sqrt(NUM_SESS_T2), 'Color',[0 .7 0], 'LineWidth',1.75, 'CapSize',0)
xlim([.05 .95])
ppretty([5,6.4])

%barplot
muFM = mean(isiFast{1}(:,5));   muAM = mean(isiAcc{1}(:,5));
muFL = mean(isiFast{2}(:,5));   muAL = mean(isiAcc{2}(:,5));
seAM = std(isiAcc{1}(:,5)) / sqrt(NUM_SESS_T1); %standard error -- Accurate / More efficient
seAL = std(isiAcc{2}(:,5)) / sqrt(NUM_SESS_T2);
seFM = std(isiFast{1}(:,5)) / sqrt(NUM_SESS_T1);
seFL = std(isiFast{2}(:,5)) / sqrt(NUM_SESS_T2);

figure(); hold on
bar(1, muFM, 0.7, 'FaceColor',[0 .7 0], 'LineWidth',0.25)
bar(2, muFL, 0.7, 'FaceColor',[0 .7 0], 'LineWidth',1.25)
bar(3, muAM, 0.7, 'FaceColor','r', 'LineWidth',0.25)
bar(4, muAL, 0.7, 'FaceColor','r', 'LineWidth',1.25)
errorbar([muFM muFL muAM muAL], [seFM seFL seAM seAL], 'Color','k', 'CapSize',0)
xticks([]); ylabel('ISI (ms)'); ylim([200 300])
ppretty([2,3])

end%fxn:plot_ISI_Distr()

