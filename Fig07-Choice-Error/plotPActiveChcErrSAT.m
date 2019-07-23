function [ ] = plotPActiveChcErrSAT( ninfo , nstats , varargin )
%plotPActiveChcErrSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

idxSEF = ismember({ninfo.area}, {'SEF'});
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxError = ([ninfo.errGrade] >= 2);
idxEfficient = ismember([ninfo.taskType], [1,2]);

idxKeep = (idxSEF & idxMonkey & idxError & idxEfficient);

NUM_CELLS = sum(idxKeep);
nstats = nstats(idxKeep);

T_RE_PRIMARY = (-200 : 500);  OFFSET = 200;
NUM_SAMP = length(T_RE_PRIMARY);

%initializations
PActiveAcc = false(NUM_CELLS,NUM_SAMP);
PActiveFast = false(NUM_CELLS,NUM_SAMP);

for cc = 1:NUM_CELLS
  
  tErrStart_Acc = nstats(cc).A_ChcErr_tErr_Acc;
  tErrStart_Fast = nstats(cc).A_ChcErr_tErr_Fast;
  
  tErrEnd_Acc = nstats(cc).A_ChcErr_tErrEnd_Acc;
  tErrEnd_Fast = nstats(cc).A_ChcErr_tErrEnd_Fast;
  
  PActiveAcc(cc,(tErrStart_Acc : tErrEnd_Acc) + OFFSET) = true;
  PActiveFast(cc,(tErrStart_Fast : tErrEnd_Fast) + OFFSET) = true;
  
end%for:cells(cc)

PActiveAcc = sum(PActiveAcc,1) / NUM_CELLS;
PActiveFast = sum(PActiveFast,1) / NUM_CELLS;

%% Plotting
tCDFAcc = sort([nstats.A_ChcErr_tErr_Acc]);
tCDFFast = sort([nstats.A_ChcErr_tErr_Fast]);

figure(); hold on
plot([0 0], [0 1], 'k:', 'LineWidth',1.25)
plot(median(tCDFAcc)*ones(1,2), [0 .4], 'r:', 'LineWidth',1.5)
plot(median(tCDFFast)*ones(1,2), [0 .4], ':', 'Color',[0 .7 0], 'LineWidth',1.5)
plot(T_RE_PRIMARY, PActiveFast, '-', 'Color',[0 .7 0], 'LineWidth',1.5)
plot(T_RE_PRIMARY, PActiveAcc, 'r-', 'LineWidth',1.5)
xlim([-100 400])
xlabel('Time from primary saccade (ms)')
ylabel('P (active)')
ytickformat('%2.1f')

ppretty([6,2.5])

end%fxn:plotPActiveChcErrSAT()

