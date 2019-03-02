function [ ] = plotPPISIvsRT( binfo , moves , movesPP )
%plotPPISIvsRT Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(movesPP);
MIN_PER_BIN = 3; %minimum number of saccades per RT bin

RT_FAST = (175 : 50 : 425);
RT_ACC = (450 : 50 : 800);
NBIN_FAST = length(RT_FAST) - 1;
NBIN_ACC = length(RT_ACC) - 1;
RTFAST_PLOT = RT_FAST(1:end-1) + diff(RT_FAST)/2;
RTACC_PLOT = RT_ACC(1:end-1) + diff(RT_ACC)/2;

isiAcc = NaN(NUM_SESSION,NBIN_ACC);
isiFast = NaN(NUM_SESSION,NBIN_FAST);

medRTAcc = NaN(1,NUM_SESSION); %plot mean of the session-wise medians
medRTFast = NaN(1,NUM_SESSION);
medISIAcc = NaN(1,NUM_SESSION);
medISIFast = NaN(1,NUM_SESSION);

for kk = 1:NUM_SESSION
  
  %index by condition
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  %index by trial outcome
  idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  %skip trials with no recorded post-primary saccade
  idxNoPP = (movesPP(kk).resptime == 0);
  
  %isolate timing data
  RTkk = double(moves(kk).resptime);
  tFinP = RTkk + double(moves(kk).duration);
  tInitPP = double(movesPP(kk).resptime);
  ISIkk = tInitPP - tFinP;
  
  for ii = 1:NBIN_ACC %loop over RT bins (Acc)
    idxII = ((RTkk > RT_ACC(ii)) & (RTkk <= RT_ACC(ii+1)));
    if (sum(idxAcc & idxErr & ~idxNoPP & idxII) >= MIN_PER_BIN)
      isiAcc(kk,ii) = nanmedian(ISIkk(idxAcc & idxErr & ~idxNoPP & idxII));
    end
  end%for:RT-bin-Acc
  
  for ii = 1:NBIN_FAST %loop over RT bins (Fast)
    idxII = ((RTkk > RT_FAST(ii)) & (RTkk <= RT_FAST(ii+1)));
    if (sum(idxFast & idxErr & ~idxNoPP & idxII) >= MIN_PER_BIN)
      isiFast(kk,ii) = nanmedian(ISIkk(idxFast & idxErr & ~idxNoPP & idxII));
    end
  end%for:RT-bin-Fast
  
  %save median RT and ISI
  medRTAcc(kk) = nanmedian(RTkk(idxAcc & idxErr & ~idxNoPP));
  medISIAcc(kk) = nanmedian(ISIkk(idxAcc & idxErr & ~idxNoPP));
  medRTFast(kk) = nanmedian(RTkk(idxFast & idxErr & ~idxNoPP));
  medISIFast(kk) = nanmedian(ISIkk(idxFast & idxErr & ~idxNoPP));
  
end%for:session(kk)

%% Plotting

%for plotting condition-wise mean
muRTA = mean(medRTAcc);    seRTA = std(medRTAcc)/sqrt(NUM_SESSION);
muRTF = mean(medRTFast);   seRTF = std(medRTFast)/sqrt(NUM_SESSION);
muISIA = mean(medISIAcc);  seISIA = std(medISIAcc)/sqrt(NUM_SESSION);
muISIF = mean(medISIFast); seISIF = std(medISIFast)/sqrt(NUM_SESSION);

%for plotting ISI X RT
NSEM_ACC = sum(~isnan(isiAcc));
NSEM_FAST = sum(~isnan(isiFast));

figure(); hold on
% plot(RTFAST_PLOT, isiFast, 'g-')
% plot(RTACC_PLOT, isiAcc, 'r-')
errorbar_no_caps(RTFAST_PLOT, nanmean(isiFast), 'err',nanstd(isiFast)./sqrt(NSEM_FAST), 'color',[0 .7 0])
errorbar_no_caps(RTACC_PLOT, nanmean(isiAcc), 'err',nanstd(isiAcc)./sqrt(NSEM_ACC), 'color','r')
errorbar(muRTA, muISIA, seISIA, seISIA, seRTA, seRTA, 'LineWidth',1.5, 'Color','r', 'CapSize',0)
errorbar(muRTF, muISIF, seISIF, seISIF, seRTF, seRTF, 'LineWidth',1.5, 'Color',[0 .7 0], 'CapSize',0)
ppretty('image_size',[6.4,4])

end%fxn:plotPPISIvsRT()

