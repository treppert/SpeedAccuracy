function [ varargout ] = plotSDFChoiceErrXisiSAT( binfo , moves , movesPP , ninfo , nstats , spikes , varargin )
%plotSDFChoiceErrSAT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});
ROOT_DIR = 'C:\Users\TDT\Dropbox\Speed Accuracy\SEF_SAT\Figs\Error-Choice\SDF-ChoiceErr-xISI-Test\'; %for printing figs

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

idxErrorGrade = (abs([ninfo.errGrade]) >= 0.5);
idxEfficient = ismember([ninfo.taskType], [1,2]);

idxKeep = (idxArea & idxMonkey & idxErrorGrade & idxEfficient);

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

NUM_CELLS = length(spikes);
T_RESP = 3500 + (-200 : 400); OFFSET = 201; %time from primary saccade
T_BASE = 3500 + (-300 : -1); %time from array

%initializations
% tErr.sh = NaN(1,NUM_CELLS);   medISI.sh = NaN(1,NUM_CELLS);
% tErr.lo = NaN(1,NUM_CELLS);   medISI.lo = NaN(1,NUM_CELLS);

for cc = 1:NUM_CELLS
  fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  RTkk = double(moves(kk).resptime);
  ISIkk = double(movesPP(kk).resptime) - RTkk;
  ISIkk(ISIkk < 0) = NaN;
  
  %compute spike density function and align on primary and secondary sacc.
  sdfStimKK = compute_spike_density_fxn(spikes(cc).SAT);
  sdfRespKK = align_signal_on_response(sdfStimKK, RTkk);
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxFast = (binfo(kk).condition == 3 & ~idxIso);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  %index by ISI
  medISI_FE = nanmedian(ISIkk(idxFast & idxErr));
  idxISIsh = (ISIkk <= medISI_FE);
  idxISIlo = (ISIkk > medISI_FE);
  
  trialFC = find(idxFast & idxCorr);                    RTFC = RTkk(idxFast & idxCorr);
  trialFE_ISIsh = find(idxFast & idxErr & idxISIsh);    RTFE_ISIsh = RTkk(idxFast & idxErr & idxISIsh);
  trialFE_ISIlo = find(idxFast & idxErr & idxISIlo);    RTFE_ISIlo = RTkk(idxFast & idxErr & idxISIlo);  
%   figure(); histogram(RTFE_ISIsh, 'BinWidth',10); hold on; histogram(RTFE_ISIlo, 'BinWidth',10)
  
  %perform (primary) RT matching - short ISI trials
  [OLdist1, OLdist2, ~,~] = DistOverlap_Amir([trialFC;RTFC]', [trialFE_ISIsh;RTFE_ISIsh]');
  trialFC_ISIsh = OLdist1(:,1);   trialFE_ISIsh = OLdist2(:,1);
  %perform (primary) RT matching - long ISI trials
  [OLdist1, OLdist2, ~,~] = DistOverlap_Amir([trialFC;RTFC]', [trialFE_ISIlo;RTFE_ISIlo]');
  trialFC_ISIlo = OLdist1(:,1);   trialFE_ISIlo = OLdist2(:,1);
  
  %isolate single-trial SDFs - short ISI trials
  sdfCorrST_ISIsh = sdfRespKK(trialFC_ISIsh, T_RESP);   sdfErrST_ISIsh = sdfRespKK(trialFE_ISIsh, T_RESP);
  baseCorrST_ISIsh = sdfStimKK(trialFC_ISIsh, T_BASE);  baseErrST_ISIsh = sdfStimKK(trialFE_ISIsh, T_BASE);
  %isolate single-trial SDFs - long ISI trials
  sdfCorrST_ISIlo = sdfRespKK(trialFC_ISIlo, T_RESP);   sdfErrST_ISIlo = sdfRespKK(trialFE_ISIlo, T_RESP);
  baseCorrST_ISIlo = sdfStimKK(trialFC_ISIlo, T_BASE);  baseErrST_ISIlo = sdfStimKK(trialFE_ISIlo, T_BASE);
  
  %compute mean SDFs - short ISI
  sdfCorr_ISIsh = nanmean(sdfCorrST_ISIsh);     sdfErr_ISIsh = nanmean(sdfErrST_ISIsh);
  baseCorr_ISIsh = nanmean(baseCorrST_ISIsh);   baseErr_ISIsh = nanmean(baseErrST_ISIsh);
  %compute mean SDFs - long ISI
  sdfCorr_ISIlo = nanmean(sdfCorrST_ISIlo);     sdfErr_ISIlo = nanmean(sdfErrST_ISIlo);
  baseCorr_ISIlo = nanmean(baseCorrST_ISIlo);   baseErr_ISIlo = nanmean(baseErrST_ISIlo);
  
  %compute latency of the error signal - short ISI
  baseDiff_ISIsh = baseErr_ISIsh - baseCorr_ISIsh;
  tErr_ISIsh = calcTimeErrSignal(sdfCorrST_ISIsh, sdfErrST_ISIsh, OFFSET, baseDiff_ISIsh);
  %compute latency of the error signal - long ISI
  baseDiff_ISIlo = baseErr_ISIlo - baseCorr_ISIlo;
  tErr_ISIlo = calcTimeErrSignal(sdfCorrST_ISIlo, sdfErrST_ISIlo, OFFSET, baseDiff_ISIlo);
  
  ccNS = ninfo(cc).unitNum;
%   nstats(ccNS).A_ChcErr_tErr_ISIshort = tErr_ISIsh;
%   nstats(ccNS).A_ChcErr_tErr_ISIlong = tErr_ISIlo;
  
  %plot individual cell activity
  figure()
  
  ISIFE = ISIkk(idxFast & idxErr);
  ISIFE_sh = ISIFE(ISIFE <= medISI_FE);
  ISIFE_lo = ISIFE(ISIFE >  medISI_FE);
  
  subplot(2,1,1); hold on
  tmp = [sdfCorr_ISIsh sdfErr_ISIsh];
  yLim = [min(tmp) max(tmp)];
  plot([0 0], yLim, 'k:')
  plot(T_RESP-3500, sdfCorr_ISIsh, '-', 'Color',[0 .7 0], 'LineWidth',1.0)
  plot(T_RESP-3500, sdfErr_ISIsh, ':', 'Color',[0 .7 0], 'LineWidth',1.0)
  plot(nstats(ccNS).A_ChcErr_tErr_ISIshort*ones(1,2), yLim, ':', 'Color',[0 .7 0], 'LineWidth',1.5)
  plot(median(ISIFE_sh)*ones(1,2), yLim, '--', 'Color',[0 .7 0], 'LineWidth',1.0)
  xlim([T_RESP(1) T_RESP(end)]-3500)
  xticks((T_RESP(1) : 50 : T_RESP(end)) - 3500)
  ylabel('Activity (sp/sec)')
  print_session_unit(gca , ninfo(cc),[])
  title(['Ratio dtErr/dtISI = ', num2str(nstats(ccNS).A_ChcErr_dtErr_vs_dISI)])
  grid on
  
  subplot(2,1,2); hold on
  tmp = [sdfCorr_ISIlo sdfErr_ISIlo];
  yLim = [min(tmp) max(tmp)];
  plot([0 0], yLim, 'k:')
  plot(T_RESP-3500, sdfCorr_ISIlo, '-', 'Color',[0 .3 0], 'LineWidth',1.0)
  plot(T_RESP-3500, sdfErr_ISIlo, ':', 'Color',[0 .3 0], 'LineWidth',1.0)
  plot(nstats(ccNS).A_ChcErr_tErr_ISIlong*ones(1,2), yLim, ':', 'Color',[0 .3 0], 'LineWidth',1.5)
  plot(median(ISIFE_lo)*ones(1,2), yLim, '--', 'Color',[0 .3 0], 'LineWidth',1.0)
  xlim([T_RESP(1) T_RESP(end)]-3500)
  xticks((T_RESP(1) : 50 : T_RESP(end)) - 3500)
  xlabel('Time from primary saccade (ms)')
  ylabel('Activity (sp/sec)')
  print_session_unit(gca , ninfo(cc),[])
  grid on
  
  ppretty([8,6])
  
%   print([ROOT_DIR, ninfo(cc).area,'-',ninfo(cc).sess,'-',ninfo(cc).unit,'.tif'], '-dtiff'); pause(0.1); close()
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = nstats;
end

end%fxn:plotSDFChoiceErrXisiSAT()
