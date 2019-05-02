function [ varargout ] = testVisRespXareaSAT( ninfo , nstats , param )
%testVisRespXareaSAT Summary of this function goes here
%   This function aims to assess the degree of SAT-related modulation of
%   the visual response in SEF, FEF, and SC, and to determine any
%   differences across the three areas.


idxSEF = (ismember({ninfo.area}, {'SEF'}) & ismember({ninfo.visType}, {'sustained'}));
idxFEF = (ismember({ninfo.area}, {'FEF'}) & ([ninfo.visGrade] >= 0.5));
idxSC =  (ismember({ninfo.area}, {'SC'}) & ([ninfo.visGrade] >= 0.5));

if strcmp(param, 'TST')
  idxTST = ~(isnan([nstats.VRTSTAcc]) | isnan([nstats.VRTSTFast]));
  idxSEF = (idxSEF & idxTST);
  idxFEF = (idxFEF & idxTST);
  idxSC = (idxSC & idxTST);
elseif ~ismember(param, {'Latency','Magnitude'})
  error('Input "param" not recognized')
end

if strcmp(param, 'TST')
  fieldAcc = 'VRTSTAcc';
  fieldFast = 'VRTSTFast';
  unit = '(ms)';
elseif strcmp(param, 'Latency')
  fieldAcc = 'VRlatAcc';
  fieldFast = 'VRlatFast';
  unit = '(sp/s)';
else %Magnitude
  fieldAcc = 'VRmagAcc';
  fieldFast = 'VRmagFast';
  unit = '(ms)';
end

nSEF = sum(idxSEF);
nFEF = sum(idxFEF);
nSC = sum(idxSC);

%parameter split by SAT condition
parmAccSEF = [nstats(idxSEF).(fieldAcc)];     parmFastSEF = [nstats(idxSEF).(fieldFast)];
parmAccFEF = [nstats(idxFEF).(fieldAcc)];     parmFastFEF = [nstats(idxFEF).(fieldFast)];
parmAccSC = [nstats(idxSC).(fieldAcc)];     parmFastSC = [nstats(idxSC).(fieldFast)];

%difference across conditions
if strcmp(param, 'Magnitude')
  dparmSEF = parmFastSEF - parmAccSEF;
  dparmFEF = parmFastFEF - parmAccFEF;
  dparmSC = parmFastSC - parmAccSC;
else
  dparmSEF = parmAccSEF - parmFastSEF;
  dparmFEF = parmAccFEF - parmFastFEF;
  dparmSC = parmAccSC - parmFastSC;
end


%% Plotting
%cumulative distribution
if (0)
figure(); hold on
cdfplotTR(parmFastSEF, 'Color',[0 .7 0], 'LineWidth',0.75, 'LineStyle','-')
cdfplotTR(parmFastFEF, 'Color',[0 .7 0], 'LineWidth',0.75, 'LineStyle',':')
cdfplotTR(parmFastSC, 'Color',[0 .7 0], 'LineWidth',0.75, 'LineStyle','--')
cdfplotTR(parmAccSEF, 'Color','r', 'LineWidth',0.75, 'LineStyle','-')
cdfplotTR(parmAccFEF, 'Color','r', 'LineWidth',0.75, 'LineStyle',':')
cdfplotTR(parmAccSC, 'Color','r', 'LineWidth',0.75, 'LineStyle','--')
plot([0 0], [0 1], 'k:')
xlabel([param, ' ', unit])
ylabel('Cumulative probability')
legend({'SEF','FEF','SC','SEF','FEF','SC'})
ppretty([5 5]); pause(0.1)
end

%boxplot
if (0)
figure(); hold on
grpBP = [ones(1,nSEF) 2*ones(1,nSEF) 3*ones(1,nFEF) 4*ones(1,nFEF) 5*ones(1,nSC) 6*ones(1,nSC)];
parmBP = [parmAccSEF parmFastSEF parmAccFEF parmFastFEF parmAccSC parmFastSC];
labelBP = {'SEFacc','SEFfast','FEFacc','FEFfast','SCacc','SCfast'};
boxplot(parmBP, grpBP, 'Labels',labelBP, 'Colors','k', 'Whisker',0.8, 'Widths',0.7, ...
  'OutlierSize',3, 'Jitter',0.3, 'Orientation','horizontal')
ylabel('Target selection time (ms)')
ppretty([4.8 3]); pause(0.1)
end

%% Plotting - Difference (SAT effect) X area
%cumulative distribution
if (0)
figure(); hold on
cdfplotTR(dparmSEF, 'Color','k', 'LineWidth',0.75, 'LineStyle','-')
cdfplotTR(dparmFEF, 'Color','k', 'LineWidth',0.75, 'LineStyle',':')
cdfplotTR(dparmSC, 'Color','k', 'LineWidth',0.75, 'LineStyle','--')
plot([0 0], [0 1], 'k:')
ylim([0 1]); ytickformat('%2.1f')
xlabel([param, ' diff. ', unit])
ylabel('Cumulative probability')
legend({'SEF','FEF','SC'})
ppretty([4 4])
end

%boxplot
if (0)
figure(); hold on
grpBP = [ones(1,nSEF) 2*ones(1,nFEF) 3*ones(1,nSC)];
parmBP = [dparmSEF dparmFEF dparmSC];
labelBP = {'SEF','FEF','SC'};
boxplot(parmBP, grpBP, 'Labels',labelBP, 'Colors','k', 'Whisker',1.0, 'Widths',0.7, ...
  'OutlierSize',3, 'Jitter',0.3, 'Orientation','horizontal')
ylabel(['Difference in ', param, ' ', unit])
ppretty([4 2]); pause(0.1)
end

end%fxn:testVisRespXareaSAT()

%% Stats
% dparm = [dparmSEF dparmFEF dparmSC]; %dependent variable
% area = [ones(1,length(dparmSEF)), 2*ones(1,length(dparmFEF)), 3*ones(1,length(dparmSC))]; %factor 1
% 
% if (nargout > 0)
%   [~,ANtbl,ANstats] = anovan(dparm', area', 'model','linear', 'display','off');
%   varargout{1} = ANtbl;
%   if (nargout > 1)
%     MCresults = multcompare(ANstats, 'Dimension',1);
%     varargout{2} = MCresults;
%   end
% end
