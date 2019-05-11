function [ ] = plotISIvsErrMagSAT( binfo , moves , movesPP , ninfo , nstats , spikes , varargin )
%plotISIvsErrMagSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxErrorGrade = (abs([ninfo.errGrade]) >= 0.5);

idxKeep = (idxArea & idxMonkey & idxErrorGrade);

ninfo = ninfo(idxKeep);
nstats = nstats(idxKeep);
spikes = spikes(idxKeep);
NUM_CELLS = length(spikes);

T_INTERVAL_ESTIMATE_MAG = 200; %interval over which we compute the integral of error signal

%output initializations
pvalFast = NaN(1,NUM_CELLS);
pvalAcc = NaN(1,NUM_CELLS);

for cc = 1:NUM_CELLS
  fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  RTkk = double(moves(kk).resptime);
  ISIkk = double(movesPP(kk).resptime) - RTkk;
  ISIkk(ISIkk < 0) = NaN; %trials with no secondary saccade
  ISIkk(ISIkk > 600) = NaN;
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxAcc = (binfo(kk).condition == 1 & ~idxIso);
  idxFast = (binfo(kk).condition == 3 & ~idxIso);
  %index by trial outcome
  idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  isiFast = ISIkk(idxFast & idxErr);
  isiAcc = ISIkk(idxAcc & idxErr);
  
  trialFast = find(idxFast & idxErr);
  trialAcc = find(idxAcc & idxErr);
  if (trialFast(end) == binfo(kk).num_trials)
    trialFast(end) = [];
  end
  if (trialAcc(end) == binfo(kk).num_trials)
    trialAcc(end) = [];
  end
  dRT_Fast = RTkk(trialFast+1) - RTkk(trialFast);
  dRT_Acc = RTkk(trialAcc+1) - RTkk(trialAcc);
  
%   endptFast = movesPP(kk).endpt(idxFast & idxErr);
%   endptAcc = movesPP(kk).endpt(idxAcc & idxErr);
  
  tErrFast = nstats(cc).A_ChcErr_tErr_Fast + 3500;
  tErrAcc = nstats(cc).A_ChcErr_tErr_Acc + 3500;
  
  spCtFast = cellfun(@(x) sum((x > tErrFast) & (x <= (tErrFast+T_INTERVAL_ESTIMATE_MAG))), spikes(cc).SAT(trialFast));
  spCtAcc = cellfun(@(x) sum((x > tErrAcc) & (x <= (tErrAcc+T_INTERVAL_ESTIMATE_MAG))), spikes(cc).SAT(trialAcc));
  
%   [~,tmpFast] = corr([spCtFast(~inanFast) ; isiFast(~inanFast)]', 'Type','Spearman');   pvalFast(cc) = tmpFast(1,2);
%   [~,tmpAcc] = corr([spCtAcc(~inanAcc) ; isiAcc(~inanAcc)]', 'Type','Spearman');        pvalAcc(cc) = tmpAcc(1,2);
  [~,tmpFast] = corr([spCtFast ; dRT_Fast]', 'Type','Spearman');   pvalFast(cc) = tmpFast(1,2);
  [~,tmpAcc] = corr([spCtAcc ; dRT_Acc]', 'Type','Spearman');      pvalAcc(cc) = tmpAcc(1,2);
  
%   figure()
%   subplot(1,2,1); hold on
%   scatter(spCtFast, dRT_Fast, 10, [0 .7 0], 'filled')
% %   plot(spCtFastVec, isiFastVec, '.-', 'MarkerSize',15, 'Color',[0 .3 0])
%   xlabel('Spike count'); ylabel('ISI (ms)')
%   print_session_unit(gca , ninfo(cc), [])
%   
%   subplot(1,2,2); hold on
%   scatter(spCtAcc, dRT_Acc, 10, 'r', 'filled')
% %   plot(spCtAccVec, isiAccVec, '.-', 'MarkerSize',15, 'Color',[.4 0 0])
%   xlabel('Spike count')
%   ppretty([8 4])
  
end%for:cells(cc)

figure()
subplot(2,1,1); hold on
histogram(-log(pvalFast), 'BinWidth',.5)
subplot(2,1,2); hold on
histogram(-log(pvalAcc), 'BinWidth',.5)
ppretty([4.8,4])


end%plotISIvsErrMagSAT()

%   spCtFastVec = sort(unique(spCtFast)); nCtFast = length(spCtFastVec);
%   spCtAccVec = sort(unique(spCtAcc)); nCtAcc = length(spCtAccVec);
%   isiFastVec = NaN(1,nCtFast);
%   isiAccVec = NaN(1,nCtAcc);
%   for jj = 1:nCtFast
%     idxJJ = (spCtFast == spCtFastVec(jj));
%     if (sum(idxJJ) >= 5)
%       isiFastVec(jj) = nanmedian(isiFast(idxJJ));
%     end
%   end
%   for jj = 1:nCtAcc
%     idxJJ = (spCtAcc == spCtAccVec(jj));
%     if (sum(idxJJ) >= 5)
%       isiAccVec(jj) = nanmedian(isiAcc(idxJJ));
%     end
%   end
%   

