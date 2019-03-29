function [ ] = plotPPsaccISIvsRT( binfo , moves , movesPP , varargin )
%plotPPsaccISIvsRT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

[binfo, moves, movesPP] = utilIsolateMonkeyBehavior(binfo, moves, movesPP, args.monkey);
NUM_SESSION = length(binfo);

MIN_PER_BIN = 3; %minimum number of saccades per RT bin

RT_FAST = (175 : 50 : 425);  NBIN_FAST = length(RT_FAST) - 1;
RT_ACC = (450 : 50 : 800);   NBIN_ACC = length(RT_ACC) - 1;

isiAcc{1} = NaN(NUM_SESSION,NBIN_ACC);   isiAcc{2} = isiAcc{1};   isiAcc{3} = isiAcc{1};
isiFast{1} = NaN(NUM_SESSION,NBIN_FAST); isiFast{2} = isiFast{1}; isiFast{3} = isiFast{1};

for kk = 1:NUM_SESSION
  
  %index by condition
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  %index by trial outcome
  idxErr = (binfo(kk).err_dir);
  %skip trials with no recorded post-primary saccade
  idxNoPP = (movesPP(kk).resptime == 0);
  
  %isolate timing data
  RTkk = double(moves(kk).resptime);
  tFinP = RTkk + double(moves(kk).duration);
  tInitPP = double(movesPP(kk).resptime);
  ISIkk = tInitPP - tFinP;
  
  %index by task (T/L or L/T)
  tt = binfo(kk).taskType;
  
  for ii = 1:NBIN_ACC %loop over RT bins (Acc)
    idxII = ((RTkk > RT_ACC(ii)) & (RTkk <= RT_ACC(ii+1)));
    if (sum(idxAcc & idxErr & ~idxNoPP & idxII) >= MIN_PER_BIN)
      isiAcc{tt}(kk,ii) = nanmedian(ISIkk(idxAcc & idxErr & ~idxNoPP & idxII));
    end
  end%for:RT-bin-Acc
  
  for ii = 1:NBIN_FAST %loop over RT bins (Fast)
    idxII = ((RTkk > RT_FAST(ii)) & (RTkk <= RT_FAST(ii+1)));
    if (sum(idxFast & idxErr & ~idxNoPP & idxII) >= MIN_PER_BIN)
      isiFast{tt}(kk,ii) = nanmedian(ISIkk(idxFast & idxErr & ~idxNoPP & idxII));
    end
  end%for:RT-bin-Fast
  
end%for:session(kk)

%remove extra NaNs based on task (T/L or L/T)
idxTT1 = ([binfo.taskType] == 1);
idxTT2 = ([binfo.taskType] == 2);
isiAcc{1}(idxTT2,:) = []; isiFast{1}(idxTT2,:) = [];
isiAcc{2}(idxTT1,:) = []; isiFast{2}(idxTT1,:) = [];

%create array with combined data across both tasks
isiAcc{3} = [isiAcc{1} ; isiAcc{2}];
isiFast{3} = [isiFast{1} ; isiFast{2}];

%% Plotting
RTPLOT_FAST = RT_FAST(1:end-1) + diff(RT_FAST)/2;
RTPLOT_ACC = RT_ACC(1:end-1) + diff(RT_ACC)/2;

%SEM for plotting ISI X RT
NSEM_ACC{1} = NaN(1,NBIN_ACC); NSEM_FAST{1} = NaN(1,NBIN_FAST);
NSEM_ACC{2} = NaN(1,NBIN_ACC); NSEM_FAST{2} = NaN(1,NBIN_FAST);
NSEM_ACC{3} = NaN(1,NBIN_ACC); NSEM_FAST{3} = NaN(1,NBIN_FAST);
for tt = 1:3
  NSEM_ACC{tt}(:) = sum(~isnan(isiAcc{tt}), 1);
  NSEM_FAST{tt}(:) = sum(~isnan(isiFast{tt}), 1);
end

%remove data points with < 3 sessions
for tt = 1:3
  isiAcc{tt}(:,(NSEM_ACC{tt} < 3)) = NaN;
  isiFast{tt}(:,(NSEM_FAST{tt} < 3)) = NaN;
end

figure(); hold on
errorbar(RTPLOT_FAST+5, nanmean(isiFast{1}), nanstd(isiFast{1})./sqrt(NSEM_FAST{1}), 'Color',[0 .7 0], 'LineWidth',0.75, 'CapSize',0)
errorbar(RTPLOT_ACC+5, nanmean(isiAcc{1}), nanstd(isiAcc{1})./sqrt(NSEM_ACC{1}), 'Color','r', 'LineWidth',0.75, 'CapSize',0)
errorbar(RTPLOT_FAST-5, nanmean(isiFast{2}), nanstd(isiFast{2})./sqrt(NSEM_FAST{2}), 'Color',[0 .7 0], 'LineWidth',1.75, 'CapSize',0)
errorbar(RTPLOT_ACC-5, nanmean(isiAcc{2}), nanstd(isiAcc{2})./sqrt(NSEM_ACC{2}), 'Color','r', 'LineWidth',1.75, 'CapSize',0)
errorbar(RTPLOT_FAST, nanmean(isiFast{3}), nanstd(isiFast{3})./sqrt(NSEM_FAST{1}), 'Color',[.5 .5 .5], 'LineWidth',1.5, 'CapSize',0)
errorbar(RTPLOT_ACC, nanmean(isiAcc{3}), nanstd(isiAcc{3})./sqrt(NSEM_ACC{1}), 'Color',[.5 .5 .5], 'LineWidth',1.5, 'CapSize',0)
xlim([190 800])
ppretty([6.4,4])

end%fxn:plotPPsaccISIvsRT()

