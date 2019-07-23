function [ ] = plotChcErrRate_X_RTavg( binfo , moves, varargin )
%plotChcErrRate_X_RTavg Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

[binfo, moves] = utilIsolateMonkeyBehavior(binfo, moves, cell(1,length(binfo)), args.monkey);
NUM_SESSION = length(binfo);

erAcc = NaN(1,NUM_SESSION);   rtAcc = NaN(1,NUM_SESSION);
erFast = NaN(1,NUM_SESSION);  rtFast = NaN(1,NUM_SESSION);

for kk = 1:NUM_SESSION
  %index by condition
  idxAcc = (binfo(kk).condition == 1);
  idxFast = (binfo(kk).condition == 3);
  %index by trial outcome
  idxErr = (binfo(kk).err_dir);
  
  rtAcc(kk) = nanmedian(moves(kk).resptime(idxAcc));
  rtFast(kk) = nanmedian(moves(kk).resptime(idxFast));
  erAcc(kk) = sum(idxAcc & idxErr) / sum(idxAcc);
  erFast(kk) = sum(idxFast & idxErr) / sum(idxFast);
  
end%for:session(kk)

%compute stats for effect of condition
ttestTom(rtAcc, rtFast) %RT
ttestTom(erAcc, erFast) %error rate

idxMore = ([binfo.taskType] == 1);
idxLess = ([binfo.taskType] == 2);

%split RT by condition and efficiency
rtAM = rtAcc(idxMore);    rtAL = rtAcc(idxLess);
erAM = erAcc(idxMore);    erAL = erAcc(idxLess);
rtFM = rtFast(idxMore);   rtFL = rtFast(idxLess);
erFM = erFast(idxMore);   erFL = erFast(idxLess);

%compute mean and SE of response time
muRT_AM = mean(rtAM);    seRT_AM = std(rtAM)/sqrt(sum(idxMore));
muRT_AL = mean(rtAL);    seRT_AL = std(rtAL)/sqrt(sum(idxLess));
muRT_FM = mean(rtFM);    seRT_FM = std(rtFM)/sqrt(sum(idxMore));
muRT_FL = mean(rtFL);    seRT_FL = std(rtFL)/sqrt(sum(idxLess));
%compute mean and SE of error rate
muER_AM = mean(erAM);    seER_AM = std(erAM)/sqrt(sum(idxMore));
muER_AL = mean(erAL);    seER_AL = std(erAL)/sqrt(sum(idxLess));
muER_FM = mean(erFM);    seER_FM = std(erFM)/sqrt(sum(idxMore));
muER_FL = mean(erFL);    seER_FL = std(erFL)/sqrt(sum(idxLess));

%% Plotting

figure(); hold on
errorbarxy([muRT_FM muRT_AM], [muER_FM muER_AM], [seRT_FM seRT_AM], [seER_FM seER_AM], {'k-','k','k'})
errorbarxy([muRT_FL muRT_AL], [muER_FL muER_AL], [seRT_FL seRT_AL], [seER_FL seER_AL], {'k-','k','k'})
xlim([245 550]); ylim([.05 .45])
ppretty([4.8,3])

% figure(); hold on
% plot([rtFast(1,:);rtAcc(1,:)], [erFast(1,:);erAcc(1,:)], 'k-', 'LineWidth',0.75)
% plot([rtFast(2,:);rtAcc(2,:)], [erFast(2,:);erAcc(2,:)], 'k-', 'LineWidth',1.5)
% plot(rtFast, erFast, '.', 'Color',[0 .7 0], 'MarkerSize',25)
% plot(rtAcc, erAcc, 'r.', 'MarkerSize',25)
% ytickformat('%3.2f')
% ppretty([4.8,3])

end%fxn:plotChcErrRate_X_RTavg()

