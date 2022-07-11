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
XLIM = [0.5 , NBIN_dRT+0.5];
QUARTILE = (1:4);

%fit line to average trend
fLin = fit(QUARTILE', mean(A_TE)', 'poly1');

figure(); hold on
errorbar(mean(A_TE), std(A_TE)/sqrt(NUM_UNIT), 'r', 'CapSize',0, 'LineWidth',1.25)
plot(QUARTILE, fLin(QUARTILE), 'k-')
xlim(XLIM); ytickformat('%3.2f')
ppretty([1.3,1.8]); set(gca, 'xminortick','off')

figure(); hold on
plot(A_TE')
xlim(XLIM); ytickformat('%3.2f')
ppretty([1.3,1.8]); set(gca, 'xminortick','off')


%% Output
if (nargout > 0)
  varargout{1} = A_TE;
end

end % fxn : compute_TESignal_X_dRT()
