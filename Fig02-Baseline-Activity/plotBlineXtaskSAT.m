function [ ] = plotBlineXtaskSAT( binfo , ninfo , spikes , varargin )
%plotBlineXtaskSAT Summary of this function goes here
%   Detailed explanation goes here

args = getopt(varargin, {{'area=','SEF'}, {'monkey=',{'D','E'}}});

idxArea = ismember({ninfo.area}, args.area);
idxMonkey = ismember({ninfo.monkey}, args.monkey);

ninfo = ninfo(idxArea & idxMonkey);
spikes = spikes(idxArea & idxMonkey);

NUM_CELLS = length(spikes);
T_BASE  = 3500 + (-700 : 0);

blineDiff{1} = NaN(NUM_CELLS,length(T_BASE));
blineDiff{2} =  NaN(NUM_CELLS,length(T_BASE));

meanDiff = NaN(2,NUM_CELLS);

for cc = 1:NUM_CELLS
  kk = ismember({binfo.session}, ninfo(cc).sess);
  SDFkk = compute_spike_density_fxn(spikes(cc).SAT);

  %index by isolation quality
  idxIso = identify_trials_poor_isolation_SAT(ninfo(cc), binfo(kk).num_trials);
  %index by condition
  idxAcc = ((binfo(kk).condition == 1) & ~idxIso);
  idxFast = ((binfo(kk).condition == 3) & ~idxIso);
  
  %index by task (T/L or L/T)
  tt = binfo(kk).taskType;
  
  %compute SDFs
  blineAcc = nanmean(SDFkk(idxAcc, T_BASE));
  blineFast = nanmean(SDFkk(idxFast, T_BASE));
  blineDiff{tt}(cc,:) = blineFast - blineAcc;
  
  %mean difference in baseline activity
  meanDiff(tt,cc) = mean(blineDiff{tt}(cc,:));
  
end%for:cells(cc)

%% Plotting

figure(); hold on
histogram(meanDiff(1,:), 'FaceColor','b', 'BinWidth',2)
histogram(meanDiff(2,:), 'FaceColor',[.3 .3 .3], 'BinWidth',2)
ppretty([5,4])

end%fxn:plotBlineXtaskSAT()

