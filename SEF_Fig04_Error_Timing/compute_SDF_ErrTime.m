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
iRec    = 3500 + (-1200 : 800);  tRec = iRec - 3500; %re. array and primary
iRec_Rew = 3500 + (-800 : 1200); tRec_Rew = iRec_Rew - 3500; %re. reward
NUM_SAMP = length(iRec);

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

%initializations - signal timing re. reward
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
  sdfFC{uu}(:,1) =    mean(sdfA(idxFC, iRec));
  sdfFC{uu}(:,2) = nanmean(sdfP(idxFC, iRec));
  sdfFC{uu}(:,3) = nanmean(sdfR(idxFC, iRec_Rew));
  %Correct trials - Accurate
  sdfAC{uu}(:,1) =    mean(sdfA(idxAC, iRec));
  sdfAC{uu}(:,2) = nanmean(sdfP(idxAC, iRec));
  sdfAC{uu}(:,3) = nanmean(sdfR(idxAC, iRec_Rew));
  
  %Error trials - Fast
  for bb = 1:NBIN_TERR
    idxFEbb = (idxFE & (RTerr > binLim_RTerr_Fast(bb)) & (RTerr <= binLim_RTerr_Fast(bb+1)));
    for ii = 1:NBIN_dRT
      idxFEbb_ii = (idxFEbb & (dRT_kk > binLim_dRT(ii)) & (dRT_kk <= binLim_dRT(ii+1)));
      sdfFE{uu,NBIN_dRT*(bb-1)+ii}(:,1) =    mean(sdfA(idxFEbb_ii, iRec));
      sdfFE{uu,NBIN_dRT*(bb-1)+ii}(:,2) = nanmean(sdfP(idxFEbb_ii, iRec));
      sdfFE{uu,NBIN_dRT*(bb-1)+ii}(:,3) = nanmean(sdfR(idxFEbb_ii, iRec_Rew));
    end
  end
  
  %Error trials - Accurate
  for bb = 1:NBIN_TERR
    idxAEbb = (idxAE & (RTerr > binLim_RTerr_Acc(bb)) & (RTerr <= binLim_RTerr_Acc(bb+1)));
    for ii = 1:NBIN_dRT
      idxAEbb_ii = (idxAEbb & (dRT_kk > binLim_dRT(ii)) & (dRT_kk <= binLim_dRT(ii+1)));
      sdfAE{uu,NBIN_dRT*(bb-1)+ii}(:,1) =    mean(sdfA(idxAEbb_ii, iRec));
      sdfAE{uu,NBIN_dRT*(bb-1)+ii}(:,2) = nanmean(sdfP(idxAEbb_ii, iRec));
      sdfAE{uu,NBIN_dRT*(bb-1)+ii}(:,3) = nanmean(sdfR(idxAEbb_ii, iRec_Rew));
    end
  end
  
  if (args.estTime) %estimate signal timing re. reward
    [a,b] = calc_tErrorSignal_SAT(sdfR(idxAC,iRec_Rew), sdfR(idxAEbb_ii,iRec_Rew), 'minDur',200);
    vecSig{uu} = b + tRec_Rew(1); %zero times on reward
    tSig{uu}(1) = a(1) + tRec_Rew(1);
    tSig{uu}(2) = tRec_Rew(end) - a(2);
  end
  
end% for : unit (uu)

sdfCorr = struct('Fast',sdfFC, 'Acc',sdfAC);
sdfErr  = struct('Fast',sdfFE, 'Acc',sdfAE);
vecTime = transpose([iRec ; iRec ; iRec_Rew] - 3500); %save time vector
sdf = struct('Corr',sdfCorr, 'Err',sdfErr, 'Time',vecTime);

if (args.estTime)
  varargout{1} = struct('lim',tSig, 'vec',vecSig);
else
  varargout{1} = [];
end

end % fxn : compute_SDF_ErrTime()

