function [ ] = plot_Distr_tChcErr_SAT( ninfo , nstats , binfo , moves , movesPP )
%plot_Distr_tChcErr_SAT Plot cumulative distribution of time of error
%encoding and time of second saccade, relative to time of primary saccade.
%   Detailed explanation goes here
% 

idxSEF = ismember({ninfo.area}, {'SEF'});
idxMonkey = ismember({ninfo.monkey}, {'D','E'});

idxError = ([ninfo.errGrade] >= 2);
idxEfficient = ismember([ninfo.taskType], [1,2]);

idxKeep = (idxSEF & idxMonkey & idxError & idxEfficient);

NUM_CELLS = sum(idxKeep);
nstats = nstats(idxKeep);

%get start time for error encoding
tSignal_Acc =  [nstats.A_ChcErr_tErr_Acc];
tSignal_Fast = [nstats.A_ChcErr_tErr_Fast];
tSignal_Avg = mean([tSignal_Acc ; tSignal_Fast]);

%initializations -- time of second saccade
tSS_Acc = [];
tSS_Fast = [];

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  %index by condition
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  %index by trial outcome
  idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  %skip trials with no second saccade
  idxNoPP = (movesPP(kk).resptime == 0);
  
  %get time of second saccade
  tFinP = double(moves(kk).resptime) + double(moves(kk).duration);
  tInitPP = double(movesPP(kk).resptime);
  isiKK = tInitPP - tFinP;
  
  tSS_Acc = cat(2, tSS_Acc, isiKK(idxAcc & idxErr & ~idxNoPP));
  tSS_Fast = cat(2, tSS_Fast, isiKK(idxFast & idxErr & ~idxNoPP));
  
end%for:cells(cc)

%% Plotting
tSS_All = [tSS_Acc, tSS_Fast];

figure(); hold on

plot([0 0], [0 1], 'k:')

cdfplotTR(tSignal_Avg, 'Color','k')               %time of error encoding
cdfplotTR(tSS_All, 'Color','k', 'LineStyle',':')  %time of second saccade

xlabel('Time from primary saccade (ms)'); xlim([-100 500])
ylabel('Cumulative probability'); ytickformat('%2.1f')

ppretty([4.8,2.2])

end%fxn:plot_Distr_tChcErr_SAT()

