function [  ] = plot_dRT_X_RTerr( behavData , varargin )
%plot_tSacc2_X_RTerr Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

%isolate sessions from MONKEY
kkKeep = (ismember(behavData.Monkey, args.monkey) & behavData.Task_RecordedSEF);
behavData = behavData(kkKeep,:);
NUM_SESS = sum(kkKeep);

trialSwitch = identify_condition_switch(behavData);

BINLIM_dRT = linspace(-500, 600, 12);
NUM_BIN_dRT = length(BINLIM_dRT) - 1;
dRTplot = BINLIM_dRT(1:NUM_BIN_dRT) + 0.5*diff(BINLIM_dRT([1,2]));

%bin by timing error magnitude quantile
BINLIM_TERR = linspace(0, 1, 3);
NUM_BIN_TERR = length(BINLIM_TERR) - 1;

%initialization
tmp = NaN(NUM_SESS,NUM_BIN_dRT);
[cdf_dRT{1:NUM_BIN_TERR,1}] = deal(tmp);

%% Collect time of second saccade across sessions
for kk = 1:NUM_SESS
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
  
  %loop over timing error magnitude bins
  for mm = 1:NUM_BIN_TERR
    idx_AEmm = (idxAE & (RTerr_kk > binlim_RTerr(mm)) & (RTerr_kk <= binlim_RTerr(mm+1)));
    
    for ii = 1:NUM_BIN_dRT
      idx_ii = (dRT_kk > BINLIM_dRT(ii)) & (dRT_kk <= BINLIM_dRT(ii+1));
      cdf_dRT{mm}(kk,ii) = sum(idx_AEmm & idx_ii) / sum(idx_AEmm);
    end % for : binISI(ii)
    
  end % for : binTErr(mm)
  
end % for : session(kk)

%compute cumulative probability density
for mm = 1:NUM_BIN_TERR
  cdf_dRT{mm} = cumsum(cdf_dRT{mm},2);
end

%% Plotting - Distribution
colorPlot = linspace(0.8, 0.2, NUM_BIN_TERR);

figure(); hold on

for mm = 1:NUM_BIN_TERR
  line(dRTplot, mean(cdf_dRT{mm}), 'color',[colorPlot(mm) 0 0], 'linewidth',1.0)
end
xlim(BINLIM_dRT([1,end])); ylim([0 1]); ytickformat('%2.1f')
xlabel('Adjustment in RT (ms)')
ylabel('Cumulative probability')

ppretty([2.4,2])

end % fxn : plot_tSacc2_X_RTerr()
