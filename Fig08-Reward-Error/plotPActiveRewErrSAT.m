function [ ] = plotPActiveRewErrSAT( ninfo , nstats , varargin )
%plotPActiveRewErrSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxRewAcc = ~isnan([nstats.A_Reward_tErrStart_Acc]);
idxRewFast = ~isnan([nstats.A_Reward_tErrStart_Fast]);
idxEfficient = ([ninfo.taskType] == 2);

idxKeepAcc = (idxArea & idxMonkey & idxRewAcc & idxEfficient);
idxKeepFast = (idxArea & idxMonkey & idxRewFast & idxEfficient);

nstatsAcc = nstats(idxKeepAcc);
nstatsFast = nstats(idxKeepFast);
NUM_ACC = sum(idxKeepAcc);
NUM_FAST = sum(idxKeepFast);

T_RE_PRIMARY = (-100 : 800);  OFFSET = 101;
NUM_SAMP = length(T_RE_PRIMARY);

%initializations
PActiveAcc = false(NUM_ACC,NUM_SAMP);
PActiveFast = false(NUM_FAST,NUM_SAMP);

for cc = 1:NUM_ACC
  tErrStart_Acc = nstatsAcc(cc).A_Reward_tErrStart_Acc;
  tErrEnd_Acc = nstatsAcc(cc).A_Reward_tErrEnd_Acc;
  PActiveAcc(cc,(tErrStart_Acc : tErrEnd_Acc) + OFFSET) = true;
end%for:cells-Acc(cc)

PActiveAcc = sum(PActiveAcc,1) / NUM_ACC;

for cc = 1:NUM_FAST
  tErrStart_Fast = nstatsFast(cc).A_Reward_tErrStart_Fast;
  tErrEnd_Fast = nstatsFast(cc).A_Reward_tErrEnd_Fast;
  PActiveFast(cc,(tErrStart_Fast : tErrEnd_Fast) + OFFSET) = true;
end%for:cells-Fast(cc)

PActiveFast = sum(PActiveFast,1) / NUM_FAST;

%% Plotting

figure()

subplot(2,1,1); hold on
plot(T_RE_PRIMARY, PActiveFast, '-', 'Color',[0 .7 0], 'LineWidth',1.5)
xticks([])
ylabel('P (active)')

subplot(2,1,2); hold on
plot(T_RE_PRIMARY, PActiveAcc, 'r-', 'LineWidth',1.5)
xlabel('Time from reward (ms)')

ppretty([6,4.8])

end%fxn:plotPActiveRewErrSAT()

