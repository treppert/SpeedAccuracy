function [ ] = plot_SDF_ChoiceErr_X_endpt( A_POSTSACC , ninfo , binfo )
%plot_SDF_ChoiceErr_X_endpt Summary of this function goes here
%   Detailed explanation goes here

% A_POSTSACC(cc).FastErrDir
% A_POSTSACC(cc).t

NUM_CELLS = length(A_POSTSACC);

A_ChoiceErr = new_struct({'F','D','T'}, 'dim',[1,NUM_CELLS]);

for cc = 1:NUM_CELLS
  
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  %TO BE WRAPPED INTO A FXN -- get indexes for binfo/moves & movesAll
  %********************************
  idx_cond = (binfo(kk).condition == 3);
  idx_errdir = (binfo(kk).err_dir & ~binfo(kk).err_time);
  trial_errdir = find(idx_cond & idx_errdir);
  idxAll_ppsacc = (ismember(movesAll(kk).trial, trial_errdir) & (movesAll(kk).index == INDEX));
  trial_errdir = movesAll(kk).trial(idxAll_ppsacc);
  %********************************
  
  if (sum(idxAll_ppsacc) ~= length(A_POSTSACC(cc).FastErrDir
  
  %TO BE WRAPPED INTO A FXN -- characterize post-primary saccade as to T, to D, or to F
  %********************************
  xfinAll_kk = movesAll(kk).x_fin(idxAll_ppsacc);
  yfinAll_kk = movesAll(kk).y_fin(idxAll_ppsacc);
  rfinAll_kk = sqrt(xfinAll_kk.*xfinAll_kk + yfinAll_kk.*yfinAll_kk);
  diffOctAll_kk = movesAll(kk).octant(idxAll_ppsacc) - uint16(binfo(kk).tgt_octant(trial_errdir));
  idx_Fix = (rfinAll_kk < 3.0);
  idx_Tgt = (~idx_Fix & (diffOctAll_kk == 0));
  idx_Distr = (~idx_Fix & (diffOctAll_kk ~= 0));
  %********************************
  
  
  
end%for:cells(cc)

end%fxn:plot_SDF_ChoiceErr_X_endpt()

