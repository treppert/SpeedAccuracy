function [ sdf , varargout ] = compute_SDF_ErrTime( unitData , behavData , varargin )
%compute_SDF_ErrTime Summary of this function goes here
%   
%   varargin
%   nBin_TE -- Binning by magnitude of timing error
%   nBin_dRT -- Binning by adjustment in RT on trial {n+1}
%   minISI -- Minumum acceptable latency of the second saccade
%   estTime -- Flag to estimate signal timing
%   
%   varargout
%   error signal timing
% 

args = getopt(varargin, {{'nBin_TE=',1}, {'nBin_dRT=',1}, {'minISI=',600}, 'estTime'});

%specify windows for recording SDF
tRec    = 3500 + (-1300 : 400); %re. array and primary
tRec_Rew = 3500 + (-500 : 1200); %re. reward
NUM_SAMP = length(tRec);

NBIN_TERR = args.nBin_TE; %bin by timing error magnitude
BINLIM_TERR = linspace(0, 1, NBIN_TERR+1);

NBIN_dRT = args.nBin_dRT; %bin by RT adjustment
BINLIM_dRT = linspace(0, 1, NBIN_dRT+1);

%initializations - SDF
NUM_UNIT = size(unitData,1);
sdfFC = cell(NUM_UNIT,1); %Fast correct
[sdfFC{:}] = deal(NaN(NUM_SAMP,3)); %re. array | primary | reward
sdfFE = cell(NUM_UNIT,NBIN_TERR*NBIN_dRT); %Fast error
[sdfFE{:,:}] = deal(NaN(NUM_SAMP,3)); %re. array | primary | reward
sdfAC = sdfFC; %Accurate correct
sdfAE = sdfFE; %Accurate error

%initializations - signal timing
if (args.estTime)
  [tSig{1:NUM_UNIT,1}] = deal(NaN(1,2)); %start|finish
  vecSig = cell(NUM_UNIT,1); %vector of significance for plotting
end

for uu = 1:NUM_UNIT
  fprintf('%s \n', unitData.Properties.RowNames{uu})
  kk = unitData.SessionIndex(uu);
  
  RTerr = behavData.Sacc_RTerr{kk}; %RT relative to deadline
  RT_P = behavData.Sacc_RT{kk}; %RT of primary saccade
  RT_S = behavData.Sacc2_RT{kk}; %RT of second saccade
  ISI = RT_S - RT_P; %inter-saccade interval
  tRew = behavData.Task_TimeReward(kk); %time of reward (fixed)
  tRew = RT_P + tRew; %re. array
  
  dRT_kk = [diff(behavData.Sacc_RT{kk}); Inf];
  
  %compute spike density function and align appropriately
  spikes = load_spikes_SAT(unitData.Index(uu));
  sdfA = compute_spike_density_fxn(spikes);    %sdf from Array
  sdfP = align_signal_on_response(sdfA, RT_P); %sdf from Primary
  sdfR = align_signal_on_response(sdfA, tRew); %sdf from Reward
  
  %index by isolation quality
  idxIso = removeTrials_Isolation(unitData.TrialRemoveSAT{uu}, behavData.Task_NumTrials(kk));
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxIso);
  idxFast = ((behavData.Task_SATCondition{kk} == 3) & ~idxIso);
  %index by trial outcome
  idxCorr = behavData.Task_Correct{kk};
  idxErr = behavData.Task_ErrTimeOnly{kk};
  
  %combine indexing
  idxAC = (idxAcc & idxCorr);    idxAE = (idxAcc & idxErr & (ISI >= args.minISI) & (RTerr < 0));
  idxFC = (idxFast & idxCorr);   idxFE = (idxFast & idxErr & (ISI >= args.minISI) & (RTerr > 0));
  
  %work off of absolute error for Accurate condition
  RTerr = abs(RTerr);
  %compute RT error quantiles for binning based on distribution of error
  binLim_RTerr_Acc  = quantile(RTerr(idxAE), BINLIM_TERR);
  binLim_RTerr_Fast = quantile(RTerr(idxFE), BINLIM_TERR);
  
  %get quantiles of dRT for binning
  binLim_dRT = quantile(dRT_kk(idxAE), BINLIM_dRT);
  
  %% Compute mean SDF
  %Correct trials - Fast
  sdfFC{uu}(:,1) =    mean(sdfA(idxFC, tRec));
  sdfFC{uu}(:,2) = nanmean(sdfP(idxFC, tRec));
  sdfFC{uu}(:,3) = nanmean(sdfR(idxFC, tRec_Rew));
  %Correct trials - Accurate
  sdfAC{uu}(:,1) =    mean(sdfA(idxAC, tRec));
  sdfAC{uu}(:,2) = nanmean(sdfP(idxAC, tRec));
  sdfAC{uu}(:,3) = nanmean(sdfR(idxAC, tRec_Rew));
  
  %Error trials - Fast
  for bb = 1:NBIN_TERR
    idxFEbb = (idxFE & (RTerr > binLim_RTerr_Fast(bb)) & (RTerr <= binLim_RTerr_Fast(bb+1)));
    for ii = 1:NBIN_dRT
      idxFEbb_ii = (idxFEbb & (dRT_kk > binLim_dRT(ii)) & (dRT_kk <= binLim_dRT(ii+1)));
      sdfFE{uu,3*(bb-1)+ii}(:,1) =    mean(sdfA(idxFEbb_ii, tRec));
      sdfFE{uu,3*(bb-1)+ii}(:,2) = nanmean(sdfP(idxFEbb_ii, tRec));
      sdfFE{uu,3*(bb-1)+ii}(:,3) = nanmean(sdfR(idxFEbb_ii, tRec_Rew));
    end
  end
  
  %Error trials - Accurate
  for bb = 1:NBIN_TERR
    idxAEbb = (idxAE & (RTerr > binLim_RTerr_Acc(bb)) & (RTerr <= binLim_RTerr_Acc(bb+1)));
    for ii = 1:NBIN_dRT
      idxAEbb_ii = (idxAEbb & (dRT_kk > binLim_dRT(ii)) & (dRT_kk <= binLim_dRT(ii+1)));
      sdfAE{uu,3*(bb-1)+ii}(:,1) =    mean(sdfA(idxAEbb_ii, tRec));
      sdfAE{uu,3*(bb-1)+ii}(:,2) = nanmean(sdfP(idxAEbb_ii, tRec));
      sdfAE{uu,3*(bb-1)+ii}(:,3) = nanmean(sdfR(idxAEbb_ii, tRec_Rew));
    end
  end
  
  %estimate signal timing
  if (args.estTime)
    [a,b] = calc_tErrorSignal_SAT(sdfR(idxAC,tRec_Rew), sdfR(idxAE,tRec_Rew), 'minDur',200);
    %zero times on time of reward
    vecSig{uu} = b + tRec_Rew(1) - 3500;
    tSig{uu}(1) = a(1) + tRec_Rew(1) - 3500;
    tSig{uu}(2) = tRec_Rew(end) - a(2) - 3500;
  end
  
end% for : unit (uu)

sdfCorr = struct('Fast',sdfFC, 'Acc',sdfAC);
sdfErr  = struct('Fast',sdfFE, 'Acc',sdfAE);
vecTime = transpose([tRec ; tRec ; tRec_Rew] - 3500); %save time vector
sdf = struct('Corr',sdfCorr, 'Err',sdfErr, 'Time',vecTime);

if (args.estTime)
  varargout{1} = struct('lim',tSig, 'vec',vecSig);
else
  varargout{1} = [];
end

end % fxn : compute_SDF_ErrTime()

