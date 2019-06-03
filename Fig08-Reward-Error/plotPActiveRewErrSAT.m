function [ ] = plotPActiveRewErrSAT( ninfo , nstats , varargin )
%plotPActiveRewErrSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxRewAcc = (abs([ninfo.rewGrade]) >= 2);
idxRewFast = ((abs([ninfo.rewGrade]) >= 2) & ~isnan([nstats.A_Reward_tErrStart_Fast]));
idxEfficiency = ([ninfo.taskType] == 2);

idxKeepAcc = (idxArea & idxMonkey & idxRewAcc & idxEfficiency);
idxKeepFast = (idxArea & idxMonkey & idxRewFast & idxEfficiency);

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
tCDFAcc = sort([nstatsAcc.A_Reward_tErrStart_Acc]);      yCDFAcc = (1 : NUM_ACC) / NUM_ACC;
tCDFFast = sort([nstatsFast.A_Reward_tErrStart_Fast]);   yCDFFast = (1 : NUM_FAST) / NUM_FAST;

figure(); hold on
plot([0 0], [0 1], 'k:', 'LineWidth',1.25)
plot(median(tCDFAcc)*ones(1,2), [0 1], 'r:', 'LineWidth',1.5)
plot(median(tCDFFast)*ones(1,2), [0 1], ':', 'Color',[0 .7 0], 'LineWidth',1.5)
plot(T_RE_PRIMARY, PActiveFast, '-', 'Color',[0 .7 0], 'LineWidth',1.5)
plot(T_RE_PRIMARY, PActiveAcc, 'r-', 'LineWidth',1.5)
scatter(tCDFFast, yCDFFast, 40, [0 .7 0], 'filled')
scatter(tCDFAcc, yCDFAcc, 40, 'r', 'filled')
xlabel('Time from reward (ms)')
ylabel('P (active)')
ytickformat('%2.1f')

ppretty([6,2.5])

end%fxn:plotPActiveRewErrSAT()

