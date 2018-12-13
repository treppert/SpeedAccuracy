function [ ] = plot_probFixBreak_SAT( binfo , moves )
%plot_probFixBreak_SAT Summary of this function goes here
%   Detailed explanation goes here

LIM_ERR_TIME = 100; %used to split groups into small/large error
NUM_SESSION = length(binfo);

pBreakCorr = NaN(1,NUM_SESSION);
pBreakLargeErr = NaN(1,NUM_SESSION);
pBreakSmallErr = NaN(1,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  idxCond = (binfo(kk).condition == 1);
  
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time);
  idxErrTime = (~binfo(kk).err_dir & binfo(kk).err_time);
  idxErrHold = (binfo(kk).err_hold);
  
  errRT = double(moves(kk).resptime) - binfo(kk).tgt_dline;
  idxLargeErr = (abs(errRT) >= LIM_ERR_TIME);
  idxSmallErr = (abs(errRT) < LIM_ERR_TIME);
  
  pBreakCorr(kk) = sum(idxCond & idxCorr & idxErrHold) / sum(idxCond & idxCorr);
  pBreakLargeErr(kk) = sum(idxCond & idxErrTime & idxLargeErr & idxErrHold) / sum(idxCond & idxErrTime & idxLargeErr);
  pBreakSmallErr(kk) = sum(idxCond & idxErrTime & idxSmallErr & idxErrHold) / sum(idxCond & idxErrTime & idxSmallErr);
  
end%for:session(kk)

%% Plotting
X_BAR = [1,2,3];
Y_BAR = 100 * [pBreakCorr' pBreakSmallErr' pBreakLargeErr'];

figure(); hold on
bar(X_BAR, mean(Y_BAR), 'FaceColor',[.5 .5 .5], 'BarWidth',0.5)
errorbar_no_caps(X_BAR, mean(Y_BAR), 'err',std(Y_BAR)/NUM_SESSION, 'color','k')
ppretty()


end%fxn:plot_probFixBreak_SAT()

