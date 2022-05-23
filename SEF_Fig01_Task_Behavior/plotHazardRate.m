function [  ] = plotHazardRate( behavData , varargin )
%plotHazardRate Plot the hazard rate associated with RT errors committed
%during the Accurate task condition
%   Detailed explanation goes here

NUM_SESS = size(behavData,1);

%prepare for RT binning
N_RTBIN = 8;
binLim = linspace(-400, 0, N_RTBIN);
dLim = diff(binLim);
rtPlot = binLim(1:N_RTBIN) + dLim(1);

%initialize empirical pdf
pdfAcc = NaN(NUM_SESS,N_RTBIN);

for kk = 1:NUM_SESS
  RT = behavData.Sacc_RT{kk};
  
  %get RT
  idxAcc = (behavData.Task_SATCondition{kk} == 1);
  rtAcc = RT(idxAcc & ~isnan(RT));
  nAcc  = length(rtAcc);
  
  %get deadline
  dlineAcc =  nanmedian(behavData.Task_Deadline{kk}(idxAcc));
  
  %compute RT error
  rtAcc  = rtAcc - dlineAcc;
  
  %compute empirical pdf
  for bb = 1:NBIN
    idxBinAcc  = (rtAcc > rtLimAcc(bb))   & (rtAcc <= rtLimAcc(bb+1));
    pdfAcc(kk,bb)  = sum(idxBinAcc) / nAcc;
  end % for : RTbin(bb)
  
end % for : session(kk)

cdfAcc  = cumsum(pdfAcc,2);
sfAcc  = 1 - cdfAcc;
hfAcc  = pdfAcc  ./ sfAcc;

%% Use pre-fit quadratic model to compute estimated hazard rate
rtEst = linspace(-400, 0, 500);
nEst = length(rtEst);

%initialize estimated hazard rate
hEst = NaN(NUM_SESS,nEst);
for kk = 1:NUM_SESS
  hEst(kk,:) = transform_RT2hazard(rtEst, kk);
end % for : session(kk)


%% Plotting

figure(); hold on
plot(rtPlot, hfAcc, '-', 'Color','r', 'LineWidth',1.25)
if ~isempty(kkHighlight)
  title(behavData.Task_Session{kkHighlight})
  plot(rtAccPlot, hfAcc(kkHighlight,:), 'k-', 'LineWidth',1.5)
else
  plot(rtAccPlot, muHF_Acc, 'k-', 'LineWidth',1.5)
%   plot(rtAccPlot, polyval(args.hfFit, rtAccPlot), '-', 'Color',.5*ones(1,3), 'LineWidth',1.5)
end
xlabel('RT re. deadline (ms)')
ylabel('Hazard rate')
xlim([-300 0])

ppretty([3.2,2])

end % fxn : plotHazardRate()

