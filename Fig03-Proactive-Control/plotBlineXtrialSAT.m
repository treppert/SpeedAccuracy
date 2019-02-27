function [ varargout ] = plotBlineXtrialSAT( binfo , ninfo , spikes , varargin )
%plotBlineXtrialSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idx_area = ismember({ninfo.area}, args.area);
idx_monkey = ismember({ninfo.monkey}, args.monkey);

ninfo = ninfo(idx_area & idx_monkey);
spikes = spikes(idx_area & idx_monkey);

NUM_CELLS = length(spikes);
T_BASE  = 3500 + (-700 : -1);

TRIAL_PLOT = (-4 : 3);
NUM_TRIAL = length(TRIAL_PLOT);

blineA2F = NaN(NUM_CELLS,NUM_TRIAL);
blineF2A = NaN(NUM_CELLS,NUM_TRIAL);
blineMean = NaN(NUM_CELLS,1); %for normalization

trialSwitch = identify_condition_switch(binfo);

for cc = 1:NUM_CELLS
  if (ninfo(cc).baseLine ~= -1); continue; end %make sure we have baseline modulation
  kk = ismember({binfo.session}, ninfo(cc).sess);

  %compute spike density function
  sdfSess = compute_spike_density_fxn(spikes(cc).SAT);
  
  %compute mean baseline for normalization
  blineMean(cc) = computeBlineMean(sdfSess, binfo(kk), ninfo(cc), T_BASE);
  
  %index by isolation quality
  trialIso = find(identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials));
  
  trialA2F = trialSwitch(kk).A2F; trialA2F(ismember(trialA2F, trialIso)) = [];
  trialF2A = trialSwitch(kk).F2A; trialF2A(ismember(trialF2A, trialIso)) = [];
  
  for jj = 1:NUM_TRIAL
    
    sdfA2F = nanmean(sdfSess(trialA2F + TRIAL_PLOT(jj), T_BASE));
    sdfF2A = nanmean(sdfSess(trialF2A + TRIAL_PLOT(jj), T_BASE));
    
    blineA2F(cc,jj) = mean(sdfA2F);
    blineF2A(cc,jj) = mean(sdfF2A);
    
  end%for:trial(jj)
  
end%for:cells(cc)

%normalization
blineA2F = blineA2F ./ blineMean;
blineF2A = blineF2A ./ blineMean;

if (nargout > 0)
  varargout{1} = struct('A2F',blineA2F, 'F2A',blineF2A);
end

%% Plotting
NUM_SEM = sum([ninfo.baseLine] == -1);

figure(); hold on
% plot(TRIAL_PLOT, blineA2F, 'k-')
% plot(TRIAL_PLOT+NUM_TRIAL+1, blineF2A, 'k-')
shaded_error_bar(TRIAL_PLOT, nanmean(blineA2F), nanstd(blineA2F)/sqrt(NUM_SEM), {'k-'})
shaded_error_bar(TRIAL_PLOT+NUM_TRIAL+1, nanmean(blineF2A), nanstd(blineF2A)/sqrt(NUM_SEM), {'k-'})
ppretty([6,4])

end%fxn:plotBlineXtrialSAT()

function [ blineSAT ] = computeBlineMean( sdfSess , binfoKK , ninfoCC , T_BASE )

%index by isolation quality
idxIso = identify_trials_poor_isolation_SAT(ninfoCC, binfoKK.num_trials);
%index by condition (Fast OR Acc)
idxSAT = (ismember(binfoKK.condition, [1,3]) & ~idxIso);

sdfSAT = nanmean(sdfSess(idxSAT, T_BASE));
blineSAT = mean(sdfSAT);

end%util:computeBlineMean()