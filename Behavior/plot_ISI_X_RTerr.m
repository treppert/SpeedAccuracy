function [  ] = plot_ISI_X_RTerr( behavData , varargin )
%plot_ISI_X_RTerr Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'monkey=',{'D','E'}}});

%isolate sessions from MONKEY
kkKeep = (ismember(behavData.Monkey, args.monkey) & behavData.Task_RecordedSEF);
behavData = behavData(kkKeep,:);
NUM_SESS = sum(kkKeep);

MIN_ISI = 600;
BINLIM_ISI = linspace(0, 2500, 26);
NUM_BIN_ISI = length(BINLIM_ISI) - 1;
isiPlot = BINLIM_ISI(1:NUM_BIN_ISI) + 0.5*diff(BINLIM_ISI([1,2]));

%bin by timing error magnitude quantile
BINLIM_TERR = linspace(0, 1, 4);
NUM_BIN_TERR = length(BINLIM_TERR) - 1;

%initialization
tmp = NaN(NUM_SESS,NUM_BIN_ISI);
[cdfISI{1:NUM_BIN_TERR,1}] = deal(tmp);

%% Collect time of second saccade across sessions
for kk = 1:NUM_SESS
  RTerr_kk = abs(behavData.Sacc_RTerr{kk});
  ISI_kk = behavData.Sacc2_RT{kk} - behavData.Sacc_RT{kk};
  
  %index by ISI
  idxCut = (ISI_kk < MIN_ISI);
  %index by condition
  idxAcc = ((behavData.Task_SATCondition{kk} == 1) & ~idxCut);
  %index by trial outcome
  idxTErr = (behavData.Task_ErrTime{kk} & ~(behavData.Task_ErrChoice{kk} | behavData.Task_ErrHold{kk} | behavData.Task_ErrNoSacc{kk}));
  %combine indexing
  idxAE = (idxAcc & idxTErr);
  
  %get quantiles of RT error magnitude for binning
  binlim_RTerr  = quantile(RTerr_kk(idxAE), BINLIM_TERR);
  
  %loop over timing error magnitude bins
  for mm = 1:NUM_BIN_TERR
    idx_AEmm = (idxAE & (RTerr_kk > binlim_RTerr(mm)) & (RTerr_kk <= binlim_RTerr(mm+1)));
    
    for ii = 1:NUM_BIN_ISI
      idx_ii = (ISI_kk > BINLIM_ISI(ii)) & (ISI_kk <= BINLIM_ISI(ii+1));
      cdfISI{mm}(kk,ii) = sum(idx_AEmm & idx_ii) / sum(idx_AEmm);
    end % for : binISI(ii)
    
  end % for : binTErr(mm)
  
end % for : session(kk)

%compute cumulative probability density
for mm = 1:NUM_BIN_TERR
  cdfISI{mm} = cumsum(cdfISI{mm},2);
end

%% Plotting - Distribution
colorPlot = linspace(0.8, 0.2, NUM_BIN_TERR);
tReward = mean(behavData.Task_TimeReward);

figure(); hold on
line(tReward*ones(1,2), [0 1], 'color','k', 'linestyle',':')

for mm = 1:NUM_BIN_TERR
  line(isiPlot, mean(cdfISI{mm}), 'color',[colorPlot(mm) 0 0], 'linewidth',1.0)
end
xlim([500 2200]); ylim([0 1]); ytickformat('%2.1f')
xlabel('Inter-saccade interval (ms)')
ylabel('Cumulative probability')

ppretty([2.4,2])

end % fxn : plot_ISI_X_RTerr()
