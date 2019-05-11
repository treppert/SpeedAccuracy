function [ ] = plotPActiveChcErrSAT( ninfo , nstats , varargin )
%plotPActiveChcErrSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxErrorGrade = (abs([ninfo.errGrade]) >= 0.5);
idxEfficient = ismember([ninfo.taskType], [2]);

idxKeep = (idxArea & idxMonkey & idxErrorGrade & idxEfficient);

nstats = nstats(idxKeep);
NUM_CELLS = sum(idxKeep);

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

figure()

subplot(2,1,1); hold on
plot(T_RE_PRIMARY, PActiveFast, '-', 'Color',[0 .7 0], 'LineWidth',1.5)
xticks([])
ylabel('P (active)')

subplot(2,1,2); hold on
plot(T_RE_PRIMARY, PActiveAcc, 'r-', 'LineWidth',1.5)
xlabel('Time from primary saccade (ms)')
ylabel('P (active)')

ppretty([6,4.8])

end%fxn:plotPActiveChcErrSAT()

