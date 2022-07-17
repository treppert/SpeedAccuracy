function [  ] = plot_SDF_ErrTime( sdfTE , unitData , varargin )
%plot_SDF_ErrTime Summary of this function goes here
%   
%   varargin
%   'tSig_TE' - struct with vector of times with sig. diff.
% 

args = getopt(varargin, {{'tSig_TE=',[]}, {'nBin_TE=',1}, {'nBin_dRT=',4}, ...
  {'area=',{'SEF'}}, {'monkey=',{'D','E'}}, {'uID=',[]}, 'significant'});

NUM_UNIT = length(sdfTE.Corr);
TVEC_RESP = sdfTE.Time(:,1);
TVEC_REW  = sdfTE.Time(:,3);

%parameters for plotting
GREEN = [0 .7 0];
LINEWIDTH = 1.2;
COLORPLOT = linspace(0.8, 0.3, args.nBin_dRT); %error line colors

tLimA = [-600 400]; %re. array
tLimP = [-600 400]; %re. primary
tLimR = [-400 1000]; %re. reward

for uu = 1:NUM_UNIT
  figure()
  yLim = [0, max([sdfTE.Corr(uu).Acc sdfTE.Err(uu,1).Acc sdfTE.Corr(uu,1).Fast],[],'all')];
  
  for bb = 1:args.nBin_TE
    subplot(2,4, 4*(bb-1)+1); hold on %Accurate re. array
    title([unitData.Properties.RowNames{uu},'-',unitData.Area{uu}], 'FontSize',9)
    plot(TVEC_RESP, sdfTE.Corr(uu).Fast(:,1), 'Color', GREEN, 'LineWidth',LINEWIDTH)
    plot(TVEC_RESP, sdfTE.Corr(uu).Acc(:,1), 'r', 'LineWidth',LINEWIDTH)
    for ii = 1:args.nBin_dRT
      idx_ii = args.nBin_dRT*(bb-1) + ii;
      plot(TVEC_RESP, sdfTE.Err(uu,idx_ii).Acc(:,1), ':', 'Color',[COLORPLOT(ii) 0 0], 'LineWidth',LINEWIDTH)
    end
    xlim(tLimA); ylim(yLim)

    subplot(2,4, 4*(bb-1)+2); hold on %Accurate re. primary
    plot(TVEC_RESP, sdfTE.Corr(uu).Fast(:,2), 'Color', GREEN, 'LineWidth',LINEWIDTH)
    plot(TVEC_RESP, sdfTE.Corr(uu).Acc(:,2), 'r', 'LineWidth',LINEWIDTH)
    for ii = 1:args.nBin_dRT
      idx_ii = args.nBin_dRT*(bb-1) + ii;
      plot(TVEC_RESP, sdfTE.Err(uu,idx_ii).Acc(:,2), ':', 'Color',[COLORPLOT(ii) 0 0], 'LineWidth',LINEWIDTH)
    end
    xlim(tLimP); ylim(yLim); set(gca, 'YColor','none')

    subplot(2,4, 4*(bb-1)+[3 4]); hold on %Accurate re. reward
    plot(TVEC_REW, sdfTE.Corr(uu).Fast(:,3), 'Color', GREEN, 'LineWidth',LINEWIDTH)
    plot(TVEC_REW, sdfTE.Corr(uu).Acc(:,3), 'r', 'LineWidth',LINEWIDTH)
    for ii = 1:args.nBin_dRT
      idx_ii = args.nBin_dRT*(bb-1) + ii;
      plot(TVEC_REW, sdfTE.Err(uu,idx_ii).Acc(:,3), ':', 'Color',[COLORPLOT(ii) 0 0], 'LineWidth',LINEWIDTH)
    end
    if (bb == args.nBin_TE); scatter(args.tSig_TE(uu).vec, yLim(2)/25, 4, 'k'); end %show timepoint significance
    line(ones(2,1)*unitData.SignalTE_Time(uu,:), yLim/2, 'color','k', 'linestyle',':')
    xlim(tLimR); ylim(yLim); %set(gca, 'YColor','none')
    
    subplot(2,4, 4*bb+1); hold on %Fast re. array
    plot(TVEC_RESP, sdfTE.Corr(uu).Fast(:,1), 'Color', GREEN, 'LineWidth',LINEWIDTH)
    plot(TVEC_RESP, sdfTE.Corr(uu).Acc(:,1), 'r', 'LineWidth',LINEWIDTH)
    for ii = 1:args.nBin_dRT
      idx_ii = args.nBin_dRT*(bb-1) + ii;
      plot(TVEC_RESP, sdfTE.Err(uu,idx_ii).Fast(:,1), ':', 'Color',[0 COLORPLOT(ii) 0], 'LineWidth',LINEWIDTH)
    end
    xlim(tLimA); ylim(yLim)
    ylabel('Activity (sp/sec)')
    
    subplot(2,4, 4*bb+2); hold on %Fast re. primary
    plot(TVEC_RESP, sdfTE.Corr(uu).Fast(:,2), 'Color', GREEN, 'LineWidth',LINEWIDTH)
    plot(TVEC_RESP, sdfTE.Corr(uu).Acc(:,2), 'r', 'LineWidth',LINEWIDTH)
    for ii = 1:args.nBin_dRT
      idx_ii = args.nBin_dRT*(bb-1) + ii;
      plot(TVEC_RESP, sdfTE.Err(uu,idx_ii).Fast(:,2), ':', 'Color',[0 COLORPLOT(ii) 0], 'LineWidth',LINEWIDTH)
    end
    xlim(tLimP); ylim(yLim); set(gca, 'YColor','none')
    xlabel('Time from response (ms)')

    subplot(2,4, 4*bb+[3 4]); hold on %Fast re. reward
    plot(TVEC_REW, sdfTE.Corr(uu).Fast(:,3), 'Color', GREEN, 'LineWidth',LINEWIDTH)
    plot(TVEC_REW, sdfTE.Corr(uu).Acc(:,3), 'r', 'LineWidth',LINEWIDTH)
    for ii = 1:args.nBin_dRT
      idx_ii = args.nBin_dRT*(bb-1) + ii;
      plot(TVEC_REW, sdfTE.Err(uu,idx_ii).Fast(:,3), ':', 'Color',[0 COLORPLOT(ii) 0], 'LineWidth',LINEWIDTH)
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
  
end% for : unit (uu)

end % fxn : plot_SDF_ErrTime()
