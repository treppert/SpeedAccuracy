function [ varargout ] = plotSDFChoiceErrXisiSAT( binfo , moves , movesPP , ninfo , spikes , varargin )
%plotSDFChoiceErrXisiSAT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idx_area = ismember({ninfo.area}, args.area);
idx_monkey = ismember({ninfo.monkey}, args.monkey);

ninfo = ninfo(idx_area & idx_monkey);
spikes = spikes(idx_area & idx_monkey);

NUM_CELLS = length(spikes);
T_PLOT  = 3500 + (-400 : 800);
OFFSET_TEST = 200;

%initializations
sdfCorr = NaN(NUM_CELLS,length(T_PLOT));
sdfErrNoPP = NaN(NUM_CELLS,length(T_PLOT)); %no PP saccade
sdfErrISIs = NaN(NUM_CELLS,length(T_PLOT)); %short ISI
sdfErrISIl = NaN(NUM_CELLS,length(T_PLOT)); %long ISI

tStartErrISIs = NaN(1,NUM_CELLS); %start time of error encoding
tStartErrISIl = NaN(1,NUM_CELLS);
tVecErrISIs = cell(1,NUM_CELLS); %all time-points of error encoding
tVecErrISIl = cell(1,NUM_CELLS);

rtCorr = NaN(1,NUM_CELLS);
rtErr = NaN(1,NUM_CELLS);
isiErrS = NaN(1,NUM_CELLS);
isiErrL = NaN(1,NUM_CELLS);

for cc = 1:NUM_CELLS
  if (ninfo(cc).errGrade ~= 1); continue; end
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  RTkk = double(moves(kk).resptime);
  ISIkk = double(movesPP(kk).resptime) - RTkk;
  
  %compute spike density function and align on primary response
  sdfSess = compute_spike_density_fxn(spikes(cc).SAT);
  sdfSess = align_signal_on_response(sdfSess, RTkk); 
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
%   idxCond = ((binfo(kk).condition == 1) & ~idxIso);
  idxCond = (ismember(binfo(kk).condition, [1,3]) & ~idxIso);
  %index by trial outcome
  idxErr = (binfo(kk).err_dir);
  idxCorr = ~(binfo(kk).err_dir);
  %index by direction from error field
  idxDir = ismember(moves(kk).octant, ninfo(cc).errField);
  
  %index by ISI
  idxNoPP = (movesPP(kk).resptime == 0);
  [idxISIs,idxISIl] = getIdxISI(ISIkk,(idxCond & idxErr & idxDir));
  
  sdfCorr(cc,:) = nanmean(sdfSess(idxCond & idxCorr & idxDir, T_PLOT));
  sdfErrNoPP(cc,:) = nanmean(sdfSess(idxCond & idxErr & idxDir & idxNoPP, T_PLOT));
  sdfErrISIs(cc,:) = nanmean(sdfSess(idxCond & idxErr & idxDir & idxISIs, T_PLOT));
  sdfErrISIl(cc,:) = nanmean(sdfSess(idxCond & idxErr & idxDir & idxISIl, T_PLOT));
  
  %compute timing of error signal
  sdfCorrTest = sdfSess(idxCond & idxCorr & idxDir, T_PLOT+OFFSET_TEST);
  sdfErrISIsTest = sdfSess(idxCond & idxErr & idxDir & idxISIs, T_PLOT+OFFSET_TEST);
  sdfErrISIlTest = sdfSess(idxCond & idxErr & idxDir & idxISIl, T_PLOT+OFFSET_TEST);
  [tStartErrISIs(cc),tVecErrISIs{cc}] = calcTimeErrSignal(sdfCorrTest, sdfErrISIsTest, 0.05, 100, OFFSET_TEST);
  [tStartErrISIl(cc),tVecErrISIl{cc}] = calcTimeErrSignal(sdfCorrTest, sdfErrISIlTest, 0.05, 100, OFFSET_TEST);
  
  rtCorr(cc) = median(RTkk(idxCond & idxCorr & idxDir));
  rtErr(cc) =  median(RTkk(idxCond & idxErr & idxDir));
  isiErrS(cc) = median(ISIkk(idxCond & idxErr & idxDir & idxISIs));
  isiErrL(cc) = median(ISIkk(idxCond & idxErr & idxDir & idxISIl));
end%for:cells(cc)

%dt-error encoding vs. dt-PP saccade latency
dtEncode = tStartErrISIl - tStartErrISIs;
dtSaccLatency = isiErrL - isiErrS;
testStat = dtEncode ./ dtSaccLatency;

%% Plotting
if (1)
for cc = 1:NUM_CELLS
  if (ninfo(cc).errGrade ~= 1); continue; end
  figure(); hold on
  
  tmp = [sdfCorr(cc,:), sdfErrISIs(cc,:)];
  yLim = [min(min(tmp)) max(max(tmp))];
  
  if (testStat(cc) < 0.25)
    plot([0 0], yLim, 'b-', 'LineWidth',1.0) %time of primary response
  else
    plot([0 0], yLim, 'k-', 'LineWidth',1.0)
  end
  
  plot(-rtCorr(cc)*ones(1,2), yLim, 'k-') %median (primary) RT
  plot(-rtErr(cc)*ones(1,2), yLim, 'k--')
  
  plot(isiErrS(cc)*ones(1,2), yLim, '--', 'Color','k') %median ISIs
  plot(isiErrL(cc)*ones(1,2), yLim, '--', 'Color',[.5 .5 .5]) %median ISIl
  
  plot(tStartErrISIs(cc)*ones(1,2), yLim, '-.', 'Color','k') %onset of error encoding
  plot(tVecErrISIs{cc}, yLim(1), 'k.', 'MarkerSize',8) %timepoints of error encoding
  plot(tStartErrISIl(cc)*ones(1,2), yLim, '-.', 'Color',[.5 .5 .5])
  plot(tVecErrISIl{cc}, yLim(1)-2, '.', 'Color',[.5 .5 .5], 'MarkerSize',8)
  
  plot(T_PLOT-3500, sdfCorr(cc,:), '-', 'Color',[0 0 0], 'LineWidth',1.5);
  plot(T_PLOT-3500, sdfErrISIs(cc,:), '-', 'Color',[0 0 0], 'LineWidth',0.75);
  plot(T_PLOT-3500, sdfErrISIl(cc,:), '-', 'Color',[.5 .5 .5], 'LineWidth',0.75);
%   plot(T_PLOT-3500, sdfErrNoPP(cc,:), '-', 'Color',[0 0 1], 'LineWidth',0.75);
  
  ylabel('Activity (sp/sec)')
  xlabel('Time from response (ms)')
  
  xlim([T_PLOT(1) T_PLOT(end)]-3500)
  xticks((T_PLOT(1) : 200 : T_PLOT(end)) - 3500)
  
  print_session_unit(gca, ninfo(cc), binfo(kk), 'horizontal')
  ppretty('image_size',[6.4,4])
  pause(0.1); print(['~/Dropbox/Speed Accuracy/SEF_SAT/Figs/Error-Choice/SDF-ChoiceErr-xISI-Test/', ...
    ninfo(cc).area,'-',ninfo(cc).sess,'-',ninfo(cc).unit,'.eps'], '-depsc2')
  pause(0.1); close()
%   pause()
  
end%for:cells(cc)
end

if (nargout > 0)
  varargout{1} = dtSaccLatency;
  if (nargout > 1)
    varargout{2} = dtEncode;
  end
end

%% Statistics - Test of effect of post-primary saccade on error encoding
% figure(); hold on
% plot([100 250], [0 0], 'k-')
% plot([100 250], [100 250], 'k--')
% plot([100 250], [50  125], 'k:')
% plot(dtSaccLatency, dtEncode, 'ko', 'MarkerSize',6)
% xlabel('Increase in saccade latency (ms)')
% ylabel('Increase in onset of encoding (ms)')
% title('alpha = .05 || minL = 100 ms')
% ppretty('image_size',[6.4,4])

end%fxn:plotSDFChoiceErrXisiSAT()

function [ idxISIs , idxISIl ] = getIdxISI( ISIkk , idxCondErrDir )

ISIkk(ISIkk < 0) = NaN;

medISI = nanmedian(ISIkk(idxCondErrDir));

idxISIs = (ISIkk <= medISI);
idxISIl = (ISIkk >  medISI);

end%util:getIdxISI()
