function [ ] = plotBlineXerrSAT( binfo , ninfo , spikes , varargin )
%plotBlineXerrSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idx_area = ismember({ninfo.area}, args.area);
idx_monkey = ismember({ninfo.monkey}, args.monkey);

ninfo = ninfo(idx_area & idx_monkey);
spikes = spikes(idx_area & idx_monkey);

NUM_CELLS = length(spikes);
T_BASE  = 3500 + (-700 : -1);

blineCorr = NaN(1,NUM_CELLS);
blineErr = NaN(1,NUM_CELLS);
blineMean = NaN(1,NUM_CELLS); %for normalization

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
  %index by trial number
  trialF2A = trialSwitch(kk).F2A; trialF2A(ismember(trialF2A, trialIso)) = [];
  %index by trial outcome
  trialErr = find(binfo(kk).err_time);
  trialCorr = find(~(binfo(kk).err_time));
  
  sdfCorr = nanmean(sdfSess(intersect(trialF2A,trialCorr), T_BASE));
  sdfErr = nanmean(sdfSess(intersect(trialF2A,trialErr), T_BASE));
  blineCorr(cc) = mean(sdfCorr);
  blineErr(cc) = mean(sdfErr);
  
end%for:cells(cc)

%normalization
blineCorr = blineCorr ./ blineMean;
blineErr = blineErr ./ blineMean;

%% Plotting
% NUM_SEM = sum([ninfo.baseLine] == -1);

figure(); hold on
histogram(blineErr-blineCorr, 'BinWidth',0.2, 'FaceColor',[.5 .5 .5])
ppretty([5,5])

end%fxn:plotBlineXerrSAT()

function [ blineSAT ] = computeBlineMean( sdfSess , binfoKK , ninfoCC , T_BASE )

%index by isolation quality
idxIso = identify_trials_poor_isolation_SAT(ninfoCC, binfoKK.num_trials);
%index by condition (Fast OR Acc)
idxSAT = (ismember(binfoKK.condition, [1,3]) & ~idxIso);

sdfSAT = nanmean(sdfSess(idxSAT, T_BASE));
blineSAT = mean(sdfSAT);

end%util:computeBlineMean()
