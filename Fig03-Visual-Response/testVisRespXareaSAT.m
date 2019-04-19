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

dparmSEF = [nstats(idxSEF).(fieldAcc)] - [nstats(idxSEF).(fieldFast)];
dparmFEF = [nstats(idxFEF).(fieldAcc)] - [nstats(idxFEF).(fieldFast)];
dparmSC =  [nstats(idxSC).(fieldAcc)] - [nstats(idxSC).(fieldFast)];

%% Stats
dparm = [dparmSEF dparmFEF dparmSC]; %dependent variable
area = [ones(1,length(dparmSEF)), 2*ones(1,length(dparmFEF)), 3*ones(1,length(dparmSC))]; %factor 1

if (nargout > 0)
  [~,ANtbl,ANstats] = anovan(dparm', area', 'model','linear', 'display','off');
  varargout{1} = ANtbl;
  if (nargout > 1)
    MCresults = multcompare(ANstats, 'Dimension',1);
    varargout{2} = MCresults;
  end
end

%% Plotting

figure(); hold on
cdfplotTR(dparmSEF, 'Color','k', 'LineWidth',1.0, 'LineStyle','-')
cdfplotTR(dparmFEF, 'Color','b', 'LineWidth',1.0, 'LineStyle','-')
cdfplotTR(dparmSC, 'Color','k', 'LineWidth',1.0, 'LineStyle',':')
plot([0 0], [0 1], 'k:')
ylim([0 1]); ytickformat('%2.1f')
xlabel([param, ' diff. (Acc - Fast) ', unit])
ylabel('Cumulative probability')
legend({'SEF','FEF','SC'})
ppretty([4 4])





end%fxn:testVisRespXareaSAT()

