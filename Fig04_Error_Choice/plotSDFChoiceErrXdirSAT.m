function [  ] = plotSDFChoiceErrXdirSAT( behavData , moves , movesPP , unitData , unitData , spikes , varargin )
%plotSDFChoiceErrXdirSAT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

idxSEF = ismember(unitData.aArea, {'SEF'});
idxMonkey = ismember(unitData.aMonkey, args.monkey);
idxErr = (abs(unitData.Basic_ErrGrade) >= 1);

idxKeep = (idxSEF & idxMonkey & idxErr);

NUM_CELLS = sum(idxKeep);
unitData = unitData(idxKeep);
unitData = unitData(idxKeep);
spikes = spikes(idxKeep);

T_PRIMARY = 3500 + (-200 : 200); %time from primary saccade
T_SECOND  = 3500 + (-200 : 200); %time from secondary saccade

IDX_DD_PLOT = [6, 3, 2, 1, 4, 7, 8, 9];

for uu = 1:NUM_CELLS
  kk = ismember(behavData.Task_Session, unitData.Task_Session(uu));
  
  RTPkk = double(moves(kk).resptime); %RT of primary saccade
  RTPkk(RTPkk > 900) = NaN; %hard limit on primary RT
  RTSkk = double(movesPP(kk).resptime) - RTPkk; %RT of second saccade
  RTSkk(RTSkk < 0) = NaN; %trials with no secondary saccade
  
  %compute spike density function and align on primary response
  sdfKK = compute_spike_density_fxn(spikes(uu).SAT);
  sdfKK = align_signal_on_response(sdfKK, RTPkk); 
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(unitData(uu,:), behavData.Task_NumTrials{kk}, 'task','SAT');
  %index by condition
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrTime{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk});
  idxErr = (behavData.Task_ErrChoice{kk} & ~behavData.Task_ErrTime{kk});
  
  %initializations
  sdf.corr.P = NaN(8,length(T_PRIMARY));    sdf.err.P = NaN(8,length(T_PRIMARY));
  isiXdir = NaN(1,8);
  
  for dd = 1:8 %loop over response directions
    %index this direction
    idxDD = (moves(kk).octant == dd);
    %compute median RT
    isiXdir(dd) = median(RTSkk(idxFast & idxErr & idxDD));
    %compute SDFs
    sdf.corr.P(dd,:) = nanmean(sdfKK(idxFast & idxCorr & idxDD, T_PRIMARY));
    sdf.err.P(dd,:)  = nanmean(sdfKK(idxFast & idxErr & idxDD, T_PRIMARY));
  end%for:direction(dd)
  
  %% Plotting - Individual neurons
  figure()
  
  tmp = [sdf.corr.P sdf.err.P];
  yLim = [min(min(tmp)) max(max(tmp))];
  
  for dd = 1:8
    subplot(3,3,IDX_DD_PLOT(dd)); hold on
    
    plot([0 0], yLim, 'k-', 'LineWidth',1.0)
    plot(isiXdir(dd)*ones(1,2), yLim, 'k--')
    
    plot(T_PRIMARY-3500, sdf.corr.P(dd,:), '-', 'Color',[0 .7 0], 'LineWidth',1.25);
    plot(T_PRIMARY-3500, sdf.err.P(dd,:), '--', 'Color',[0 .7 0], 'LineWidth',1.25);
    
    plot(unitData.ChoiceErrorSignal_Time(2)*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
    plot(unitData.ChoiceErrorSignal_Time(4)*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
    
    if (IDX_DD_PLOT(dd) == 4)
      ylabel('Activity (sp/sec)')
      xticklabels([])
    elseif (IDX_DD_PLOT(dd) == 8)
      xlabel('Time from response (ms)')
      yticklabels([])
    else
      xticklabels([])
      yticklabels([])
    end
    
    xlim([T_PRIMARY(1) T_PRIMARY(end)]-3500)
    xticks((T_PRIMARY(1) : 200 : T_PRIMARY(end)) - 3500)
    
    pause(.05)
  end%for:direction(dd)
  
  subplot(3,3,5); xticks([]); yticks([]); print_session_unit(gca , unitData(uu,:), behavData(kk,:), 'horizontal')
  ppretty('image_size',[12,8])
%   pause(0.1); print(['~/Dropbox/Speed Accuracy/SEF_SAT/Figs/Error-Choice/SDF-PostChoiceError-xDir-FAST/', ...
%     unitData.aArea{uu},'-',unitData.Task_Session(uu),'-',unitData.aID{uu},'.tif'], '-dtiff')
%   pause(0.1); close()
  pause()
  
end%for:cells(uu)

end%fxn:plotSDFChoiceErrXdirSAT()
