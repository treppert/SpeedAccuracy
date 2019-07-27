function [ ] = plotPActiveRewErrSAT( ninfo , nstats )
%plotPActiveRewErrSAT Summary of this function goes here
%   Detailed explanation goes here

idxArea = ismember({ninfo.area}, {'SEF'});
idxMonkey = ismember({ninfo.monkey}, {'D','E'});

idxRew = ((abs([ninfo.rewGrade]) >= 2) & ~isnan([nstats.A_Reward_tErrStart_Fast]));
% idxRew = (abs([ninfo.rewGrade]) >= 2);
idxKeep = (idxArea & idxMonkey & idxRew);

NUM_CELLS = sum(idxKeep)
return
nstats = nstats(idxKeep);

T_VEC = (-100 : 800);  OFFSET = 101;

%initializations
PActiveAcc = false(NUM_CELLS,length(T_VEC));
PActiveFast = false(NUM_CELLS,length(T_VEC));

for cc = 1:NUM_CELLS
  tErrStart_Acc = nstats(cc).A_Reward_tErrStart_Acc;
  tErrStart_Fast = nstats(cc).A_Reward_tErrStart_Fast;
  
  tErrEnd_Acc = nstats(cc).A_Reward_tErrEnd_Acc;
  tErrEnd_Fast = nstats(cc).A_Reward_tErrEnd_Fast;
  
  PActiveAcc(cc,(tErrStart_Acc : tErrEnd_Acc) + OFFSET) = true;
  PActiveFast(cc,(tErrStart_Fast : tErrEnd_Fast) + OFFSET) = true;
end%for:cells-Acc(cc)

PActiveAcc = sum(PActiveAcc,1) / NUM_CELLS;
PActiveFast = sum(PActiveFast,1) / NUM_CELLS;

%% Plotting
tCDFAcc = sort([nstats.A_Reward_tErrStart_Acc]);
tCDFFast = sort([nstats.A_Reward_tErrStart_Fast]);

figure(); hold on
plot([0 0], [0 1], 'k:', 'LineWidth',1.25)
plot(median(tCDFAcc)*ones(1,2), [0 .4], 'r:', 'LineWidth',1.5)
plot(median(tCDFFast)*ones(1,2), [0 .4], ':', 'Color',[0 .7 0], 'LineWidth',1.5)
plot(T_VEC, PActiveFast, '-', 'Color',[0 .7 0], 'LineWidth',1.5)
plot(T_VEC, PActiveAcc, 'r-', 'LineWidth',1.5)
xlabel('Time from reward (ms)')
ylabel('P (active)')
ytickformat('%2.1f')

ppretty([6,2.5])

end%fxn:plotPActiveRewErrSAT()

