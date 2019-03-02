function [ ] = plotPPsaccISI( binfo , moves , movesPP )
%plotPPsaccISI Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(movesPP);

QUANT = (0.1 : 0.1 : 0.9); %quantiles of inter-saccade interval
NUM_QUANT = length(QUANT);

isiAcc = NaN(NUM_SESSION,NUM_QUANT);
isiFast = NaN(NUM_SESSION,NUM_QUANT);

for kk = 1:NUM_SESSION
  
  %index by condition
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  %index by trial outcome
  idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  %skip trials with no recorded post-primary saccade
  idxNoPP = (movesPP(kk).resptime == 0);
  
  %isolate timing data
  tFinP = double(moves(kk).resptime) + double(moves(kk).duration);
  tInitPP = double(movesPP(kk).resptime);
  
  ISIkk = tInitPP - tFinP;
  isiAcc(kk,:) = quantile(ISIkk(idxAcc & idxErr & ~idxNoPP), QUANT);
  isiFast(kk,:) = quantile(ISIkk(idxFast & idxErr & ~idxNoPP), QUANT);
  
end%for:session(kk)

%% Plotting

figure(); hold on
errorbar_no_caps(QUANT, mean(isiAcc), 'err',std(isiAcc)/sqrt(NUM_SESSION), 'color','r')
errorbar_no_caps(QUANT, mean(isiFast), 'err',std(isiFast)/sqrt(NUM_SESSION), 'color',[0 .7 0])
ppretty('image_size',[5,6.4])

end%fxn:plotPPsaccISI()

