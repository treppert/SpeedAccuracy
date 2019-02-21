function [  ] = plotSDFChoiceErrSAT( binfo , moves , movesPP , ninfo , spikes , varargin )
%plotSDFChoiceErrSAT() Summary of this function goes here
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
sdfErr = NaN(NUM_CELLS,length(T_PLOT));

tStartErr = NaN(1,NUM_CELLS); %start time of error encoding
tVecErr = cell(1,NUM_CELLS); %all time-points of error encoding

rtCorr = NaN(1,NUM_CELLS);
rtErr = NaN(1,NUM_CELLS);
isiErr = NaN(1,NUM_CELLS);

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
  idxCond = ((binfo(kk).condition == 3) & ~idxIso);
  %index by trial outcome
  idxErr = (binfo(kk).err_dir);
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_hold);
  %index by direction from error field
  idxDir = ismember(moves(kk).octant, ninfo(cc).errField);
  
  sdfCorr(cc,:) = nanmean(sdfSess(idxCond & idxCorr & idxDir, T_PLOT));
  sdfErr(cc,:) = nanmean(sdfSess(idxCond & idxErr & idxDir, T_PLOT));
  
  %compute timing of error signal
  sdfCorrTest = sdfSess(idxCond & idxCorr & idxDir, T_PLOT+OFFSET_TEST);
  sdfErrTest = sdfSess(idxCond & idxErr & idxDir, T_PLOT+OFFSET_TEST);
  [tStartErr(cc),tVecErr{cc}] = calcTimeErrSignal(sdfCorrTest, sdfErrTest, 0.05, 100, OFFSET_TEST);
  
  rtCorr(cc) = median(RTkk(idxCond & idxCorr & idxDir));
  rtErr(cc) = median(RTkk(idxCond & idxErr & idxDir));
  isiErr(cc) = median(ISIkk(idxCond & idxErr & idxDir));
end%for:cells(cc)


%% Plotting - Individual cells

if (0)
for cc = 1:NUM_CELLS
  if (ninfo(cc).errGrade ~= 1); continue; end
  figure(); hold on
  
  tmp = [sdfCorr(cc,:), sdfErr(cc,:)];
  yLim = [min(min(tmp)) max(max(tmp))];
  
  plot([0 0], yLim, 'k-', 'LineWidth',1.0)
  plot(-rtCorr(cc)*ones(1,2), yLim, 'k-')
  plot(-rtErr(cc)*ones(1,2), yLim, 'k--')
  plot(isiErr(cc)*ones(1,2), yLim, 'k--')
  plot(tStartErr(cc)*ones(1,2), yLim, ':', 'Color','k') %onset of error encoding
  plot(tVecErr{cc}, yLim(1), 'k.', 'MarkerSize',8) %timepoints of error encoding
  
  plot(T_PLOT-3500, sdfCorr(cc,:), '-', 'Color',[0 .7 0], 'LineWidth',1.25);
  plot(T_PLOT-3500, sdfErr(cc,:), '--', 'Color',[0 .7 0], 'LineWidth',1.25);
  
  ylabel('Activity (sp/sec)')
  xlabel('Time from response (ms)')
  
  xlim([T_PLOT(1) T_PLOT(end)]-3500)
  xticks((T_PLOT(1) : 100 : T_PLOT(end)) - 3500)
  
  print_session_unit(gca, ninfo(cc), binfo(kk))
  ppretty('image_size',[6.4,4])
  pause()
  
end%for:cells(cc)
end


%% Plotting - Across cells
NUM_SEM = sum([ninfo.errGrade] == 1);

%normalization
AmaxErr = max(sdfErr,[],2);
sdfCorr = sdfCorr ./ AmaxErr;
sdfErr  = sdfErr ./ AmaxErr;

%remove superfluous cells
sdfCorr([ninfo.errGrade]~=1,:) = [];
sdfErr([ninfo.errGrade]~=1,:) = [];

%plot Correct vs. Error
figure(); hold on
shaded_error_bar(T_PLOT-3500, nanmean(sdfCorr), nanstd(sdfCorr)/sqrt(NUM_SEM), {'-', 'Color',[0 .7 0]})
shaded_error_bar(T_PLOT-3500, nanmean(sdfErr), nanstd(sdfErr)/sqrt(NUM_SEM), {'--', 'Color',[0 .7 0]})
ppretty('image_size',[6.4,4])

pause(0.25)

%plot onset time of the error signal
figure(); hold on
histogram(tStartErr, 'BinWidth',50, 'FaceColor',[0 .7 0])
ppretty('image_size',[4,4])

end%fxn:plotSDFChoiceErrSAT()
