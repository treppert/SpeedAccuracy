function [ ] = plotPActiveChcErrSAT( ninfo , nstats , binfo , moves , movesPP )
%plotPActiveChcErrSAT Summary of this function goes here
%   Detailed explanation goes here

idxSEF = ismember({ninfo.area}, {'SEF'});
idxMonkey = ismember({ninfo.monkey}, {'D','E'});

idxError = ([ninfo.errGrade] >= 2);
idxEfficient = ismember([ninfo.taskType], [1,2]);

idxKeep = (idxSEF & idxMonkey & idxError & idxEfficient);

NUM_CELLS = sum(idxKeep);
nstats = nstats(idxKeep);

T_RE_SACCADE = (-350 : 250);  OFFSET = 350;
NUM_SAMP = length(T_RE_SACCADE);

%initializations
PActiveAcc = false(NUM_CELLS,NUM_SAMP);
PActiveFast = false(NUM_CELLS,NUM_SAMP);

for cc = 1:NUM_CELLS
  %% Time of second saccade
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  %index by condition
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  %index by trial outcome
  idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  %skip trials with no recorded post-primary saccade
  idxNoPP = (movesPP(kk).resptime == 0);
  
  %get time of second saccade
  tFinP = double(moves(kk).resptime) + double(moves(kk).duration);
  tInitPP = double(movesPP(kk).resptime);
  isiKK = tInitPP - tFinP;
  
  isiAcc = median(isiKK(idxAcc & idxErr & ~idxNoPP));
  isiFast = median(isiKK(idxFast & idxErr & ~idxNoPP));
  
  %% Compute time of error-related modulation relative to second saccade
  tErrStart_Acc = nstats(cc).A_ChcErr_tErr_Acc - isiAcc;
  tErrStart_Fast = nstats(cc).A_ChcErr_tErr_Fast - isiFast;
  
  tErrEnd_Acc = nstats(cc).A_ChcErr_tErrEnd_Acc - isiAcc;
  tErrEnd_Fast = nstats(cc).A_ChcErr_tErrEnd_Fast - isiFast;
  
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
% plot(median(tCDFAcc)*ones(1,2), [0 .4], 'r:', 'LineWidth',1.5)
% plot(median(tCDFFast)*ones(1,2), [0 .4], ':', 'Color',[0 .7 0], 'LineWidth',1.5)
plot(T_RE_SACCADE, PActiveFast, '-', 'Color',[0 .7 0], 'LineWidth',1.5)
plot(T_RE_SACCADE, PActiveAcc, 'r-', 'LineWidth',1.5)
% xlim([-100 400])
% xlabel('Time from primary saccade (ms)')
xlabel('Time from second saccade (ms)')
ylabel('P (active)')
ytickformat('%2.1f')

ppretty([6,2.5])

end%fxn:plotPActiveChcErrSAT()

