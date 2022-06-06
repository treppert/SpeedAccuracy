function [ sdf ] = compute_SDF_ErrTime( unitData , behavData , varargin )
%compute_SDF_ErrTime Summary of this function goes here
%   
%   varargin
%   nBin -- Binning by magnitude of timing error
%   minISI -- Minumum acceptable latency of the second saccade
%   

args = getopt(varargin, {{'nBin=',1}, {'minISI=',600}});

%specify windows for recording SDF
tRec    = 3500 + (-1300 : 400); %re. array and primary
tRec_Rew = 3500 + (-500 : 1200); %re. reward
nSamp = length(tRec);

%bin by timing error magnitude
NBIN_TERR = args.nBin;
ERR_LIM = linspace(0, 1, NBIN_TERR+1);

%initializations
NUM_UNIT = size(unitData,1);
sdfFC = cell(NUM_UNIT,1); %Fast correct
[sdfFC{:}] = deal(NaN(nSamp,3)); %re. array | primary | reward
sdfFE = cell(NUM_UNIT,NBIN_TERR); %Fast error
[sdfFE{:,:}] = deal(NaN(nSamp,3)); %re. array | primary | reward
sdfAC = sdfFC; %Accurate correct
sdfAE = sdfFE; %Accurate error

for uu = 1:NUM_UNIT
  fprintf('%s \n', unitData.Properties.RowNames{uu})
  kk = unitData.SessionIndex(uu);
  
  RTerr = behavData.Sacc_RTerr{kk}; %RT relative to deadline
  RT_P = behavData.Sacc_RT{kk}; %RT of primary saccade
  RT_S = behavData.Sacc2_RT{kk}; %RT of second saccade
  ISI = RT_S - RT_P; %inter-saccade interval
  tRew = behavData.Task_TimeReward(kk); %time of reward (fixed)
  tRew = RT_P + tRew; %re. array
  
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
  idxErr = (behavData.Task_ErrTime{kk} & ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  
  %combine indexing
  idxAC = (idxAcc & idxCorr);    idxAE = (idxAcc & idxErr & (ISI >= args.minISI) & (RTerr < 0));
  idxFC = (idxFast & idxCorr);   idxFE = (idxFast & idxErr & (ISI >= args.minISI) & (RTerr > 0));
  
  %work off of absolute error for Accurate condition
  RTerr = abs(RTerr);
  %compute RT error quantiles for binning based on distribution of error
  errLim_Acc  = quantile(RTerr(idxAE), ERR_LIM);
  errLim_Fast = quantile(RTerr(idxFE), ERR_LIM);
  
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
    idxFEbb = (idxFE & (RTerr > errLim_Fast(bb)) & (RTerr <= errLim_Fast(bb+1)));
    sdfFE{uu,bb}(:,1) =    mean(sdfA(idxFEbb, tRec));
    sdfFE{uu,bb}(:,2) = nanmean(sdfP(idxFEbb, tRec));
    sdfFE{uu,bb}(:,3) = nanmean(sdfR(idxFEbb, tRec_Rew));
  end
  
  %Error trials - Accurate
  for bb = 1:NBIN_TERR
    idxAEbb = (idxAE & (RTerr > errLim_Acc(bb)) & (RTerr <= errLim_Acc(bb+1)));
    sdfAE{uu,bb}(:,1) =    mean(sdfA(idxAEbb, tRec));
    sdfAE{uu,bb}(:,2) = nanmean(sdfP(idxAEbb, tRec));
    sdfAE{uu,bb}(:,3) = nanmean(sdfR(idxAEbb, tRec_Rew));
  end
  
end% for : unit (uu)

sdfCorr = struct('Fast',sdfFC, 'Acc',sdfAC);
sdfErr  = struct('Fast',sdfFE, 'Acc',sdfAE);
sdf = struct('Corr',sdfCorr, 'Err',sdfErr);

end % fxn : compute_SDF_ErrTime()

