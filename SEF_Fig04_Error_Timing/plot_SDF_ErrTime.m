function [  ] = plot_SDF_ErrTime( sdfTE , unitData , varargin )
%plot_SDF_ErrTime Summary of this function goes here
%   
%   varargin
%   'tSig_TE' - struct with vector of times with sig. diff.
%   'hide' (y/n) - Don't show figures
%   'print' (y/n) - Print to directory PRINTDIR
%   'significant' (y/n) - show timepoints of significant difference
% 

args = getopt(varargin, {{'tSig_TE=',[]}, {'nBin_TE=',2}, {'nBin_dRT=',3}, ...
  'hide', 'print', 'significant'});

NUM_UNIT = length(sdfTE.Corr);
tRec     = sdfTE.Time(:,1);
tRec_Rew = sdfTE.Time(:,3);

NBIN_TERR = args.nBin_TE;
NBIN_dRT  = args.nBin_dRT;

PRINTDIR = 'C:\Users\Tom\Documents\Figs - SAT\';
CPLOT = linspace(0.8, 0.3, NBIN_dRT);
GREEN = [0 .7 0];
LINEWIDTH = 1.2;

tLimA = [-600 400]; %re. array
tLimP = [-600 400]; %re. primary
tLimR = [-400 1000]; %re. reward

for uu = 7:NUM_UNIT
  figure('visible', ~args.hide);
  yLim = [0, max([sdfTE.Corr(uu).Acc sdfTE.Err(uu,1).Acc sdfTE.Err(uu,1).Fast],[],'all')];
  
  for bb = 1:NBIN_TERR
    subplot(2,4, 4*(bb-1)+1); hold on %Accurate re. array
    title([unitData.Properties.RowNames{uu},'-',unitData.Area{uu}], 'FontSize',9)
    plot(tRec, sdfTE.Corr(uu).Fast(:,1), 'Color', GREEN, 'LineWidth',LINEWIDTH)
    plot(tRec, sdfTE.Corr(uu).Acc(:,1), 'r', 'LineWidth',LINEWIDTH)
    for ii = 1:NBIN_dRT
      idx_ii = NBIN_dRT*(bb-1) + ii;
      plot(tRec, sdfTE.Err(uu,idx_ii).Acc(:,1), ':', 'Color',[CPLOT(ii) 0 0], 'LineWidth',LINEWIDTH)
    end
    xlim(tLimA); ylim(yLim)

    subplot(2,4, 4*(bb-1)+2); hold on %Accurate re. primary
    plot(tRec, sdfTE.Corr(uu).Fast(:,2), 'Color', GREEN, 'LineWidth',LINEWIDTH)
    plot(tRec, sdfTE.Corr(uu).Acc(:,2), 'r', 'LineWidth',LINEWIDTH)
    for ii = 1:NBIN_dRT
      idx_ii = NBIN_dRT*(bb-1) + ii;
      plot(tRec, sdfTE.Err(uu,idx_ii).Acc(:,2), ':', 'Color',[CPLOT(ii) 0 0], 'LineWidth',LINEWIDTH)
    end
    xlim(tLimP); ylim(yLim); set(gca, 'YColor','none')

    subplot(2,4, 4*(bb-1)+[3 4]); hold on %Accurate re. reward
    plot(tRec_Rew, sdfTE.Corr(uu).Fast(:,3), 'Color', GREEN, 'LineWidth',LINEWIDTH)
    plot(tRec_Rew, sdfTE.Corr(uu).Acc(:,3), 'r', 'LineWidth',LINEWIDTH)
    for ii = 1:NBIN_dRT
      idx_ii = NBIN_dRT*(bb-1) + ii;
      plot(tRec_Rew, sdfTE.Err(uu,idx_ii).Acc(:,3), ':', 'Color',[CPLOT(ii) 0 0], 'LineWidth',LINEWIDTH)
    end
    if ((bb == NBIN_TERR) && (args.significant))
      scatter(args.tSig_TE(uu).vec, yLim(2)/25, 4, 'k')
    end
    line(ones(2,1)*unitData.SignalTE_Time(uu,:), yLim/2, 'color','k', 'linestyle',':')
    xlim(tLimR); ylim(yLim); %set(gca, 'YColor','none')
    
    subplot(2,4, 4*bb+1); hold on %Fast re. array
    plot(tRec, sdfTE.Corr(uu).Fast(:,1), 'Color', GREEN, 'LineWidth',LINEWIDTH)
    plot(tRec, sdfTE.Corr(uu).Acc(:,1), 'r', 'LineWidth',LINEWIDTH)
    for ii = 1:NBIN_dRT
      idx_ii = NBIN_dRT*(bb-1) + ii;
      plot(tRec, sdfTE.Err(uu,idx_ii).Fast(:,1), ':', 'Color',[0 CPLOT(ii) 0], 'LineWidth',LINEWIDTH)
    end
    xlim(tLimA); ylim(yLim)
    ylabel('Activity (sp/sec)')
    
    subplot(2,4, 4*bb+2); hold on %Fast re. primary
    plot(tRec, sdfTE.Corr(uu).Fast(:,2), 'Color', GREEN, 'LineWidth',LINEWIDTH)
    plot(tRec, sdfTE.Corr(uu).Acc(:,2), 'r', 'LineWidth',LINEWIDTH)
    for ii = 1:NBIN_dRT
      idx_ii = NBIN_dRT*(bb-1) + ii;
      plot(tRec, sdfTE.Err(uu,idx_ii).Fast(:,2), ':', 'Color',[0 CPLOT(ii) 0], 'LineWidth',LINEWIDTH)
    end
    xlim(tLimP); ylim(yLim); set(gca, 'YColor','none')
    xlabel('Time from response (ms)')

    subplot(2,4, 4*bb+[3 4]); hold on %Fast re. reward
    plot(tRec_Rew, sdfTE.Corr(uu).Fast(:,3), 'Color', GREEN, 'LineWidth',LINEWIDTH)
    plot(tRec_Rew, sdfTE.Corr(uu).Acc(:,3), 'r', 'LineWidth',LINEWIDTH)
    for ii = 1:NBIN_dRT
      idx_ii = NBIN_dRT*(bb-1) + ii;
      plot(tRec_Rew, sdfTE.Err(uu,idx_ii).Fast(:,3), ':', 'Color',[0 CPLOT(ii) 0], 'LineWidth',LINEWIDTH)
    end
    xlim(tLimR); ylim(yLim'); %set(gca, 'YColor','none')
    xlabel('Time from reward (ms)')
    
  end % for : TE bin (bb)
  
  subplot(2,4, 4*(bb-1)+1); hold on
  xlabel('Time from array (ms)')
  ylabel('Activity (sp/sec)')

  subplot(2,4, 4*(bb-1)+2); hold on
  xlabel('Time from response (ms)')

  subplot(2,4, 4*(bb-1)+[3 4]); hold on
  xlabel('Time from reward (ms)')

  ppretty([8,2])
  
  if (args.print)
    pause(0.1); print([PRINTDIR,unitData.Properties.RowNames{uu},'-',unitData.Area{uu},'.tif'], '-dtiff')
    pause(0.1); close(); pause(0.1)
  else
    pause()
  end
  
end% for : unit (uu)

clearvars -except behavData unitData spikesSAT ROOTDIR_SAT* sdfAC sdfAE sdfFC sdfFE
