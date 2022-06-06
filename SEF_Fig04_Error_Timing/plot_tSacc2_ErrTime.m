function [  ] = plot_tSacc2_ErrTime( behavData , varargin )
%plot_tSacc2_SAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

%isolate sessions from MONKEY
kkKeep = (ismember(behavData.Monkey, args.monkey) & behavData.Task_RecordedSEF);
behavData = behavData(kkKeep,:);
NUM_SESS = sum(kkKeep);

MIN_ISI = 600;
BINLIM_ISI = linspace(0, 2500, 26);
NUM_BIN = length(BINLIM_ISI) - 1;
isiPlot = BINLIM_ISI(1:NUM_BIN) + 0.5*diff(BINLIM_ISI([1,2]));

cdfFC = NaN(NUM_SESS,NUM_BIN); %Fast correct
cdfFE = cdfFC; %Fast error
cdfAC = cdfFC; %Accurate correct
cdfAE = cdfFC; %Accurate error

%% Collect time of second saccade across sessions
for kk = 1:NUM_SESS
  
  ISI_kk = behavData.Sacc2_RT{kk} - behavData.Sacc_RT{kk};
  
  %index by ISI
  idxCut = (ISI_kk < MIN_ISI);
  
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxCut);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxCut);
  
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  idxTErr = behavData.Task_ErrTimeOnly{kk};
  
  %combine indexing
  idxAC = (idxAcc & idxCorr);    idxAE = (idxAcc & idxTErr);
  idxFC = (idxFast & idxCorr);   idxFE = (idxFast & idxTErr);
  
  for bin = 1:NUM_BIN
    idxBin = (ISI_kk > BINLIM_ISI(bin)) & (ISI_kk <= BINLIM_ISI(bin+1));
    cdfFC(kk,bin) = sum(idxFC & idxBin) / sum(idxFC);
    cdfAC(kk,bin) = sum(idxAC & idxBin) / sum(idxAC);
    cdfFE(kk,bin) = sum(idxFE & idxBin) / sum(idxFE);
    cdfAE(kk,bin) = sum(idxAE & idxBin) / sum(idxAE);
  end
  
end % for : session(kk)

cdfFC = cumsum(cdfFC,2);  cdfFE = cumsum(cdfFE,2);
cdfAC = cumsum(cdfAC,2);  cdfAE = cumsum(cdfAE,2);

%% Plotting - Distribution
LINEWIDTH = 1.2;

figure()
tReward = mean(behavData.Task_TimeReward);

subplot(1,2,1) %Accurate condition
for kk = 1:NUM_SESS
  line(isiPlot, cdfAC(kk,:), 'color','r', 'linewidth',LINEWIDTH)
  line(isiPlot, cdfAE(kk,:), 'color',[.4 0 0], 'linewidth',LINEWIDTH)
end
line(tReward*ones(1,2), [0 1], 'color','k', 'linestyle',':')
% line(isiPlot, mean(cdfAC), 'color',GRAY, 'lineWidth',2.0)
% line(isiPlot, mean(cdfAE), 'color','k', 'lineWidth',2.0)
xlim([500 2200]); ylim([0 1]); ytickformat('%2.1f')
xlabel('Inter-saccade interval (ms)')
ylabel('Cumulative probability')
legend('Corr','Error', 'location','northwest')

subplot(1,2,2) %Fast condition
for kk = 1:NUM_SESS
  line(isiPlot, cdfFC(kk,:), 'color',[0 .8 0], 'linewidth',LINEWIDTH)
  line(isiPlot, cdfFE(kk,:), 'color',[0 .4 0], 'linewidth',LINEWIDTH)
end
line(tReward*ones(1,2), [0 1], 'color','k', 'linestyle',':')
% line(isiPlot, mean(cdfFC), 'color',GRAY, 'lineWidth',2.0)
% line(isiPlot, nanmean(cdfFE), 'color','k', 'lineWidth',2.0)
xlim([500 2200]); ylim([0 1]); ytickformat('%2.1f')
xlabel('Inter-saccade interval (ms)')
legend('Corr','Error', 'location','northwest')

ppretty([6.4,2])

% %plot -- average
% ttestFull(tMedSacc2_Acc, tMedSacc2_Fast, 'barplot', ...
%   'xticklabels',{'Acc','Fast'}, 'ylabel','Time of second saccade (ms)')

end % fxn : plot_tSacc2_SAT()
