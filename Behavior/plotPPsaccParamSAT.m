function [ ] = plotPPsaccParamSAT( movesPP , moves , binfo )
%plotPPsaccParamSAT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(movesPP);

RT = [];
rErr = [];

for kk = 1:NUM_SESSION
  
  %index by condition
  idxCond = ((binfo(kk).condition == 3) | (binfo(kk).condition == 1));
  %index by trial outcome
  idxErr = (binfo(kk).err_dir);
  
  RTkk = movesPP(kk).resptime(idxCond & idxErr) - moves(kk).resptime(idxCond & idxErr);
  RT = cat(2, RT, RTkk);
  
  rFin = sqrt(movesPP(kk).x_fin.*movesPP(kk).x_fin + movesPP(kk).y_fin.*movesPP(kk).y_fin);
  rTgt = unique(binfo(kk).tgt_eccen);
  rErr = cat(2, rErr, rFin - rTgt);
  
end%for:session(kk)

figure(); hold on
histogram(RT)
ppretty()

figure(); hold on
histogram(rErr)
ppretty()

end%fxn:plotPPsaccParamSAT()

