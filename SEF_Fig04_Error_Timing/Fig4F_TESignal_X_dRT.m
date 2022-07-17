function [ varargout ] = Fig4F_TESignal_X_dRT( sdfTE , unitTest , varargin )
%Fig4F_TESignal_X_dRT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'nBin_TE=',1}, {'nBin_dRT=',4}, {'monkey=',{'D','E'}}});

%index by monkey
idxMonk = ismember(unitTest.Monkey, args.monkey);
sdfTE.Corr = sdfTE.Corr(idxMonk,:);
sdfTE.Err  = sdfTE.Err(idxMonk,:);
unitTest = unitTest(idxMonk,:);

NUM_UNIT = size(unitTest,1);

%initializations
A_TE = NaN(NUM_UNIT,args.nBin_TE*args.nBin_dRT);

for uu = 1:NUM_UNIT
  
  %start and finish of timing error signal
  tLim_uu = unitTest.SignalTE_Time(uu,:);
  tLim_uu = tLim_uu - sdfTE.Time(1,3); %take into account offset in SDF
  
  for bb = 1:args.nBin_TE
    for ii = 1:args.nBin_dRT
      idx_ii = args.nBin_dRT*(bb-1) + ii;
      sdfCorr = sdfTE.Corr(uu).Acc(:,3);
      sdfErr = sdfTE.Err(uu,idx_ii).Acc(:,3);
      A_TE(uu,idx_ii) = calc_ErrorSignalMag_SAT(sdfCorr, sdfErr, 'limTest',tLim_uu);
    end % for : dRT bin (ii)
  end % for : RT error bin (bb)
  
end % for : unit(uu)

%reverse sign for error-suppressed neurons
idxSuppressed = (unitTest.Grade_TErr == -1);
A_TE(idxSuppressed,:) = -A_TE(idxSuppressed,:);

%% Plotting
XLIM = [0.5 , args.nBin_dRT+0.5];

%fit line to average trend
% QUARTILE = (1:4);
% fLin = fit(QUARTILE', mean(A_TE)', 'poly1');

figure(); hold on
errorbar(mean(A_TE), std(A_TE)/sqrt(NUM_UNIT), 'Color',[.5 0 0], 'CapSize',0, 'LineWidth',1.25)
% plot(QUARTILE, fLin(QUARTILE), 'k-')
xlim(XLIM); ytickformat('%3.2f')
ppretty([1.3,1.8]); set(gca, 'xminortick','off')
drawnow

figure(); hold on
plot(A_TE')
errorbar(mean(A_TE), std(A_TE)/sqrt(NUM_UNIT), 'k', 'CapSize',0, 'LineWidth',1.25)
xlim(XLIM); ytickformat('%3.2f')
ppretty([1.3,1.8]); set(gca, 'xminortick','off')

%% Output
if (nargout > 0)
  varargout{1} = A_TE;
end

end % fxn : Fig4F_TESignal_X_dRT()
