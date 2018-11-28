function [ movesPP ] = classify_endpt_ppsacc( binfo , movesPP )
%classify_endpt_ppsacc Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(binfo);


for kk = 1:NUM_SESSION
  
  %skip trials with no recorded post-primary saccade
  idx_noPP = (movesPP(kk).resptime == 0);
  
  %index by trial outcome
  idx_errdir = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  %isolate saccade endpoint data
  xfinPP_ = movesPP(kk).x_fin(idx_errdir & ~idx_noPP);
  yfinPP_ = movesPP(kk).y_fin(idx_errdir & ~idx_noPP);
  
  %haracterize post-primary saccade as to T, to D, or to F
  rfinPP_ = sqrt(xfinPP_.*xfinPP_ + yfinPP_.*yfinPP_);
  dOctPP_ = movesPP(kk).octant(idx_errdir & ~idx_noPP) - uint16(binfo(kk).tgt_octant(idx_errdir & ~idx_noPP));
  
  idxFix = (rfinPP_ < 3.0);
  idxTgt = (~idxFix & (dOctPP_ == 0));
  idxDistr = (~idxFix & (dOctPP_ ~= 0));
  
  %save for future trial indexing
  trialPP_ = find(idx_errdir & ~idx_noPP);
  movesPP(kk).endpt = zeros(1,binfo(kk).num_trials);
  movesPP(kk).endpt(trialPP_(idxTgt)) = 1;
  movesPP(kk).endpt(trialPP_(idxDistr)) = 2;
  movesPP(kk).endpt(trialPP_(idxFix)) = 3;
  
end%for:session(kk)

end%fxn:classify_endpt_ppsacc()
