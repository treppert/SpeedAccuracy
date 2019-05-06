function [ varargout ] = plotSDFChoiceErrSAT( binfo , moves , movesPP , ninfo , nstats , spikes , varargin )
%plotSDFChoiceErrSAT() Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E','Q','S'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);
idxEfficient = ismember([ninfo.taskType], [1,2]);

idxKeep = (idxArea & idxMonkey & idxEfficient);

ninfo = ninfo(idxKeep);
spikes = spikes(idxKeep);

NUM_CELLS = length(spikes);
T_1 = 3500 + (-200 : 400); %time from primary saccade
T_2 = 3500 + (-200 : 400); %time from secondary saccade
T_BASE = 3500 + (-300 : -1); %time from array

%output initializations
sdf1Corr = NaN(NUM_CELLS, length(T_1)); %aligned on primary
sdf1Err = NaN(NUM_CELLS, length(T_1));
sdf2Corr = NaN(NUM_CELLS, length(T_1)); %aligned on secondary
sdf2Err = NaN(NUM_CELLS, length(T_1));

for cc = 1:NUM_CELLS
  fprintf('%s - %s\n', ninfo(cc).sess, ninfo(cc).unit)
%   if (ninfo(cc).errGrade ~= 1); continue; end
  kk = ismember({binfo.session}, ninfo(cc).sess);
  
  RTkk = double(moves(kk).resptime);
  ISIkk = double(movesPP(kk).resptime) - RTkk;
  ISIkk(ISIkk < 0) = NaN; %trials with no secondary saccade
  
  %compute spike density function and align on primary and secondary sacc.
  sdfKK = compute_spike_density_fxn(spikes(cc).SAT);
  sdf1KK = align_signal_on_response(sdfKK, RTkk); %primary saccade
  sdf2KK = align_signal_on_response(sdfKK, RTkk + ISIkk); %secondary sacc.
  
  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxAcc = (binfo(kk).condition == 1 & ~idxIso);
  idxFast = (binfo(kk).condition == 3 & ~idxIso);
  %index by trial outcome
  idxCorr = ~(binfo(kk).err_dir | binfo(kk).err_time | binfo(kk).err_hold);
  idxErr = (binfo(kk).err_dir & ~binfo(kk).err_time);
  
  %perform RT matching
  trialFC = find(idxFast & idxCorr);    RTFC = RTkk(idxFast & idxCorr);
  trialFE = find(idxFast & idxErr);     RTFE = RTkk(idxFast & idxErr);
  [OLdist1, OLdist2, ~,~] = DistOverlap_Amir([trialFC;RTFC]', [trialFE;RTFE]');
  trialFC = OLdist1(:,1);   RTFC = OLdist1(:,2);
  trialFE = OLdist2(:,1);   RTFE = OLdist2(:,2);
%   figure(); histogram(RTFC, 'FaceColor','k', 'BinWidth',5); hold on; histogram(RTFE, 'FaceColor','r', 'BinWidth',5)
  
  %isolate single-trial SDFs
  sdf1CorrST = sdf1KK(trialFC, T_1); %aligned on primary
  sdf1ErrST = sdf1KK(trialFE, T_1);
  sdf2CorrST = sdf2KK(trialFC, T_2); %aligned on secondary
  sdf2ErrST = sdf2KK(trialFE, T_2);
  sdfBaseCorrST = sdfKK(trialFC, T_BASE); %aligned on array
  sdfBaseErrST = sdfKK(trialFE, T_BASE);
  
  %compute mean SDFs
  sdf1Corr(cc,:) = nanmean(sdf1CorrST);   sdf2Corr(cc,:) = nanmean(sdf2CorrST);
  sdf1Err(cc,:) = nanmean(sdf1ErrST);     sdf2Err(cc,:) = nanmean(sdf2ErrST);
  sdfBaseCorr = nanmean(sdfBaseCorrST);   sdfBaseErr = nanmean(sdfBaseErrST);
  
  %% Parameterize the SDF
  ccNS = ninfo(cc).unitNum;
  OFFSET = 201;
  
  %latency
  sdfBaseDiff = sdfBaseErr - sdfBaseCorr;
  tErrFast = calcTimeErrSignal(sdf1CorrST, sdf1ErrST, OFFSET, sdfBaseDiff);
  nstats(ccNS).tChcErrFast = tErrFast;
  
  %plot individual cell activity
  SDFcc = struct('CorrRe1',sdf1Corr(cc,:), 'ErrRe1',sdf1Err(cc,:), 'CorrRe2',sdf2Corr(cc,:), 'ErrRe2',sdf2Err(cc,:));
  plotSDFChcErrSATcc(T_1, T_2, SDFcc, ninfo(cc), nstats(ccNS))
  
end%for:cells(cc)

if (nargout > 0)
  varargout{1} = nstats;
end

end%fxn:plotSDFChoiceErrSAT()
