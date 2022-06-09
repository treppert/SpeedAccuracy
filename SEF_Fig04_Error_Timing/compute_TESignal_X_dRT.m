function [ varargout ] = compute_TESignal_X_dRT( sdfTE , unitData , varargin )
%compute_TESignal_X_dRT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'nBin_TE=',2}, {'nBin_dRT=',3}, 'plot_cdf'});

NUM_UNIT = size(unitData,1);
NUM_SAMP = size(sdfTE.Time,1);
NBIN_TERR = args.nBin_TE;
NBIN_dRT  = args.nBin_dRT;

%initializations
A_TE = NaN(NUM_UNIT,NBIN_TERR*NBIN_dRT);
A_TE_vec = cell(NBIN_TERR,NBIN_dRT);
[A_TE_vec{:,:}] = deal(NaN(NUM_UNIT,NUM_SAMP));

for uu = 1:NUM_UNIT
  
  %start and finish of timing error signal
  tLim_uu = unitData.SignalTE_Time(uu,:);
  tLim_uu = tLim_uu - sdfTE.Time(1,3); %take into account offset in SDF
  
  for bb = 1:NBIN_TERR
    for ii = 1:NBIN_dRT
      idx_ii = NBIN_dRT*(bb-1) + ii;
      sdfCorr = sdfTE.Corr(uu).Acc(:,3);
      sdfErr = sdfTE.Err(uu,idx_ii).Acc(:,3);
      A_TE(uu,idx_ii) = calc_ErrorSignalMag_SAT(sdfCorr, sdfErr, 'limTest',tLim_uu);
      A_TE_vec{bb,ii}(uu,:) = (sdfErr-sdfCorr) ./ (sdfErr + sdfCorr);
    end % for : dRT bin (ii)
  end % for : RT error bin (bb)
  
end % for : unit(uu)

%reverse sign for error-suppressed neurons
idxSuppressed = (unitData.Grade_TErr == -1);
A_TE(idxSuppressed,:) = -A_TE(idxSuppressed,:);
for bb = 1:NBIN_TERR
  for ii = 1:NBIN_dRT
    A_TE_vec{bb,ii}(idxSuppressed,:) = -A_TE_vec{bb,ii}(idxSuppressed,:);
  end
end

%% Plotting

% CPLOT = linspace(.8, .2, NBIN_dRT);
% figure(); hold on
% for bb = 1:NBIN_TERR
%   for ii = 1:NBIN_dRT
%     shaded_error_bar(sdfTE.Time(:,3), mean(A_TE_vec{bb,ii}), std(A_TE_vec{bb,ii})/sqrt(NUM_UNIT), ...
%       {'color',[CPLOT(ii) 0 0]})
%   end
% end
% xlim([-500 1000])
% xlabel('Time from reward (ms)')
% ylabel('Error signal magnitude')
% ppretty([2.4,1.4])

figure(); hold on
% plot(A_TE', 'k-')
errorbar(mean(A_TE), std(A_TE)/sqrt(NUM_UNIT), 'k', 'CapSize',0)
ppretty([1.4,2])

if (args.plot_cdf)
  YPLOT = (1 : NUM_UNIT);
  CPLOT = linspace(.8, .2, NBIN_dRT);

  for bb = 1:NBIN_TERR

    figure(); hold on
    for ii = 1:NBIN_dRT %bins of dRT
      idx_ii = NBIN_dRT*(bb-1) + ii;
      plot(sort(A_TE(:,idx_ii)), YPLOT, 'color',[CPLOT(ii) 0 0])
    end
    ylim([1 NUM_UNIT])

  end % for : TE bin (bb)
end % if : plot CDF

if (nargout > 0)
  varargout{1} = A_TE;
end

end % fxn : compute_TESignal_X_dRT()

