function [ ] = Fig4X_ErrorSignal_X_Hazard( unitData ,  sdfCorr , sdfErr )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

NUM_UNIT = size(unitData,1);
OFFSET_TIME = 501; %number of samples prior to reward (plot_SDF_ErrTime.m)

NBIN_dRT = 2;
NBIN_TERR = 2;

%bin by change in RT
BINLIM_dRT = linspace(0, 1, NBIN_dRT+1);

%bin by timing error magnitude quantile
BINLIM_TERR = linspace(0, 1, NBIN_TERR+1);

%initializations
sigCorr = NaN(NUM_UNIT,1);
sigErr  = NaN(NUM_UNIT,NBIN_TERR);
hazard = NaN(NUM_UNIT,NBIN_TERR);

for uu = 1:NUM_UNIT
  RTerr_kk = abs(behavData.Sacc_RTerr{kk});
  dRT_kk = [diff(behavData.Sacc_RT{kk}); Inf];
  
  %exclude trials at task condition switch
  idxSwitch = false(behavData.Task_NumTrials(kk),1);
  idxSwitch(sort([trialSwitch.A2F{kk}; trialSwitch.F2A{kk}])) = true;
  
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxSwitch);
  %index by trial outcome
  idxTErr = (behavData.Task_ErrTime{kk} & ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  %combine indexing
  idxAE = (idxAcc & idxTErr & ~idxSwitch);
  
  %get quantiles of RT error magnitude for binning
  binlim_RTerr  = quantile(RTerr_kk(idxAE), BINLIM_TERR);
  %get quantiles of dRT for binning
  binlim_dRT = quantile(dRT_kk(idxAE), BINLIM_dRT);
  
  idxTest  = OFFSET_TIME + unitData.SignalTE_Time(uu,:);
  idxTest = idxTest(1):idxTest(2);
  
  sdfAC_Rew = unitData.sdfAC_TE{uu}(idxTest,3);
  sigCorr(uu) = mean(sdfAC_Rew);
  
  for ii = 1:NBIN_TERR
    
    for kk = 1:NBIN_dRT
      %TODO - Use plot_SDF_ErrTime.m to bin by dRT, or move SDF comp here
      sdfAE_bb = unitData.sdfAE_TE{uu}(idxTest,3*ii); %sdf re. reward
      sigErr(uu,ii) = mean(sdfAE_bb);
      
    end % for : dRT bin (kk)
    
  end % for : RTerr bin(ii)
  
end % for : unit(uu)

sig_Plot = abs(sigErr-sigCorr)./mean(sigErr+sigCorr,2);

%% Plotting

figure(); hold on
line(hazard', sig_Plot', 'Color',.5*ones(1,3), 'Marker','.', 'MarkerSize',10, 'LineWidth',0.75)
ylabel('Normalized error signal')
% xlabel('Shannon information')
ppretty([5,3])

end

