function [] = barplot_X_condition_SAT( ninfo , nstats , param , varargin )
%barplot_X_condition_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxVis = ([ninfo.visGrade] >= 2);   idxMove = ([ninfo.moveGrade] >= 2);
idxErr = ([ninfo.errGrade] >= 2);
idxRew = ((abs([ninfo.rewGrade]) >= 2) & ~isnan([nstats.A_Reward_tErrStart_Fast]));

if strcmp(param, 'ErrLat')
  idxKeep = (idxArea & idxMonkey & idxErr);
  fieldAcc = 'A_ChcErr_tErr_Acc';
  fieldFast = 'A_ChcErr_tErr_Fast';
elseif strcmp(param, 'ErrMag')
  idxKeep = (idxArea & idxMonkey & idxErr);
  fieldAcc = 'A_ChcErr_magErr_Acc';
  fieldFast = 'A_ChcErr_magErr_Fast';
elseif strcmp(param, 'RewLat')
  idxKeep = (idxArea & idxMonkey & idxRew);
  fieldAcc = 'A_Reward_tErrStart_Acc';
  fieldFast = 'A_Reward_tErrStart_Fast';
elseif strcmp(param, 'RewMag')
  idxKeep = (idxArea & idxMonkey & idxRew);
  fieldAcc = 'A_Reward_magErr_Acc';
  fieldFast = 'A_Reward_magErr_Fast';
else
  error('Input "param" not recognized')
end

NUM_CELLS = sum(idxKeep);
ninfo = ninfo(idxKeep);
nstats = nstats(idxKeep);

if strcmp(param, 'RewMag')
  parmAcc = abs([nstats.(fieldAcc)]);
  parmFast = abs([nstats.(fieldFast)]);
else
  parmAcc = [nstats.(fieldAcc)];
  parmFast = [nstats.(fieldFast)];
end

%compute mean and SE
muAcc = mean(parmAcc);    seAcc = std(parmAcc)/sqrt(NUM_CELLS);
muFast = mean(parmFast);  seFast = std(parmFast)/sqrt(NUM_CELLS);

fprintf('Accurate: %g +/- %g\n', muAcc, seAcc)
fprintf('Fast: %g +/- %g\n', muFast, seFast)

%% Plotting
figure(); hold on
bar(1, muFast, 0.7, 'FaceColor',[0 .7 0], 'LineWidth',0.25)
bar(2, muAcc, 0.7, 'FaceColor','r', 'LineWidth',0.25)
errorbar([muFast muAcc], [seFast seAcc], 'Color','k', 'CapSize',0)
xticks([]); xticklabels([]); ylabel(param)
ppretty([2,3])

%% Stats
ttestTom(parmAcc', parmFast');

end%util:barplot_X_condition_SAT()

