function [  ] = plot_SDF_ErrTime( sdfTE , unitData , varargin )
%plot_SDF_ErrTime Summary of this function goes here
%   
%   varargin
%   'hide' (y/n) - Don't show figures
%   'print' (y/n) - Print to directory PRINTDIR
%   'significant' (y/n) - show timepoints of significant difference
% 

args = getopt(varargin, {'hide','print','significant'});

NUM_UNIT = length(sdfTE.Corr);
tRec     = (-1300 : 400);
tRec_Rew = (-500 : 1200);

PRINTDIR = 'C:\Users\Tom\Documents\Figs - SAT\';
NBIN_TERR = size(sdfTE.Err,2);
SHADE_PLOT = linspace(0.8, 0.5, NBIN_TERR);
GREEN = [0 .7 0];

tLimA = [-400 250]; %re. array
tLimP = [-250 400]; %re. primary
tLimR = [-500 1200]; %re. reward

for uu = 1:NUM_UNIT
  figure('visible', ~args.hide);
  yLim = [0, max([sdfTE.Corr(uu).Acc sdfTE.Corr(uu).Fast sdfTE.Err(uu,end).Acc],[],'all')];

  subplot(2,4,1); hold on %Accurate re. array
  title([unitData.Properties.RowNames{uu},'-',unitData.Area{uu}], 'FontSize',9)
  plot(tRec, sdfTE.Corr(uu).Fast(:,1), 'Color', GREEN, 'LineWidth',1.25)
  plot(tRec, sdfTE.Corr(uu).Acc(:,1), 'r', 'LineWidth',1.25)
  for bb = 1:NBIN_TERR
    plot(tRec, sdfTE.Err(uu,bb).Acc(:,1), ':', 'Color',[SHADE_PLOT(bb) 0 0], 'LineWidth',1.25)
  end
  xlim(tLimA); ylim(yLim)
  ylabel('Activity (sp/sec)')

  subplot(2,4,2); hold on %Accurate re. primary
  plot(tRec, sdfTE.Corr(uu).Fast(:,2), 'Color', GREEN, 'LineWidth',1.25)
  plot(tRec, sdfTE.Corr(uu).Acc(:,2), 'r', 'LineWidth',1.25)
  for bb = 1:NBIN_TERR
    plot(tRec, sdfTE.Err(uu,bb).Acc(:,2), ':', 'Color',[SHADE_PLOT(bb) 0 0], 'LineWidth',1.25)
  end
  xlim(tLimP); ylim(yLim); set(gca, 'YColor','none')

  subplot(2,4,[3 4]); hold on %Accurate re. reward
  plot(tRec_Rew, sdfTE.Corr(uu).Fast(:,3), 'Color', GREEN, 'LineWidth',1.25)
  plot(tRec_Rew, sdfTE.Corr(uu).Acc(:,3), 'r', 'LineWidth',1.25)
  for bb = 1:NBIN_TERR
    plot(tRec_Rew, sdfTE.Err(uu,bb).Acc(:,3), ':', 'Color',[SHADE_PLOT(bb) 0 0], 'LineWidth',1.25)
  end
  if (args.significant)
    scatter(unitData.SignalTE_TimeVec{uu}, yLim(2)/25, 4, 'k')
  end
  line(ones(2,1)*unitData.SignalTE_Time(uu,:), yLim, 'color','k', 'linestyle',':')
  xlim(tLimR); ylim(yLim); set(gca, 'YColor','none')

  subplot(2,4,5); hold on %Fast re. array
  plot(tRec, sdfTE.Corr(uu).Fast(:,1), 'Color', GREEN, 'LineWidth',1.25)
  plot(tRec, sdfTE.Corr(uu).Acc(:,1), 'r', 'LineWidth',1.25)
  for bb = 1:NBIN_TERR
    plot(tRec, sdfTE.Err(uu,bb).Fast(:,1), ':', 'Color',[0 SHADE_PLOT(bb) 0], 'LineWidth',1.25)
  end
  xlim(tLimA); ylim(yLim)
  xlabel('Time from array (ms)')
  ylabel('Activity (sp/sec)')

  subplot(2,4,6); hold on %Fast re. primary
  plot(tRec, sdfTE.Corr(uu).Fast(:,2), 'Color', GREEN, 'LineWidth',1.25)
  plot(tRec, sdfTE.Corr(uu).Acc(:,2), 'r', 'LineWidth',1.25)
  for bb = 1:NBIN_TERR
    plot(tRec, sdfTE.Err(uu,bb).Fast(:,2), ':', 'Color',[0 SHADE_PLOT(bb) 0], 'LineWidth',1.25)
  end
  xlim(tLimP); ylim(yLim); set(gca, 'YColor','none')
  xlabel('Time from response (ms)')

  subplot(2,4,[7 8]); hold on %Fast re. reward
  plot(tRec_Rew, sdfTE.Corr(uu).Fast(:,3), 'Color', GREEN, 'LineWidth',1.25)
  plot(tRec_Rew, sdfTE.Corr(uu).Acc(:,3), 'r', 'LineWidth',1.25)
  for bb = 1:NBIN_TERR
    plot(tRec_Rew, sdfTE.Err(uu,bb).Fast(:,3), ':', 'Color',[0 SHADE_PLOT(bb) 0], 'LineWidth',1.25)
  end
  xlim(tLimR); ylim(yLim'); set(gca, 'YColor','none')
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
