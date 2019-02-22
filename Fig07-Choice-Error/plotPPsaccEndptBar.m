function [ ] = plotPPsaccEndptBar( binfo , movesPP )
%plotPPsaccEndptBar Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(movesPP);

endpt = new_struct({'T','D','F','N','O'}, 'dim',[1,1]);
endpt = populate_struct(endpt, {'T','D','F','N','O'}, NaN(1,NUM_SESSION));

for kk = 1:NUM_SESSION
  
  %index by condition
  idxCond = ((binfo(kk).condition == 1) | (binfo(kk).condition == 3));
  %index by trial outcome
  idxErr = (binfo(kk).err_dir);
  
  endpt.N(kk) = sum((movesPP(kk).endpt == 0) & idxCond & idxErr) / sum(idxCond & idxErr);
  endpt.T(kk) = sum((movesPP(kk).endpt == 1) & idxCond & idxErr) / sum(idxCond & idxErr);
  endpt.D(kk) = sum((movesPP(kk).endpt == 2) & idxCond & idxErr) / sum(idxCond & idxErr);
  endpt.F(kk) = sum((movesPP(kk).endpt == 3) & idxCond & idxErr) / sum(idxCond & idxErr);
  endpt.O(kk) = sum((movesPP(kk).endpt == 4) & idxCond & idxErr) / sum(idxCond & idxErr);
  
end%for:session(kk)

yyMean = [mean(endpt.N), mean(endpt.T), mean(endpt.D), mean(endpt.F), mean(endpt.O)];
yySE = [std(endpt.N), std(endpt.T), std(endpt.D), std(endpt.F), std(endpt.O)] / sqrt(NUM_SESSION);

figure(); hold on
bar((1:5), yyMean, 'BarWidth',0.75)
errorbar_no_caps((1:5), yyMean, 'err',yySE, 'color','k')
ppretty('image_size',[3,4])

end%fxn:plotPPsaccEndptBar()

