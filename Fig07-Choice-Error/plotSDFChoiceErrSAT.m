function [ varargout ] = plotSDFChoiceErrSAT( binfo , moves , movesPP , ninfo , spikes , varargin )
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
PERFORM_RT_MATCHING = true;

TASK_CONDITION = [1,3];

%initializations
sdfCorr = cell(1,2);
sdfCorr{1} = NaN(NUM_CELLS,length(T_PLOT));
sdfCorr{2} = NaN(NUM_CELLS,length(T_PLOT));
sdfErr = sdfCorr;
% sdfErr = NaN(NUM_CELLS,length(T_PLOT));

tStartErr = NaN(2,NUM_CELLS); %start time of error encoding
tVecErr = cell(2,NUM_CELLS); %all time-points of error encoding

rtCorr = NaN(2,NUM_CELLS); %first row = ACC
rtErr = NaN(2,NUM_CELLS); %second row = FAST
isiErr = NaN(2,NUM_CELLS);

for tc = 1:2
  
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
    idxCond = ((binfo(kk).condition == TASK_CONDITION(tc)) & ~idxIso);
    %index by trial outcome
    idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
    idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_hold);
    %index by direction from error field
    idxDir = ismember(moves(kk).octant, ninfo(cc).errField);

    if (PERFORM_RT_MATCHING) %if desired, do RT matching
      arrTestRTcorr = [ find(idxCond & idxCorr & idxDir); RTkk(idxCond & idxCorr & idxDir) ]';
      arrTestRTerr =  [ find(idxCond & idxErr & idxDir);  RTkk(idxCond & idxErr & idxDir) ]';
      [arrOutRTcorr, arrOutRTerr] = DistOverlap_Amir(arrTestRTcorr, arrTestRTerr, 15);
      idxErr = arrOutRTerr(:,1);
      idxCorr = arrOutRTcorr(:,1);
    else
      idxErr = (idxCond & idxErr & idxDir);
      idxCorr = (idxCond & idxCorr & idxDir);
    end%if:RT-MATCHING

    sdfCorr{tc}(cc,:) = nanmean(sdfSess(idxCorr, T_PLOT));
    sdfErr{tc}(cc,:) = nanmean(sdfSess(idxErr, T_PLOT));

    %compute timing of error signal
    sdfCorrTest = sdfSess(idxCorr, T_PLOT+OFFSET_TEST);
    sdfErrTest = sdfSess(idxErr, T_PLOT+OFFSET_TEST);
    [tStartErr(tc,cc),tVecErr{tc,cc}] = calcTimeErrSignal(sdfCorrTest, sdfErrTest, 0.05, 100, OFFSET_TEST);

    rtCorr(tc,cc) = median(RTkk(idxCorr));
    rtErr(tc,cc) = median(RTkk(idxErr));
    isiErr(tc,cc) = median(ISIkk(idxErr));

  end%for:cells(cc)
  
end%for:task-condition(tc)

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
  
  plot(T_PLOT-3500, sdfCorr(cc,:), '-', 'Color',[1 0 0], 'LineWidth',1.25);
  plot(T_PLOT-3500, sdfErr(cc,:), '--', 'Color',[1 0 0], 'LineWidth',1.25);
  
  ylabel('Activity (sp/sec)')
  xlabel('Time from response (ms)')
  
  xlim([T_PLOT(1) T_PLOT(end)]-3500)
  xticks((T_PLOT(1) : 100 : T_PLOT(end)) - 3500)
  
  print_session_unit(gca, ninfo(cc), binfo(kk))
  ppretty('image_size',[6.4,4])
  pause(0.1); print(['~/Dropbox/Speed Accuracy/SEF_SAT/Figs/Error-Choice/SDF-ChoiceErr-ACC/', ...
    ninfo(cc).area,'-',ninfo(cc).sess,'-',ninfo(cc).unit,'.tif'], '-dtiff')
  pause(0.1); close()
%   pause()
  
end%for:cells(cc)
return
end


%% Plotting - Across cells
NUM_SEM = sum([ninfo.errGrade] == 1);

%normalization re. max error activity in FAST
AmaxErr = max(sdfErr{2},[],2);
sdfCorr{1} = sdfCorr{1} ./ AmaxErr; %ACC
sdfCorr{2} = sdfCorr{2} ./ AmaxErr; %FAST
sdfErr{1}  = sdfErr{1} ./ AmaxErr;
sdfErr{2}  = sdfErr{2} ./ AmaxErr;

%remove superfluous cells
sdfCorr{1}([ninfo.errGrade]~=1,:) = [];
sdfCorr{2}([ninfo.errGrade]~=1,:) = [];
sdfErr{1}([ninfo.errGrade]~=1,:) = [];
sdfErr{2}([ninfo.errGrade]~=1,:) = [];
tStartErr(:,[ninfo.errGrade]~=1) = [];

%plot Correct vs. Error
figure(); hold on
shaded_error_bar(T_PLOT-3500, nanmean(sdfCorr{1}), nanstd(sdfCorr{1})/sqrt(NUM_SEM), {'-', 'Color',[1 0 0]})
shaded_error_bar(T_PLOT-3500, nanmean(sdfErr{1}), nanstd(sdfErr{1})/sqrt(NUM_SEM), {'--', 'Color',[1 0 0]})
shaded_error_bar(T_PLOT-3500, nanmean(sdfCorr{2}), nanstd(sdfCorr{1})/sqrt(NUM_SEM), {'-', 'Color',[0 .7 0]})
shaded_error_bar(T_PLOT-3500, nanmean(sdfErr{2}), nanstd(sdfErr{1})/sqrt(NUM_SEM), {'--', 'Color',[0 .7 0]})
ppretty('image_size',[6.4,4])

%plot onset time of the error signal
% figure(); hold on
% histogram(tStartErr, 'BinWidth',50, 'FaceColor',[.4 .4 .4])
% ppretty('image_size',[4,4])

if (nargout > 0)
  varargout{1} = tStartErr;
end

end%fxn:plotSDFChoiceErrSAT()