function [ ] = plotPPsaccEndptDistr( binfo , movesPP )
%plotPPsaccEndptDistr Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(binfo);

xFinPP = [];
yFinPP = [];

for kk = 1:NUM_SESSION
  
  %index by condition
  idxCond = (binfo(kk).condition == 3 | binfo(kk).condition == 1);
  %index by trial outcome
  idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  %skip trials with no recorded post-primary saccade
  idxNoPP = (movesPP(kk).resptime == 0);
  
  %isolate saccade endpoint data
  xfinPP_ = movesPP(kk).x_fin(idxCond & idxErr & ~idxNoPP);
  yfinPP_ = movesPP(kk).y_fin(idxCond & idxErr & ~idxNoPP);
  
  %determine location of singleton relative to absolute right
  th_tgt = convert_tgt_octant_to_angle(binfo(kk).tgt_octant((idxCond & idxErr & ~idxNoPP)));
  %rotate post-primary saccade trajectory according to singleton loc.
  xtmp = cos(2*pi-th_tgt) .* xfinPP_ - sin(2*pi-th_tgt) .* yfinPP_;
  ytmp = sin(2*pi-th_tgt) .* xfinPP_ + cos(2*pi-th_tgt) .* yfinPP_;
  
  xFinPP = cat(2, xFinPP, xtmp);
  yFinPP = cat(2, yFinPP, ytmp);
  
end%for:session(kk)


%% Plotting

%polar distribution of endpoints
TH_PPSACC = atan2(yFinPP, xFinPP);
R_PPSACC = sqrt(xFinPP.*xFinPP + yFinPP.*yFinPP);

figure(); polaraxes()
polarscatter(TH_PPSACC, R_PPSACC, 40, [.3 .3 .3], 'filled', 'MarkerFaceAlpha',0.3)
rlim([0 10]); rticklabels([]); thetaticks([])
ppretty()

end%fxn:plotPPsaccEndptDistr()
