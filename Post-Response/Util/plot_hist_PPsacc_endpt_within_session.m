%plot_hist_PPsacc_endpt_within_session

NUM_SESSION = length(movesPP);

numPP2T = NaN(1,NUM_SESSION);
numPP2D = NaN(1,NUM_SESSION);
numPP2F = NaN(1,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  numPP2T(kk) = sum((info_(kk).condition == 1) & (movesPP(kk).endpt == 1));
  numPP2D(kk) = sum((info_(kk).condition == 1) & (movesPP(kk).endpt == 2));
  numPP2F(kk) = sum((info_(kk).condition == 1) & (movesPP(kk).endpt == 3));
  
end%for:sessions(kk)

figure(); hold on
histogram(numPP2T, 'FaceColor','k')
ppretty()

pause(0.25)

figure(); hold on
histogram(numPP2D, 'FaceColor','b')
ppretty()

pause(0.25)

figure(); hold on
histogram(numPP2F, 'FaceColor','r')
ppretty()

clear numPP2* kk NUM_SESSION