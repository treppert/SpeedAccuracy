function [ ] = plot_hazardRT( behavData , varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

kkKeep = ismember(behavData.Monkey, args.monkey);
behavData = behavData(kkKeep, :);
NUM_SESS = size(behavData,1);

NBIN = 20;
rtLimAcc  = linspace(0, 800, NBIN+1);   rtAccPlot  = rtLimAcc(1:NBIN) + unique(diff(rtLimAcc));
rtLimFast = linspace(0, 800, NBIN+1);   rtFastPlot = rtLimFast(1:NBIN) + unique(diff(rtLimFast));

pdfAcc = NaN(NUM_SESS,NBIN);
pdfFast = pdfAcc;

dlineAcc  = NaN(NUM_SESS,1);
dlineFast = dlineAcc;

for kk = 1:NUM_SESS
  RT = behavData.Sacc_RT{kk};
  
  %index by condition
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  idxFast = (behavData.Task_SATCondition{kk} == 3);
  
  rtAcc = RT(idxAcc & ~isnan(RT));    nAcc  = length(rtAcc);
  rtFast = RT(idxFast & ~isnan(RT));  nFast = length(rtFast);
  
  %get deadline for each condition
  dlineAcc(kk) =  nanmedian(behavData.Task_Deadline{kk}(idxAcc));
  dlineFast(kk) = nanmedian(behavData.Task_Deadline{kk}(idxFast));
  
  for bb = 1:NBIN
    
    idxBinFast = (rtFast > rtLimFast(bb)) & (rtFast <= rtLimFast(bb+1));
    idxBinAcc  = (rtAcc > rtLimAcc(bb))   & (rtAcc <= rtLimAcc(bb+1));
    
    pdfFast(kk,bb) = sum(idxBinFast) / nFast;
    pdfAcc(kk,bb)  = sum(idxBinAcc) / nAcc;
    
  end % for : RTbin(bb)
  
end % for : session(kk)

cdfFast = cumsum(pdfFast,2);
cdfAcc  = cumsum(pdfAcc,2);

sfFast = 1 - cdfFast;
sfAcc  = 1 - cdfAcc;

hfFast = pdfFast ./ sfFast;
hfAcc  = pdfAcc  ./ sfAcc;

%% Compute mean and SE across sessions
muDLine_Acc  = mean(dlineAcc);  seDLine_Acc  = std(dlineAcc)/sqrt(NUM_SESS);
muDLine_Fast = mean(dlineFast); seDLine_Fast = std(dlineFast)/sqrt(NUM_SESS);
muPDF_Acc = mean(pdfAcc);     sePDF_Acc = std(pdfAcc)/sqrt(NUM_SESS);
muCDF_Acc = mean(cdfAcc);     seCDF_Acc = std(cdfAcc)/sqrt(NUM_SESS);
muSF_Acc = mean(sfAcc);       seSF_Acc  = std(sfAcc)/sqrt(NUM_SESS);
muHF_Acc = mean(hfAcc);       seHF_Acc  = std(hfAcc)/sqrt(NUM_SESS);
muPDF_Fast = mean(pdfFast);   sePDF_Fast = std(cdfFast)/sqrt(NUM_SESS);
muCDF_Fast = mean(cdfFast);   seCDF_Fast = std(cdfFast)/sqrt(NUM_SESS);
muSF_Fast = mean(sfFast);     seSF_Fast  = std(sfFast)/sqrt(NUM_SESS);
muHF_Fast = mean(hfFast);     seHF_Fast  = std(hfFast)/sqrt(NUM_SESS);

%% Plotting
figure()

subplot(2,4,1); hold on
title('Probability density')
plot(rtFastPlot, pdfFast, '-', 'Color',[0 .7 0], 'LineWidth',1.25)
plot(dlineFast*ones(1,2), [0 .4], 'k:')
% shaded_error_bar(rtFastPlot, muPDF_Fast, sePDF_Fast, {'Color',[0 .7 0]}, 0);
% plot(muDLine_Fast*ones(1,2), [0 .2], 'k:')

subplot(2,4,2); hold on
title('Cumulative density')
plot(rtFastPlot,cdfFast, '-', 'Color',[0 .7 0], 'LineWidth',1.25)
plot(dlineFast*ones(1,2), [0 1], 'k:')
% shaded_error_bar(rtFastPlot, muCDF_Fast, seCDF_Fast, {'Color',[0 .7 0]}, 0);
% plot(muDLine_Fast*ones(1,2), [0 1], 'k:')

subplot(2,4,3); hold on
title('Survivor function')
plot(rtFastPlot, sfFast, '-', 'Color',[0 .7 0], 'LineWidth',1.25)
plot(dlineFast*ones(1,2), [0 1], 'k:')
% shaded_error_bar(rtFastPlot, muSF_Fast, seSF_Fast, {'Color',[0 .7 0]}, 0);
% plot(muDLine_Fast*ones(1,2), [0 1], 'k:')

subplot(2,4,4); hold on
title('Hazard function')
plot(rtFastPlot, hfFast, '-', 'Color',[0 .7 0], 'LineWidth',1.25)
plot(dlineFast*ones(1,2), [0 2], 'k:')
% shaded_error_bar(rtFastPlot, muHF_Fast, seHF_Fast, {'Color',[0 .7 0]}, 0);
% plot(muDLine_Fast*ones(1,2), [0 .5], 'k:')
ylim([0 2])

subplot(2,4,5); hold on
plot(rtAccPlot, pdfAcc, '-', 'Color','r', 'LineWidth',1.25)
plot(dlineAcc*ones(1,2), [0 .2], 'k:')
% shaded_error_bar(rtAccPlot, muPDF_Acc, sePDF_Acc, {'Color','r'}, 0);
% plot(muDLine_Acc*ones(1,2), [0 .1], 'k:')
xlabel('Response time (ms)')

subplot(2,4,6); hold on
plot(rtAccPlot, cdfAcc, '-', 'Color','r', 'LineWidth',1.25)
plot(dlineAcc*ones(1,2), [0 1], 'k:')
% shaded_error_bar(rtAccPlot, muCDF_Acc, seCDF_Acc, {'Color','r'}, 0);
% plot(muDLine_Acc*ones(1,2), [0 1], 'k:')
xlabel('Response time (ms)')

subplot(2,4,7); hold on
plot(rtAccPlot, sfAcc, '-', 'Color','r', 'LineWidth',1.25)
plot(dlineAcc*ones(1,2), [0 1], 'k:')
% shaded_error_bar(rtAccPlot, muSF_Acc, seSF_Acc, {'Color','r'}, 0);
% plot(muDLine_Acc*ones(1,2), [0 1], 'k:')
xlabel('Response time (ms)')

subplot(2,4,8); hold on
plot(rtAccPlot, hfAcc, '-', 'Color','r', 'LineWidth',1.25)
plot(dlineAcc*ones(1,2), [0 2], 'k:')
% shaded_error_bar(rtAccPlot, muHF_Acc, seHF_Acc, {'Color','r'}, 0);
% plot(muDLine_Acc*ones(1,2), [0 .5], 'k:')
xlabel('Response time (ms)')
ylim([0 2])

ppretty([10,2])

end % fxn : hazardRT()

