%plot_SDF_X_Dir_SAT() Summary of this function goes here
%   Detailed explanation goes here

PRINTDIR = 'C:\Users\Tom\Documents\Figs - SAT\';

idxArea = ismember(unitData.Area, {'SEF'});
idxMonkey = ismember(unitData.Monkey, {'D'});
idxFunction = (unitData.Grade_Err == 4);
idxKeep = (idxArea & idxMonkey & idxFunction);

NUM_UNIT = 1;%sum(idxKeep);
unitTest = unitData(41,:);

T_STIM_Acc = 3500 + (-300 : 500);
T_RESP_Acc = 3500 + (-500 : 300);
NUM_SAMP_Acc = length(T_STIM_Acc);
T_STIM_Fast = 3500 + (-200 : 300);
T_RESP_Fast = 3500 + (-300 : 200);
NUM_SAMP_Fast = length(T_STIM_Fast);

IDX_STIM_PLOT = [11, 5, 3, 1, 7, 13, 15, 17];
IDX_RESP_PLOT = IDX_STIM_PLOT + 1;

for uu = 1:NUM_UNIT
  fprintf('%s - %s\n', unitTest.Session{uu}, unitTest.ID{uu})
  kk = ismember(behavData.Session, unitTest.Session{uu});
  RT_P = behavData.Sacc_RT{kk}; %Primary saccade RT
  
  %compute spike density function and align on primary response
  spikes_uu = load_spikes_SAT(unitTest.Index(uu));
  sdfA = compute_spike_density_fxn(spikes_uu);
  sdfP = align_signal_on_response(sdfA, RT_P); 
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitTest.TrialRemoveSAT{uu}, behavData.NumTrials(kk));
  %index by condition
  idxAcc = ((behavData.Condition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Condition{kk} == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Correct{kk};
  
  %% Compute mean SDF for each direction
  Octant_Sacc1 = behavData.Sacc_Octant{kk};
  sdfAccA = NaN(NUM_SAMP_Acc,8); %re. array
  sdfAccP = sdfAccA; %re. primary
  sdfFastA = NaN(NUM_SAMP_Fast,8);
  sdfFastP = sdfFastA;
  RT_Acc = NaN(8,1);
  RT_Fast = RT_Acc;
  for dd = 1:8 %loop over response directions
    idxDir = (Octant_Sacc1 == dd);
    sdfAccA(:,dd) = nanmean(sdfA(idxAcc & idxCorr & idxDir, T_STIM_Acc));
    sdfAccP(:,dd) = nanmean(sdfP(idxAcc & idxCorr & idxDir, T_RESP_Acc));
    sdfFastA(:,dd) = nanmean(sdfA(idxFast & idxCorr & idxDir, T_STIM_Fast));
    sdfFastP(:,dd) = nanmean(sdfP(idxFast & idxCorr & idxDir, T_RESP_Fast));
    RT_Acc(dd) = median(RT_P(idxAcc & idxCorr & idxDir));
    RT_Fast(dd) = median(RT_P(idxFast & idxCorr & idxDir));
  end%for:direction(dd)
  
  %% Plotting
  hFig = figure('visible','on');
  yLim = [0, max([sdfAccA; sdfAccP; sdfFastA; sdfFastP],[],'all')];
  xLimStim = T_STIM_Acc([1,NUM_SAMP_Acc]) - 3500;
  xLimResp = T_RESP_Acc([1,NUM_SAMP_Acc]) - 3500;
  
  for dd = 1:8 %loop over directions and plot
    
    subplot(3,6,IDX_STIM_PLOT(dd)); hold on %re. array
    plot([0 0], yLim, 'k:')
    plot(RT_Acc(dd)*ones(1,2), yLim, 'r:')
    plot(RT_Fast(dd)*ones(1,2), yLim, ':', 'Color',[0 .7 0])
    plot(T_STIM_Acc-3500, sdfAccA(:,dd), 'r-');
    plot(T_STIM_Fast-3500, sdfFastA(:,dd), '-', 'Color',[0 .7 0]);
    xlim(xLimStim)
    
    if (IDX_STIM_PLOT(dd) == 13)
      ylabel('Activity (sp/sec)')
      xlabel('Time from array (ms)')
    else
      xticklabels([])
      yticklabels([])
    end
    subplot(3,6,IDX_RESP_PLOT(dd)); hold on %re. response
    plot([0 0], yLim, 'k:')
    plot(-RT_Acc(dd)*ones(1,2), yLim, 'r:')
    plot(-RT_Fast(dd)*ones(1,2), yLim, ':', 'Color',[0 .7 0])
    plot(T_RESP_Acc-3500, sdfAccP(:,dd), 'r-');
    plot(T_RESP_Fast-3500, sdfFastP(:,dd), '-', 'Color',[0 .7 0]);
    xlim(xLimResp)
    set(gca, 'YAxisLocation','right')
    
    if (IDX_RESP_PLOT(dd) == 14)
      xlabel('Time from response (ms)')
    else
      xticklabels([])
      yticklabels([])
    end
    
    pause(.01)
      
  end%for:direction(dd)
  
  subplot(3,6,[9 10]); print_session_unit(gca, unitTest(uu,:), behavData(kk,:), 'horizontal'); axis('off')
  ppretty([12,6])
  
%   pause(0.1); print([PRINTDIR,unitTest.Properties.RowNames{uu},'-',unitTest.aArea{uu},'.tif'], '-dtiff')
%   pause(0.1); close(hFig); pause(0.1)
  
end % for : unit(uu)

clearvars -except behavData unitData spkCorr
